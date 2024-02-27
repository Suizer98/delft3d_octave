function varargout = jdb_insert_struct(conn, table, sqlValues, varargin)
%JDB_INSERT_STRUCT  Inserts a structure into a table
%
%   function NOT TESTED for Oracle
%
%   Inserts the values in a structure into a given table of the current
%   database. The fields in the structure should match the column names in
%   the table. The structure may be a structure array. Each item in the
%   array is inserted as a separate record. The values are casted and
%   escaped automatically.
%
%   Syntax:
%   jdb_insert_struct(conn, table, sqlValues, varargin)
%
%   Input:
%   conn      = Database connection object
%   table     = Table where the data should be inserted
%   sqlValues = Structure with fieldnames matching the column names of the
%               tables and values to be inserted
%   varargin  = If specified, this structure with fieldnames matching the
%               column names of the tables and values specifies the records
%               to be inserted and cancels the insert in case it already
%               exists.
%
%   Output:
%   varargout = primary key of existing/inserted records
%
%   Example
%   sqlValues = struct('Column_1', 3);
%   jdb_insert_struct(conn, 'someTable', sqlValues);
%
%   sqlValues = struct('Column_1', 3, 'Column_2', 'someValue');
%   jdb_insert_struct(conn, 'someTable', sqlValues);
%
%   sqlValues = struct('Column_1', {3 4 5}, 'Column_2', {'someValue' '' ''});
%   [sqlValues.Column_3] = deal('someConstantValue');
%   jdb_insert_struct(conn, 'someTable', sqlValues);
%
%   sqlValues = struct('Column_1', 3, 'Column_2', 'someValue');
%   jdb_insert_struct(conn, 'someTable', sqlValues, sqlValues);
%
%   See also jdb_select_struct, jdb_update_struct, jdb_upsert_struct


OPT.debug = 0;

%% read input
sqlWhere = [];

if ~isempty(varargin)
    if isstruct(varargin{1})
        sqlWhere = varargin{1};
    end
end

l1 = length(sqlValues);
l2 = length(sqlWhere);

n = max(l1, l2);

varargout = cell(1,nargout);

%% built sql statement
for i = 1:n

    if l2>0
        id = jdb_getid(conn, table, sqlWhere(min(l2,i)));
        
        if id > 0
            varargout{i} = id;
            continue;
        end
    end
    
    strSQL = jdb_query('INSERT', table, sqlValues(min(l1,i)));
    
    if OPT.debug
        disp(strSQL)
    end
    
    jdb_exec(conn, strSQL);
    
    if nargout >= i
       if l2>0
           varargout{i} = jdb_getid(conn, table, sqlWhere(min(l2,i)));
       else
           varargout{i} = [];
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
% Created: 27 Jul 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id: jdb_insert_struct.m 10181 2014-02-10 15:42:22Z rho.x $
% $Date: 2014-02-10 23:42:22 +0800 (Mon, 10 Feb 2014) $
% $Author: rho.x $
% $Revision: 10181 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/jdb/jdb_insert_struct.m $
% $Keywords: $
