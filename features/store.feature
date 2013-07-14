Feature: load triples into a store

	In order to query and share data
	I want to be able load the output into a variety of store 

	Scenario: Use a store to wrap the RDF::Graph
		Given a turtle file spec/turtle/reference and a store of type graph
		When I call the store's add method
		Then I should recieve a non-empty graph