Feature: create generator

	In order to do a basic cucumber test
	As a person with a keyboard
	I want to create a generator for CSV

	Scenario: create a Dataframe generator
		Given a Dataframe generator
		When I ask for its methods
		Then I should have access to a generate_n3 method

	Scenario: create a CSV generator
		Given a CSV generator
		When I ask for its methods
		Then I should have access to a generate_n3 method	