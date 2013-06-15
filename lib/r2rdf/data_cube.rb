	#monkey patch to make rdf string w/ heredocs prettier ;)	
  class String
    def unindent
      gsub /^#{self[/\A\s*/]}/, ''
     # gsub(/^#{scan(/^\s*/).min_by{|l|l.length}}/, "")
    end

  end

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
		<<-EOF.unindent
		:refRow a rdf:Property, qb:DimensionProperty ;
		\trdfs:label "Row"@en .
		
		EOF
	end

	def measure_properties(rexp, type=:dataframe)
		props = []
		if type == :dataframe
			rexp.attr.payload["row.names"].to_ruby.map{|n|
				props <<  <<-EOF.unindent
				:#{n} a rdf:Property, qb:MeasureProperty ;
					\trdfs:label "#{n}"@en .
				
				EOF
                	}
		end
		props
	end

	
	def observations(rexp, type=:dataframe)	
		str = ""
		if type == :dataframe
			x.attr.payload["row.names"].to_ruby.each_with_index.map{|r, i|
				str << ":obs #{r} a qb:Observation ;\n\
					\tqb:dataSet :dataset-#{var} ;\n\
					\tprop:refRow :#{r} ;\n"
				x.payload.map{|c| str << "\tprop:#{l} #{w} ;\n"}
				str << "\t.\n\n"
			}
		end
		str
	end
  end
end
