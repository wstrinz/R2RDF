require_relative '../../lib/r2rdf/data_cube.rb'
require_relative '../../lib/r2rdf/generators/r_matrix.rb'
require 'rdf/turtle'
require 'tempfile'
require 'rserve'

describe R2RDF::Generators::RMatrix do
	
	def create_graph(turtle_string)
		f = Tempfile.new('graph')
		f.write(turtle_string)
		f.close
		graph = RDF::Graph.load(f.path, :format => :ttl)
		f.unlink
		graph
	end

	before(:each) do 
		@generator = R2RDF::Generators::RMatrix.new
		@connection = Rserve::Connection.new 
	end

	it "generators a simple output automatically" do
		f=Tempfile.new('matrix')
		@connection.eval "mat = matrix(c(2, 4, 3, 1, 5, 7), nrow=3, ncol=2)" 
		@generator.generate_n3(@connection,'mat',f.path,{quiet: true})

		turtle_string = IO.read("#{f.path}_structure.ttl") + IO.read("#{f.path}_0.ttl")
		graph = create_graph(turtle_string) 
		graph.size.should > 0
	end

end