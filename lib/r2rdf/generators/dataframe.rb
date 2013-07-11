module R2RDF
	module Generators
		class Dataframe
			include R2RDF::Generator
		
			# def initialize(var)
			# 	@var = var
			# end
			
			def generate_n3(rexp, var, options={})
				@rexp = rexp
				@options = options

				generate(measures, dimensions, codes, observation_data, observation_labels, var, options)
			end

			def dimensions
				if @options[:dimensions]
					@options[:dimensions]
				elsif @options[:row_label]
					[@options[:row_label]]
				else
					["refRow"]
				end	
			end

			def codes
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
						@rexp.payload.names - @options[:dimensions]
					end
				else
					@options[:measures] || @rexp.payload.names
				end
			end

			def observation_labels
				row_names = @rexp.attr.payload["row.names"].to_ruby
	      row_names = (1..@rexp.payload.first.to_ruby.size).to_a unless row_names.first
	      row_names
			end

			def observation_data

				## apparently you can't easily add to an Rexp...
				## probably would be good to figure a way in the future, but for now this works

				data = {}
				@rexp.payload.names.map{|name|
					data[name] = @rexp.payload[name].to_ruby
				}
				data[@options[:row_label] || "refRow"] = observation_labels()
				data
			end
		end
	end
end