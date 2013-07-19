# require_relative '../../lib/r2rdf/data_cube.rb'
# require_relative '../../lib/r2rdf/generators/dataframe.rb'
# require 'rdf/turtle'
# require 'rserve'
require_relative '../../lib/r2rdf/loader.rb'

require 'tempfile'

describe R2RDF::Reader::Dataframe do
	
	def create_graph(turtle_string)
		f = Tempfile.new('graph')
		f.write(turtle_string)
		f.close
		graph = RDF::Graph.load(f.path, :format => :ttl)
		f.unlink
		graph
	end

	# before(:each) do 
	# 	@connection = Rserve::Connection.new 
	# end
  context "with r/qtl dataframe" do
		before(:all) do 
			@r = Rserve::Connection.new
			@generator = R2RDF::Reader::Dataframe.new
			@r.eval <<-EOF
				library(qtl)
				data(listeria)
				mr = scanone(listeria,method="mr")
EOF
			@rexp = @r.eval 'mr'
			@turtle = @generator.generate_n3(@rexp,'mr')
		end

		it "generates rdf from R dataframe" do
			turtle = @generator.generate_n3(@rexp,'mr')
			turtle.is_a?(String).should be true
		end
		
		it "creates correct graph according to refrence file" do
			# cube = R2RDF::Cube.new('mr')
			# turtle_string = cube.generate_n3(@rexp)
			open('ooot.ttl','w'){|f|
				f.write(@turtle)
			}
			reference = IO.read(File.dirname(__FILE__) + '/../turtle/reference')
			@turtle.should eq reference
		end

		it "can optionally specify a row label" do
			@turtle = @generator.generate_n3(@rexp,'mr',{row_label:"markers"})
		end
	end

		

end