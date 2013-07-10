require_relative '../../lib/r2rdf/data_cube.rb'
require_relative '../../lib/r2rdf/generators/dataframe.rb'
require 'rdf/turtle'
require 'tempfile'
require 'rserve'

describe R2RDF::Generators::Dataframe do
	
	def create_graph(turtle_string)
		f = Tempfile.new('graph')
		f.write(turtle_string)
		f.close
		graph = RDF::Graph.load(f.path, :format => :ttl)
		f.unlink
		graph
	end

	before(:each) do 
		@generator = R2RDF::Generators::Dataframe.new
		@connection = Rserve::Connection.new 
	end
  context "with r/qtl dataframe" do
		before(:all) do 
			@r = Rserve::Connection.new
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
		end
		
		it "creates correct graph according to refrence file" do
			# cube = R2RDF::Cube.new('mr')
			# turtle_string = cube.generate_n3(@rexp)
			reference = IO.read(File.dirname(__FILE__) + '/../turtle/reference')
			@turtle.should eq reference
		end
	end

		

end