function conn = jdb_connectdb(db, varargin)
% Creates a JDBC connection to a PostgreSQL or Oracle database with database toolbox
%
%   Creates a JDBC connection to a PostgreSQL database 
%   with the (i) licensed Mathworks database toolbox 
%   or otherwise with (ii) the JDBC driver directly.
%   A JDBC driver should be loaded first, see PG_SETTINGS and README.txt.
%   If a schema is given, this schema is set to the default for the current
%   session.
%
%   Syntax:
%   conn = jdb_connectdb(db, <keyword,value>)
%
%   Input:
%   db        = Name of database to connect to
%   keywords  = host    - Hostname of database server    (default: localhost)
%               port    - Port number of database server (default: 5432)
%               user    - Username for database server
%               pass    - Password for database server
%               schema  - Default schema for current session
%      database_toolbox - use Matlab database toolbox if license (default) or JDBC
%
%   Output:
%   conn      = Database connection object
%
%   Example:
%
%    conn = jdb_connectdb('someDatabase')
%    conn = jdb_connectdb('anotherDatabase','host','posgresql.deltares.nl')
%    conn = jdb_connectdb('anotherDatabase','schema','someSchema')
%
%   Example:connecting to the empty database of a virgin local Win32 PostgreSQL 9.1
%
%    conn = jdb_connectdb('postgres','user','postgres','pass','MyPassword')
%    conn = jdb_connectdb('postgres','user','postgres','pass','MyPassword','schema','public')
%
%   See also database, jdb_settings, jdb_connectdb_jdbc, jdb_exec,
%   jdb_fetch, jdb_select_struct, jdb_insert_struct, jdb_update_struct,
%   jdb_getpk, jdb_getid 

%% Copyright notice: see below

%% read options
   OPT = struct( ...
    'dbtype',           'postgresql',...
    'host',             'localhost', ...
    'port',             5432, ...
    'user',             '', ...
    'pass',             '', ...
    'schema',           '', ...
    'SSLmode',          '', ...
    'database_toolbox', 1, ...
    'quiet'           , 0);

   if nargin==0;conn = OPT;return;end

   OPT = setproperty(OPT,varargin,'onExtraField','silentIgnore');

%% connect to database
switch lower(OPT.dbtype) % lower(db)
    case 'postgresql'
        url    = ['jdbc:postgresql://' OPT.host ':' num2str(OPT.port) '/' db];   
        driver = org.postgresql.Driver;
    case 'oracle'
        % http://razorsql.com/articles/oracle_jdbc_connect.html
        url    = ['jdbc:oracle:thin:@//' OPT.host ':' num2str(OPT.port) '/' db];        
        driver  = oracle.jdbc.driver.OracleDriver;
    case 'access'
        % "jdbc:ucanaccess://<mdb or accdb file path>",user, password)
        url    = ['jdbc:ucanaccess://' db ]; %';memory=false;showschema=true;sysschema=true'];        
        driver = net.ucanaccess.jdbc.UcanaccessDriver ; %net.ucanaccess.jdbc.UcanaccessDriver;
    otherwise
        error('Unknown dbtype: %s',OPT.dbtype)
end

   if ~isdeployed && license('test','database_toolbox') && OPT.database_toolbox
      OPT.database_toolbox = 1;
      conn = database( ...
       db, ...
       OPT.user, ...
       OPT.pass, ...
       'org.postgresql.Driver', ...
       url);
       if ~OPT.quiet
           disp([db,': database_toolbox license used.'])
       end
       message = conn.message;
   else
      OPT.database_toolbox = 0;
      props = java.util.Properties;
      props.setProperty('user'    , OPT.user);
      props.setProperty('password', OPT.pass);
      
      if ~isempty(OPT.SSLmode)
          props.setProperty('sslmode', OPT.SSLmode);          
      end
      
      conn   = driver.connect(url, props);
      if isempty(conn)
         message = [db ': JDBC was not able to connect to ',url];
      else
         message = '';
      end
      if ~OPT.quiet
        disp([db,': database_toolbox license absent, used JDC driver directly. Some features might not work yet.'])
      end
   end
  
%% display message on error
   if ~isempty(message)
      if jdb_settings('check',1)<0
        disp('run jdb_settings first')
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
             disp('Schema not implemented yet for JDBC, only for database toolbox.')
             pstat = conn.prepareStatement(sqlStr);
             rsraw = pstat.executeQuery();
             pstat.close();
             rsraw.close();
          end
       end
       
   end
   
     
%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Bas Hoonhout
%   Copyright (C) 2014 Van Oord
%       R.A. van der Hout
%
%       bas.hoonhout@deltares.nl
%       ronald.vanderhout@vanoord.com
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

% $Id: jdb_connectdb.m 16426 2020-06-18 08:49:23Z wcn.vessies.x $
% $Date: 2020-06-18 16:49:23 +0800 (Thu, 18 Jun 2020) $
% $Author: wcn.vessies.x $
% $Revision: 16426 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/jdb/jdb_connectdb.m $
% $Keywords: $

