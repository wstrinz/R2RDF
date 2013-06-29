require_relative '../lib/r2rdf/data_cube.rb'
require_relative '../lib/r2rdf/r_client.rb'
require_relative '../lib/r2rdf/r_builder.rb'


describe R2RDF::Cube do
	context "when using r/qtl dataframe" do
		it "generates rdf from scanone result" do
			cube = R2RDF::Cube.new('mr')
			turtle_string = cube.generate_n3(@rexp)
			turtle_string.should_not == nil 
		end

		before do 
			@r = Rserve::Connection.new
			@r.eval <<-EOF
				library(qtl)
				data(listeria)
				mr = scanone(listeria,method="mr")
EOF
			@rexp = @r.eval 'mr'
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

			it 'obeys IC-12, has do duplicate observations' do
				SPARQL.execute(@checks['12'], @graph).first.should be_nil
			end

			it 'obeys IC-14, has a value for each measure in every observation' do
				SPARQL.execute(@checks['14'], @graph).first.should be_nil
			end
		end

		describe 'Functional R to vocabulary element generation' do
			# before(:all) do
			# 	@cube = R2RDF::Cube.new('mr')
			# 	@turtle = @cube.generate_n3(@rexp)
			# end

			it 'generates prefixes' do
				prefixes = @cube.prefixes
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