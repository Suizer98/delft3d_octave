function [tables, owners, types] = jdb_getviews(conn, varargin)
%JDB_GETTABLES  List all tables in current database
%
%   List all views in current database. Return a list with view names in
%   given database connection. Ignores system tables like pg_catalog and
%   information_schema. For tables use jdb_gettables().
%
%   Syntax:
%   [views, <owners, <types>>] = jdb_gettables(conn, varargin)
%
%   Input:
%   conn      = Database connection object
%   varargin  = none
%
%   Output:
%   tables    = Cell array with view names
%   owners    = Cell array with view owners
%   types     = Cell array with view types (table or view)
%
%   Example
%   conn = jdb_connectdb('someDatabase');
%   tables = jdb_gettables(conn);
%
%   See also jdb_connectdb, jdb_getcolumns, jdb_table2struct, jdb_gettables

%% Copyright notice: see below


%% read options
OPT.all = true;
OPT.table = '';

OPT = setproperty(OPT,varargin{:});

%% list tables
% dbtype = class(conn);
% C      = textscan(dbtype, '%s', 'delimiter','.');
% dbtype = C{:}{1};
C = textscan(class(conn), '%s', 'delimiter','.');
C = C{:};
if ismember('oracle',C)
    dbtype = 'oracle';
elseif ismember('postgresql',C)
    dbtype = 'postgresql';    
elseif ismember('ucanaccess',C)
    dbtype = 'access';  
else
    dbtype = 'unknown';
end

switch dbtype
    case 'oracle'        
        sql = 'SELECT DISTINCT "OWNER", "OBJECT_NAME","OBJECT_TYPE" FROM ALL_OBJECTS WHERE OBJECT_TYPE = ''VIEW''                            ORDER BY "OBJECT_NAME"';
       %sql = 'SELECT DISTINCT "OWNER", "OBJECT_NAME","OBJECT_TYPE" FROM ALL_OBJECTS WHERE                           OBJECT_TYPE = ''TABLE'' ORDER BY "OBJECT_NAME"';
       %sql = 'SELECT DISTINCT "OWNER", "OBJECT_NAME","OBJECT_TYPE" FROM ALL_OBJECTS WHERE OBJECT_TYPE = ''VIEW'' OR OBJECT_TYPE = ''TABLE'' ORDER BY "OBJECT_TYPE", "OBJECT_NAME"';
       
        if ~isempty(OPT.table)
            sql = [sql, sprintf(' AND "OBJECT_NAME" = ''%s''',OPT.table)];
        end
    case 'postgresql'
       %sql = 'SELECT tableowner, tablename FROM pg_tables WHERE schemaname NOT IN (''pg_catalog'',''information_schema'')';
        sql = 'SELECT viewowner,  viewname  FROM pg_views  WHERE schemaname NOT IN (''pg_catalog'',''information_schema'')';
        if ~isempty(OPT.table)
            sql = [sql, sprintf(' AND tablename = ''%s''',OPT.table)];
        end
        type = 'view';
    case 'access'
        %% TODO check  objtype 6 = Query
%         sql = [ 'SELECT MSysObjects.Name AS table_name '    ,...
%                 'FROM MSysObjects '                         ,...
%                 'WHERE (((Left([Name],1))<>"~") '           ,...
%                 '        AND ((Left([Name],4))<>"MSys") '   ,...
%                 '        AND ((MSysObjects.Type) = 6)) '    ,...
%                 'order by MSysObjects.Name '];
            
       %Get all info from tables and view objects
        sql = 'SELECT * FROM information_schema.tables' ;
       
    otherwise
        sql = '';
end

tables = jdb_fetch(conn, sql);

if size(tables,2)==2
    owners = tables(:,1);
    types  = repmat({type},size(tables(:,1)));
    tables = tables(:,2); % !
elseif size(tables,2)==3
    owners = tables(:,1);
    types  = tables(:,3);
    tables = tables(:,2); % !
elseif size(tables,2)==12  % From ucanaccess
    owners = tables(:,2);
    types  = tables(:,4);
    tables = tables(:,3);
else
    owners  = repmat({''},size(tables(:,1)));
    types   = repmat({type},size(tables(:,1)));
end

% Postproces tablenames
if ~OPT.all
    switch dbtype
        case 'oracle'        
            idx = ~ismember(owners(:,1),{'SYS' 'SYSTEM' 'MDSYS' 'XDB' 'OLAPSYS' 'APEX_030200' 'EXFSYS' 'CTXSYS'});
            tables = tables(idx,:);
            owners = owners(idx,:);
        case 'access'
            idx = ~ismember(owners(:,1),{'INFORMATION_SCHEMA' 'SYSTEM' 'SYSTEM_LOBS' 'UCA_METADATA'});
            tables = tables(idx,:);
            owners = owners(idx,:);   
            types  = types(idx,:);
    end
end

% Filter only the views
switch dbtype
    case 'access'
        idx = strcmpi(types(:,1),'VIEW');
        tables = tables(idx,:);
        owners = owners(idx,:);   
        types  = types(idx,:);        
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

% $Id: jdb_gettables.m 11373 2014-11-13 13:33:36Z tda.x $
% $Date: 2014-11-13 14:33:36 +0100 (Thu, 13 Nov 2014) $
% $Author: tda.x $
% $Revision: 11373 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/jdb/jdb_gettables.m $
% $Keywords: $
