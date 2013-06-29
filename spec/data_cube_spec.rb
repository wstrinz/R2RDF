require_relative '../lib/r2rdf/data_cube.rb'
require_relative '../lib/r2rdf/r_client.rb'
require_relative '../lib/r2rdf/r_builder.rb'


describe R2RDF::Cube do
	context "when using r/qtl dataframe" do
		before(:all) do 
			@r = Rserve::Connection.new
			@r.eval <<-EOF
				library(qtl)
				data(listeria)
				mr = scanone(listeria,method="mr")
EOF
			@rexp = @r.eval 'mr'
		end


		it "generates rdf from scanone result" do
			cube = R2RDF::Cube.new('mr')
			turtle_string = cube.generate_n3(@rexp)
			turtle_string.should_not == nil 
		end

		context 'output validity' do

			before(:all) do
				@cube = R2RDF::Cube.new('mr')
				@turtle = @cube.generate_n3(@rexp)
			end

			it "generates valid turtle syntax" do
				graph = RDF::Graph.new
				RDF::Reader.for(:turtle).new(@turtle) {|r|
					r.each_statement{|st| graph.insert st}
				}
				graph.size.should > 0
			end

			context 'under official W3C integrity constraints' do
				before(:all) do
					@checks = {}
					Dir.foreach(File.dirname(__FILE__) + '/queries/integrity') do |file|
						if file.split('.').last == 'rq'
							query = ""
							open(File.dirname(__FILE__) + '/queries/integrity/' + file){|f| f.each_line{|l| query << l}}
							@checks[file.split('.').first] = query
						end
					end
					@graph = RDF::Graph.new
					RDF::Reader.for(:turtle).new(@turtle) {|r|
						r.each_statement{|st| @graph.insert st}
					}
				end

				it 'has a unique dataset for each observation (IC-1)' do
					SPARQL.execute(@checks['1'], @graph).first.should be_nil
				end

				it 'has a unique data structure definition of each dataset (IC-2)' do
					SPARQL.execute(@checks['2'], @graph).first.should be_nil
				end

				it 'has a measure property specified for each dataset (IC-3)' do
					SPARQL.execute(@checks['3'], @graph).first.should be_nil
				end

				it 'specifies a range for all dimensions (IC-4)' do
					SPARQL.execute(@checks['4'], @graph).first.should be_nil
				end

				it 'has a value for each dimension in every observation (IC-11)' do
					SPARQL.execute(@checks['11'], @graph).first.should be_nil
				end

				it 'has do duplicate observations (IC-12)' do
					SPARQL.execute(@checks['12'], @graph).first.should be_nil
				end

				it 'has a value for each measure in every observation (IC-14)' do
					SPARQL.execute(@checks['14'], @graph).first.should be_nil
				end
			end
		end

		context 'Functional R to vocabulary element generation' do
			before(:all) do
				@cube = R2RDF::Cube.new('mr')
				@turtle = @cube.generate_n3(@rexp)
			end

			it 'generates prefixes' do
				prefixes = @cube.prefixes
				prefixes.is_a?(String).should == true
			end

			it 'generates data structure definition' do
				dsd = @cube.data_structure_definition(@rexp, "mr")
				dsd.is_a?(String).should == true
			end

			it 'generates dataset' do
				dsd = @cube.dataset(@rexp, "mr")
				dsd.is_a?(String).should == true
			end

			it 'generates component specifications' do
				components = @cube.component_specifications(@rexp, "mr")
				components.is_a?(Array).should == true
				components.first.is_a?(String).should == true
			end

			it 'generates dimension properties' do
				dimensions = @cube.dimension_properties(@rexp, "mr")
				dimensions.is_a?(Array).should == true
				dimensions.first.is_a?(String).should == true
			end

			it 'generates measure properties' do
				measures = @cube.measure_properties(@rexp, "mr")
				measures.is_a?(Array).should == true
				measures.first.is_a?(String).should == true
			end

			it 'generates observations' do
				observations = @cube.observations(@rexp, "mr")
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