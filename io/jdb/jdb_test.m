function OK = jdb_test(varargin)
%JDB_TEST test postgresql toolbox with simple 2-column datamodel:
%
% For the simple test datamodel see "pg_test_template.sql".
%
% See also: postgresql

%% Copyright notice: see below

OPT.db               = 'postgresql';  
OPT.host             = 'localhost';  
OPT.port             =  5432 ;     

OPT.schema           = 'public' ;         
OPT.user             = '';
OPT.pass             = '';
OPT.table            = 'TestAf';
OPT.database_toolbox = 0;

OPT = setproperty(OPT,varargin);

%% connect
   if ~(jdb_settings('db',OPT.db, 'check',1)==1)
      jdb_settings('db',OPT.db)
   end
   if isempty(OPT.user)
       disp('User info missing')
       return
%     [OPT.user,OPT.pass] = pg_credentials();
   end
   conn = jdb_connectdb(OPT.db,'host',OPT.host,'port',OPT.port,'user',OPT.user,'pass',OPT.pass,'database_toolbox',OPT.database_toolbox);
   
   jdb_dump(conn,'all',false)

   
%% show existing contents
[tables, owners] = jdb_gettables(conn,'all',false);
% add_table = 1;
itab = find(ismember(OPT.table,tables));
for ii = itab
    table = tables{ii};
    owner = owners{ii};
    columns = jdb_getcolumns(conn,table,owner);
    disp([OPT.db,':',table])
    for icol=1:length(columns)
        column = columns{icol};
        disp([OPT.db,':',table,':',column])
    end
    warning(['request table for pg_test is already in database:',OPT.table])
%     add_table = 0;
end


%% read a table
[tables, owners] = jdb_gettables(conn,'all',false);
table = tables{3};
owner = owners{3};
T = jdb_table2struct(conn, table, owner); %, column_names, varargin)


%% THE FUNCTIONS BELOW ARE NOT TESTED
% It was not possible to create a empty writable database for Oracle and
% Postgres
return


%% add datamodel for testing
% http://archives.postgresql.org/pgsql-performance/2004-11/msg00350.php
% http://dba.stackexchange.com/questions/322/what-are-the-drawbacks-with-using-uuid-or-guid-as-a-primary-key
   if add_table
      sql   = loadstr('pg_test_template.sql');
      for i=1:length(sql)
          sqlstr = strrep(sql{i},'?TABLE',OPT.table);
          sqlstr = strrep(sqlstr,'?USER' ,OPT.user );
          pg_exec(conn,sqlstr);
      end
      OK = 1;
   else
      OK = 0;
   end % add_table
   
%% remove and re-add data
   pg_cleartable   (conn,OPT.table) % reset values and serial
   
   pg_insert_struct(conn,OPT.table,struct('Value','3.1416'       ,'ObservationTime', '1648-10-24 00:01:00+1')); % 1
   pg_insert_struct(conn,OPT.table,struct('Value',[3.1416 3.1416],'ObservationTime',['1648-10-24 00:02:00+1';'1648-10-24 00:03:00+1'])); % 2 3
   pg_insert_struct(conn,OPT.table,struct('Value','2'            ,'ObservationTime', '1648-10-24 00:04:00+1')); % 4
   pg_insert_struct(conn,OPT.table,struct('Value',[2 2]          ,'ObservationTime',['1648-10-24 00:05:00+1';'1648-10-24 00:06:00+1'])); % 4 5
   
   D0 = struct('ObservationID',1:6,'ObservationTime',datenum(1648,10,24,0,1:6,0)','Value',[3.1416 3.1416 3.1416 2 2 2]);

%% extract re-add data  
   R = pg_select_struct(conn,OPT.table,struct('Value','2'));
   OK(end+1) = isequal(cell2mat({R{:,1}}),[4 5 6]);
   tmp = pg_datenum(char({R{:,2}}));
   OK(end+1) = isequal(tmp,datenum(['1648-10-24 00:04:00';'1648-10-24 00:05:00';'1648-10-24 00:06:00']));
   disp(char({R{:,2}}))
   disp('warning: timezone not included yet')
   
   R = pg_select_struct(conn,OPT.table,struct('Value',2));
   OK(end+1) = isequal(cell2mat({R{:,1}}),[4 5 6]);
   tmp = pg_datenum(char({R{:,2}}));
   OK(end+1) = isequal(tmp,datenum(['1648-10-24 00:04:00';'1648-10-24 00:05:00';'1648-10-24 00:06:00']));
   disp(char({R{:,2}}))
   disp('warning: timezone not included yet')
   
   R = pg_select_struct(conn,OPT.table,struct('Value','3.1416'));
   OK(end+1) = isequal(cell2mat({R{:,1}}),[1 2 3]);
   tmp = pg_datenum(char({R{:,2}}));
   OK(end+1) = isequal(tmp,datenum(['1648-10-24 00:01:00';'1648-10-24 00:02:00';'1648-10-24 00:03:00']));
   disp(char({R{:,2}}))
   disp('warning: timezone not included yet')
   
   % for reals, the selection does not work if numeric data 
   % are supplied, perhaps due to machine precision issues
   R = pg_select_struct(conn,OPT.table,struct('Value',3.1416));
   %isequal(cell2mat({D{:,1}}),[1 2 3])

%% extract all, and convert to struct 
   R = pg_select_struct(conn,OPT.table,struct([])); % all
   OK(end+1) = isequal(cell2mat({R{:,1}}),[1 2 3 4 5 6]);
   tmp = pg_datenum(char({R{:,2}}));
   OK(end+1) = isequal(tmp,datenum(['1648-10-24 00:01:00.0';'1648-10-24 00:02:00.0';'1648-10-24 00:03:00.0';'1648-10-24 00:04:00.0';'1648-10-24 00:05:00.0';'1648-10-24 00:06:00.0']));
   disp(char({R{:,2}}))
   disp('warning: timezone not included yet');
   
   [nams,typs] = pg_getcolumns(conn,OPT.table);

   D = pg_fetch2struct(R,nams,typs);
   
   if isfield(D,'timezone')
       D =  rmfield(D,'timezone');
   end
   
   OK(end+1) = structcmp(D,D0,1e-6);
   
%% test column name data-type query  
   for i=1:length(nams)
   [~,t] = pg_getcolumns(conn,OPT.table,{nams{i}});
   typs2{i,1} = char(t);
   end
   OK(end+1) = isequal(typs,typs2);

   
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
% $Id: jdb_test.m 11149 2014-09-29 12:00:29Z rho.x $
% $Date: 2014-09-29 20:00:29 +0800 (Mon, 29 Sep 2014) $
% $Author: rho.x $
% $Revision: 11149 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/jdb/jdb_test.m $
% $Keywords: $
