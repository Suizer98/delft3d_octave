function conn = pg_connectdb(db, varargin)
%PG_CONNECTDB  Creates a JDBC connection to a PostgreSQL database with database toolbox
%
%   Creates a JDBC connection to a PostgreSQL database 
%   with the (i) licensed Mathworks database toolbox 
%   or otherwise with (ii) the JDBC driver directly.
%   A JDBC driver should be loaded first, see PG_SETTINGS and README.txt.
%   If a schema is given, this schema is set to the default for the current
%   session.
%
%   Syntax:
%   conn = pg_connectdb(db, <keyword,value>)
%
%   Input:
%   db        = Name of database to connect to
%   keywords  = host    - Hostname of database server    (default: localhost)
%               port    - Port number of database server (default: 5432)
%               user    - Username for database server
%               pass    - Password for database server
%               schema  - Default schema for current session
%
%   Output:
%   conn      = Database connection object
%
%   Example:
%
%    conn = pg_connectdb('someDatabase')
%    conn = pg_connectdb('anotherDatabase','host','posgresql.deltares.nl')
%    conn = pg_connectdb('anotherDatabase','schema','someSchema')
%
%   Example:connecting to the empty database of a virgin local Win32 PostgreSQL 9.1
%
%    conn = pg_connectdb('postgres','user','postgres','pass','MyPassword')
%    conn = pg_connectdb('postgres','user','postgres','pass','MyPassword','schema','public')
%
%   See also database, pg_connectdb_jdbc, pg_exec, pg_fetch, pg_select_struct, pg_insert_struct,
%   pg_update_struct, pg_getpk, pg_getid

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Bas Hoonhout
%       bas.hoonhout@deltares.nl
%
%       Rotterdamseweg 185
%       2629HD Delft
%       Netherlands
%
%   JDBC: Copyright (C) 2012 Deltares for Building with Nature
%       Gerben J. de Boer
%       gerben.deboer@deltares.nl
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 27 Jul 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id: pg_connectdb.m 7705 2012-11-20 12:54:51Z boer_g $
% $Date: 2012-11-20 20:54:51 +0800 (Tue, 20 Nov 2012) $
% $Author: boer_g $
% $Revision: 7705 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/postgresql/pg_connectdb.m $
% $Keywords: $

%% read options

   OPT = struct( ...
    'host',            'localhost', ...
    'port',            5432, ...
    'user',            '', ...
    'pass',            '', ...
    'schema',          '', ...
    'database_toolbox',1);

   if nargin==0;conn = OPT;return;end

   OPT = setproperty(OPT,varargin{:});

%% connect to database

   url    = ['jdbc:postgresql://' OPT.host ':' num2str(OPT.port) '/' db];
   if license('test','database_toolbox') & OPT.database_toolbox
      OPT.database_toolbox = 1;
      conn = database( ...
       db, ...
       OPT.user, ...
       OPT.pass, ...
       'org.postgresql.Driver', ...
       url);
       disp(['PostgreSQL: database_toolbox license used.'])
       message = conn.message;
   else
      props = java.util.Properties;
      props.setProperty('user'    , OPT.user);
      props.setProperty('password', OPT.pass);
      
      driver = org.postgresql.Driver;
      conn   = driver.connect(url, props);
      if isempty(conn)
         message = ['JDBC was not able to connect to ',url];
      else
         message = '';
      end
      disp(['PostgreSQL: database_toolbox license absent, used JDC driver directly. Some features might not work yet.'])
   end

%% display message on error

   if ~isempty(message)
       if pg_settings('check',1)<0
       disp('run PG_Settings first')
       end
       error(message)
   else
       
       % set default schema, if given
       if ~isempty(OPT.schema)
          sqlStr = sprintf('SET search_path TO %s', OPT.schema);
          if OPT.database_toolbox
             exec(conn, sqlStr);
          else

             % http://www.coderanch.com/t/301594/JDBC/databases/Difference-execute-executeQuery-executeUpdate
             % http://docs.oracle.com/javase/7/docs/api/java/sql/PreparedStatement.html
             % executeQuery()  --- This is used generally for reading the content of the database. The output will be in the form of ResultSet. Generally SELECT statement is used.
             % executeUpdate() --- This is generally used for altering the databases. Generally DROP TABLE or DATABASE, INSERT into TABLE, UPDATE TABLE, DELETE from TABLE statements will be used in this. The output will be in the form of int. This int value denotes the number of rows affected by the query.
             % execute()       --- If you dont know which method to be used for executing SQL statements, this method can be used. This will return a boolean. TRUE indicates the result is a ResultSet and FALSE indicates it has the int value which denotes number of rows affected by the query.            
             pstat = conn.prepareStatement(sqlStr);
             rsraw = pstat.executeQuery();
             pstat.close();
             rsraw.close();
             disp(['Schema not implemented yet for JDBC, only for database toolbox.'])
          end
       end
       
   end
