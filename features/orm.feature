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

	Scenario: raise error when unknown components are used
		Given an ORM::DataCube entitled "animals"
		When I add a "robustness" dimension
		And I add a "species" measure
		And I add the observation {species: "Balaenoptera musculus", robustness: 25}
		And I add the observation {species: "Hypsibius dujardini", robustness: 9001}
		Then the to_n3 method should return a string
		When I add the observation {species: "Deinococcus radiodurans", robustness: 350, chunkiness: 9}
		Then the to_n3 method should raise error UnknownProperty ["chunkiness"]

	Scenario: raise error when components are missing
		Given an ORM::DataCube entitled "animals"
		When I add a "robustness" dimension
		And I add a "species" measure
		And I add the observation {species: "Felis catus"}
		Then the to_n3 method should raise error MissingValues for ["robustness"]

	Scenario: raise error when components are missing
		Given an ORM::DataCube entitled "animals" with the following options: 
		| key | value |
		| :validate_each | true |
		When I add a "robustness" dimension
		And I add a "species" measure
		Then adding the observation {species: "big"} should raise error MissingValues for ["robustness"]
