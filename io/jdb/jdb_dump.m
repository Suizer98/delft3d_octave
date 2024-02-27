function jdb_dump(conn,varargin)
%JDB_DUMP  Display overview of tables, columns and sizes of database schema
%
% JDB_DUMP(conn) shows alls tables with all columns
% JDB_DUMP(conn, table_name) shows only requested tables where
% table_name is a char or cellstr.
%
% Example: pg_test datamodel
%  jdb_dump(conn,{'TEST01'})
%  jdb_dump(conn)
%
%  TEST01(6) :
%      ObservationID(integer)
%      ObservationTime(timestamp with time zone)
%      Value(real)
%
% See also: nc_dump, postgresql, netcdf

%% Copyright notice: see below

OPT.table = '';
OPT.all   = true;

OPT = setproperty(OPT,varargin{:});

[tnames, towners, ttypes] = jdb_gettables(conn,'all',OPT.all,'table',OPT.table);
[vnames, vowners, vtypes] = jdb_getviews (conn,'all',OPT.all,'table',OPT.table);

tables=[tnames;vnames];
owners=[towners;vowners];
types=[ttypes;vtypes];

for ii=1:length(tables)
    table = tables{ii};
    owner = owners{ii};
    type  = types{ii};
    try % ERROR: relation "topology" does not exist
        [column_name,data_type,data_length] = jdb_getcolumns(conn, table, owner);
        
        pk_name = jdb_getpk(conn, table);
        %         pk_name = '';
        
        disp([table,' (',num2str(data_length),'): -- ', type])
        for j=1:length(column_name)
            if strcmpi(column_name{j},pk_name)
                disp(['    ',column_name{j},' (',data_type{j},') [PK]'])
            else
                disp(['    ',column_name{j},' (',data_type{j},')'])
            end
        end
        disp(' ')
    catch ME
        disp(['ERROR in table: ' table])
        disp(ME.message)
        
    end
end

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Tu Delft / Deltares for Building with Nature
%       Gerben J. de Boer
%   Copyright (C) 2014 Van Oord
%       R.A. van der Hout
%
%       g.j.deboer@tudelft.nl / gerben.deboer@deltares.nl
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
% $Id: jdb_dump.m 12450 2015-12-16 16:28:47Z gerben.deboer.x $
% $Date: 2015-12-17 00:28:47 +0800 (Thu, 17 Dec 2015) $
% $Author: gerben.deboer.x $
% $Revision: 12450 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/jdb/jdb_dump.m $
