load File.dirname(__FILE__) + '/../lib/r2rdf/loader.rb'

gen = R2RDF::Generators::RMatrix.new
con = Rserve::Connection.new
con.eval("load('#{ARGV[0] || './.RData'}')")
gen.generate_n3(con, "islet.mlratio", "pheno", {measures: ["probe","individual","pheno"], no_labels: true})
