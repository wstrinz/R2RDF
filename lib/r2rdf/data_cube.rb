module R2RDF
  # used to generate data cube observations, data structure definitions, etc
  class DataCube

    def initialize(variable_name="DC#{Time.now.to_i}")
      @var = variable_name
    end

    # def prefixes
    #   @prefixes ||= {
    #     base: "",
    #     components: "cs"
    #   }
    # end

    # def prefixes=(prefixes)
    #   @prefixes = prefixes
    # end

    def data_structure_definition()

    end
  end
end
