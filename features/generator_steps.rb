require_relative '../lib/r2rdf/loader.rb'
require_relative '../lib/r2rdf/generators/csv.rb'
Given /^a (.*) generator$/ do |arg1|
	@generator = R2RDF::Generators::CSV.new
end

When /^I ask for its methods$/ do
	@methods = @generator.methods
end

Then /^I should find they are there$/ do
	@methods != nil
end