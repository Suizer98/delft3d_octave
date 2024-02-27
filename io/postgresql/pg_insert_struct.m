function varargout = pg_insert_struct(conn, table, sqlValues, varargin)
%PG_INSERT_STRUCT  Inserts a structure into a table
%
%   Inserts the values in a structure into a given table of the current
%   database. The fields in the structure should match the column names in
%   the table. The structure may be a structure array. Each item in the
%   array is inserted as a separate record. The values are casted and
%   escaped automatically.
%
%   Syntax:
%   pg_insert_struct(conn, table, sqlValues, varargin)
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
%   pg_insert_struct(conn, 'someTable', sqlValues);
%
%   sqlValues = struct('Column_1', 3, 'Column_2', 'someValue');
%   pg_insert_struct(conn, 'someTable', sqlValues);
%
%   sqlValues = struct('Column_1', {3 4 5}, 'Column_2', {'someValue' '' ''});
%   [sqlValues.Column_3] = deal('someConstantValue');
%   pg_insert_struct(conn, 'someTable', sqlValues);
%
%   sqlValues = struct('Column_1', 3, 'Column_2', 'someValue');
%   pg_insert_struct(conn, 'someTable', sqlValues, sqlValues);
%
%   See also pg_select_struct, pg_update_struct, pg_upsert_struct

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

% $Id: pg_insert_struct.m 7264 2012-09-21 11:27:43Z boer_g $
% $Date: 2012-09-21 19:27:43 +0800 (Fri, 21 Sep 2012) $
% $Author: boer_g $
% $Revision: 7264 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/postgresql/pg_insert_struct.m $
% $Keywords: $

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
        id = pg_getid(conn, table, sqlWhere(min(l2,i)));
        
        if id > 0
            varargout{i} = id;
            continue;
        end
    end
    
    strSQL = pg_query('INSERT', table, sqlValues(min(l1,i)));
    
    if OPT.debug
        disp(strSQL)
    end
    
    pg_exec(conn, strSQL);
    
    if nargout >= i
       if l2>0
           varargout{i} = pg_getid(conn, table, sqlWhere(min(l2,i)));
       else
           varargout{i} = [];
       end
    end
    
end
