module R2RDF
	module Rconnect
		require 'rserve'
		
		def connect(address=nil)
			if address
				Rserve::Connection.new(address)
			else
				Rserve::Connection.new
			end
		end

		def load_workspace(connection,loc=Dir.home,file=".RData")
			loc = File.join(loc,file)
			connection.eval "load(\"#{loc}\")"
		end

		def get(connection, instruction)
			connection.eval instruction
		end

		def get_vars(connection)
			connection.eval("ls()")
		end
	end 

	class Client
		include R2RDF::Rconnect
    attr :R
    
		def initialize(auto=true)
      @R = connect
			load_ws if auto
			puts "vars: #{vars.payload}" if auto
		end

		def load_ws
			load_workspace(@R)
		end

		def get_var(var)
			get(@R,var)
		end

		def vars
			get_vars(@R)
		end
  end
end
