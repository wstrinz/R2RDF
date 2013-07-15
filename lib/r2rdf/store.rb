module R2RDF
  # handles connection and messaging to/from the triple store
  class Store
    def defaults
	    {
	      type: :fourstore,
	      url: "http://localhost:8080" #TODO port etc should eventually be extracted from URI if given
	    }
	  end

	  def add(file,graph)
	  	if @options[:type] == :graph
	  		throw "please provide an RDF::Graph" unless graph.is_a? RDF::Graph
	  		graph.load(file)
	  		graph
	  	elsif @options[:type] == :fourstore
		  	`curl --data-urlencode data@#{file} -d 'graph=http%3A%2F%2Frqtl.org%2F#{graph}' -d 'mime-type=application/x-turtle' #{@options[:url]}/data/`
		  end
	  end

	  def add_all(dir, graph, pattern=nil)
	  	pattern = /.+\.ttl/ if pattern == :turtle || pattern == :ttl 

	  	files = Dir.entries(dir) - %w(. ..)
	  	files = files.grep(pattern) if pattern.is_a? Regexp
	  	nfiles = files.size
			n = 0
			files.each{|file| puts file + " #{n+=1}/#{nfiles} files"; puts add(file,graph)}
	  end

    def initialize(options={})
      @options = defaults.merge(options)
    end

    def connection
      @connection ||= new_connection
    end

    def new_connection
      case @options[:type]
      when :fourstore
        @repo = RDF::FourStore::Repository.new("#{@options[:url]}/")
      end
    end

   	def load_string(string)
   		
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


    def clear
    	@repo.clear_statements
    end

    def load_string
      case options[:type]
      when :fourstore

      end
    end

    def load(object, include_prefixes=true)
      if object.is_a? RDF::Statement
      	load_statement(object)
      # elsif object.is_a? String
        
      else
        puts "Don't know how to load objects of type #{object.class}"
      end
    end
  end
end
