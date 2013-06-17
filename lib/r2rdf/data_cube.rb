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
		def prefixes(type=:dataframe)
			<<-EOF.unindent
			@prefix : <http://www.rqtl.org/ns/#> .
			@prefix qb: <http://purl.org/linked-data/cube#> .
			@prefix rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
			@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
			@prefix prop: <http://www.rqtl.org/dc/properties/> .
			@prefix cs: <http://www.rqtl.org/dc/cs/> .
						
			EOF
		end

    def data_structure_definition(rexp,var,type=:dataframe)
			str = "dsd-#{var} a qb:DataStructureDefinition;\n"
			if type == :dataframe
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

		def dataset(rexp,var,type=:dataframe)
			<<-EOF.unindent    
			:dataset-#{@var} a qb:DataSet ;
				rdfs:label "#{var}"@en ;
				qb:structure :dsd-#{@var} .

			EOF
		end

		def component_specifications(rexp,var, type=:dataframe)
			specs = []
			if type == :dataframe
				specs << <<-EOF.unindent 
				cs:refRow a qb:ComponentSpecification ;
					rdfs:label "Component Spec for Row" ;
					qb:dimension prop:refRow .

				EOF
				#still needs method for distinguishing measure vs dimension
				rexp.payload.names.map{|n|
					specs << <<-EOF.unindent
						cs:#{n} a qb:ComponentSpecification ;
							rdfs:label "Component Spec for #{n}" ;
							qb:measure prop:#{n} .

						EOF
				}
			end
			specs
		end

		def dimension_properties(rexp,var,type=:dataframe)
			<<-EOF.unindent
			:refRow a rdf:Property, qb:DimensionProperty ;
				rdfs:label "Row"@en .
			
			EOF
		end

		def measure_properties(rexp,var,type=:dataframe)
			props = []
			if type == :dataframe
				rexp.payload.names.map{|n|
					props <<  <<-EOF.unindent
					:#{n} a rdf:Property, qb:MeasureProperty ;
						rdfs:label "#{n}"@en .
				
					EOF
         }
			end
			props
		end

		def rows(rexp, var, type=:dataframe)
			rows = []
			if type == :dataframe
				rexp.attr.payload["row.names"].to_ruby.map{|r|
					rows << <<-EOF.unindent
						:#{r} a prop:refRow ;
							rdfs:label "#{r}" .

					EOF
				}
			end
			rows
		end
	
		def observations(rexp, var, type=:dataframe)	
			obs = []
			if type == :dataframe
				rexp.attr.payload["row.names"].to_ruby.each_with_index.map{|r, i|
					str = <<-EOF.unindent 
						:obs#{r} a qb:Observation ;
							qb:dataSet :dataset-#{var} ;
							prop:refRow :#{r} ;
						EOF
					rexp.payload.names.map{|n| str << "\tprop:#{n} #{rexp.payload[n].to_a[i]} ;\n"}
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

		def generate_n3(rexp)
			str = prefixes()
			str << data_structure_definition(rexp,@var)
			str << dataset(rexp,@var)
			component_specifications(rexp,@var).map{ |c| str << c }
			str << dimension_properties(rexp,@var)
			measure_properties(rexp,@var).map{|p| str << p}
			rows(rexp,@var).map{|r| str << r}
			observations(rexp,@var).map{|o| str << o}
			str
		end
	end
end
