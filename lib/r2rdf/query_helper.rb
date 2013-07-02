require 'rdf'
require 'sparql'
module R2RDF
  #.gsub(/^\s+/,'')
  module Query
    def vocabulary
      {
        base: RDF::Vocabulary.new('<http://www.rqtl.org/ns/#>'),
        qb:   RDF::Vocabulary.new("http://purl.org/linked-data/cube#"),
        rdf:  RDF::Vocabulary.new('http://www.w3.org/1999/02/22-rdf-syntax-ns#'),
        rdfs: RDF::Vocabulary.new('http://www.w3.org/2000/01/rdf-schema#'),
        prop: RDF::Vocabulary.new('http://www.rqtl.org/dc/properties/'),
        cs:   RDF::Vocabulary.new('http://www.rqtl.org/dc/cs')
      }
    end

    def get_ary(response,method='to_s')
      response.map{|solution|
        solution.to_a.map{|entry|
          if entry.last.respond_to? method
	          entry.last.send(method)
	        else
	        	entry.last.to_s
	        end
        }
      }
    end

    def execute(query,repo)
      SPARQL.execute(query,repo)
    end

    def prefixes
      <<-EOF
PREFIX ns:     <http://www.rqtl.org/ns/#> 
PREFIX qb:   <http://purl.org/linked-data/cube#> 
PREFIX rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> 
PREFIX prop: <http://www.rqtl.org/dc/properties/> 
PREFIX cs:   <http://www.rqtl.org/dc/cs/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#> 

      EOF
    end

    def property_values(var, property)
      str = prefixes
      str << <<-EOS
SELECT ?val WHERE {
  ?obs qb:dataSet ns:dataset-#{var} ;
      prop:#{property} ?val ;
}
      EOS
      str
    end

    def row_names(var)
      str = prefixes
      str << <<-EOS
SELECT ?label WHERE {
  ?obs qb:dataSet ns:dataset-#{var} ;
       prop:refRow ?row .
  ?row skos:prefLabel ?label .
}
      EOS
    end

    # Currently will say "___ Component", needs further parsing
    def property_names(var)
      str = prefixes
      str << <<-EOS
SELECT DISTINCT ?label WHERE {
  ns:dsd-#{var} qb:component ?c .
  ?c rdfs:label ?label
}
      EOS
    end

  end

  class QueryHelper
    include R2RDF::Query
  end  
end