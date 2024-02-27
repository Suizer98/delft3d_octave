function T = jdb_table2struct(conn, table, owner, column_names, varargin)
%JDB_TABLE2STRUCT  Load all or some columns of table into struct
%
%   T = JDB_TABLE2STRUCT(conn, table, owner, <column_names>, <limit>) loads
%   all (default) or optionally only the specified column_names (cellstr) 
%   into a struct T. Do not use for large tables, use optional limit argument 
%   as criterion when not to load (default 2e6). Set to Inf to always load.
%
%   This jdb toolbox was first created as a pg (postgresql) toolbox
%   The toolbox was then modified for use with Oracle as wel.
%
%   Example:
%   
%   jdb_table2struct(conn,'my_table',[])
%   jdb_table2struct(conn,'my_table',[],1e7)
%   jdb_table2struct(conn,'my_table',{'col1','col2'})
%   jdb_table2struct(conn,'my_table',{'col1','col2'},Inf)
%
%   See also postgresql, nc2struct, jdb_select_struct, jdb_select_struct

%% Copyright notice: see below

limit = 2e6; % SQL keyword
dbtype = jdb_dbtype(conn);

if nargin  > 3
    if ~isempty(column_names)
        [nams, typs, siz] = jdb_getcolumns(conn,table,owner,column_names);
    else
        [nams, typs, siz] = jdb_getcolumns(conn,table,owner);
    end
elseif nargin > 2
    [nams, typs, siz] = jdb_getcolumns(conn,table,owner);
else
    [nams, typs, siz] = jdb_getcolumns(conn,table);    
end

if nargin > 4
   limit = varargin{1};
end

if siz <= limit
%    R = jdb_select_struct(conn,table,struct([]),nams);
    if strcmp(dbtype,'oracle')
	R = jdb_select_struct(conn,jdb_table_owner(table,owner),struct([]),nams);
    else
	R = jdb_select_struct(conn,table,struct([]),nams);
    end
	T = jdb_fetch2struct(R,nams,typs);
else
   T = [];
   disp(['table not loaded, table length exceeds limit: ',num2str(limit)])
end


%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Tu Delft / Deltares for Building with Nature
%       Gerben J. de Boer
%   Copyright (C) 2014 Van Oord
%       R.A. van der Hout
%
%       g.j.deboer@tudelft.nl / gerben.deboer@deltares.nl
%       ronald.vanderhout@vanoord.com
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
% $Id: jdb_table2struct.m 12952 2016-10-26 12:09:54Z gerben.deboer.x $
% $Date: 2016-10-26 20:09:54 +0800 (Wed, 26 Oct 2016) $
% $Author: gerben.deboer.x $
% $Revision: 12952 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/jdb/jdb_table2struct.m $
