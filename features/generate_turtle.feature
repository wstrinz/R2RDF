Feature: generate RDF

	In order to test the generators
	I want to be able to create turtle strings from various objects

	Scenario: generate turtle RDF from a Dataframe
		Given a Dataframe generator
		When I provide an R dataframe and the label "mr"
		Then it should generate a turtle string containing a "qb:dataSet"