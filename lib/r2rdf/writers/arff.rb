module R2RDF
	module Writer
		class ARFF
			include R2RDF::Query
			include R2RDF::Parser
			include R2RDF::Analyzer

			def build_arff(relation, attributes, data, source)
				str = <<-EOS
% 1. Title: #{relation.capitalize} Database
%
% 2. Sources:
%			(a) Generated from RDF source #{source}
%     
@RELATION #{relation}

EOS

				Hash[attributes.sort].map{|attribute,type|
					str << "@ATTRIBUTE #{attribute} #{type}\n"
				}

				str << "\n@DATA\n"
				data.map { |d| str << Hash[d[1].sort].values.join(',') + "\n" }
				
				str
			end

			def from_turtle(turtle_file, dataset_name=nil, relation_name=nil, verbose=false)
				unless dataset_name && relation_name
					puts "no variable specified. Simple inference coming soon" if verbose
					return
				end
				puts "loading #{turtle_file}" if verbose
				repo = RDF::Repository.load(turtle_file)
				puts "loaded #{repo.size} statements into temporary repo" if verbose
				
				dims = get_ary(execute_from_file("dimensions.rq",repo,:graph)).flatten
				meas = get_ary(execute_from_file("measures.rq",repo,:graph)).flatten
				relation = execute_from_file("dataset.rq",repo,:graph).to_h.first[:label].to_s

				data = observation_hash(execute_from_file("observations.rq",repo,:graph), true)
				attributes = {}
				(dims | meas).map{|component|
					attributes[component] = case recommend_range(data.map{|o| o[1][component]})
						when "xsd:int"
							"integer"
						when "xsd:double"
							"real"
						when :coded
							"string"
						end
				}

				build_arff(relation, attributes, data, turtle_file)
			end

			def from_store(endpoint_url,connection,variable_in=nil, variable_out=nil, verbose=true, save=true)
				unless variable_in && variable_out
					puts "no variable specified. Simple inference coming soon" if verbose
					return
				end
				puts "connecting to endpoint at #{endpoint_url}" if verbose
				sparql = SPARQL::Client.new(endpoint_url)
				query = R2RDF::QueryHelper.new

				rows = query.get_ary(sparql.query(query.row_names(variable_in))).flatten

			end
		end
	end
end
