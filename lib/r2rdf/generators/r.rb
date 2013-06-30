module R2RDF
	module Generators
		class R
			include R2RDF::Generator
		
			# def initialize(var)
			# 	@var = var
			# end
			
			def generate_n3(rexp, var, options={})
				@rexp = rexp
				@options = options
				generate(measures, dimensions, codes, observation_data, observation_labels, var, options)
				
				# str = prefixes()
				# str << data_structure_definition(rexp.payload.names, @var, options)
				# str << dataset(@var, options)
				# component_specifications(measures(), dimensions(), @var, options).map{ |c| str << c }
				# dimension_properties(dimensions(), codes(), @var, options).map{|p| str << p}
				# measure_properties(measures(), @var, options).map{|p| str << p}
				# code_lists(codes(), observation_data(), @var, options).map{|l| str << l}
				# concept_codes(codes(), observation_data(), @var, options).map{|c| str << c}
				# observations(measures(), dimensions(), codes(), observation_data(), observation_labels(), @var, options).map{|o| str << o}
				# str
			end

			def components(rexp, options)

			end

			def dimensions
				@options[:dimensions] || ["refRow"]
			end

			def codes
				@options[:codes] || ["refRow"]
			end

			def measures
				if @options[:dimensions]
					if @options[:measures]
						@options[:measures] - @options.dimensions
					else
						@rexp.payload.names - @options.dimensions
					end
				else
					@options[:dimensions] || @rexp.payload.names
				end
			end

			def observation_labels
				row_names = @rexp.attr.payload["row.names"].to_ruby
	      row_names = 1..@rexp.payload.first.to_ruby.size unless row_names.first
	      row_names
			end

			def observation_data

				## apparently you can't easily add to an Rexp...
				## probably would be good to figure a way in the future, but for now this works

				data = {}
				@rexp.payload.names.map{|name|
					data[name] = @rexp.payload[name].to_ruby
				}
				data["refRow"] = observation_labels()
				data
			end
		end
	end
end