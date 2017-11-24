function readschema(filename::String)
    # Read yaml
    io  = open(filename)
    dct = YAML.load(io)
    close(io)
    length(dct) > 1 && error("File $(filename) contains an incorrectly specified schema.")

    # Get schema-level info
    schema = ""
    schema_name = ""
    for (k, v) in dct
        schema_name = k
        schema = v
        break
    end
    schema_descr = schema["description"]

    # Extract tables
    tables = TableSchema[]
    tblschemata = schema["tables"]  # Vector{Dict}, each Dict contains 1 kv pair: tblname => tblschema
    for tblsch in tblschemata
        length(tblsch) > 1 && error("Table schema has more than 1 name.")
        for (tblname, tblschema) in tblsch
            # Extract table description and primary key
            tbl_descr = tblschema["description"]
            primkey   = tblschema["primary_key"]
            primkey   = typeof(primkey) == String ? [Symbol(primkey)] : [Symbol(colname) for colname in primkey]

            # Extract columns
            columns = ColumnSchema[]
            colschemata = tblschema["columns"]  # Vector{Dict}, each Dict contains 1 kv pair: colname => colschema
            for colsch in colschemata
                length(colsch) > 1 && error("Column schema in table $tblname has more than 1 name.")
                for (colname, colschema) in colsch
                    col_descr = colschema["description"]
                    eltyp     = eval(parse(colschema["datatype"]))
                    catgry    = colschema["categorical"]
                    required  = colschema["required"]
                    uniq      = colschema["unique"]
                    validvals = determine_validvalues(colschema["validvalues"])
                    cs        = ColumnSchema(Symbol(colname), col_descr, eltyp, catgry, required, uniq, validvals)
                    push!(columns, cs)
                end
            end

            # Push table schema to result
            ts = TableSchema(Symbol(tblname), tbl_descr, columns, primkey)
            push!(tables, ts)
        end
    end
    Schema(schema_name, schema_descr, tables)
end

#=
function writeschema(filename::String, schema::Schema)
end
=#

##################################33333##3######################################
"Returns: An instance of ColumnSchema.valid_values."
function determine_validvalues(vv)
    vv
end

function determine_validvalues(vv::String)
    ex = parse(vv)
    eval(ex)
end

