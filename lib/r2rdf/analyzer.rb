module R2RDF
  
  #handles analysis of R expression to extract properties and recognize potential
  #ambiguity
  class Analyzer

    #extracts the properties (class, attribute information, row names, ...)
    def properties_of(expression)

    end

    #convert all the data to a hash. Could cause memory problems but helps debug at least
    #probably just monkey-patch rserve-client with a to_h method, or move this into another class.
    def hash_for(expression)

    end
  end
end