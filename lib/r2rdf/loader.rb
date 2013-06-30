# This is temporary, just to help w/ development so I don't have to rewrite r2rdf.rb to be
# a standard gem base yet. Also load s the files instead of require for easy reloading

load File.dirname(__FILE__) + '/data_cube.rb'
load File.dirname(__FILE__) + '/generators/dataframe.rb'
load File.dirname(__FILE__) + '/query_helper.rb'
load File.dirname(__FILE__) + '/r_client.rb'
load File.dirname(__FILE__) + '/r_builder.rb'