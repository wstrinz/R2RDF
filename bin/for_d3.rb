require_relative '../lib/r2rdf/data_cube.rb'
require 'rserve'

class Gen
	include R2RDF::Dataset::DataCube
end

def peaks(connection)
	peak=connection.eval 'peaks'

end

def probes(connection)
	connection.eval 'probe'
end

def pmark(connection)
	connection.eval 'pmark'
end

def geno(connection)
	connection.eval 'f2gi'
end


def measures
	pheno_names = client.eval("names(#{var}$pheno)").to_ruby
	measures = pheno.names | ["genotype","markerpos"]
	measure_properties(measures,var,options)
end

g=Gen.new

cli = Rserve::Connection.new
