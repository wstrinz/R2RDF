module R2RDF
		module Reader
		class ARFF
			include R2RDF::Dataset::DataCube
			def generate_n3(arff, options={})
				arff = IO.read(arff) if File.exist? arff	
				options[:no_labels] = true # unless options[:no_labels] == nil
				@options = options
				comps =  components(arff)
				obs = data(arff, comps.keys)
				generate(comps.reject{|c| comps[c][:codes]}.keys, comps.select{|c| comps[c][:codes]}.keys, comps.select{|c| comps[c][:codes]}.keys, obs, (1..obs.first[1].size).to_a, relation(arff), options)
			end

			def relation(arff)
				arff.match(/@relation.+/i).to_a.first.split.last
			end

			def components(arff)
				#still needs support for quoted strings with whitespace
				h ={}
				arff.split("\n").select{|lin| lin =~ /^@ATTRIBUTE/i}.map{|line|
					if line =~ /\{.*}/
						name = line.match(/\s.*/).to_a.first.strip.split.first
						type = :coded
						codes = line.match(/\{.*}/).to_a.first[1..-2].split(',')
						h[name] = {type: type, codes: codes}
					else
						name = line.split[1]
						type = line.split[2]
						h[name] = {type: type}
					end
				}
				h
			end

			def data(arff, attributes)
				lines = arff.split("\n")
				data_lines = lines[lines.index(lines.select{|line| line =~ /^@DATA/i}.first)+1..-1]
				h=attributes.inject({}){|ha,attrib| ha[attrib] = []; ha}
				data_lines.map{|line|
					line = line.split ','
					attributes.each_with_index{|a,i| h[a] << line[i]}
				}
				h
			end

		# 	def coded_dimensions
		# 		if @options[:codes]
		# 			@options[:codes]
		# 		elsif @options[:row_label]
		# 			[@options[:row_label]]
		# 		else
		# 			["refRow"]
		# 		end	
		# 	end

		# 	def measures
		# 		if @options[:dimensions]
		# 			if @options[:measures]
		# 				@options[:measures] - @options[:dimensions]
		# 			else
		# 				# @rexp.payload.names - @options[:dimensions]
		# 			end
		# 		else
		# 			@options[:measures] # || @rexp.payload.names
		# 		end
		# 	end

		# 	def observation_labels
		# 		# row_names = @rexp.attr.payload["row.names"].to_ruby
	 #   #    row_names = (1..@rexp.payload.first.to_ruby.size).to_a unless row_names.first
	 #   #    row_names
		# 	end

		# 	def observation_data

		# 		# data = {}
		# 		# @rexp.payload.names.map{|name|
		# 		# 	data[name] = @rexp.payload[name].to_ruby
		# 		# }
		# 		# data[@options[:row_label] || "refRow"] = observation_labels()
		# 		# data
		# 	end
		end
	end
end
