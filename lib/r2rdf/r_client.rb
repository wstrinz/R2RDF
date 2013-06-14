module R2RDF
  class RClient
    def initialize
      @R = RServe::Connection.new
    end

    def vars
      @R.eval("ls()").payload
    end

    def get(var)
      @R.eval(var)
    end
  end
end