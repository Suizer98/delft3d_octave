function swan_io_table2nc(S,ncfile,varargin)
%swan_io_table2nc save table structure as netCDF-CF (SWAN does not write netCDF for tables)
%
% swan_io_table2nc(S,ncfile) saves struct S to netCDF file,
% where S = swan_io_table or can be constructed otherwise.
% swan_io_table2nc uses the same variable names as SWAN netCDF 
% itself (agioncmd.f90), so it should be able to use swan_io_table2nc
% to construct SWAN netCDF input.
%
% NB Table fields XP and YP, use keyword coordinates for cartesian/nautical
% NB Table fields TIME is needed for nonstationary datafiles.
% NB Use  SWAN short names for variables (leaving out small caps].
%
%See also: swan_io_spectrum, netcdf, swan_io_spectrum2nc

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Van Oord
%       Gerben de Boer, <gerben.deboer@vanoord.com>
%
%       Watermanweg 64
%       3067 GG
%       Rotterdam
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
% Created: 09 Nov 2012
% Created with Matlab version: 8.0.0.783 (R2012b)

% $Id: running_median_filter.m 10097 2014-01-29 23:02:09Z boer_g $
% $Date: 2014-01-30 00:02:09 +0100 (Thu, 30 Jan 2014) $
% $Author: boer_g $
% $Revision: 10097 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/signal_fun/running_median_filter.m $
% $Keywords: $

%% keywords

OPT.coordinates = 'cartesian';
OPT.project     = '';
OPT.model       = '';
OPT.run         = '';
OPT.swap        = 0; % [time,locations] as in agioncmd, or [locations,time] as 10GB worldwaves
OPT.rename      = {{},{}}; % ERA-40 WAM: {{'HS' ,'RTP' ,'TMM10','HSWELL','DIR'},{'SWH','PP1D','MWP'  ,'SHPS'  ,'fro'}};
OPT.platform_name = '';

OPT = setproperty(OPT,varargin);

%% map vector quantitities

q = swan_quantity;
vecnames = {'VEL','TRA','WIND','FOR'};
for i=1:length(vecnames);
     vecname = vecnames{i};
     if isfield(S,vecname)
         S.([vecname,'_X']) = S.(vecname)(:,:,1);q.([vecname,'_X']) = q.(vecname);
         S.([vecname,'_y']) = S.(vecname)(:,:,2);q.([vecname,'_y']) = q.(vecname);
         S = rmfield(S,vecname);
     end
end

%% detect all switches

    if ~(isfield(S,'XP') & isfield(S,'YP'))
        error('no coordinates speficied')
    end

% coordinates

    if strcmpi(OPT.coordinates,'nautical')
        x = 'XP' ;OPT.x.name = 'longitude' ;OPT.x.units = 'degrees_east' ;OPT.x.cf = 'longitude';
        y = 'YP' ;OPT.y.name = 'latitude'  ;OPT.y.units = 'degrees_north';OPT.y.cf = 'latitude';
    else
        x = 'XP' ;OPT.x.name = 'x';        OPT.x.units = 'meter'        ;OPT.x.cf = 'projection_x_coordinate';
        y = 'YP' ;OPT.y.name = 'y';        OPT.y.units = 'meter'        ;OPT.y.cf = 'projection_y_coordinate';
    end

% non-stationary mode (time /run switch)

    if isfield(S,'TIME')
        OPT.nstatm = true ;
    else
        OPT.nstatm = false ;
        S.TIME = nan; % include dummy dimension
    end

%%
   nc.Name   = '/';
   nc.Format = '64bit'; % 10 GB
   
   nc.Attributes(    1) = struct('Name','title'              ,'Value',  'SWAN table');
   nc.Attributes(end+1) = struct('Name','institution'        ,'Value',  'Tu Delft');
   nc.Attributes(end+1) = struct('Name','source'             ,'Value',  '');
   nc.Attributes(end+1) = struct('Name','history'            ,'Value',  '$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/nctools/ncwritetutorial_grid_lat_lon_curvilinear.m $ $Id: ncwritetutorial_grid_lat_lon_curvilinear.m 8907 2013-07-10 12:39:16Z boer_g $');
   nc.Attributes(end+1) = struct('Name','references'         ,'Value',  'http://svn.oss.deltares.nl');
   nc.Attributes(end+1) = struct('Name','email'              ,'Value',  '');
   nc.Attributes(end+1) = struct('Name','featureType'        ,'Value',  '');

   nc.Attributes(end+1) = struct('Name','comment'            ,'Value',  '');
   nc.Attributes(end+1) = struct('Name','version'            ,'Value',  '');

   nc.Attributes(end+1) = struct('Name','Conventions'        ,'Value',  'CF-1.9');

   nc.Attributes(end+1) = struct('Name','terms_for_use'      ,'Value',  'please specify');
   nc.Attributes(end+1) = struct('Name','disclaimer'         ,'Value',  'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.');
   
   if OPT.nstatm
   nc.Attributes(end+1) = struct('Name','time_coverage_start','Value',datestr(min(S.TIME),'yyyy-mm-ddTHH:MM'));
   nc.Attributes(end+1) = struct('Name','time_coverage_end'  ,'Value',datestr(max(S.TIME),'yyyy-mm-ddTHH:MM'));
   end
   
   nc.Attributes(end+1) = struct('Name','project'               ,'Value', OPT.project);
   nc.Attributes(end+1) = struct('Name','model'                 ,'Value', OPT.model);
   nc.Attributes(end+1) = struct('Name','run'                   ,'Value', OPT.run);
   
