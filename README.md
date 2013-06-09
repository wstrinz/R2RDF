Usage: `java -jar QTL2RDF.jar variable [directory] [4store_port] [output]`  
Takes `variable` from R session in `directory`, converts to RDF triples. Stores the result to 4store at `4store_port`, or prints to stdout if `output` is non-nil

**Building jar File**  

    gem install warbler  
    bundle install  
    warble  
    

**Running with Ruby**  
Uncomment first line of `bin/dumpvar.rb`  
`ruby dumpvar.rb`