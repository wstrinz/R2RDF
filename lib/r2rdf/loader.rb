# This is temporary, just to help w/ development so I don't have to rewrite r2rdf.rb to be
# a standard gem base yet. Also load s the files instead of require for easy reloading

def load_folder(folder)
	Dir.foreach(File.dirname(__FILE__) + "/#{folder}") do |file|
		unless file == "." or file == ".."
			load File.dirname(__FILE__) + "/#{folder}/" + file
		end
	end
end

load File.dirname(__FILE__) + '/data_cube.rb'
load File.dirname(__FILE__) + '/query_helper.rb'
load File.dirname(__FILE__) + '/r_client.rb'
load File.dirname(__FILE__) + '/r_builder.rb'
load File.dirname(__FILE__) + '/store.rb'


load_folder('generators')
load_folder('ORM')
# Dir.foreach(File.dirname(__FILE__) + '/generators') do |file|
# 	unless file == "." or file == ".."
# 		load File.dirname(__FILE__) + '/generators/' + file
# 	end
# end