function [column_name, data_type,data_length] = jdb_getcolumns(conn, table, owner, column_name0)
% List all column_names, their data_types and length from a given table
%
%   List all columns in a given table in the current database. Returns a
%   cellstr list with column names with the following SQL statements:
%      SELECT column_name, data_type FROM information_schema.columns WHERE table_name = ''table''
%      SELECT count(*)               FROM "table"
%
%   Syntax:
%   [column_name,<data_type>,<data_length>] = jdb_getcolumns(conn, table,<column_name0>)
%
%   Input:
%   conn         = Database connection object
%   table        = Table name
%   column_name0 = optional cellstr array with columns names for which to
%                  query datatype, for use in jdb_fetch2struct in combination
%                  with jdb_select_struct.
%
%   Output:
%   column_name = Cell array with column names
%   data_type   = Cell array with column data names (optional)
%   data_length = Length of the table, and all of its columns
%
%   Example: get overview of contents of table
%
%     conn            = jdb_connectdb('someDatabase');
%     tables          = jdb_gettables(conn);
%     [nam, typ, siz] = jdb_getcolumns(conn, tables{1});
%
%   Example 2: use JDB_GETCOLUMNS to convert requested
%              subset of columns to struct from pg_test datamodel.
%
%     columns     = {'Value','ObservationTime'};
%     R           = jdb_select_struct(conn,table,struct([]),columns);
%     [nams,typs] = jdb_getcolumns(conn,table,columns);
%     D           = jdb_fetch2struct(R,nams,typs);
%
%   See also jdb_connectdb, jdb_gettables, jdb_fetch2struct, jdb_table2struct

%% Copyright notice: see below

%% read options

% low-level: don't
% skip dropped tables like "........pg.dropped.1......." (http://forums.whirlpool.net.au/archive/497602)
%strSQL = sprintf('SELECT attname FROM jdb_attribute, jdb_type WHERE typname = ''%s'' AND attrelid = typrelid AND attname NOT IN (''tableoid'',''cmax'',''xmax'',''cmin'',''xmin'',''ctid'') AND attisdropped NOT IN (TRUE)', table);
%rs     = jdb_fetch(conn, strSQL);

% high-level: do
% ?? why does "" encapsulation not work here ??
% somehow order is  reversed, so we reverse it back
% dbtype = class(conn);
% C      = textscan(dbtype, '%s', 'delimiter','.');
% dbtype = C{:}{1};
C = textscan(class(conn), '%s', 'delimiter','.');
C = C{:};
if ismember('oracle',C)
    dbtype = 'oracle';
elseif ismember('postgresql',C)
    dbtype = 'postgresql';    
else
    dbtype = 'unknown';
end

switch dbtype
    case 'oracle' 
        table  = upper(table);
        strSQL = ['SELECT "COLUMN_NAME", "DATA_TYPE" FROM  ALL_TAB_COLS WHERE "TABLE_NAME"= ''',table,''' ORDER BY "COLUMN_ID"'];
    case 'postgresql'
        strSQL = ['SELECT column_name, data_type FROM information_schema.columns WHERE table_name = ''',table,''''];
    otherwise
        strSQL = '' ;
end

rs     = jdb_fetch(conn, strSQL);

if isempty(rs) && isnumeric(rs); % required for combi: empty tables & database_toolbox license
    rs = {};
end

if nargin > 2+1
   for i=1:length(column_name0)
      tmp = strmatch(column_name0{i}, {rs{:,1}}, 'exact');
      if isempty(tmp)
         error(['column_name "','" not found in table ',table])
      else
          
         indices(i) = tmp;
      end
   end
else
    switch dbtype
    case 'oracle' 
        indices = 1:size(rs,1);
    otherwise
        indices = size(rs,1):-1:1;
    end
end

column_name = {rs{indices,1}}';
if nargout > 1
    data_type = {rs{indices,2}}';
    if nargout > 2
        % ?? why does '''' encapsulation not work here ??
        switch dbtype
            case 'oracle'
                idx = ismember(owner,{'SYS' 'SYSTEM' 'MDSYS' 'XDB' 'OLAPSYS' 'APEX_030200' 'EXFSYS' 'CTXSYS'});
                if idx
                    strSQL = ['SELECT count(*) FROM ',jdb_quote(table)];
                else
                    strSQL = ['SELECT count(*) FROM ',jdb_quote(owner) , '.' ,jdb_quote(table)];
                end
                
            case 'postgresql'
                strSQL = ['SELECT count(*) FROM ',jdb_quote(table)];
            otherwise
                strSQL = '' ;
        end
        try
            data_length = jdb_fetch(conn, strSQL);
            data_length = data_length{1};
        catch
            data_length = [];
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

% $Id: jdb_getcolumns.m 12857 2016-08-18 13:30:10Z rho.x $
% $Date: 2016-08-18 21:30:10 +0800 (Thu, 18 Aug 2016) $
% $Author: rho.x $
% $Revision: 12857 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/jdb/jdb_getcolumns.m $
% $Keywords: $
