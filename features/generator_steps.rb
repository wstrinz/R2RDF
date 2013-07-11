require_relative '../lib/r2rdf/loader.rb'
require_relative '../lib/r2rdf/generators/csv.rb'
Given /^a (.*) generator$/ do |generator|
	@generator = R2RDF::Generators.const_get(generator).new
end

When /^I ask for its methods$/ do
	@methods = @generator.methods
end

Then /^I should have access to a (.*) method$/ do |method|
	@methods.include? method
end