%pg_stationTimeSeries_tutorial  tutorial for postgresql toolbox with simple scalar time series
%
% For the simple test datamodel see "pg_test_template.sql".
%
%See also: postgresql, nc_cf_stationTimeSeries_tutorial
%          http://publicwiki.deltares.nl/display/OET/OPeNDAP+access+with+Matlab

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Tu Delft / Deltares for Building with Nature
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl / gerben.deboer@deltares.nl
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
% $Id: pg_stationTimeSeries_tutorial.m 7572 2012-10-24 11:37:42Z boer_g $
% $Date: 2012-10-24 19:37:42 +0800 (Wed, 24 Oct 2012) $
% $Author: boer_g $
% $Revision: 7572 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/postgresql/pg_stationTimeSeries_tutorial.m $
% $Keywords: $

OPT.db     = 'postgres';
OPT.schema = 'public';
OPT.user   = '';
OPT.pass   = '';
OPT.table  = 'waterbase01';

%% connect
if ~(pg_settings('check',1)==1)
   pg_settings
end
if isempty(OPT.user)
[OPT.user,OPT.pass] = pg_credentials();
end

conn=pg_connectdb(OPT.db,'user',OPT.user,'pass',OPT.pass,'schema',OPT.schema);

%% show existing contents

   tables = pg_gettables(conn);
   add_table = 1;
   if any(strmatch(OPT.table,tables))
      add_table = 0;
   end

%% add datamodel for testing
% http://archives.postgresql.org/pgsql-performance/2004-11/msg00350.php
% http://dba.stackexchange.com/questions/322/what-are-the-drawbacks-with-using-uuid-or-guid-as-a-primary-key

   if    add_table
      sql   = loadstr('pg_test_template.sql');
      for i=1:length(sql)
          sqlstr = strrep(sql{i},'?',OPT.table);
          pg_exec(conn,sqlstr);
      end
   end

%% add some time series data from OPeNDAP server

   pg_cleartable(conn,OPT.table) % reset values and serial

  %D0 = nc2struct('F:\opendap.deltares.nl\thredds\dodsC\opendap\rijkswaterstaat\waterbase\concentration_of_suspended_matter_in_sea_water\id410-DELFZBTHVN.nc');
   D0 = nc2struct('http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/waterbase/concentration_of_suspended_matter_in_sea_water/id410-DELFZBTHVN.nc');

   pg_insert_struct(conn,OPT.table,struct('Value',D0.concentration_of_suspended_matter_in_sea_water,...
                                'ObservationTime',pg_datenum(D0.datenum))); % 2 3

%% get the data into struct (exclude "ObservationID" column)

   [nams, typs] = pg_getcolumns(conn,OPT.table);
   
   OPT.columns = {'Value','ObservationTime'};
  
   R = pg_select_struct(conn,OPT.table,struct([]),OPT.columns); % all
   
   [nams,typs]=pg_getcolumns(conn,OPT.table,OPT.columns);
   
   D = pg_fetch2struct(R,nams,typs);
   
%% plot   

   plot(D.ObservationTime,D.Value)
   datetick('x')
   grid on
