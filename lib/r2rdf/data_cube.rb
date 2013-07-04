  #monkey patch to make rdf string w/ heredocs prettier ;)	
  class String
    def unindent
      gsub /^#{self[/\A\s*/]}/, ''
     # gsub(/^#{scan(/^\s*/).min_by{|l|l.length}}/, "")
    end

  end

module R2RDF
  # used to generate data cube observations, data structure definitions, etc
  module Generator
    def defaults
      {
        type: :dataframe,
			}
    end
    
    def generate(measures, dimensions, codes, data, observation_labels, var, options={})
    	dimensions = sanitize(dimensions)
    	codes = sanitize(codes)
    	measures = sanitize(measures)
    	var = sanitize([var]).first
    	data = sanitize_hash(data)

    	str = prefixes()
    	str << data_structure_definition((measures | dimensions), var, options)
    	str << dataset(var, options)
    	component_specifications(measures, dimensions, var, options).map{ |c| str << c }
    	dimension_properties(dimensions, codes, var, options).map{|p| str << p}
    	measure_properties(measures, var, options).map{|p| str << p}
    	code_lists(codes, data, var, options).map{|l| str << l}
    	concept_codes(codes, data, var, options).map{|c| str << c}
    	observations(measures, dimensions, codes, data, observation_labels, var, options).map{|o| str << o}
    	str
    end

    def sanitize(array)
    	#remove spaces and other special characters
    	processed = []
    	array.map{|entry|
    		if entry.is_a? String
    			processed << entry.gsub(/[\s\.]/,'_')
    		else
    			processed << entry
    		end
    	}
    	processed
    end

    def sanitize_hash(h)
    	mappings = {}
    	h.keys.map{|k| 
    		if(k.is_a? String)
	    		mappings[k] = k.gsub(' ','_')
	    	end
    	}

    	h.keys.map{|k|
    		h[mappings[k]] = h.delete(k) if mappings[k]
    	}

    	h
    end

		def prefixes(options={})
      options = defaults().merge(options)
			<<-EOF.unindent
			@base <http://www.rqtl.org/ns/dc/> .
			@prefix ns: <http://www.rqtl.org/ns/#> .
			@prefix qb: <http://purl.org/linked-data/cube#> .
			@prefix rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
			@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
			@prefix prop: <http://www.rqtl.org/dc/properties/> .
			@prefix cs: <http://www.rqtl.org/dc/cs/> .
			@prefix code: <http://www.rqtl.org/dc/code/> .
			@prefix class: <http://www.rqtl.org/dc/class/> .
			@prefix owl: <http://www.w3.org/2002/07/owl#> .
			@prefix skos: <http://www.w3.org/2004/02/skos/core#> .

			EOF
		end

    def data_structure_definition(components,var,options={})
      options = defaults().merge(options)
			str = "ns:dsd-#{var} a qb:DataStructureDefinition;\n"
			str << "\tqb:component\n"
			components.map{|n|
						str << "\t\tcs:#{n} ,\n"
			}
			str[-2]='.'
			str<<"\n"
			str
			# Still needs: 
			# Recursiveness
			#	class and other attributes
    end

		def dataset(var,options={})
      options = defaults().merge(options)
			<<-EOF.unindent    
			ns:dataset-#{var} a qb:DataSet ;
				rdfs:label "#{var}"@en ;
				qb:structure ns:dsd-#{var} .

			EOF
		end

		def component_specifications(measure_names, dimension_names, var, options={})
      options = defaults().merge(options)
			specs = []
			
				dimension_names.map{|d|
        specs << <<-EOF.unindent
					cs:#{d} a qb:ComponentSpecification ;
						rdfs:label "#{d} Component" ;
						qb:dimension prop:#{d} .

					EOF
        }

        measure_names.map{|n|
					specs << <<-EOF.unindent
						cs:#{n} a qb:ComponentSpecification ;
							rdfs:label "#{n} Component" ;
							qb:measure prop:#{n} .

						EOF
				}
			
			specs
		end

		def dimension_properties(dimensions, codes, var, options={})
      options = defaults().merge(options)
      props = []
      
        dimensions.map{|d|  
          if codes.include?(d)
          	props << <<-EOF.unindent
          	prop:#{d} a rdf:Property, qb:DimensionProperty ;
          	  rdfs:label "#{d}"@en ;
          	  qb:codeList code:#{d.downcase} ;
          	  rdfs:range code:#{d.downcase.capitalize} .

          	EOF
          else
	          props << <<-EOF.unindent
	          prop:#{d} a rdf:Property, qb:DimensionProperty ;
	            rdfs:label "#{d}"@en .
	            
	          EOF
          end
        }
      
      props
		end

		def measure_properties(measures, var, options={})
      options = defaults().merge(options)
			props = []
			
        measures.map{ |m|
            
            props <<  <<-EOF.unindent
            prop:#{m} a rdf:Property, qb:MeasureProperty ;
              rdfs:label "#{m}"@en .
          
            EOF
          }
			
			props
		end

		def observations(measures, dimensions, codes, data, observation_labels, var, options={})	
      options = defaults().merge(options)
			obs = []
			
				observation_labels.each_with_index.map{|r, i|
					str = <<-EOF.unindent 
						ns:obs#{r} a qb:Observation ;
							qb:dataSet ns:dataset-#{var} ;
					EOF

					str << "\trdfs:label \"#{r}\" ;\n" unless options[:no_labels]
					
					dimensions.map{|d|
						if codes.include? d
							str << "\tprop:#{d} <code/#{d.downcase}/#{data[d][i]}> ;\n"
						else
							str << "\tprop:#{d} ns:#{to_resource(data[d][i])} ;\n"
						end
					}

					measures.map{|m|
						str << "\tprop:#{m} #{to_literal(data[m][i])} ;\n"
					}

					str << "\t.\n\n"
					obs << str
				}
			
			obs
		end

		def code_lists(codes, data, var, options={})
			options = defaults().merge(options)
			lists = []
		  codes.map{|code|
	    	str = <<-EOF.unindent
					code:#{code.downcase.capitalize} a rdfs:Class, owl:Class;
						rdfs:subClassOf skos:Concept ;
						rdfs:label "Code list for #{code} - codelist class"@en;
						rdfs:comment "Specifies the #{code} for each observation";
						rdfs:seeAlso code:#{code.downcase} .

					code:#{code.downcase} a skos:ConceptScheme;
						skos:prefLabel "Code list for #{code} - codelist scheme"@en;
						rdfs:label "Code list for #{code} - codelist scheme"@en;
						skos:notation "CL_#{code.upcase}";
						skos:note "Specifies the #{code} for each observation";
	    	EOF
	    	data[code].uniq.map{|value|
	    		str << "\tskos:hasTopConcept <code/#{code.downcase}/#{value}> ;\n"
	    	}
	    	str <<"\t.\n\n"
	    	lists << str
	    }
			

			lists
		end

		def concept_codes(codes, data, var, options={})
			options = defaults().merge(options)
			concepts = []
      codes.map{|code|
      	data[code].uniq.map{|value|
      	concepts << <<-EOF.unindent
      		<code/#{code.downcase}/#{value}> a skos:Concept, code:#{code.downcase.capitalize};
      			skos:topConceptOf code:#{code.downcase} ;
      			skos:prefLabel "#{value}" ;
      			skos:inScheme code:#{code.downcase} .

      	EOF
      	}
      }

			concepts
		end


		def to_resource(obj)
			if obj.is_a? String
				#TODO decide the right way to handle missing values, since RDF has no null
				#probably throw an error here since a missing resource is a bigger problem
				obj = "null" if obj.empty?
				
				#TODO  remove special characters (faster) as well (eg '?')
				obj.gsub(' ','_').gsub('?','')
			elsif obj == nil
				"null"
			elsif obj.is_a? Numeric
				#resources cannot be referred to purely by integer (?)
				"n"+obj.to_s
			else
				obj
			end
		end

		def to_literal(obj)
			if obj.is_a? String
				# Depressing that there's no more elegant way to check if a string is 
				# a number...
				if val = Integer(obj) rescue nil
					val
				elsif val = Float(obj) rescue nil
					val
				else
					'"'+obj+'"'
				end
			elsif obj == nil
				#TODO decide the right way to handle missing values, since RDF has no null
				-1
			else
				obj
			end
		end
  end
end
