function rs = pg_fetch(conn, sql, varargin)
%PG_FETCH  Executes a SQL query and imports database data into matlab
%
%   Executes a SQL query with the (i) licensed Mathworks database
%   toolbox or otherwise with (ii) the JDBC driver directly
%   fetches the result and checks the result for
%   errors. Returns the resulting data in a cell array or matrix.
%
%   Syntax:
%   rs = pg_fetch(conn, sql, varargin)
%
%   Input:
%   conn      = Database connection object
%   sql       = SQL query string
%   varargin  = none
%
%   Output:
%   rs        = Fetched data from result set from SQL query
%
%   Example
%   conn = pg_connectdb('someDatabase');
%   pg_fetch(conn, 'SELECT * FROM someTable');
%
%   See also pg_exec, pg_select_struct, pg_insert_struct, pg_update_struct, fetch

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

% $Id: pg_fetch.m 7705 2012-11-20 12:54:51Z boer_g $
% $Date: 2012-11-20 20:54:51 +0800 (Tue, 20 Nov 2012) $
% $Author: boer_g $
% $Revision: 7705 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/postgresql/pg_fetch.m $
% $Keywords: $

%% execute sql query

   prefs = getpref('postgresql');

   % inspect conn object to find out whether is was created with
   % the licensed database toolbox or the JDCB driver directly.
   OPT.database_toolbox = 0;
   try
       if any(strfind(char(conn.Constructor),'mathworks'))
           OPT.database_toolbox = 1;
       end
   end

   if OPT.database_toolbox
       rs = fetch(conn, sql);
   else
      % http://docs.oracle.com/javase/7/docs/api/java/sql/PreparedStatement.html
      pstat = conn.prepareStatement(sql);
      rsraw = pstat.executeQuery();

      count=0;
      rs = {};
      while rsraw.next()
          count=count+1;
          icol = 0;
          while 1
              icol = icol + 1;
              try
                 rs{count,icol}=rsraw.getDouble(icol);
              catch
                 try
                    rs{count,icol}=rsraw.getInt(icol);
                 catch
                    try
                       rs{count,icol}=char(rsraw.getString(icol));
                    catch
                       % reached end
                       % error('datatype not implemented')
                       break
                    end
                 end
              end
          end
      end

      pstat.close();
      rsraw.close();
      
   end

   pg_error(rs);

   if isstruct(prefs) && isfield(prefs, 'verbose') && prefs.verbose
   	disp(sql);
   end
           
   if isstruct(prefs) && isfield(prefs, 'file') && ~isempty(prefs.file)
       fid = fopen(prefs.file, 'a');
       fprintf(fid, '%s\n', sql);
       fclose(fid);
   end
