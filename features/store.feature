Feature: load triples into a store

	In order to query and share data
	I want to be able load the output into a variety of store 

	Scenario: Use an RDF::Graph to store data
		Given a store of type graph
		When I call the stores add method with the turtle file spec/turtle/reference and an RDF::Graph
		Then I should recieve a non-empty graph

	Scenario: Use 4store to store data
		Given a store of type fourstore
		When I call the stores add method with the turtle file spec/turtle/reference the graph name "test"
		Then I should receive an info string