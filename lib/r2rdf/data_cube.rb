module R2RDF
  # used to generate data cube observations, data structure definitions, etc
  class DataCube

    def initialize(variable_name="DC#{Time.now.to_i}")
      @var = variable_name
    end

    def data_structure_definition(rexp,type=:dataframe)
	str = "dsd-#{@var} a qb:DataStructureDefinition;\n"
	if type == :dataframe
		str << "\tcs:refRow a qb:ComponentSpecification,\n"
		#should eventually move these reusable map functions over to
		#the analyzer class
		rexp.attr.payload["row.names"].map{|n|
			str << "\t\tcs:#{n} ,\n"
		}
		str[-2]='.'
		str<<"\n"
	end
	str
	# Row names 
	# Recursiveness
	# class and other attributes
	# how to handle measure properties etc?
    end

	def dataset(rexp,type=:dataframe)
		    ":dataset-#{@var} a qb:DataSet ;\n\
			\trdfs:label \"#{@var}\"@en ;\n\
			\tqb:structure :dsd-#{@var} .\n\n"
	end

	def component_specifications(rexp, type=:dataframe)
		str = ""
		if type == :dataframe
			str << "cs:refRow a qb:ComponentSpecification ;\n\
				\trdfs:label \"Component Spec for #{@var}\" ;\n\
				\tqb:dimension prop:refRow .\n\n"
			
			#still needs method for distinguishing measure vs dimension
			rexp.attr.payload["row.names"].map{|n|
				str << "\tcs:#{n} a qb:ComponentSpecification ;\n\
					\trdfs:label \"Component Spec for #{n}\" ;\n\
					\tqb:measure prop:#{n} .\n\n"
			}
		end
	end

	def dimension_properties(rexp, type=:dataframe)
		":refRow a rdf:Property, qb:DimensionProperty ;\n\
		\trdfs:label \"Row\"@en .\n\n"
	end

	def measure_properties(rexp, type=:dataframe)
		if type == :dataframe
			rexp.attr.payload["row.names"].map{|n|
                                str << "\tcs:#{n} a rdf:Property, qb:MeasureProperty ;\n\
                                        \trdfs:label \"#{n}\" ;\n\n"
                	}
		end
	end

	
	def observations(rexp, type=:dataframe)	
		
	end
  end
end
