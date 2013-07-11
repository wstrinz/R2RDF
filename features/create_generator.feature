Feature: create generators

	In order to do a basic cucumber test
	As a person with a keyboard
	I want to create a generator for CSV

	Scenario: create a Dataframe generator
		Given a Dataframe generator
		Then I should have access to its generate_n3 method

	Scenario: create a CSV generator
		Given a CSV generator
		Then I should have access to its generate_n3 method	

	Scenario: create a RMatrix generator
		Given a RMatrix generator
		Then I should have access to its generate_n3 method

	Scenario: create a Cross generator
		Given a Cross generator
		Then I should have access to its generate_n3 method	