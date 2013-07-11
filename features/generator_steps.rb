require_relative '../lib/r2rdf/loader.rb'

Given /^a (.*) generator$/ do |generator|
	@generator = R2RDF::Generators.const_get(generator).new
end

When /^I ask for its methods$/ do
	@methods = @generator.methods
end

When /^I provide an R (.*) and the label "(.*?)"$/ do |type, label|
	if type == "dataframe"
		r = Rserve::Connection.new
		r.eval <<-EOF
			library(qtl)
			data(listeria)
			mr = scanone(listeria,method="mr")
EOF
		rexp = r.eval 'mr'
		@attr = rexp,label
	else
		raise "Unknown object #{type}"
	end

end

Then /^I should have access to a (.*) method$/ do |method|
	@methods.include?(method).should == true
end

Then /^I should be able to call its (.*) method$/ do |method|
	@generator.methods.include?(:"#{method}").should == true
end

Then /^it should generate a turtle string containing a "(.*?)"$/ do |search|
	str = @generator.send :generate_n3, *@attr
	str[search].should_not be nil
end