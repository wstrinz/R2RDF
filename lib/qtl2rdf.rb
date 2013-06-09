require 'rserve'
require 'rdf/4store'
Dir[File.dirname(__FILE__) + '/vocabs/*.rb'].each {|file| require file }

class QTL2RDF

  attr_accessor :port_4s

  def initialize(dir='.')
    dir = File.absolute_path(dir)
    @R = Rserve::Connection.new()
    if File.exist?(dir + "/.RData")
      # puts "loading workspace #{dir}/.RData"
      @R.eval("load('#{dir}/.RData')")
    end

    if File.exist?(dir + "/.Rhistory")
      # puts "loading history #{dir}/.Rhistory"
      @R.eval("loadhistory('#{dir}/.Rhistory')")
    end

    @port_4s = 8080
  end

  def dump_mr(var)
    h = {}
    h[var] = {"attr" => {}, "rows"=>{}}

    x = @R.eval(var)

    x.attr.payload.keys.map{ |a|
      h[var]["attr"][a] = x.attr.payload[a].to_ruby
    }

    rownames = x.attr.payload["row.names"].to_ruby
    colnames = x.payload.keys
    rownames.each_with_index.map{ |row,i|
      rh = {}
      colnames.map{ |col|
        rh[col] = x.payload[col].to_a[i].to_f
      }
      h[var]["rows"][row] = rh
    }

    h
  end

  def triples_for(h)
    statements = []
    base_n = RDF::Node.new
    attr_n = RDF::Node.new
    vocab = RDF::Vocabulary.new('http://www.placeholder.com/rqtl#')
    base_uri = RDF::URI.new('http://www.placeholder.com/')
    var = h.keys.first

    statements << RDF::Statement.new(base_n, RDF::DC.title, RDF::Literal.new(var))
    statements << RDF::Statement.new(base_n, vocab.attributes, attr_n)

    h[var]["attr"].map{ |k,v| statements << RDF::Statement.new(attr_n, vocab[k], RDF::Literal.new(v)) }

    h[var]["rows"].map{ |k,v|

      row_uri = base_uri.join("row#{k}")
      statements << RDF::Statement.new(row_uri, vocab.row_of, base_n)
      statements << RDF::Statement.new(row_uri, RDF::DC.title, k)
      v.map { |j,u|
        statements << RDF::Statement.new(row_uri, vocab[j], RDF::Literal.new(u))
      }
    }

    statements
  end

  def load_statements(statements)
    repo = RDF::FourStore::Repository.new("http://localhost:#{@port_4s}")
    statements.each{|s| repo.insert(s)}
  end

  def to_store(var)
    load_statements(triples_for(dump_mr(var)))
  end

  def vars
    @R.eval("ls()").payload
  end

end