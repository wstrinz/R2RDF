require_relative '../lib/r2rdf/data_cube.rb'
require_relative '../lib/r2rdf/generators/dataframe.rb'
require_relative '../lib/r2rdf/r_client.rb'
require_relative '../lib/r2rdf/r_builder.rb'
require_relative '../lib/r2rdf/query_helper.rb'
require_relative '../lib/r2rdf/generators/csv.rb'


describe R2RDF::Rbuilder do

	context "when using r/qtl dataframe" do

		before(:all) do 
			@r = Rserve::Connection.new
			@r.eval <<-EOF
				library(qtl)
				data(listeria)
				mr = scanone(listeria,method="mr")
EOF
			@builder = R2RDF::Builder.new
		end

		it "produces equivalent dataframe from rdf" do
			@builder.from_turtle(File.dirname(__FILE__) +'/turtle/reference','mr', 'mo', false, false)
			@r.eval('identical(mr,mo)').to_ruby.should == true
		end
	end
end