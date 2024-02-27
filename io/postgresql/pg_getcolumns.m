function [column_name, data_type,data_length] = pg_getcolumns(conn, table, column_name0)
%PG_GETCOLUMNS  List all column_names, their data_types and length from a given table
%
%   List all columns in a given table in the current database. Returns a
%   cellstr list with column names with the following SQL statements:
%      SELECT column_name, data_type FROM information_schema.columns WHERE table_name = ''table''
%      SELECT count(*)               FROM "table"
%
%   Syntax:
%   [column_name,<data_type>,<data_length>] = pg_getcolumns(conn, table,<column_name0>)
%
%   Input:
%   conn         = Database connection object
%   table        = Table name
%   column_name0 = optional cellstr array with columns names for which to
%                  query datatype, for use in pg_fetch2struct in combination
%                  with pg_select_struct.
%
%   Output:
%   column_name = Cell array with column names
%   data_type   = Cell array with column data names (optional)
%   data_length = Length of the table, and all of its columns
%
%   Example: get overview of contents of table
%
%     conn            = pg_connectdb('someDatabase');
%     tables          = pg_gettables(conn);
%     [nam, typ, siz] = pg_getcolumns(conn, tables{1});
%
%   Example 2: use PG_GETCOLUMNS to convert requested
%              subset of columns to struct from pg_test datamodel.
%
%     columns = {'Value','ObservationTime'};
%     R = pg_select_struct(conn,table,struct([]),columns);
%     [nams,typs]=pg_getcolumns(conn,table,columns);
%     D = pg_fetch2struct(R,nams,typs);
%
%   See also pg_connectdb, pg_gettables, pg_fetch2struct, pg_table2struct

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

% $Id: pg_getcolumns.m 7705 2012-11-20 12:54:51Z boer_g $
% $Date: 2012-11-20 20:54:51 +0800 (Tue, 20 Nov 2012) $
% $Author: boer_g $
% $Revision: 7705 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/postgresql/pg_getcolumns.m $
% $Keywords: $

%% read options

% low-level: don't
% skip dropped tables like "........pg.dropped.1......." (http://forums.whirlpool.net.au/archive/497602)
%strSQL = sprintf('SELECT attname FROM pg_attribute, pg_type WHERE typname = ''%s'' AND attrelid = typrelid AND attname NOT IN (''tableoid'',''cmax'',''xmax'',''cmin'',''xmin'',''ctid'') AND attisdropped NOT IN (TRUE)', table);
%rs     = pg_fetch(conn, strSQL);

% high-level: do
% ?? why does "" encapsulation not work here ??
% somehow order is  reversed, so we reverse it back

strSQL = ['SELECT column_name, data_type FROM information_schema.columns WHERE table_name = ''',table,''''];
rs     = pg_fetch(conn, strSQL);

if isempty(rs) && isnumeric(rs); % required for combi: empty tables & database_toolbox license
    rs = {};
end

if nargin > 2
   for i=1:length(column_name0)
      tmp = strmatch(column_name0{i}, {rs{:,1}}, 'exact');
      if isempty(tmp)
         error(['column_name "','" not found in table ',table])
      else
         indices(i) = tmp;
      end
   end
else
   indices = size(rs,1):-1:1;
end

column_name = {rs{indices,1}}';
if nargout > 1
 data_type = {rs{indices,2}}';
 if nargout > 2
  % ?? why does '''' encapsulation not work here ??
  strSQL = ['SELECT count(*) FROM ',pg_quote(table)];
  data_length = pg_fetch(conn, strSQL);
  data_length = data_length{1};
 end
end