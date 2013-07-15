Feature: generate data using ORM
	
	In order to make the generator simpler and more accessible to ruby users
	I want to implement an ORM (OTM? OGM?) to assist creation of datacube objects

	Scenario: generate turtle for a simple object
		Given an ORM::DataCube entitled "cats"
		When I add a "size" dimension
		And I add a "breed" dimension
		And I add a "fluffiness" measure
		And I add the observation {size: "big", breed: "American Shorthair", fluffiness: 100}
		And I add the observation {size: "huge", breed: "Maine Coon", fluffiness: 9001}
		And I add the observation {size: "little", breed: "American Shorthair", fluffiness: 15}
		Then the to_n3 method should return a string

	Scenario: raise error when components are missing

	Scenario: raise error when unknown components are used
