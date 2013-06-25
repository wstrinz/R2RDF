require 'sparql'
require 'sparql/client'
require 'rdf/turtle'

module R2RDF
  module Rbuilder

    def framestring(name,vectors)
      framestr = "#{name} = data.frame("
      vectors.map{ |k,v| framestr << k + '=' + k +','}
      framestr[-1] = ')'
      framestr
    end

    def create_dataframe(name, connection, rows, vectors)
      connection.assign('rows', rows)
      vectors.map{ |k,v| 
        connection.assign(k,v) 
      }
      connection.eval(framestring(name,vectors))
      connection.eval("row.names(#{name}) <- rows")
      connection.eval(name)
    end
  end

  class Builder
    include R2RDF::Rbuilder

    def get_vectors(variable_name, helper, repo)
      column_names = helper.get_ary(helper.property_names(variable_name), repo).flatten.map{|n| n.gsub('Component Spec for ','')}
      vectors = {}
      column_names.map{|n| 
        vectors[n] = helper.get_ary(helper.property_values(variable_name,n),repo,'to_f').flatten unless n == "Row"
      }
      vectors
    end

    def from_turtle(turtle_file,variable_name=nil)
      unless variable_name
        puts "no variable specified. Simple inference coming soon"
        return
      end
      repo = RDF::Repository.load(turtle_file)
      client = R2RDF::Client.new
      query = R2RDF::QueryHelper.new
      rows = query.get_ary(query.row_names(variable_name), repo).flatten
      create_dataframe(variable_name, client.R, rows, get_vectors(variable_name, query, repo))
    end

    def from_store(store_uri,variable)

    end

  end
end