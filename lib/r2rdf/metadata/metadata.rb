module R2RDF
	module Metadata
		def defaults
		{
			encode_nulls: false,
			base_url: "http://www.rqtl.org",
		}
		end

		def basic(fields, options={} )
			fields[:var] = sanitize([fields[:var]]).first
			options = defaults().merge(options)
			str = <<-EOF.unindent
			ns:dataset-#{fields[:var]} rdfs:label "#{fields[:title]}";
				dct:title "#{fields[:title]}";
				dct:creator "#{fields[:creator]}";
				rdfs:comment "#{fields[:description]}";
				dct:description "#{fields[:description]}";
				dct:issued "#{fields[:date]}"^^xsd:date;
			EOF

			end_str = ""

			if fields[:subject]
				str << "\tdct:subject \n"
				fields[:subject].each{|subject| str << "\t\t" + subject + ",\n" }
				str[-2] = ";"
			end

			if fields[:publishers]
				fields[:publishers].map{|publisher|
					raise "No URI for publisher #{publisher}" unless publisher[:uri]
					raise "No label for publisher #{publisher}" unless publisher[:label]
					str << "\tdct:publisher <#{publisher[:uri]}> ;\n"
					end_str << "<#{publisher[:uri]}> a org:Organization, foaf:Agent;\n\trdfs:label \"#{publisher[:label]}\" .\n\n"
				}
				str[-2] = '.'
			end

			str + "\n" + end_str
		end

		def provenance(fields, options={})
			var = sanitize([fields[:var]]).first
			software = fields[:software]
			process = fields[:process]
			object_type = fields[:object]

		end
	end
end