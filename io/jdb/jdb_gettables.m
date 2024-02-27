function [tables, owners, types] = jdb_gettables(conn, varargin)
%JDB_GETTABLES  List all tables in current database
%
%   List all tables in current database. Return a list with tablew names in
%   given database connection. Ignores system tables like pg_catalog and
%   information_schema. For views use jdb_getviews().
%
%   Syntax:
%   [tables, <owners, <types>>] = jdb_gettables(conn, varargin)
%
%   Input:
%   conn      = Database connection object
%   varargin  = none
%
%   Output:
%   tables    = Cell array with table names
%   owners    = Cell array with table owners
%   types     = Cell array with table types (table or view)
%
%   Example
%   conn = jdb_connectdb('someDatabase');
%   tables = jdb_gettables(conn);
%
%   See also jdb_connectdb, jdb_getcolumns, jdb_table2struct, jdb_getviews

%% Copyright notice: see below


%% read options
OPT.all = true;
OPT.table = '';

OPT = setproperty(OPT,varargin{:});

%% list tables
dbtype = jdb_dbtype(conn);

switch dbtype
    case 'oracle'        
       %sql = 'SELECT DISTINCT "OWNER", "OBJECT_NAME","OBJECT_TYPE" FROM ALL_OBJECTS WHERE OBJECT_TYPE = ''VIEW''                            ORDER BY "OBJECT_NAME"';
        sql = 'SELECT DISTINCT "OWNER", "OBJECT_NAME","OBJECT_TYPE" FROM ALL_OBJECTS WHERE                           OBJECT_TYPE = ''TABLE'' ORDER BY "OBJECT_NAME"';
       %sql = 'SELECT DISTINCT "OWNER", "OBJECT_NAME","OBJECT_TYPE" FROM ALL_OBJECTS WHERE OBJECT_TYPE = ''VIEW'' OR OBJECT_TYPE = ''TABLE'' ORDER BY "OBJECT_TYPE", "OBJECT_NAME"';
       
        if ~isempty(OPT.table)
            sql = [sql, sprintf(' AND "OBJECT_NAME" = ''%s''',OPT.table)];
        end
    case 'postgresql'
        sql = 'SELECT tableowner, tablename FROM pg_tables WHERE schemaname NOT IN (''pg_catalog'',''information_schema'')';
       %sql = 'SELECT viewowner,  viewname  FROM pg_views  WHERE schemaname NOT IN (''pg_catalog'',''information_schema'')';
        if ~isempty(OPT.table)
            sql = [sql, sprintf(' AND tablename = ''%s''',OPT.table)];
        end
        type = 'table';  
    case 'access'
        %% TODO check
%       sql = 'SELECT DISTINCT MSysObjects.Name FROM MSysObjects WHERE                           OBJECT_TYPE = ''TABLE'' ORDER BY "OBJECT_NAME"';
%         sql = [ 'SELECT * AS table_name '        ,...
%                 'FROM sys.MSysObjects '                             ,...
%                 'WHERE (((Left([Name],1))<>"~") '               ,...
%                 '        AND ((Left([Name],4))<>"MSys") '       ,...
%                 '        AND ((MSysObjects.Type) In (1,4,6))) ' ,...
%                 'order by MSysObjects.Name '];
%             
%         sql = 'SELECT * FROM sys.MSysObjects WHERE Type=1 AND Flags=0';  
%         sql = 'SELECT * FROM sys.MSysObjects WHERE Type=1';  

        %Returns (p 77)
        %   AUTHORIZATIONS
        %   ADMINSTRABLE_ROLE_AUTHORIZATIONS
        % objects object_type   etc.. ?
        % 
            
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
            types  = types(idx,:);
            
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
        idx = ismember(types(:,1),{'TABLE' 'BASE TABLE'});
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

% $Id: jdb_gettables.m 12952 2016-10-26 12:09:54Z gerben.deboer.x $
% $Date: 2016-10-26 20:09:54 +0800 (Wed, 26 Oct 2016) $
% $Author: gerben.deboer.x $
% $Revision: 12952 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/jdb/jdb_gettables.m $
% $Keywords: $
