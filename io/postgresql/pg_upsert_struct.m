function varargout = pg_upsert_struct(conn, table, sqlValues, sqlWhere, varargin)
%PG_UPSERT_STRUCT  Updates existing records or inserts it otherwise
%
%   Checks whether a record exists in the given table in the current
%   database based on the WHERE clause. If it exists, it is updated with
%   the provided VALUES structure. Otherwise, it is inserted. Basically,
%   this function either calls the pg_insert_struct or the pg_update_struct
%   function depending on the existance of the specified record. The
%   function has basic support for structure arrays like pg_update_struct.
%
%   Syntax:
%   varargout = pg_upsert_struct(conn, table, sqlValues, sqlWhere, varargin)
%
%   Input:
%   conn      = Database connection object
%   table     = Table where the data should be updated or inserted
%   sqlValues = Structure with fieldnames matching the column names of the
%               tables and values to be updated
%   sqlWhere  = Structure with fieldnames matching the column names of the
%               tables and values that specify the records to be updated or
%               inserted
%   varargin  = none
%
%   Output:
%   varargout = primary key of updated/inserted records
%
%   Example
%   sqlValues = struct('Column_1', 3);
%   sqlWhere = struct('id', 123);
%   pg_upsert_struct(conn, 'someTable', sqlValues, sqlWhere);
%
%   sqlValues = struct('Column_1', 3, 'Column_2', 'someValue');
%   sqlWhere = struct('Column_2', '123');
%   pg_upsert_struct(conn, 'someTable', sqlValues, sqlWhere);
%
%   sqlValues = struct('Column_1', {3 4 5}, 'Column_2', {'someValue' '' ''});
%   [sqlValues.Column_3] = deal('someConstantValue');
%   sqlWhere = struct('id', 123);
%   pg_upsert_struct(conn, 'someTable', sqlValues, sqlWhere);
%
%   See also pg_select_struct, pg_insert_struct, pg_update_struct

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
% Created: 31 Jul 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id: pg_upsert_struct.m 7174 2012-09-03 06:57:54Z boer_g $
% $Date: 2012-09-03 14:57:54 +0800 (Mon, 03 Sep 2012) $
% $Author: boer_g $
% $Revision: 7174 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/postgresql/pg_upsert_struct.m $
% $Keywords: $

%% built sql statement

l1 = length(sqlValues);
l2 = length(sqlWhere);

n = max(l1, l2);

varargout = cell(1,nargout);

for i = 1:n
    
    id = pg_getid(conn, table, sqlWhere(min(l2,i)));

    if id == 0

        pg_insert_struct(conn, table, sqlValues(min(l1,i)));
        
        if nargout >= i
            varargout{i} = pg_getid(conn, table, sqlWhere(min(l2,i)));
        end

    else

        pk = pg_getpk(conn, table);
        pg_update_struct(conn, table, sqlValues(min(l1,i)), struct(pk, id));
        
        varargout{i} = id;

    end
    
end
