load File.dirname(__FILE__) + '/../lib/r2rdf/loader.rb'

gen = R2RDF::Reader::RMatrix.new
con = Rserve::Connection.new
con.eval("load('#{ARGV[0] || './.RData'}')")
gen.generate_n3(con, "scan.islet", "scan", {measures: ["probe","marker","lod"], no_labels: true})
