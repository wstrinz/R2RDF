require_relative '../lib/r2rdf/data_cube.rb'
require_relative '../lib/r2rdf/generators/dataframe.rb'
require_relative '../lib/r2rdf/r_client.rb'
require_relative '../lib/r2rdf/r_builder.rb'
require_relative '../lib/r2rdf/generators/csv.rb'


describe R2RDF::Generator do

	context "with Plain Old Ruby objects" do
		#define a temporary class to use module methods
		before(:all) do
			class Gen
				include R2RDF::Generator
			end
		end
		it "should generate output for simple objects" do
			gen = Gen.new
			data = {
				"producer" =>      ["hormel","newskies",  "whys"],
				"pricerange" =>    ["low",   "medium",    "nonexistant"],
				"chunkiness"=>     [1,         6,          9001],
				"deliciousness"=>  [1,         9,          6]  
			}

			turtle_string = gen.generate(["chunkiness","deliciousness"], ["producer","pricerange"], ["producer","pricerange"],
				data, %w(hormel newskies whys), 'bacon')
			 ref = IO.read(File.dirname(__FILE__) + '/turtle/bacon')
			turtle_string.should == ref
		end
	end

	context "with csv file" do
		it "generates turtle string for csv" do
			gen = R2RDF::Generators::CSV.new

			#prebuilt generators should infer missing information if possible, eg measure, coded dimensions
			turtle_string = gen.generate_n3(File.dirname(__FILE__) + '/csv/bacon.csv','bacon',{dimensions:["producer","pricerange"], label_column:0})
			ref = IO.read(File.dirname(__FILE__) + '/turtle/bacon')
			turtle_string.should == ref
		end
	end

	context "when using r/qtl dataframe" do

		before(:all) do 
			@r = Rserve::Connection.new
			@r.eval <<-EOF
				library(qtl)
				data(listeria)
				mr = scanone(listeria,method="mr")
EOF
			@rexp = @r.eval 'mr'
			@cube = R2RDF::Generators::Dataframe.new
			@turtle = @cube.generate_n3(@rexp,'mr')
		end
		
		it "generates rdf from scanone result" do
			# cube = R2RDF::Cube.new('mr')
			# turtle_string = cube.generate_n3(@rexp)
			reference = IO.read(File.dirname(__FILE__) + '/turtle/reference')
			@turtle.should eq reference
		end

		context 'under official W3C integrity constraints' do
			before(:all) do
				@checks = {}
				Dir.foreach(File.dirname(__FILE__) + '/queries/integrity') do |file|
					if file.split('.').last == 'rq'
						@checks[file.split('.').first] = IO.read(File.dirname(__FILE__) + '/queries/integrity/' + file)
					end
				end
				@graph = RDF::Graph.new
				RDF::Reader.for(:turtle).new(@turtle) {|r|
					r.each_statement{|st| @graph.insert st}
				}
			end

			it 'obeys IC-1, has a unique dataset for each observation' do
				SPARQL.execute(@checks['1'], @graph).first.should be_nil
			end

			it 'obeys IC-2, has a unique data structure definition of each dataset' do
				SPARQL.execute(@checks['2'], @graph).first.should be_nil
			end

			it 'obeys IC-3, has a measure property specified for each dataset' do
				SPARQL.execute(@checks['3'], @graph).first.should be_nil
			end

			it 'obeys IC-4, specifies a range for all dimensions' do
				SPARQL.execute(@checks['4'], @graph).first.should be_nil
			end

			it 'obeys IC-5, every dimension with range skos:Concept must have a qb:codeList' do
				SPARQL.execute(@checks['5'], @graph).first.should be_nil
			end

			it 'obeys IC-11, has a value for each dimension in every observation' do
				SPARQL.execute(@checks['11'], @graph).first.should be_nil
			end

			## currently locks up. possible bug in SPARQL gem parsing?
			## works fine as a raw query
			# it 'obeys IC-12, has do duplicate observations' do
			# 	SPARQL.execute(@checks['12'], @graph).first.should be_nil
			# end

			it 'obeys IC-14, has a value for each measure in every observation' do
				SPARQL.execute(@checks['14'], @graph).first.should be_nil
			end

			it 'obeys IC-19, all codes for each codeList are included' do
				SPARQL.execute(@checks['19_1'], @graph).first.should be_nil
				## second query for IC-19 uses property paths that aren't as easy to
				## convert to sparql 1.0, so for now I've left it out
				# SPARQL.execute(@checks['19_2'], @graph).first.should be_nil
			end
		end

		it "generates valid turtle syntax" do
			graph = RDF::Graph.new
			RDF::Reader.for(:turtle).new(@turtle) {|r|
				r.each_statement{|st| graph.insert st}
			}
			graph.size.should > 0
		end

		describe 'Functional R to vocabulary element' do
			# before(:all) do
			# 	@cube = R2RDF::Cube.new('mr')
			# 	@turtle = @cube.generate_n3(@rexp)
			# end

			it 'generates prefixes' do
				prefixes = @cube.prefixes('test')
				prefixes.is_a?(String).should == true
			end

			it 'generates data structure definition' do
				dsd = @cube.data_structure_definition(@rexp.payload.names, "mr")
				dsd.is_a?(String).should == true
			end

			it 'generates dataset' do
				dsd = @cube.dataset("mr")
				dsd.is_a?(String).should == true
			end

			it 'generates component specifications' do
				components = @cube.component_specifications(@rexp.payload.names, ["refRow"], "mr")
				components.is_a?(Array).should == true
				components.first.is_a?(String).should == true
			end

			it 'generates dimension properties' do
				dimensions = @cube.dimension_properties(["refRow"],["refRow"],"mr")
				dimensions.is_a?(Array).should == true
				dimensions.first.is_a?(String).should == true
			end

			it 'generates measure properties' do
				measures = @cube.measure_properties(@rexp.payload.names, "mr")
				measures.is_a?(Array).should == true
				measures.first.is_a?(String).should == true
			end

			it 'generates observations' do
				#measures, dimensions, codes, var, observation_labels, data, options={}
				data = {}
				@rexp.payload.names.map{|name|
					data[name] = @rexp.payload[name].to_ruby
				}
				data["refRow"] = @rexp.attr.payload["row.names"].to_ruby
				observations = @cube.observations(@rexp.payload.names, ["refRow"], ["refRow"], data, @rexp.attr.payload["row.names"].to_ruby, "mr")
				observations.is_a?(Array).should == true
				observations.first.is_a?(String).should == true
			end
		end

		it "can set dimensions vs measures via hash" do

		end
	end

	context "when using simple dataframe" do

	end


end