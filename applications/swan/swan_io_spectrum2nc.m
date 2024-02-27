function swan_io_spectrum2nc(S,ncfile,varargin)
%swan_io_spectrum2nc save spectral structure as netCDF-CF (same as SWAN does)
%
% swan_io_spectrum2nc(S,ncfile) saves struct S to netCDF file,
% where S = swan_io_spectrum or can be constructed otherwise.
% swan_io_spectrum2nc uses the same variable names as SWAN netCDF 
% itself (agioncmd.f90), so it should be able to use swan_io_spectrum2nc
% to construct SWAN netCDF input.
%
%See also: swan_io_spectrum, netcdf, swan_io_table2nc

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Van Oord
%       Gerben de Boer, <gerben.deboer@vanoord.com>
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

%% TO DO for SWAN?
% - use standard_name for x/y: projection_x_coordinate/projection_y_coordinate
% - double x/y instead of float
% - global attribute Convention with small c
% - global attribute History small h
% - please include an extra variable to store the point names
% - add attribute coordinates
% - add standard name for theta_1d
% - theta_1d:standard_name = "sea_surface_wave_from_direction" ;


%% keywords

OPT.project     = '';
OPT.model       = '';
OPT.run         = '';

OPT = setproperty(OPT,varargin);

%% detect all switches

% coordinates

    if isfield(S,'lon')
        x = 'lon';OPT.x.name = 'longitude';OPT.x.units = 'degrees_east' ;OPT.x.cf = 'longitude';
        y = 'lat';OPT.y.name = 'latitude' ;OPT.y.units = 'degrees_north';OPT.y.cf = 'latitude';
    else
        x = 'x'  ;OPT.x.name = 'x';        OPT.x.units = 'meter'        ;OPT.x.cf = 'projection_x_coordinate';
        y = 'y'  ;OPT.y.name = 'y';        OPT.y.units = 'meter'        ;OPT.y.cf = 'projection_y_coordinate';
    end

% multi dimensional coordinates

    if isvector(S.(x))
        OPT.mdc    = false;
    else
        OPT.mdc    = true;
    end

% non-stationary mode (time /run switch)

    if isfield(S,'time')
        OPT.nstatm = true ;
    else
        OPT.nstatm = false ;
        S.TIME = nan; % include dummy dimension        
    end
    
% 1d or 2d

	OPT.ndir = 0;
    if   isfield(S,'directions')
        OPT.ndir = length(S.directions);
        if strcmpi(S.direction_convention,'nautical')
            OPT.d.cf     = 'sea_surface_wave_from_direction';
            OPT.nautical = true;
        else
            OPT.d.cf     = 'sea_surface_wave_to_direction';
            OPT.nautical = false;
        end
    else
        if     isfield(S,'NDIR')
            OPT.d.name = 'spread_1d';OPT.d.cf = 'sea_surface_wave_from_direction';
            OPT.nautical = true;
        elseif isfield(S,'CDIR')
            OPT.d.name = 'spread_1d';OPT.d.cf = 'sea_surface_wave_to_direction';
            OPT.nautical = false;
        end        
    end    

    if strcmpi(S.frequency_type,'absolute')
        OPT.relative_to_current = 0;% netcdf can't handle logicala
    else
        OPT.relative_to_current = 1;
    end

%%
   nc.Name   = '/';
   nc.Format = '64bit'; % 10 GB
   
   nc.Attributes(    1) = struct('Name','title'              ,'Value',  'SWAN spectrum');
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
   nc.Attributes(end+1) = struct('Name','time_coverage_start','Value',datestr(min(S.time),'yyyy-mm-ddTHH:MM'));
   nc.Attributes(end+1) = struct('Name','time_coverage_end'  ,'Value',datestr(max(S.time),'yyyy-mm-ddTHH:MM'));
   end
   
   nc.Attributes(end+1) = struct('Name','project'            ,'Value', OPT.project);
   nc.Attributes(end+1) = struct('Name','model'              ,'Value', OPT.model);
   nc.Attributes(end+1) = struct('Name','run'                ,'Value', OPT.run);
   
