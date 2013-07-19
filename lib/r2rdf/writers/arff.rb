module R2RDF
	module Writer
	 	class ARFF
		include R2RDF::Query
		include R2RDF::Analyzer

 		  def from_turtle(turtle_file, dataset_name=nil, file_name=nil, verbose=false)
 		    unless dataset_name && file_name
 		      puts "no variable specified. Simple inference coming soon" if verbose
 		      return
 		    end
 		    puts "loading #{turtle_file}" if verbose
 		    repo = RDF::Repository.load(turtle_file)
 		    puts "loaded #{repo.size} statements into temporary repo" if verbose
 		    
 		    dims = get_ary(execute_from_file("dimensions.rq",repo,:graph)).flatten
 		    meas = get_ary(execute_from_file("measures.rq",repo,:graph)).flatten
 		    obs = observation_hash(execute_from_file("observations.rq",repo,:graph), true)
 		    types = {}
 		    (dims | meas).map{|component| types[component] = recommend_range(obs.map{|o| o[1][component]})}
 		    types = types.map{|prop,type|
 		    	case type
 		    	when "xsd:int"
 		    		"integer"
 		    	when "xsd:double"
 		    		"real"
 		    	when :coded
 		    		"string"
 		    	end
 		    }
 		    types
 		  end

 		  def from_store(endpoint_url,connection,variable_in=nil, variable_out=nil, verbose=true, save=true)
 		  	unless variable_in && variable_out
 		  	  puts "no variable specified. Simple inference coming soon" if verbose
 		  	  return
 		  	end
 		  	puts "connecting to endpoint at #{endpoint_url}" if verbose
 		  	sparql = SPARQL::Client.new(endpoint_url)
 		    query = R2RDF::QueryHelper.new

 		    rows = query.get_ary(sparql.query(query.row_names(variable_in))).flatten

 		  end
	  end
	end
end
