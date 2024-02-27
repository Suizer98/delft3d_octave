function jdb_update_struct(conn, table, sqlValues, sqlWhere, varargin)
%JDB_UPDATE_STRUCT  Updates a record in a table based on a structure
%
%   function NOT TESTED for Oracle
%
%   Updates the values in a specific record in a given table of the current
%   database from a structure. The fields in the structure should match the
%   column names in the table. The structure may be a structure array. Each
%   item in the array updates as a separate record. A second structure
%   specifies the values of fields that should match the existing record to
%   be updated. In case the number of items in the two structure arrays are
%   unequal, the last value of the shortest array is reused to match the
%   one of the longest. The values are casted and escaped automatically.
%
%   Syntax:
%   jdb_update_struct(conn, table, sqlValues, sqlWhere, varargin)
%
%   Input:
%   conn      = Database connection object
%   table     = Table where the data should be updated
%   sqlValues = Structure with fieldnames matching the column names of the
%               tables and values to be updated
%   sqlWhere  = Structure with fieldnames matching the column names of the
%               tables and values that specify the records to be updated
%   varargin  = none
%
%   Output:
%   none
%
%   Example
%   sqlValues = struct('Column_1', 3);
%   sqlWhere = struct('id', 123);
%   jdb_update_struct(conn, 'someTable', sqlValues, sqlWhere);
%
%   sqlValues = struct('Column_1', 3, 'Column_2', 'someValue');
%   sqlWhere = struct('Column_2', '123');
%   jdb_update_struct(conn, 'someTable', sqlValues, sqlWhere);
%
%   sqlValues = struct('Column_1', {3 4 5}, 'Column_2', {'someValue' '' ''});
%   [sqlValues.Column_3] = deal('someConstantValue');
%   sqlWhere = struct('id', 123);
%   jdb_update_struct(conn, 'someTable', sqlValues, sqlWhere);
%
%   See also jdb_select_struct, jdb_insert_struct, jdb_upsert_struct


%% built sql statement
l1 = length(sqlValues);
l2 = length(sqlWhere);
n  = max(l1, l2);

for i = 1:n    
    strSQL = pg_query('UPDATE', table, sqlValues(min(l1,i)), sqlWhere(min(l2,i)));    
    jdb_exec(conn, strSQL);    
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
%       Rotterdamseweg 185
%       2629HD Delft
%       Netherlands
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
% Created: 30 Jul 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id: jdb_update_struct.m 10181 2014-02-10 15:42:22Z rho.x $
% $Date: 2014-02-10 23:42:22 +0800 (Mon, 10 Feb 2014) $
% $Author: rho.x $
% $Revision: 10181 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/jdb/jdb_update_struct.m $
% $Keywords: $

