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

    def data_structure_definition(rexp,var,type=:dataframe)
	str = "dsd-#{var} a qb:DataStructureDefinition;\n"
	if type == :dataframe
		str << "\tcs:refRow a qb:ComponentSpecification,\n"
		#should eventually move these reusable map functions over to
		#the analyzer class
		rexp.attr.payload["row.names"].to_ruby.map{|n|
			str << "\t\tcs:#{n} ,\n"
		}
		str[-2]='.'
		str<<"\n"
	end
	str
	# Still needs: 
	# Row names 
	# Recursiveness
	# class and other attributes
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
			rexp.attr.payload["row.names"].to_ruby.map{|n|
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
		\trdfs:label "Row"@en .
		
		EOF
	end

	def measure_properties(rexp,var,type=:dataframe)
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

	
	def observations(rexp, var, type=:dataframe)	
		obs = []
		if type == :dataframe
			rexp.attr.payload["row.names"].to_ruby.each_with_index.map{|r, i|
				str = <<-EOF.unindent 
					:obs #{r} a qb:Observation ;
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
end
