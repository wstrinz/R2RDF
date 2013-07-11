Feature: create generator

	In order to do a basic cucumber test
	As a person with a keyboard
	I want to create a generator for CSV

	Scenario: create generator
		Given a csv generator
		When I ask for its methods
		Then I should find they are there	