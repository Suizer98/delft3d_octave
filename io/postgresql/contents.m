%Toolbox for <a href="http://www.postgresql.org/">PostgreSQL</a> relational database management system
%
% This PostgreSQL toolbox uses:
% (i) by default the licensed Mathworks database toolbox 
% (ii) otherwise the JDBC4 driver is used directly without the need 
% for the licensed Mathworks database toolbox altogether. You can enforce usage 
% of JDBC4 over Mathworks toolbox with keyword 'database_toolbox' in PG_CONNECTDB.
%
% START:
% pg_settings                    - Load toolbox for JDBC connection to a PostgreSQL database
% pg_connectdb                   - Creates a JDBC connection to a PostgreSQL database
% 
% Highest-level READ,INSPECT:
% pg_dump                        - Display overview of tables, columns and sizes of database schema
% pg_gettables                   - List all tables in current database
% pg_getcolumns                  - List all column_names, their data_types and length from a given table
% pg_table2struct                - Load all or some columns of PostgreSQL table into struct
%
% High-level READ,INSPECT:
% pg_getpk                       - Retrieve name of primary key for given table
% pg_getid                       - Retrieves primary key value for specific record in given table
% pg_getids                      - Retrieves primary key value for many records in given table
% pg_select_struct               - Selects records from a table based on a structure
% pg_fetch2struct                - parse cell from pg_fetch or pg_select_struct into struct 
% pg_stationTimeSeries_tutorial  - tutorial for postgresql toolbox with simple scalar time series
% pg_building_with_nature_zandmotor_tutorial - extract all tables with all columns into one struct
%
% WRITE,CHANGE:
% pg_insert_struct               - Inserts a structure into a table
% pg_update_struct               - Updates a record in a table based on a structure
% pg_upsert_struct               - Updates existing records or inserts it otherwise
% pg_cleartable                  - Deletes all contents from a table
%
% <a href="http://www.postgis.net/">PostGIS</a> geospatial data (<a href="http://www.opengeospatial.org/standards/sfs">OGC Simple Feature Access</a>):
% PG_READ_EWKB                   - Read WKB (Well Known Binary) string into WKT struct 
% PG_READ_EWKT                   - Read WKT (Well Known Text)   string into WKT struct     
% PG_WRITE_EWKT                  - Write WKT struct to WKT string
% PG_WRITE_EWKB                  - Write WKT struct to WKB string
% PG_READ_SHP                    - Read shapefile into WKT struct  
%
% Low-level SQL query: for explanation see <a href="http://www.postgresql.org/docs/current/static/sql.html">SQL primer</a> 
% pg_quote                       - Wrap identifiers (table, column names) in " quotes to enable mixed upper/lower case
% pg_query                       - Builts a SQL query string from structures
% pg_exec                        - Executes a SQL query
% pg_fetch                       - Executes a SQL query and fetches the result
% pg_fetch_struct                - Executes a SQL query and fetches the result as struct
% pg_error                       - Checks a SQL query result for errors
% pg_value2sql                   - Makes a cell array of arbitrary values suitable for the use in an SQL query
% pg_datenum                     - conversion between Matlab datenumbers and PG datetime
% pg_test                        - unit test for postgresql
%
%See also: TO BE REPLACED BY jdb, LICENSED database, save, load, netcdf

% some possibly useful links

% http://www.cybertec.at/postgresql_produkte/pg_matlab-matlab-postgresql-integration/
% http://www.mathworks.com/matlabcentral/fileexchange/3027
% http://www-css.fnal.gov/dsg/external/freeware/mysql-vs-pgsql.html
% http://www.serverwatch.com/trends/article.php/3883441/Top-10-Enterprise-Database-Systems-to-Consider.htm
% http://philip.greenspun.com/panda/
% http://humdoi.mae.ufl.edu/~prabirbarooah/Research/instructions.html
% http://www.tech.plym.ac.uk/spmc/links/matlab/matlab_database.html
% http://www.roseindia.net/tutorial/java/jdbc/index.html