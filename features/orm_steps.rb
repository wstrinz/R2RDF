require_relative '../lib/r2rdf/loader.rb'

# Given /a store of type (.*?)$/ do |type|
# 	@store = R2RDF::Store.new(type: :"#{type}")
# end

# When /^I call the stores add method with the turtle file (.*?) and an (.*?)$/ do |file,graph|
# 	graph = Object.const_get(graph).new #rescue graph
# 	@graph = @store.add(file,graph)
# end

# When /^I call the stores add method with the turtle file (.*?) the graph name "(.*?)"$/ do |file,graph|
# 	@graph = @store.add(file,graph)
# end


# Then /^I should recieve a non-empty graph$/ do
# 	@graph.is_a?(RDF::Graph).should be true
# 	@graph.size.should > 0
# end

# Then /^raise the result$/ do
# 	raise "got @graph"
# end


Given /^an ORM::DataCube entitled "(.*?)"$/ do |name|
	@cube = R2RDF::ORM::DataCube.new(name: name)
end

When /^I add a "(.*?)" dimension$/ do |dim|
	@cube.add_dimension(dim)
end

And /^I add a "(.*?)" measure$/ do |meas|
	@cube.add_measure(meas)
end

And /^I add the observation \{(.*)\}$/ do |obs|
	data = {}
	obs.split(',').map{|entry| data[entry.chomp.strip.split(':')[0].to_s] = eval(entry.chomp.strip.split(':')[1])}
	@cube.add_observation(data)
end

Then /^the to_n3 method should return a string$/ do
	@cube.to_n3.is_a?(String).should be true
end

