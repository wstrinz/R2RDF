module R2RDF
		module Reader
		class ARFF
			include R2RDF::Dataset::DataCube
		
			
			def generate_n3(arff, options={})
				arff = IO.read(arff) if File.exist? arff	
				@arff = arff
				@options = options
				@options[:no_labels] = true unless @options[:no_labels].nil?
				components
				# generate(measures, dimensions, coded_dimensions, observation_data, observation_labels, var, options)
			end

			def components

			end

			def dimensions
				
			end

			def coded_dimensions
				if @options[:codes]
					@options[:codes]
				elsif @options[:row_label]
					[@options[:row_label]]
				else
					["refRow"]
				end	
			end

			def measures
				if @options[:dimensions]
					if @options[:measures]
						@options[:measures] - @options[:dimensions]
					else
						# @rexp.payload.names - @options[:dimensions]
					end
				else
					@options[:measures] # || @rexp.payload.names
				end
			end

			def observation_labels
				# row_names = @rexp.attr.payload["row.names"].to_ruby
	   #    row_names = (1..@rexp.payload.first.to_ruby.size).to_a unless row_names.first
	   #    row_names
			end

			def observation_data

				# data = {}
				# @rexp.payload.names.map{|name|
				# 	data[name] = @rexp.payload[name].to_ruby
				# }
				# data[@options[:row_label] || "refRow"] = observation_labels()
				# data
			end
		end
	end
end
