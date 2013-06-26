  #monkey patch to make rdf string w/ heredocs prettier ;)	
  class String
    def unindent
      gsub /^#{self[/\A\s*/]}/, ''
     # gsub(/^#{scan(/^\s*/).min_by{|l|l.length}}/, "")
    end

  end

module R2RDF
  # used to generate data cube observations, data structure definitions, etc
  module DataCube
    def defaults
      {
        type: :dataframe,
        dimensions: ["refRow"],
        measures: [:all],
      }
    end

		def prefixes(options={})
      # type = options[:type] || :dataframe
      options = defaults().merge(options)
			<<-EOF.unindent
			@prefix : <http://www.rqtl.org/ns/#> .
			@prefix qb: <http://purl.org/linked-data/cube#> .
			@prefix rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
			@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
			@prefix prop: <http://www.rqtl.org/dc/properties/> .
			@prefix cs: <http://www.rqtl.org/dc/cs/> .
						
			EOF
		end

    def data_structure_definition(rexp,var,options={})
      # type = options[:type] || :dataframe
      options = defaults().merge(options)
			str = ":dsd-#{var} a qb:DataStructureDefinition;\n"
			if options[:type] == :dataframe
				str << "\tqb:component cs:refRow ,\n"
				#should eventually move these reusable map functions over to
				#the analyzer class
				rexp.payload.names.map{|n|
							str << "\t\tcs:#{n} ,\n"
				}
				str[-2]='.'
				str<<"\n"
			end
			str
			# Still needs: 
			# Row names 
			# Recursiveness
			#	class and other attributes
    end

		def dataset(rexp,var,options={})
      # type = options[:type] || :dataframe
      options = defaults().merge(options)
			<<-EOF.unindent    
			:dataset-#{@var} a qb:DataSet ;
				rdfs:label "#{var}"@en ;
				qb:structure :dsd-#{@var} .

			EOF
		end

		def component_specifications(rexp,var,options={})
      # type = options[:type] || :dataframe
      options = defaults().merge(options)
			specs = []
			if options[:type] == :dataframe
				options[:dimensions].map{|d|
        specs << <<-EOF.unindent
					cs:#{d} a qb:ComponentSpecification ;
						rdfs:label "Component Spec for #{d}" ;
						qb:dimension prop:#{d} .

					EOF
        }
				#still needs method for distinguishing measure vs dimension
				if options[:measures].first == :all
          measures = rexp.payload.names
        else
          measures = (rexp.payload.names & options[:measures])
        end
        measures.map{|n|
					specs << <<-EOF.unindent
						cs:#{n} a qb:ComponentSpecification ;
							rdfs:label "Component Spec for #{n}" ;
							qb:measure prop:#{n} .

						EOF
				}
			end
			specs
		end

		def dimension_properties(rexp,var,options={})
      # type = options[:type] || :dataframe
      options = defaults().merge(options)
      props = []
      if options[:type] == :dataframe
  			if options[:dimensions].include? "refRow"
          props << <<-EOF.unindent
    			:refRow a rdf:Property, qb:DimensionProperty ;
    				rdfs:label "Row"@en .
    			
    			EOF
        else
        	#Keep row for now even if not specified. Remove later to save space.
          props << <<-EOF.unindent
          :refRow a rdf:Property;
            rdfs:label "Row"@en .

          EOF
        end
        (options[:dimensions] - ["refRow"]).map{|d|
          props << <<-EOF.unindent
          :#{d} a rdf:Property, qb:DimensionProperty ;
            rdfs:label "#{d}"@en .
          
          EOF
        }
      end
      props
		end

		def measure_properties(rexp,var,options={})
      # type = options[:type] || :dataframe
      options = defaults().merge(options)
			props = []
			if options[:type] == :dataframe
        if options[:measures].first == :all
  				rexp.payload.names.map{|n|
  					props <<  <<-EOF.unindent
  					:#{n} a rdf:Property, qb:MeasureProperty ;
  						rdfs:label "#{n}"@en .
  				
  					EOF
          }
        else
          (options[:measures] & rexp.payload.names).map{ |m|
            
            props <<  <<-EOF.unindent
            :#{m} a rdf:Property, qb:MeasureProperty ;
              rdfs:label "#{m}"@en .
          
            EOF
          }
        end
			end
			props
		end

		def rows(rexp, var, options={})
      # type = options[:type] || :dataframe
      options = defaults().merge(options)
			rows = []
			if options[:type] == :dataframe
        names = rexp.attr.payload["row.names"].to_ruby
        names = 1..rexp.payload.first.to_ruby.size unless names.first
				names.map{|r|
					rows << <<-EOF.unindent
					:#{r} a prop:refRow ;
						rdfs:label "#{r}" .

					EOF
				}
			end
			rows
		end
	
		def observations(rexp, var, options={})	
      # type = options[:type] || :dataframe
      options = defaults().merge(options)
			obs = []
			if options[:type] == :dataframe
        row_names = rexp.attr.payload["row.names"].to_ruby
        row_names = 1..rexp.payload.first.to_ruby.size unless row_names.first
				row_names.each_with_index.map{|r, i|
					str = <<-EOF.unindent 
						:obs#{r} a qb:Observation ;
							qb:dataSet :dataset-#{var} ;
							rdfs:label "#{r}" ;
						EOF
					str << "\tprop:refRow :#{r} ;\n" if options[:dimensions].include? "refRow"
					#TODO proper naming for dimensions, hopefully using coded properties
					(options[:dimensions] - ["refRow"]).map{|d| str << "\tprop:#{d} :#{d}#{rexp.payload[d].to_a[i]} ;\n"}
					if options[:measures].first == :all
						rexp.payload.names.map{|n| str << "\tprop:#{n} #{rexp.payload[n].to_a[i]} ;\n"}
					else
						(options[:measures] & rexp.payload.names).map{|n| str << "\tprop:#{n} #{rexp.payload[n].to_a[i]} ;\n"}
					end
					str << "\t.\n\n"
					obs << str
				}
			end
			obs
		end
  end

	class Cube
		include R2RDF::DataCube
		
		def initialize(var)
			@var = var
		end

		def rexp
			#maybe create client here?
		end

		def generate_n3(rexp,options={})
			str = prefixes()
			str << data_structure_definition(rexp, @var, options)
			str << dataset(rexp, @var, options)
			component_specifications(rexp, @var, options).map{ |c| str << c }
			dimension_properties(rexp, @var, options).map{|p| str << p}
			measure_properties(rexp, @var, options).map{|p| str << p}
			rows(rexp, @var, options).map{|r| str << r}
			observations(rexp, @var, options).map{|o| str << o}
			str
		end
	end
end
