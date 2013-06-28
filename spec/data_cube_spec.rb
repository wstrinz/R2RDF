require_relative '../lib/r2rdf/data_cube.rb'
require_relative '../lib/r2rdf/r_client.rb'
require_relative '../lib/r2rdf/r_builder.rb'


describe R2RDF::Cube do
	
	context "when using r/qtl dataframe" do
		before(:each) do 
			@r = Rserve::Connection.new
			@r.eval <<-EOF
				library(qtl)
				data(listeria)
				mr = scanone(listeria,method="mr")
EOF
			@rexp = @r.eval 'mr'
			@cube = R2RDF::Cube.new('mr')

		end

		it "generates rdf from scanone result" do
			turtle_string = @cube.generate_n3(@rexp)
			turtle_string.should_not == nil 
		end

		it "generates valid turtle syntax" do
			turtle_string = @cube.generate_n3(@rexp)
			graph = RDF::Graph.new
			RDF::Reader.for(:turtle).new(turtle_string) {|r|
				r.each_statement{|st| graph.insert st}
			}
			graph.size.should > 0
		end

		it "generates valitd Data Cube format rdf" do

		end

		it "can set dimensions vs measures via hash" do

		end
	end

	context "when using simple dataframe" do

	end
end