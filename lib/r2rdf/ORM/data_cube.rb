module R2RDF
	module ORM
		class DataCube
			include R2RDF::Generator

			attr_accessor :labels
			attr_accessor :dimensions
			attr_accessor :measures
			attr_accessor :obs

			def initialize(options={})
				@dimensions = {}
				@measures = []
				@obs = []
				@generator_options = {}
				
				parse_options options
			end

			def parse_options(options)
				if options[:dimensions]
					options[:dimensions].each{|name,details|
						add_dimension(name, details[:type] || :coded)
					}
				end

				if options[:measures]
					options[:measures].each{|m| @measures << m}
				end

				if options[:obs]
					options[:obs].each{|obs_data| add_observation obs_data}
				end

				@generator_options = options[:generator_options] if options[:generator_options]

				if options[:name]
					@name = options[:name]
				else
					raise "No dataset name specified!"
				end

				if options[:validate_each]
					@options[:validate_each] = options[:validate_each]
				end
			end

			def to_n3

				#create labels if not specified
				unless @labels.is_a?(Array) && @labels.size == @obs.size
					if @labels.is_a? Symbol
						#define some automatic labeling methods
					else
						@labels = (1..@obs.size).to_a.map(&:to_s)
					end
				end
				data = {}


				check_integrity(data)
				#collect observation data
				@obs.map{|obs|
					(@measures | @dimensions.keys).map{ |component|
					 (data[component] ||= []) <<  obs.data[component]
					}
				}

				codes = @dimensions.map{|d,v| d if v[:type] == :coded}.compact

				generate(@measures, @dimensions.keys, codes, data, @labels, @name, @generator_options)
			end

			def add_dimension(name, type=:coded)
				@dimensions[name.to_s] = {type: type}
			end

			def add_measure(name)
				@measures << name
			end

			def check_integrity(observations)
				observations.map{|o|
						raise "MissingValues for #{(@dimensions.keys | @measures) - data.keys}" unless ((@dimensions.keys | @measures) - o.data.keys).empty?
						raise "UnknownProperty #{data.keys - (@dimensions.keys | @measures)}" unless (o.data.keys - (@dimensions.keys | @measures)).empty?
				}
			end

			def add_observation(data)
				data = Hash[data.map{|k,v| [k.to_s, v]}]
				obs = Observation.new(data)
				# check_integrity([obs]) if @options[:validate_each]
				@obs << obs

			end

			def insert(observation)
				@obs << observation
			end
		end
	end
end