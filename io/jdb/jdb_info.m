function info = jdb_info(conn, varargin)
% Retrieves overview of tables, columns and sizes of database schema
%
%   jdb_info(conn) shows alls tables with all columns
%   jdb_info(conn, 'table', table_name) shows only requested tables where
%   table_name is a char or cellstr.
%
%   Remark: 
%       The output is exacly the same as format as nc_info
%       This is a point for discussion.
%
% Input:
%       conn = Database connection object
%       $varargin  =
%
%   where the following <keyword,value> pairs have been implemented (values indicated are the current default settings):
%       'all'          , true        = flag for retrieveing all the tables including the database system tables
%       'table'        , ''          = table name or cell array with table names
%       'column_name'  , ''          = column name or cell array with column names
%
%   Output:
%       info = structure with database info
%
% Example: 
%   conn    = DWHreport.tools.DWHconnect;    % Connect to database
%   info    = jdb_info(conn)
%   info    = jdb_info(conn,'all',false)
%   info    = jdb_info(conn,'all',false,'table','F_COMP_TSHD')
%   info    = jdb_info(conn,'all',false,'table',{'F_COMP_TSHD' 'Something'})
%
% See also: jdb_dump, nc_info, nc_dump, netcdf

%% Copyright notice: see below

OPT.all          = true;
OPT.table        = '';
OPT.column_name  = '';

% Overrule defaults
OPT = setproperty(OPT,varargin{:});

% First select the available tables
[tnames, towners, ttypes] = jdb_gettables(conn,'all',OPT.all,'table',OPT.table);
[vnames, vowners, vtypes] = jdb_getviews (conn,'all',OPT.all,'table',OPT.table);

tables=[tnames;vnames];
owners=[towners;vowners];
types=[ttypes;vtypes];

% Check if passed tables are present
if ~isempty(OPT.table)
    if ischar(OPT.table); OPT.table = cellstr(OPT.table); end
    idx    = ismember(OPT.table, tables );
    tables = OPT.table(idx);
    [~,idb]= ismember(tables, OPT.table);
    owners = owners(idb);    
    types  = types(idb);    

    %Create dummy struct fields when not present
    unknown = OPT.table(~idx);
    for ii = 1:numel(unknown)
        info.(unknown{ii}).fieldnames    = {};
        info.(unknown{ii}).datatype      = {};
        info.(unknown{ii}).isprimarykey  = [];
        info.(unknown{ii}).records       = [];
        info.(unknown{ii}).err           = 'Not present';
    end
end

% Fill the information
tablefieldnames = matlab.lang.makeUniqueStrings(matlab.lang.makeValidName(tables));

for ii=1:length(tables)
    table = tables{ii};
    owner = owners{ii};
    type  = types{ii};
    tablename = tablefieldnames{ii}; 
    disp(['table: ',num2str(ii),'/',num2str(length(tables))])
    try
        if isempty(OPT.column_name)
            [nams, typs, siz] = jdb_getcolumns(conn,table,owner);    
        else
            if ischar(OPT.column_name); OPT.column_name = cellstr(OPT.column_name); end
            [nams, typs, siz] = jdb_getcolumns(conn,table,owner,OPT.column_name);
        end
        pk_name = jdb_getpk(conn, table);
        ispk    = ismember(nams,pk_name);

        info.(tablename).table         = table;  % The original tablename
        info.(tablename).fieldnames    = nams;
        info.(tablename).datatype      = typs;
        info.(tablename).isprimarykey  = ispk;
        info.(tablename).records       = siz;
        info.(tablename).err           = '';
        info.(tablename).owner         = owner;
        info.(tablename).type          = type;
    catch ME
        info.(tablename).table         = table;
        info.(tablename).fieldnames    = {};
        info.(tablename).datatype      = {};
        info.(tablename).isprimarykey  = [];
        info.(tablename).records       = [];
        info.(tablename).err           = ['Error in reading table: ' ME.message];
        info.(tablename).owner         = {};
        info.(tablename).type          = {};
    end
end
info = orderfields(info);

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Van Oord
%       R.A. van der Hout
%
%       ronald.vanderhout@vanoord.com
%
%       Schaardijk 211
%       3063 NH
%       Rotterdam
%       Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tools is part of VOTools which is the internal clone of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 10 Jan 2014
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id: jdb_info.m 12450 2015-12-16 16:28:47Z gerben.deboer.x $
% $Date: 2015-12-17 00:28:47 +0800 (Thu, 17 Dec 2015) $
% $Author: gerben.deboer.x $
% $Revision: 12450 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/jdb/jdb_info.m $
% $Keywords: $
