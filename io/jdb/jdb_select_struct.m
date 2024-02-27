function rs = jdb_select_struct(conn, table, sqlWhere, varargin)
%JDB_SELECT_STRUCT  Selects records from a table based on a structure
%
%   Selects records from a table based on a structure containing fields
%   that correspond to the table columns and values that should match the
%   values in the selected structure. The columns to be returned can be
%   specified. By default, all columns are returned.
%
%   Syntax:
%   rs = jdb_select_struct(conn, table, sqlWhere, <column_names>)
%
%   Input:
%   conn          = Database connection object
%   table         = Name of table to be queried
%   sqlWhere      = structure with fields corresponding to the table columns
%                   and values that should match the selected columns.
%                   Use struct([]) to get the entire table columns.
%   column_names  = Columns to be returne das cellstr or list of char.
%
%   Output:
%   rs        = Cell array with resulting records
%
%   Example
%   conn = jdb_connectdb('someDatabase');
%   rs = jdb_select_struct(conn, 'someTable', struct('id', 1));
%   rs = jdb_select_struct(conn, 'someTable', struct('id', 2), 'someColumn');
%   rs = jdb_select_struct(conn, 'someTable', struct('id', 3), 'Column_1', 'Column_2');
%   rs = jdb_select_struct(conn, 'someTable', struct('id', 3),{'Column_1', 'Column_2'});
%   rs = jdb_select_struct(conn, 'someTable', struct([])     , 'Column_1')
%
%   See also jdb_insert_struct, jdb_update_struct, jdb_upsert_struct

%% Copyright notice: see below

%% read input
sqlSelect = varargin;

if ~isempty(varargin)
    if iscell(varargin{1})
        sqlSelect = varargin{1};
    end
end

strSQL = jdb_query('SELECT', table, sqlSelect, sqlWhere);

rs = jdb_fetch(conn, strSQL);


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

% $Id: jdb_select_struct.m 10181 2014-02-10 15:42:22Z rho.x $
% $Date: 2014-02-10 23:42:22 +0800 (Mon, 10 Feb 2014) $
% $Author: rho.x $
% $Revision: 10181 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/jdb/jdb_select_struct.m $
% $Keywords: $