%% Dimensions   
   
   nc.Dimensions(    1) = struct('Name', 'time'              ,'Length',length(S.TIME      ));m.t = 1;
   nc.Dimensions(end+1) = struct('Name', 'points'            ,'Length',length(S.(x)       ));m.x = length(nc.Dimensions);m.xy = m.x;
   
%% Coordinates
% swap variable dimensions following C convention, and mimic agioncmd.ftn90

   M.time         = struct('Name','units'        ,'Value','days since 1970-01-01');
   M.time(end+1)  = struct('Name','calendar'     ,'Value','gregorian');
   M.time(end+1)  = struct('Name','standard_name','Value','time');
   M.time(end+1)  = struct('Name','long_name'    ,'Value','time');
   
   M.x            = struct('Name','units'        ,'Value',OPT.x.units);
   M.x(end+1)     = struct('Name','standard_name','Value',OPT.x.cf);
   M.x(end+1)     = struct('Name','long_name'    ,'Value',OPT.x.name);   

   M.y            = struct('Name','units'        ,'Value',OPT.y.units);
   M.y(end+1)     = struct('Name','standard_name','Value',OPT.y.cf);
   M.y(end+1)     = struct('Name','long_name'    ,'Value',OPT.y.name);
   
   nc.Variables(    1) = struct('Name','time'     ,'Datatype','double','Dimensions',nc.Dimensions([m.t  ]),'Attributes',M.time);
   nc.Variables(end+1) = struct('Name',OPT.x.name ,'Datatype','double','Dimensions',nc.Dimensions([m.xy ]),'Attributes',M.x);
   nc.Variables(end+1) = struct('Name',OPT.y.name ,'Datatype','double','Dimensions',nc.Dimensions([m.xy ]),'Attributes',M.y);  
   
%% Platform names

   if ~isempty(OPT.platform_name)
   OPT.platform_name = cellstr(OPT.platform_name);
   nc.Dimensions(end+1) = struct('Name','points_name_length','Length',length(OPT.platform_name));m.name = length(nc.Dimensions);;
   M.platform_name(    1) = struct('Name','standard_name'     ,'Value','platform_name');
   nc.Variables(end+1)  = struct('Name','platform_name','Datatype','char','Dimensions',nc.Dimensions([m.name m.xy]),'Attributes',M.platform_name);
   OPT.coordinates = [OPT.x.name ' ' OPT.y.name ' platform_name'];      
   else
   OPT.coordinates = [OPT.x.name ' ' OPT.y.name];
   end
   
%% Variables

    S.quantity_names = setxor(fieldnames(S),{'XP','YP','TIME'});
 
    for ivar=1:length(S.quantity_names)
        OVSNAM = S.quantity_names{ivar};
       
        ind = find(strcmp(OPT.rename{1},OVSNAM));
        if any(ind)
        S.nc_names{ivar} = OPT.rename{2}{ind};
        else
        S.nc_names{ivar} = OVSNAM;
        end
        
        M.(OVSNAM)(    1) = struct('Name','long_name'     ,'Value',q.(OVSNAM).OVLNAM);
        M.(OVSNAM)(    2) = struct('Name','units'         ,'Value',q.(OVSNAM).OVUNIT);
        M.(OVSNAM)(    2) = struct('Name','standard_name' ,'Value',q.(OVSNAM).OVCFNM);
        M.(OVSNAM)(end+1) = struct('Name','swan_code'     ,'Value',           OVSNAM);        
        M.(OVSNAM)(end+1) = struct('Name','swan_name'     ,'Value',q.(OVSNAM).OVSNAM);        
        M.(OVSNAM)(end+1) = struct('Name','swan_long_name','Value',q.(OVSNAM).OVLNAM);        
        M.(OVSNAM)(end+1) = struct('Name','coordinates'   ,'Value',[OPT.x.name ' ' OPT.y.name]);
        if OPT.swap
        nc.Variables(end+1) = struct('Name',S.nc_names{ivar},'Datatype','double','Dimensions',nc.Dimensions([m.xy m.t]),'Attributes',M.(OVSNAM));
        else
        nc.Variables(end+1) = struct('Name',S.nc_names{ivar},'Datatype','double','Dimensions',nc.Dimensions([m.t m.xy]),'Attributes',M.(OVSNAM));
        end
       
   end
   
%% Create file   

   %var2evalstr(nc)
   if exist(ncfile,'file')
       disp(['File already exist, press enter to replace it, press CTRL_C to quit: ''',ncfile,''''])
       pause
       delete(ncfile)
   end
   ncwriteschema(ncfile, nc);
   ncdisp(ncfile)
   nc_dump(ncfile,'',[filepathstrname(ncfile),'.cdl'])
   
%% write
    ncwrite(ncfile,'time'     ,S.TIME - datenum(1970,0,0))
    ncwrite(ncfile,OPT.x.name ,S.(x))
    ncwrite(ncfile,OPT.y.name ,S.(y))

    if isfield(S,'platform_name')
    ncwrite(ncfile,'platform_name',char(OPT.platform_name)')
    end    
    
    for ivar=1:length(S.quantity_names)
    disp(['processing ',num2str(ivar),': ',S.quantity_names{ivar}])
	if OPT.swap        
        ncwrite(ncfile,S.nc_names{ivar},S.(S.quantity_names{ivar}))
    else
        ncwrite(ncfile,S.nc_names{ivar},S.(S.quantity_names{ivar})')
    end
    end
