# require_relative '../lib/qtl2rdf.rb'
require 'qtl2rdf'
def print_usage
  puts "Usage: java -jar QTL2RDF.jar variable [directory] [4store_port] [output]"
  puts "\nTakes <variable> from R session in <directory>, converts to RDF triples. Stores the result to 4store at <4store_port>, or prints to stdout if <output> is non-nil"
end

var = ARGV[0]
dir = ARGV[1] || '.'
port = ARGV[2]
out = ARGV[3]

unless var
  print_usage
  exit
end


puts "Dumping object #{var} for R session in #{File.absolute_path(dir)}"
cl = QTL2RDF.new(dir)

if port
  cl.port_4s = port
end

if out
  puts cl.triples_for(cl.dump_mr(var))
else
  cl.to_store(var)
end