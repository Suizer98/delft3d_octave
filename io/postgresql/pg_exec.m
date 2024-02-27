function rs = pg_exec(conn, sql, varargin)
%PG_EXEC  Executes a SQL query and returns a cursor object
%
%   Executes a SQL query with the (i) licensed Mathworks database
%   toolbox or otherwise with (ii) the JDBC driver directly
%   and checks the result for errors. Returns the result set.
%
%   Syntax:
%   rs = pg_exec(conn, sql, varargin)
%
%   Input:
%   conn      = Database connection object created with PG_CONNECTDB
%   sql       = SQL query string
%   varargin  = none
%
%   Output:
%   rs        = Result set from SQL query
%
%   Example
%   conn = pg_connectdb('someDatabase');
%   pg_exec(conn, 'DELETE FROM someTable WHERE someColumn = 1');
%
%   See also PG_CONNECTDB, pg_fetch, pg_select_struct, pg_insert_struct, pg_update_struct, exec

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Bas Hoonhout
%
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

% $Id: pg_exec.m 7705 2012-11-20 12:54:51Z boer_g $
% $Date: 2012-11-20 20:54:51 +0800 (Tue, 20 Nov 2012) $
% $Author: boer_g $
% $Revision: 7705 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/postgresql/pg_exec.m $
% $Keywords: $

%% execute sql query

prefs = getpref('postgresql');

if ~isstruct(prefs) || ~isfield(prefs, 'passive') || ~prefs.passive

   % inspect conn object to find out whether is was created with
   % the licensed database toolbox or the JDCB driver directly.
   OPT.database_toolbox = 0;
   try
       if any(strfind(char(conn.Constructor),'mathworks'))
           OPT.database_toolbox = 1;
       end
   end
   
   if any(strfind('--',strtok(sql)))
      % JDBC fails for comments because nothing is returned
   else
      if OPT.database_toolbox
         rs = exec(conn, sql);
      else
         % http://www.coderanch.com/t/301594/JDBC/databases/Difference-execute-executeQuery-executeUpdate
         % http://docs.oracle.com/javase/7/docs/api/java/sql/PreparedStatement.html
         % executeQuery()  --- This is used generally for reading the content of the database. The output will be in the form of ResultSet. Generally SELECT statement is used.
         % executeUpdate() --- This is generally used for altering the databases. Generally DROP TABLE or DATABASE, INSERT into TABLE, UPDATE TABLE, DELETE from TABLE statements will be used in this. The output will be in the form of int. This int value denotes the number of rows affected by the query.
         % execute()       --- If you dont know which method to be used for executing SQL statements, this method can be used. This will return a boolean. TRUE indicates the result is a ResultSet and FALSE indicates it has the int value which denotes number of rows affected by the query.            
         pstat = conn.prepareStatement(sql);
         if any(strfind('CREATE ALTER DROP INSERT UPDATE DELETE',strtok(sql)))
            rs = pstat.executeUpdate();
            %disp(['executeUpdate : ',sql])
            %pausedisp
         else
            rs = pstat.executeQuery()
            rs.close();
            %disp(['executeQuery  : ',sql])
            %pausedisp
         end
         pstat.close();
      end
      pg_error(rs);
   end
end

if isstruct(prefs) && isfield(prefs, 'verbose') && prefs.verbose
	disp(sql);
end
        
if isstruct(prefs) && isfield(prefs, 'file') && ~isempty(prefs.file)
    fid = fopen(prefs.file, 'a');
    fprintf(fid, '%s\n', sql);
    fclose(fid);
end
