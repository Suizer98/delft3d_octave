function T = pg_table2struct(conn, table, column_names, varargin)
%PG_TABLE2STRUCT  Load all or some columns of PostgreSQL table into struct
%
%   T = PG_PG_TABLE2STRUCT(conn, table, <column_names>,<limit>) loads
%   all (default) or optionally only the specified column_names (cellstr) 
%   into a struct T. Do not use for large tables, use optional limit argument 
%   as criterion when not to load (default 2e6). Set to Inf to always load.
%
%   Example:
%   
%   pg_table2struct(conn,'my_table')
%   pg_table2struct(conn,'my_table',[])
%   pg_table2struct(conn,'my_table',[],1e7)
%   pg_table2struct(conn,'my_table',{'col1','col2'})
%   pg_table2struct(conn,'my_table',{'col1','col2'},Inf)
%
%   See also postgresql, nc2struct, pg_select_struct

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Tu Delft / Deltares for Building with Nature
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl / gerben.deboer@deltares.nl
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
% $Id: pg_table2struct.m 8373 2013-03-25 15:34:23Z boer_g $
% $Date: 2013-03-25 23:34:23 +0800 (Mon, 25 Mar 2013) $
% $Author: boer_g $
% $Revision: 8373 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/postgresql/pg_table2struct.m $

limit = 2e6; % SQL keyword

if nargin  > 2
   if ~isempty(column_names)
   [nams, typs, siz] = pg_getcolumns(conn,table,column_names);
   else
   [nams, typs, siz] = pg_getcolumns(conn,table);
   end
else   
   [nams, typs, siz] = pg_getcolumns(conn,table);
end

if nargin > 3
   limit = varargin{1};
end

if siz <= limit
   R = pg_select_struct(conn,table,struct([]),nams);
   T = pg_fetch2struct(R,nams,typs);
else
   T = [];
   disp(['table not loaded, table length exceeds limit: ',num2str(limit)])
end
