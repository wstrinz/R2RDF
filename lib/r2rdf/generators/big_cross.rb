module R2RDF
	module Generators
		class BigCross
			include R2RDF::Generator

			def generate_n3(client, var, outfile, options={})
				meas = measures(client,var,options)
				dim = dimensions(client,var,options)
				codes = codes(client,var,options)
				n_individuals = client.eval("#{var}$pheno[[1]]").to_ruby.size
				
				#write structure
				open(outfile,'w'){|f| f.write structure(client,var,options)}
				
				
				geno_chr = client.eval("#{var}$geno$'1'")

				#write observations
				n_individuals.times{|indi|
					puts "#{indi}/#{n_individuals}"
					obs_data = observation_data(client,var,'1',indi,geno_chr,options)
					labels = labels_for(obs_data,'1',indi)
					open(outfile,'a'){|f| observations(meas,dim,codes,obs_data,labels,var,options).map{|obs| f.write obs}}
				}
				#generate(measures, dimensions, codes, observation_data, observation_labels, var, options)
			end

			def structure(client,var,options={})
				meas = measures(client,var,options)
				dim = dimensions(client,var,options)
				codes = codes(client,var,options)

				str = prefixes()
				str << data_structure_definition(meas,var,options)
				str << dataset(var,options)
    		component_specifications(meas, dim, var, options).map{ |c| str << c }
				measure_properties(meas,var,options).map{|m| str << m}
				
				str
			end

			def measures(client, var, options={})
				pheno_names = client.eval("names(#{var}$pheno)").to_ruby
				pheno_names | ["genotype","markerpos","marker"]
				# measure_properties(measures,var,options)
			end

			def dimensions(client, var, options={})
				# dimension_properties([""],var)
				[]
			end

			def codes(client, var, options={})
				[]				
			end

			def labels_for(data,chr,individual,options={})
				labels=(((data.first.last.size*individual)+1)..(data.first.last.size*(individual+1))).to_a.map(&:to_s)
				labels.map{|l| l.insert(0,"#{chr}_")}
				labels
			end

			def observation_data(client, var, chr, row_individ, geno_chr, options={})
				data = {}
				entries_per_individual = client.eval("#{var}$geno$'#{chr}'").payload["map"].payload.size
				# geno_chr = client.eval("#{var}$geno$'#{chr}'")
				# n_individuals = client.eval("#{var}$pheno[[1]]").to_ruby.size
				# entries_per_individual = @rexp.payload["geno"].payload[row_individ].payload["map"].payload.size * @rexp.payload["geno"].payload.names.size
				data["chr"] = []
				data["genotype"] = []
				data["individual"] = []
				data["marker"] = []
				data["markerpos"] = []
				client.eval("names(#{var}$pheno)").to_ruby.map{|name|
					data[name] = []
				}
				# n_individuals.times{|row_individ|
					# puts "#{row_individ}/#{n_individuals}"
				data["individual"] << (1..entries_per_individual).to_a.fill(row_individ)
				client.eval("names(#{var}$pheno)").to_ruby.map{|name|
					data[name] << (1..entries_per_individual).to_a.fill(client.eval("#{var}$pheno").payload[name].to_ruby[row_individ])
				}
				# @rexp.payload["geno"].payload.names.map { |chr|
				num_markers = geno_chr.payload.first.to_ruby.column_size
				data["chr"] << (1..num_markers).to_a.fill(chr)
				data["genotype"] << geno_chr.payload["data"].to_ruby.row(row_individ).to_a
				data["marker"] << client.eval("names(#{var}$geno$'#{chr}'$map)").payload
				data["markerpos"] << geno_chr.payload["map"].to_a
					# }
				# }
				data.map{|k,v| v.flatten!}
				data
			end

			def num_individuals(client, var, options={})
				client.eval("#{var}$pheno").payload.first.to_ruby.size
			end


		end
	end
end