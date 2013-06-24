require 'sparql/client'
require 'rdf/turtle'
module R2RDF
  module Rbuilder
    def create_dataframe(name, connection, rows, vectors)
      c.assign('rows', rows)
      framestr = "#{name} = data.frame("
      vectors.map{ |k,v| 
        c.assign(k,v) 
        framestr << k + '=' + k
      }
      framestr << ')'

      c.eval(framestr)
    end
  end

  class Builder
    include R2RDF::Rbuilder

    def from_turtle(turtle_string)

    end

    def from_store(store_uri,variable)

    end

  end
end