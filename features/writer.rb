Given(/^a (.*) writer$/) do |type|
  @writer = R2RDF::Writer.const_get(type).new
end

When(/^I call its from_turtle method on the file (.*) with the variable "(.*?)"$/) do |file,var|
  @result = @writer.from_turtle(file,var,var)
end

Then(/^I should receive a \.arff file as a string$/) do
  puts @result.inspect
  # pending # express the regexp above with the code you wish you had
end
