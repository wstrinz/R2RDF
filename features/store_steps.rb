require_relative '../lib/r2rdf/loader.rb'

Given /a store of type (.*?)$/ do |type|
	@store = R2RDF::Store.new(type: :"#{type}")
end

When /^I call the stores add method with the turtle file (.*?) and an (.*?)$/ do |file,graph|
	graph = Object.const_get(graph).new #rescue graph
	@graph = @store.add(file,graph)
end

When /^I call the stores add method with the turtle file (.*?) the graph name "(.*?)"$/ do |file,graph|
	@graph = @store.add(file,graph)
end


Then /^I should recieve a non-empty graph$/ do
	@graph.is_a?(RDF::Graph).should be true
	@graph.size.should > 0
end

Then /^raise the result$/ do
	raise "got @graph"
end
