module R2RDF
  # handles connection and messaging to/from the triple store
  class Store
    DEFAULTS = {
      port: 8080,
      type: :fourstore,
      url: "http://localhost" #TODO port etc should eventually be extracted from URI if given
      prefixes: <<-EOF
@prefix : <http://www.rqtl.org/ns/#> .
@prefix qb: <http://purl.org/linked-data/cube#> .
@prefix rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix prop: <http://www.rqtl.org/dc/properties/> .
@prefix cs: <http://www.rqtl.org/dc/cs/> .

      EOF
    }

    def initialize(options={})
      #NOTE: make sure this works this way
      @options = DEFAULTS.merge(options)
    end

    def connection
      @connection ||= new_connection
    end

    def new_connection
      case @options[:type]
      when :fourstore
        RDF::FourStore::Repository.new("#{@options[:url]}:#{@options[:port]}/")
      end
    end

    #TODO any place these case statements exist should have a check on if the
    #repo conforms to the RDF::Repository interface, instead of calling insert
    #for each one.
    def load_statement(statement)
      case options[:type]
      when :fourstore
        repo.insert(s)
      end
    end

    
    def load_string
      case options[:type]
      when :fourstore

      end
    end

    def load(object, include_prefixes=true)
      if object.is_a? RDF::Statement

      elsif object.is_a? String
        
      else
        puts "Don't know how to load objects of type #{object.class}"
      end
    end
  end
end