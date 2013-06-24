require 'rdf'
module R2RDF
  module Query
    def vocabulary
      {
        qb: RDF::Vocabulary.new()
      }
    end
  end

  class QueryHelper

  end  
end