%% Dimensions   
   
   nc.Dimensions(    1) = struct('Name', 'time'              ,'Length',length(S.time      ));m.t = 1;
   
   if OPT.mdc
   nc.Dimensions(end+1) = struct('Name', OPT.x.name          ,'Length',length(S.(x)       ));m.x = length(nc.Dimensions);
   nc.Dimensions(end+1) = struct('Name', OPT.y.name          ,'Length',length(S.(x)       ));m.y = length(nc.Dimensions);m.xy = [m.x m.y];
   else
   nc.Dimensions(end+1) = struct('Name', 'points'            ,'Length',length(S.(x)       ));m.x = length(nc.Dimensions);m.xy = m.x;
   end
   
   nc.Dimensions(end+1) = struct('Name', 'frequency'         ,'Length',length(S.frequency ));m.f = length(nc.Dimensions);

   if isfield(S,'directions')
   nc.Dimensions(end+1) = struct('Name', 'direction'         ,'Length',length(S.directions));m.d = length(nc.Dimensions); %  NB dropping of -s
   nc.Attributes(end+1) = struct('Name','Directional_convention','Value',S.direction_convention);
   end
   
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
   
   M.frequency        = struct('Name','units'        ,'Value','s-1');
   M.frequency(end+1) = struct('Name','standard_name','Value','wave_frequency');
   M.frequency(end+1) = struct('Name','flow'         ,'Value',min(S.frequency));
   M.frequency(end+1) = struct('Name','fhigh'        ,'Value',max(S.frequency));
   M.frequency(end+1) = struct('Name','msc'          ,'Value',length(S.frequency)-1);
   
   nc.Variables(    1) = struct('Name','time'     ,'Datatype','double','Dimensions',nc.Dimensions([m.t  ]),'Attributes',M.time);
   nc.Variables(end+1) = struct('Name',OPT.x.name ,'Datatype','double','Dimensions',nc.Dimensions([m.xy ]),'Attributes',M.x);
   nc.Variables(end+1) = struct('Name',OPT.y.name ,'Datatype','double','Dimensions',nc.Dimensions([m.xy ]),'Attributes',M.y);  
   nc.Variables(end+1) = struct('Name','frequency','Datatype','double','Dimensions',nc.Dimensions([m.f  ]),'Attributes',M.frequency);  

   if isfield(m,'d')
   M.d            = struct('Name','units'        ,'Value','degree');
   M.d(end+1)     = struct('Name','long_name'    ,'Value','direction');
   M.d(end+1)     = struct('Name','standard_name','Value',OPT.d.cf);
   M.d(end+1)     = struct('Name','mdc'          ,'Value',length(S.directions));   
   nc.Variables(end+1) = struct('Name','direction','Datatype','double','Dimensions',nc.Dimensions([m.d  ]),'Attributes',M.d);
   end
   
%% Platform names

   if isfield(S,'platform_name')
   nc.Dimensions(end+1) = struct('Name','points_name_length','Length',size(S.platform_name,2));m.name = length(nc.Dimensions);;
   M.platform_name(    1) = struct('Name','standard_name'     ,'Value','platform_name');
   nc.Variables(end+1)  = struct('Name','platform_name','Datatype','char','Dimensions',nc.Dimensions([m.name m.xy]),'Attributes',M.platform_name);
   OPT.coordinates = [OPT.x.name ' ' OPT.y.name ' platform_name'];      
   else
   OPT.coordinates = [OPT.x.name ' ' OPT.y.name];
   end
   
