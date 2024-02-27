function varargout = delft3d_io_meteo_write_example(varargin)
%DELFT3D_IO_METEO_WRITE_EXAMPLE
%
% Example how to convert a set of netCDF meteo files to
% meteo files for Delft3D. It also creates an mdf
% file that can readily be used to check the meteo
% files with Delf3D itself. You can also use this 
% tutorial as function with by specifying <keyword,value>
% arguments. This example uses the GETM meteo file
% variable names as default. Note that GETM has 4 options
% to specify relative humidity, 2 of which are implemented.
%
%See also: netcdf, grib, delft3d_io_meteo_write, getm2delft3d

%%  --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%
%       Gerben de Boer / gerben.deboer@deltares.nl	
%       Deltares / P.O. Box 177 / 2600 MH Delft / The Netherlands
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

%% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
%  OpenEarthTools is an online collaboration to share and manage data and 
%  programming tools in an open source, version controlled environment.
%  Sign up to recieve regular updates of this function, and to contribute 
%  your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
%  $Id: delft3d_io_meteo_write_tutorial.m 9337 2013-10-04 15:56:19Z boer_g $
%  $Date: 2013-10-04 23:56:19 +0800 (Fri, 04 Oct 2013) $
%  $Author: boer_g $
%  $Revision: 9337 $
%  $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/flow/delft3d_io_meteo_write_tutorial.m $
%  $Keywords: $

   OPT.ncfiles        = {'meteo\CFSR.NS.2003.nc','meteo\CFSR.NS.2004.nc'};
   OPT.refdatenum     = datenum(2003,1,1); % for mdf test file
   OPT.period         = datenum(2003,11,[1 8]);
   OPT.workdir        = '';
   OPT.preduplicate   = []; % duplicate first timestep from 1st  file at this earlier date to cover larger period
   OPT.postduplicate  = []; % duplicate last  timestep from last file at this later   date to cover larger period
   OPT.write_amx      = 1;  % external data files can be switched off during debugging
   OPT.suffix         = ''; % to distuinguish temporal subsets

