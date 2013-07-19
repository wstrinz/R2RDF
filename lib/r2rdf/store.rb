module R2RDF
  # handles connection and messaging to/from the triple store
  class Store
  	include R2RDF::Query
    def defaults
	    {
	      type: :fourstore,
	      url: "http://localhost:8080" #TODO port etc should eventually be extracted from URI if given
	    }
	  end

	  def add(file,graph)
	  	if @options[:type] == :graph
	  		throw "please provide an RDF::Repository" unless graph.is_a? RDF::Repository
	  		graph.load(file)
	  		@store = graph
	  		@store
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

    def query(string)
    	# execute(string, )
			if @options[:type] == :graph
				execute(string, @store, :graph)
			elsif @options[:type] == :fourstore
				execute(string, @options[:url], :fourstore)
		  end
    end

   	def load_string(string)
			#write to temp file and load   		
   	end
  end
end