%% Variables 
    for ivar=1:length(S.quantity_names)
       varcode = S.quantity_names{ivar};
       
       if     strcmpi(varcode,'VaDens') | strcmpi(varcode,'EnDens')
           
        if OPT.ndir > 0
        M.density(    1) = struct('Name','long_name',     'Value','density');
        M.density(end+1) = struct('Name','units'        , 'Value',strrep(S.quantity_units{ivar},'/Hz',' s'));
        M.density(end+1) = struct('Name','standard_name', 'Value','sea_surface_wave_directional_variance_spectral_density');
        M.density(end+1) = struct('Name','swan_code',     'Value',varcode);
        M.density(end+1) = struct('Name','swan_name',     'Value',varcode);
        M.density(end+1) = struct('Name','swan_long_name','Value',S.quantity_names_long{ivar});
        M.density(end+1) = struct('Name','relative_to_current','Value',OPT.relative_to_current);
        M.density(end+1) = struct('Name','coordinates'   ,'Value',OPT.coordinates);        
        
        nc.Variables(end+1) = struct('Name','density' ,'Datatype','double','Dimensions',nc.Dimensions([m.d m.f m.xy m.t]),'Attributes',M.density); % density(time, points, frequency, direction) ;
        S.nc_names{ivar} = 'density';
        S.(varcode) = permute(S.(varcode),[3 2 1 4]); % [m.xy m.f m.d m.t] > [m.d m.f m.xy m.t]
        else
        M.density(    1) = struct('Name','long_name',     'Value','energy');
        M.density(end+1) = struct('Name','units'        , 'Value',strrep(S.quantity_units{ivar},'/Hz',' s'));
        M.density(end+1) = struct('Name','standard_name', 'Value','sea_surface_wave_directional_variance_spectral_density');
        M.density(end+1) = struct('Name','swan_code',     'Value',varcode);
        M.density(end+1) = struct('Name','swan_name',     'Value',varcode);
        M.density(end+1) = struct('Name','swan_long_name','Value',S.quantity_names_long{ivar});
        M.density(end+1) = struct('Name','relative_to_current','Value',OPT.relative_to_current);
        M.density(end+1) = struct('Name','coordinates'   ,'Value',OPT.coordinates);        
        
        nc.Variables(end+1) = struct('Name','energy_1d','Datatype','double','Dimensions',nc.Dimensions([   m.f m.xy m.t]),'Attributes',M.density);
        S.nc_names{ivar} = 'energy_1d';
        S.(varcode) = permute(S.(varcode),[2 1 3]);   % [    m.xy m.f m.t] > [    m.f m.xy m.t]        
        end
       
       elseif strcmpi(varcode,'NDIR') | strcmpi(varcode,'CDIR')
           
        M.DIR(    2) = struct('Name','long_name'     ,'Value','principal wave direction');
        M.DIR(    1) = struct('Name','units'         ,'Value','degree');
        M.DIR(end+1) = struct('Name','standard_name' ,'Value',OPT.d.cf);
        M.DIR(end+1) = struct('Name','scale_factor'  ,'Value',1);
        M.DIR(end+1) = struct('Name','add_offset'    ,'Value',0);        
        M.DIR(end+1) = struct('Name','swan_code'     ,'Value',varcode);
        M.DIR(end+1) = struct('Name','swan_name'     ,'Value',varcode);
        M.DIR(end+1) = struct('Name','swan_long_name','Value',S.quantity_names_long{ivar});
        M.DIR(end+1) = struct('Name','coordinates'   ,'Value',OPT.coordinates);        
        nc.Variables(end+1) = struct('Name','theta_1d' ,'Datatype','double','Dimensions',nc.Dimensions([m.xy m.f     m.t]),'Attributes',M.DIR);
        S.nc_names{ivar} = 'theta_1d';
        
       elseif strcmpi(varcode,'DSPRDEGR') 
           
        M.DSPRDEGR(    2) = struct('Name','long_name'     ,'Value','Longuet-Higgins short-crestedness parameter (s in cos(theta/2)^2s)');
        M.DSPRDEGR(    1) = struct('Name','units'         ,'Value','degree');
        M.DSPRDEGR(end+1) = struct('Name','swan_code'     ,'Value',varcode);        
        M.DSPRDEGR(end+1) = struct('Name','swan_name'     ,'Value',varcode);        
        M.DSPRDEGR(end+1) = struct('Name','swan_long_name','Value',S.quantity_names_long{ivar});        
        M.DSPRDEGR(end+1) = struct('Name','coordinates'   ,'Value',[OPT.x.name ' ' OPT.y.name]);        
        nc.Variables(end+1) = struct('Name','spread_1d','Datatype','double','Dimensions',nc.Dimensions([m.xy m.f     m.t]),'Attributes',M.DSPRDEGR);
        S.nc_names{ivar} = 'spread_1d';
       
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
    ncwrite(ncfile,'time'     ,S.time - datenum(1970,0,0))
    ncwrite(ncfile,OPT.x.name ,S.(x))
    ncwrite(ncfile,OPT.y.name ,S.(y))
    ncwrite(ncfile,'frequency',S.frequency);
    
    if OPT.ndir > 1
    ncwrite(ncfile,'direction',S.directions); %  NB dropping of -s
    end
    
    if isfield(S,'platform_name')
    ncwrite(ncfile,'platform_name',char(S.platform_name)')
    end    
    
    for ivar=1:length(S.quantity_names)
    ncwrite(ncfile,S.nc_names{ivar},S.(S.quantity_names{ivar}))
    end