%% map parameters from netcf file to delft3d parameters:
%  For functional conversions, make sure all required variables
%  are loaded before by setting respective OPT.amkeep for to 1.
%  Last loaded dataset (incl itself) is always called data.

   OPT.lon           = 'lon';
   OPT.lat           = 'lat';%                            t2 or sst?       d3d:[%]      d3d:[%]         or ...
                             %                                             gtm:[0..1    gtm:[%]         or ...
   OPT.varnames      = {'slp'         ,'u10'   ,'v10'   ,'t2'             ,'tcc'       ,'rh'               ,'dev2'                                    };
  %CONVERT_UNITS does not work on 'degree Celsius' so we specify conversion factors  
  %OPT.varunits      = {'Pascal'      ,'m/s'   ,'m/s'   ,'deg_C'          ,'.01'       ,'1'                ,'deg_C'                                   };
   OPT.amfac         = {1             ,1        ,1      ,1                ,100         , 1                 ,'relative_humidity(''wmo_water'',t2,data)'};
   OPT.amkeep        = [0              0         0       1                 0           , 0                 ,0                                         ];
   OPT.amfmt         = {'%.6g'        ,'%.3g'  ,'%.3g'  ,'%.3g'           ,'%.3g'      ,'%.3g'             ,'%.3g'                                    };

   OPT.amnames       = {'air_pressure','x_wind','y_wind','air_temperature','cloudiness','relative_humidity','relative_humidity'                       };
   OPT.amext         = {'.amp'        ,'.amu'  ,'.amv'  ,'.amt'           ,'.amc'      ,'rh.amr'           ,'dev2.amr'                                };
   OPT.amunits       = {'Pa'          ,'m s-1' ,'m s-1' ,'Celsius'        ,'%'         ,'%'                ,'%'                                       };
   OPT.amkeyword     = {'fwndgp'      ,'fwndgu','fwndgv','fwndgt'         ,'fwndgc'    ,'fwndgr'           ,'fwndgr'                                  };

   if nargin==0
      varargout = {OPT};
      return
   end
   
   OPT = setproperty(OPT,varargin);
   
   if ischar(OPT.ncfiles)
      OPT.ncfiles = cellstr(OPT.ncfiles);
   end

%% load space dimensions

   D.lon  =         ncread(OPT.ncfiles{  1},OPT.lon);
   D.lat  =         ncread(OPT.ncfiles{  1},OPT.lat);
   
%% load time dimensions

   files2proces  = [];
   for ifile=1:length(OPT.ncfiles)
      T(ifile).count   = nc_getdiminfo(OPT.ncfiles{ifile},'time','Length')-1;
      T(ifile).datenum =    nc_cf_time(OPT.ncfiles{ifile},'time');
      T(ifile).dt      =    mode(diff(T.datenum)); % unique(diff(T(ifile).datenum (ifile))); % deal with hick-ups operational model
      index = find(T(ifile).datenum >= OPT.period(1) & ...
                   T(ifile).datenum <= OPT.period(2));
      if ~isempty(index)
      T(ifile).start   = index(  1);
      T(ifile).stop    = index(end);
      T(ifile).t0      = datestr(T(ifile).datenum(T(ifile).start));
      T(ifile).t1      = datestr(T(ifile).datenum(T(ifile).stop));
      files2proces = [files2proces ifile];
      end
   end

%% create delft3d ascii file headers (and add 1st timestep)

   MDF = delft3d_io_mdf('new');
   
   ifile = files2proces(1);
   for ivar=1:length(OPT.varnames)
     if nc_isvar(OPT.ncfiles{1},OPT.varnames{ivar})
       data = ncread(OPT.ncfiles{1},OPT.varnames{ivar},[1 1 1],[Inf Inf 1]);

       if OPT.amkeep(ivar)
         %disp([OPT.varnames{ivar},' = data;']);
          eval([OPT.varnames{ivar},' = data;']);
       end
       if isnumeric(OPT.amfac{ivar})
          data = data.*OPT.amfac{ivar};
       else
          data = eval(OPT.amfac{ivar});
       end

       amfilename = [mkvar(filename(OPT.ncfiles{ifile})),OPT.suffix,OPT.amext{ivar}]; % D3D cannot handle internal "." , it is reserved for extension
       grdfile    = [      filename(OPT.ncfiles{ifile}),'.grd'];
       encfile    = [      filename(OPT.ncfiles{ifile}),'.enc'];

       if OPT.write_amx
       if isempty(OPT.preduplicate)
          t0 = T(ifile).datenum(T(ifile).start);
          comment = '';
       else
          t0 = OPT.preduplicate;
          comment = ['duplicate of next TIME'];
       end
       fid(ivar) = delft3d_io_meteo_write([OPT.workdir,filesep,amfilename],t0,data,D.lon,D.lat,...
           'CoordinateSystem','Spherical',...
                  'grid_file',grdfile,...
                   'quantity',OPT.amnames{ivar},...
                       'unit',OPT.amunits{ivar},...
                   'writegrd',ivar==1,... % only needed once
                        'fmt',OPT.amfmt{ivar},...
                    'comment',comment,...
                     'header',['source: ',OPT.ncfiles{1}]);
       end %OPT.write_amx
       ADD.keywords.(OPT.amkeyword{ivar}) = amfilename;        
       MDF.keywords.(OPT.amkeyword{ivar}) = amfilename;
     end % isvar
   end % ivar
    
   % do not add 1st timestep again
   if isempty(OPT.preduplicate)
      T(1).start          = min(T(1).start + 1,T(1).stop);
   else
      comment = '';
   end

   MDF.keywords.mnkmax = [size(data)+1 1];
   MDF.keywords.depuni = 1e3;
   MDF.keywords.thick  = 100;
   MDF.keywords.filcco = grdfile;
   MDF.keywords.filgrd = encfile;

   ifile = files2proces(1);
   MDF.keywords.tstart = (T(ifile).datenum(T(ifile).start) - OPT.refdatenum)*24*60;
   ifile = files2proces(end);
   MDF.keywords.tstop  = (T(ifile).datenum(T(ifile).stop) - OPT.refdatenum)*24*60;
   MDF.keywords.dt     = (T(ifile).dt)*24*60;
   MDF.keywords.itdate = datestr(OPT.refdatenum,'yyyy-mm-dd');
   MDF.keywords.flmap  = round([MDF.keywords.tstart MDF.keywords.dt MDF.keywords.tstop]);
   MDF.keywords.flhis  = [0 0 0];
   MDF.keywords.flrst  = 0;

   MDF.keywords.airout = 'yes';  % save p,u,v  to trim file
   MDF.keywords.heaout = 'yes';  % save rh,c,t to trim file
   MDF.keywords.wnsvwp = 'Y';    % spatially varying meteo input
   ADD.keywords.wnsvwp = 'Y';    % spatially varying meteo input
   MDF.keywords.ktemp  = 5; % ocean heat model
   MDF.keywords.secchi = 13.3858;
   MDF.keywords.stantn = 0.00145 ;
   MDF.keywords.dalton = 0.0012 ;
   MDF.keywords.sub1   = ' TW '; % activate temperature and wind
   MDF.keywords.wndint = 'y'; % ?

  %MDF.keywords.Cstbnd = #Y#
  %MDF.keywords.PavBnd = 

%% pump rest of times teps from netcdf to delft3d ascii file
   I = ncinfo(OPT.ncfiles{ifile});
   allvarnames = {I.Variables.Name};

   if OPT.write_amx
   for ifile=files2proces
      for it=T(ifile).start:T(ifile).stop
          
          disp(['file: ',num2str(ifile),' progress: ',num2str(100*it/T(ifile).count,'%07.3f'),' %', datestr(T(ifile).datenum(it),'yyyy-mm-dd HH:MM')])
          
          D.time = T(ifile).datenum(it); %nc_cf_time(OPT.ncfiles{ifile},'time',it);
          
          for ivar=1:length(OPT.varnames)
            if ~any(strcmp(OPT.varnames{ivar},allvarnames))
                % implement 1st here to have warning only once
                warning([OPT.ncfiles{ifile},':',OPT.varnames{ivar},' not found.'])
            else
              data = ncread(OPT.ncfiles{ifile},OPT.varnames{ivar},[1 1 it],[Inf Inf 1]);

              if OPT.amkeep(ivar)
                %disp([OPT.varnames{ivar},' = data;']);
                 eval([OPT.varnames{ivar},' = data;']);
              end
              if isnumeric(OPT.amfac{ivar})
                 data = data.*OPT.amfac{ivar};
              else
                 data = eval(OPT.amfac{ivar});
              end

              delft3d_io_meteo_write(fid(ivar),D.time,data,'fmt',OPT.amfmt{ivar});
              
              if ifile==files2proces && it==T(ifile).stop && ~isempty(OPT.postduplicate)
                 delft3d_io_meteo_write(fid(ivar),OPT.postduplicate,data,'fmt',OPT.amfmt{ivar},'comment',['duplicate of previous TIME']);
              end
              
            end
          end   
      end
   end

%% close delft3d ascii files for further writing

   for ivar=1:length(OPT.varnames);
       if fid(ivar) > 0;
       fclose(fid(ivar));
       end
   end
   end %OPT.write_amx

%% save mdf for unit test simulation

   delft3d_io_mdf('write',[OPT.workdir,filesep,mkvar(filename(OPT.ncfiles{1})),'.mdf'],MDF.keywords); % cannot handle internal "."
   
   varargout = {ADD};
