module R2RDF
	module Dataset
		module ORM
			class DataCube
				extend R2RDF::Dataset::DataCube
				extend R2RDF::Analyzer
				extend R2RDF::Metadata
				extend R2RDF::Query
				extend R2RDF::Parser

				include R2RDF::Dataset::DataCube
				include R2RDF::Analyzer
				include R2RDF::Metadata
				include R2RDF::Query
				include R2RDF::Parser
				
				attr_accessor :labels
				attr_accessor :dimensions
				attr_accessor :measures
	      attr_accessor :obs
				attr_accessor :meta

				def initialize(options={},do_parse = true)
					@dimensions = {}
					@measures = []
					@obs = []
					@generator_options = {}
					@options = {}

	        @meta = {}

					parse_options options if do_parse
				end

				def self.load(turtle_string,options={})
					# dimensions = get_ary(execute_from_file('dimensions.rq'))
					graph = create_graph(turtle_string)
					# puts get_hashes(execute_from_file('dimension_ranges.rq',graph))
					dimensions = Hash[get_hashes(execute_from_file('dimension_ranges.rq',graph),"to_s").map{|solution|
						#TODO coded properties should be found via SPARQL queries
						if solution[:range].split('/')[-2] == "code"
							type = :coded
						else
							type = strip_uri(solution[:range])
						end
						[strip_uri(solution[:dimension]), {type: type}]
					}]
					measures = get_ary(execute_from_file('measures.rq',graph)).flatten
					obs = execute_from_file('observations.rq',graph)
					observations = observation_hash(obs)
					simple_observations = observation_hash(obs,true)
					name = execute_from_file('dataset.rq',graph).to_h.first[:label]

					new_opts = {
						measures: measures,
						dimensions: dimensions,
						observations: simple_observations.values,
						name: name,
					}

					# puts new_opts[:observations]
					# puts options
					options = options.merge(new_opts)
					# puts options



					self.new(options)
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

					if options[:observations]
						options[:observations].each{|obs_data| add_observation obs_data}
					end

					@generator_options = options[:generator_options] if options[:generator_options]
					@options[:skip_metadata] = options[:skip_metadata] if options[:skip_metadata]

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


					#collect observation data
					check_integrity(@obs.map{|o| o.data}, @dimensions.keys, @measures)
					@obs.map{|obs|
						(@measures | @dimensions.keys).map{ |component|
						 (data[component] ||= []) <<  obs.data[component]
						}
					}
					

					codes = @dimensions.map{|d,v| d if v[:type] == :coded}.compact


					str = generate(@measures, @dimensions.keys, codes, data, @labels, @name, @generator_options)
					unless @options[:skip_metadata]
		        fields = {
		          publishers: publishers(),
		          subject: subjects(),
		          author: author(),
		          description: description(),
		          date: date(),
		          var: @name,
		        }
		        # puts basic(fields,@generator_options)
		        str += "\n" + basic(fields,@generator_options)
	      	end
	        str
				end

				def add_dimension(name, type=:coded)
					@dimensions[name.to_s] = {type: type}
				end

				def add_measure(name)
					@measures << name
				end

				def add_observation(data)
					data = Hash[data.map{|k,v| [k.to_s, v]}]
					obs = Observation.new(data)
					check_integrity([obs.data],@dimensions.keys,@measures) if @options[:validate_each]
					@obs << obs
				end

				def insert(observation)
					@obs << observation
				end

	      def publishers
	        @meta[:publishers] ||= []
	      end

	      def publishers=(publishers)
	        @meta[:publishers] = publishers
	      end

	      def subjects
	        @meta[:subject] ||= []
	      end

	      def subjects=(subjects)
	        @meta[:subject]=subjects
	      end

	      def add_publisher(label,uri)
	        publishers << {label: label, uri: uri}
	      end

	      def add_subject(id)
	        subject << id
	      end

	      def author
	        @meta[:creator] ||= ""
	      end

	      def author=(author)
	        @meta[:creator] = author
	      end

	      def description
	        @meta[:description] ||= ""
	      end

	      def description=(description)
	        @meta[:description] = description
	      end

	      def date
	        @meta[:date] ||= "#{Time.now.day}-#{Time.now.month}-#{Time.now.year}"
	      end

	      def date=(date)
	        @meta[:date] =  date
	      end

	      def to_h
					{
						measures: @measures,
						dimensions: @dimensions,
						observations: @obs.map{|o| o.data}
					}
				end
			end
		end
	end
end