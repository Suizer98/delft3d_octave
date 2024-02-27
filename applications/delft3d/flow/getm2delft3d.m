function MDF = getm2delft3d(OPT0,getm0)
%getm2delft3d convert GETM grid, depth and boundary conditions input to Delft3D input
%
%  getm2delft3d(OPT,getm,<keyword,value>) where OPT and getm contain values to overwrite defaults.
%
% getm is a struct representation of the GETM Fortran namelist input file,
% which can be parsed with FORTRAN_NAMELIST2STRUCT(). getm should
% only contain those fields that need to be overwritten in the *.inp file specified,
% for instance setting that differ per monthly or annual run such as:
% getm.time.start, getm.time.stop, 
% getm.param.hotstart, getm.m2d.elev_file, getm.temp.temp_file, getm.salt.salt_file
%
% The Delft3D RUNID is used to name the time-dependent files (bct, bcc, dis, ini)
% rather than the getm file names, to make sure that different temporal subsets
% get different names.
%
% GETM:
%  getm.domain.bathymetry  = '*.nc';  % name of GETM netCDF topo file
%  getm.domain.bdyinfofile = '*.dat'; % name of GETM ascii boundary definitions
%  getm.m2d.bdyfile_2d     = '*.nc';  % name of GETM netCDF 2D boundary condition values
%  getm.m3d.bdyfile_3d     = '*.nc';  % name of GETM netCDF 3D boundary condition values
%  getm.rivers.river_info  = '*.dat';
%  getm.rivers.river_data  = '*.nc';
%
% OPT:
% * inp            - name of GETM Fortran namelist input file
% * mdf            - empty settings file for Delft3D input
% * reference_time - reference time for Delft3D input
% * points_per_bnd - stride for converting GETM bdy values to Delft3D bnd segments:
%                    is at least 2 because Delft3D has boundary segments that
%                    connect 2 endpoints, whereas GETM has seperate boundary points
%
%See also: delft3d, fortran_namelist2struct

%%  --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%
%       Gerben de Boer
%
%       gerben.deboer@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
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
%  $Id: getm2delft3d.m 9087 2013-08-20 15:12:47Z boer_g $
%  $Date: 2013-08-20 23:12:47 +0800 (Tue, 20 Aug 2013) $
%  $Author: boer_g $
%  $Revision: 9087 $
%  $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/flow/getm2delft3d.m $
%  $Keywords: $

   OPT.inp             = '*.inp'; % fortran namelist, not yet xml

  %getm.domain.bathymetry  = '';
  %getm.domain.bdyinfofile = '*.dat';
  %getm.m2d.bdyfile_2d     = '*.nc';
  %getm.m3d.bdyfile_3d     = '*.nc';
  %getm.rivers.river_info  = '*.dat';
  %getm.rivers.river_data  = '*.nc';

   OPT.RUNID          = mfilename;
   OPT.bdy3d_nudge    = 1; % shift 1st and last bcc to match simulation time
   OPT.reference_time = datenum(2003,1,1); % overwrites on in mdf, used for *.bct and *.dis
   OPT.mdf            = '*.mdf';
   OPT.points_per_bnd = 2;
   OPT.ntmax          = []; % for debugging save only so many boundary time points: [] means adapt to sim time, Inf is everything
   OPT.d3ddir         = '';
   OPT.nan.dis        = 0; % value to use for filling of NaNs
   OPT.nan.bct        = 0; % value to use for filling of NaNs, use [] for linear interpolation in time (mind leading and trlaing nans)
   OPT.kmax           = [];
   OPT.dt             = 1; % also used for rounding off bcc support points
   OPT.fmt.elev       = ' %+.3f'; % waterlevel float in mm
   OPT.fmt.salt       = ' %.2f'; % 1% precision
   OPT.fmt.temp       = ' %.2f'; % 1% precision
   OPT.min_salt       = 0;    % getm has different valid range (incl ice) than delft3d (> 0)
   OPT.min_temp       = 0.01; % getm has different valid range (incl ice) than delft3d (> 0)
   OPT.restid         = '';

   OPT.dt.map         = 60;
   OPT.dt.his         = 10;   
   OPT.dt.com         = 0;   
   OPT.dt.waq         = 60;   
   OPT.dt.bct         = 10; % correct floating precision errors from GETM
   OPT.dt.bcc         = 10; % correct floating precision errors from GETM
   OPT.dt.dis         = 10; % correct floating precision errors from GETM

   % switch off generating a particiular external files, while mdf stays identical to speed up debugging other external files
   OPT.write.grd      = 1;
   OPT.write.dep      = 1; % requires OPT.write.grd for sigma levels  
   OPT.write.rst      = 1; % requires OPT.write.dep for sigma levels
   OPT.write.bct      = 1;
   OPT.write.bcc      = 1; % requires OPT.write.bct for sigma levels and OPT.write.dep
   OPT.write.dis      = 1;

   OPT = setproperty(OPT,OPT0);
   
%% load input

   getm0.rivers.use_river_salt   = 1; % delft3d cannot neglect it
   getm0.rivers.use_river_temp   = 1; % delft3d cannot neglect it

   if ~isempty(OPT.inp)

      getm = fortran_namelist2struct(OPT.inp);
      if ~isempty(OPT.kmax)
      getm.domain.kdum = OPT.kmax;
      end
      
   else
   % initialize getm with flow defaults
      getm.param.title             = '';
      getm.param.runid             = OPT.RUNID;
      getm.time.start              = [];
      getm.time.stop               = [];
      getm.domain.vel_depth_method = 0;
      getm.domain.longitude        = [];
      getm.domain.latitude         = [];
      getm.domain.f_plane          = 0;
      getm.domain.crit_depth       = .3;
      getm.domain.min_depth        = .1;
      getm.domain.kdum             = 1;
      getm.domain.z0_method        = 0;
      getm.domain.z0_const         = 0.001;
      getm.meteo.metforcing        = 0;
      getm.meteo.met_method        = 1;
      getm.m2d.elev_method         = 1;
      getm.m2d.elev_const          = 0;
      getm.m2d.Am                  = 1;
      getm.m2d.An_const            = 1;
      getm.m3d.avmback             = 1e-6;
      getm.m3d.avhback             = 1e-6;
      getm.temp.temp_method        = 1;
      getm.temp.temp_const         = 15;
      getm.salt.salt_method        = 1;
      getm.salt.salt_const         = 31;
   end
   
   getm = mergestructs('overwrite','recursive',getm,getm0);

%% translate input

   MDF  = delft3d_io_mdf('new');
   MDF.keywords.runtxt = getm.param.title;
   MDF.keywords.tstart = (datenum(getm.time.start,'yyyy-mm-dd hh:MM:ss') - OPT.reference_time)*24*60;
   MDF.keywords.tstop  = (datenum(getm.time.stop ,'yyyy-mm-dd hh:MM:ss') - OPT.reference_time)*24*60;
   MDF.keywords.itdate = datestr(OPT.reference_time,'yyyy-mm-dd');
                          %123456789012345678901234567890
   MDF.keywords.runtxt = ['GETM converted to Delft3D from',...
                          filenameext(OPT.inp      ),';',...
                          filenameext(getm.domain.bathymetry),';',...
                          getm.param.title,';',...
                          '$Revision: 9087 $ ',...
                          '$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/flow/getm2delft3d.m $'];
   
   MDF.keywords.anglon = getm.domain.longitude;
   MDF.keywords.anglat = getm.domain.latitude;
   MDF.keywords.dryflc = getm.domain.min_depth;
   MDF.keywords.vicouv = getm.m2d.Am;
   MDF.keywords.dicouv = getm.m2d.An_const;
   MDF.keywords.forfww = 'Y';% hardcoded for now
   MDF.keywords.sigcor = 'Y';% hardcoded for now
   MDF.keywords.tlfsmo = 720;% hardcoded for now
   if OPT.min_salt <0;error('min_salt should be >=0 in Delft3D');end
   if OPT.min_temp <0;error('min_temp should be >=0 in Delft3D');end
   MDF.keywords.vicoww = max(getm.m3d.avmback,1e-5); % Guus Stelling, pers.com.: min 1e-5
   warning([mfilename,' added vertical background viscosity of 1e-5'])
   MDF.keywords.dicoww =     getm.m3d.avhback;
   MDF.keywords.thick  = repmat(roundoff(100/getm.domain.kdum,4),[getm.domain.kdum 1]);
   err = 100-sum(MDF.keywords.thick);
   if err > 0
      MDF.keywords.thick(1) = MDF.keywords.thick(1) + err;
      warning([mfilename,' adapted thick(1) to get sum 100% with: ',num2str(err)])
   end
   MDF.keywords.denfrm = 'UNESCO'; % d3d default
   if ~(getm.eqstate.eqstate_method==2)
      warning([mfilename,' equation of state not implemented in delft3d, only Eckert & Unesco (default)'])
   end
   switch getm.domain.vel_depth_method
   case 0, MDF.keywords.dpuopt = 'mean';
   case 1, MDF.keywords.dpuopt = 'min';
   case 2, MDF.keywords.dpuopt = 'upw';
   end
   MDF.keywords.dpuopt  = 'MIN'; % required in combination with depth at centers
   
   if ~exist(OPT.d3ddir,'dir')
       mkpath(OPT.d3ddir)
       disp(['Created: ',OPT.d3ddir])
   end

   delft3d_io_mdf('write',[OPT.d3ddir,filesep,OPT.RUNID,'.mdf'],MDF.keywords); % updated and overwritten after each new addition
   
   if isempty(OPT.dt.dis);OPT.dt.dis = MDF.keywords.dt;end
   if isempty(OPT.dt.bct);OPT.dt.bct = MDF.keywords.dt;end
   if isempty(OPT.dt.bcc);OPT.dt.bcc = MDF.keywords.dt;end
   
%% grid and depth and dry
%  chop fully dry part from grid vertices (4 surrounding dry points)
%  to exclude it from computational domain
   if OPT.write.grd
  [D,M] = nc2struct(getm.domain.bathymetry,'exclude',{'latc','lonc','convc','z0'});
   D.bathymetry(D.bathymetry==M.bathymetry.missing_value)=NaN; % missing_value in netCDF has incorrect datatype, so we have to apply it ourselves.
  
  [D.cor.x,D.cor.y]=meshgrid(D.xx(2:end-1),D.yx(2:end-1));
   D.cor.mask = corner2centernan(isnan(D.bathymetry));

   D.cor.lat = corner2center(nc_varget(getm.domain.bathymetry,'latc'));
   D.cor.lon = corner2center(nc_varget(getm.domain.bathymetry,'lonc'));

   D.cor.x  (D.cor.mask==1)=nan; % mask is 0|.25|.5|.75|1
   D.cor.y  (D.cor.mask==1)=nan;
   D.cor.lat(D.cor.mask==1)=nan; % mask is 0|.25|.5|.75|1
   D.cor.lon(D.cor.mask==1)=nan;
   
   D.cor.z = corner2center(D.bathymetry);
   end % OPT.write.grd 
   
   if getm.domain.f_plane & ~(getm.meteo.metforcing)
   MDF.keywords.filcco  = [filename(getm.domain.bathymetry),'_cartesian.grd'];
   filcc2               = [filename(getm.domain.bathymetry),'_spherical.grd'];
   if OPT.write.grd;wlgrid('write','FileName',[OPT.d3ddir,filesep,MDF.keywords.filcco],'X',D.cor.x'  ,'Y',D.cor.y'  ,'CoordinateSystem','Cartesian');end
   if OPT.write.grd;wlgrid('write','FileName',[OPT.d3ddir,filesep,             filcc2],'X',D.cor.lon','Y',D.cor.lat','CoordinateSystem','Spherical');end
   else
   if getm.domain.f_plane
   warning([mfilename,' delft3d cannot handle f_plane and spatially varying meteo simultaneously: using spatially varying Coriolis parameter with spherical coordinates'])
   end
   MDF.keywords.filcco  = [filename(getm.domain.bathymetry),'_spherical.grd'];
   filcc2               = [filename(getm.domain.bathymetry),'_cartesian.grd'];
   if OPT.write.grd;wlgrid('write','FileName',[OPT.d3ddir,filesep,MDF.keywords.filcco],'X',D.cor.lon','Y',D.cor.lat','CoordinateSystem','Spherical');end
   if OPT.write.grd;wlgrid('write','FileName',[OPT.d3ddir,filesep,             filcc2],'X',D.cor.x'  ,'Y',D.cor.y'  ,'CoordinateSystem','Cartesian');end
   end
  %wlgrid('write','FileName',[OPT.d3ddir,filesep,MDF.keywords.filcco],'X',D.xx(2:end-1),'Y',D.yx(2:end-1)); % this would keep land cells defined and thus yield too many dry points
   
   MDF.keywords.filgrd  = [filename(getm.domain.bathymetry),'.enc'           ];
   MDF.keywords.fildep  = [filename(getm.domain.bathymetry),'_at_centers.dep'];
   MDF.keywords.fildry  = [filename(getm.domain.bathymetry),'.dry'           ];
   MDF.keywords.dpsopt  = 'DP';
   MDF.keywords.mnkmax  = [fliplr(nc_getvarinfo(getm.domain.bathymetry,'bathymetry','Size')) getm.domain.kdum];

   if OPT.write.grd
   D.enclosure = enclosure('extract',D.cor.x',D.cor.y');
   enclosure('write',[OPT.d3ddir,filesep,MDF.keywords.filgrd],D.enclosure);
   end %if OPT.write.grd

   if OPT.write.dep
   wldep    ('write',[OPT.d3ddir,filesep,MDF.keywords.fildep],'',D.bathymetry'); % already includes 2 dummy rows/cols
   wldep    ('write',[OPT.d3ddir,filesep,strrep(MDF.keywords.fildep,'center','corner')],'',addrowcol(D.cor.z',1,1,nan)); % includes 2 dummy rows/cols

%% dry points: those not yet excluded by removing vertices
%  all inactive T-cells with 4 real vertices: (i) a square, (ii) a c or u shape, or (iii) a ||-shape.
%  In contrast: -shape or | shapes are aready switched off in vertices.
   
   D.cen.mask = isnan(D.bathymetry(2:end-1,2:end-1))&... % z is nan
               (corner2center(~isnan(D.cor.x))==1); % and all surrouning corners are real which can be: 
   
   [n,m] = find(D.cen.mask);
   %pcolorcorcen(D.cen.mask);
   %plot(m,n,'ko');
   delft3d_io_dry('write',[OPT.d3ddir,filesep,MDF.keywords.fildry],m+1,n+1);
   
%% save mask for ascii diff comparison with supplied GETM mask

   fid = fopen([OPT.d3ddir,filesep,'mask.txt'],'w');
   for row=size(D.bathymetry,1):-1:1
      fprintf(fid,'%1d ',~isnan(D.bathymetry(row,1:end-1)));
      fprintf(fid,'%1d' ,~isnan(D.bathymetry(row,  end  ))); % no trailing space
      fprintf(fid,'\n');
   end
   fclose(fid);
   end %OPT.write.dep
   
%% roughness

   MDF.keywords.roumet = 'Z'; % only option in GETM anyway
   if getm.domain.z0_method==0
      MDF.keywords.ccofu  =  getm.domain.z0_const;
      MDF.keywords.ccofv  =  getm.domain.z0_const;
   elseif getm.domain.z0_method==1
      D.z0 = ncread(getm.domain.bathymetry,'z0');
      MDF.keywords.filrgh  = ['z0_at_centers.dep'];
      wldep    ('write',[OPT.d3ddir,filesep,MDF.keywords.filrgh],'',D.z0); % already includes 2 dummy rows/cols
      fprintf(2,'space varying roughness not yet tested')
   end

   delft3d_io_mdf('write',[OPT.d3ddir,filesep,OPT.RUNID,'.mdf'],MDF.keywords); % updated and overwritten after each new addition

%% meteo forcing

   if getm.meteo.metforcing
      MDF.keywords.sub1(3) = 'W';
      if getm.m3d.calc_temp
         if getm.meteo.calc_met
            MDF.keywords.ktemp = 5;
         else
            warning([mfilename,' find new ktemp number for direct meteo flux prescription (Deepak)'])
         end
      end
      if     getm.meteo.met_method==1
         MDF.keywords.filwnd = 'todo.wnd';
         MDF.keywords.filtem = 'todo.tem';
         warning([mfilename,' to do: *.wnd + *.tem'])
      elseif getm.meteo.met_method==2
         MDF.keywords.wnsvwp  = 'Y';
         disp('run delft3d_io_meteo_write_tutorial.m for spatial meteo files')
      end
   end

   delft3d_io_mdf('write',[OPT.d3ddir,filesep,OPT.RUNID,'.mdf'],MDF.keywords); % updated and overwritten after each new addition
   
%% initial conditions
%  Note: initialize barotropic in case baroclinic temp/salt is initialized

   INI = struct();

   if getm.m2d.elev_method==1
      MDF.keywords.zeta0 = getm.m2d.elev_const;
   else
      % INI.waterlevel = f(getm.m2d.elev_file);
      INI.waterlevel = repmat(0,MDF.keywords.mnkmax(1:2));
      warning([mfilename,' ini/hotstart not yet implemented, zeros inserted for waterlevel'])
   end
   
   % calc_* means it solves the equation (d3d has no diagnostic mode, getm.param.runtype is irrelevant)
   % 0: read from hotstart file
   % 1: constant
   % 2: homogeneous stratification
   % 3: from 3D field
    
   if getm.temp.temp_method ==3 |  getm.salt.salt_method ==3
      if ~isfield(INI,'waterlevel')
      INI.waterlevel = repmat(0,MDF.keywords.mnkmax(1:2));
      end
      INI.u = repmat(0,MDF.keywords.mnkmax);
      INI.v = repmat(0,MDF.keywords.mnkmax);
      warning([mfilename,' ini/hotstart not yet implemented, zeros inserted for (u,v)'])
   end
   
   if getm.m3d.calc_temp;
      MDF.keywords.sub1(2) = 'T';
      if getm.temp.temp_method==0
         warning([mfilename,' GETM ASCII hotstart not yet implemented 4 temp'])
      elseif getm.temp.temp_method==1
         if isfield(INI,'waterlevel')
         INI.temperature = repmat(getm.temp.temp_const,MDF.keywords.mnkmax);
         else
         MDF.keywords.t0 = repmat(getm.temp.temp_const,size(MDF.keywords.thick));
         end
      elseif getm.temp.temp_method==2
         warning([mfilename,' GETM homogenous stratification not yet implemented 4 temp'])
      elseif getm.temp.temp_method==3
         if getm.temp.temp_format==1
            error([mfilename,' GETM ASCII 3D field not yet implemented 4 temp'])
         else
            if OPT.write.rst
            INI.temperature = repmat(0,MDF.keywords.mnkmax);
            warning([mfilename,' 3D z/sigma interpolation not validated: check up/down and relation to getm.domain.maxdepth'])
            tmp.zax  = ncread([getm.temp.temp_file],'zax'); % POSITIVE DOWN
            tmp.time = ncread([getm.temp.temp_file],'time');
            tmp.data = ncread([getm.temp.temp_file],getm.temp.temp_name,[1 1 1 getm.temp.temp_field_no],[Inf Inf Inf 1]); % 1-based indices
            disp([mfilename,' interpolating 3D initial conditions temp field, please wait ...'])
            INI.temperature = interp_z2sigma(-tmp.zax,tmp.data,(d3d_sigma(MDF.keywords.thick./100)),0,-D.bathymetry');
            INI.temperature(isnan(INI.temperature ))=0; % d3d cannot handle nans
            end
         end
      end
   end

   if getm.m3d.calc_salt;
      MDF.keywords.sub1(1) = 'S';
      if getm.salt.salt_method==0
         %if getm.salt.salt_format==0
         %else
         warning([mfilename,' GETM hotstart not yet implemented 4 salt'])
         %end
      elseif getm.salt.salt_method==1
         if isfield(INI,'waterlevel')
         INI.salinity    = repmat(getm.salt.salt_const,MDF.keywords.mnkmax);
         else
         MDF.keywords.s0 = repmat(getm.salt.salt_const,size(MDF.keywords.thick));
         end
      elseif getm.salt.salt_method==2
         warning([mfilename,' GETM homogenous stratification not yet implemented 4 salt'])
      elseif getm.salt.salt_method==3
         if getm.salt.salt_format==1
            error([mfilename,' GETM ASCII 3D field not yet implemented 4 salt'])
         else
            if OPT.write.rst
            INI.salinity = repmat(0,MDF.keywords.mnkmax);
            warning([mfilename,' 3D z/sigma interpolation not validated: check up/down and relation to getm.domain.maxdepth'])
            tmp.zax  = ncread([getm.salt.salt_file],'zax'); % POSITIVE DOWN
            tmp.time = ncread([getm.salt.salt_file],'time');
            tmp.data = ncread([getm.salt.salt_file],getm.salt.salt_name,[1 1 1 getm.salt.salt_field_no],[Inf Inf Inf 1]); % 1-based indices
            disp([mfilename,' interpolating 3D initial conditions salt field, please wait ...'])
            INI.salinity = interp_z2sigma(-tmp.zax,tmp.data,(d3d_sigma(MDF.keywords.thick./100)),0,-D.bathymetry');
            INI.salinity(isnan(INI.salinity ))=0; % d3d cannot handle nans
            % *** ERROR NaN found in r1 (restart-file) at (n,m,k,l) = (           1,          47,           1,           1) 
            end
         end
      end
   end
   clear tmp
   
   INI.tke         = repmat(0,MDF.keywords.mnkmax+[0 0 1]); % at sigma-faces
   INI.dissipation = repmat(0,MDF.keywords.mnkmax+[0 0 1]); % at sigma-faces
   INI.ufiltered   = repmat(0,MDF.keywords.mnkmax(1:2));
   INI.vfiltered   = repmat(0,MDF.keywords.mnkmax(1:2));
   
   if ~isempty(OPT.restid)
      MDF.keywords.restid = OPT.restid;
   else
      MDF.keywords.restid = OPT.RUNID;
   end
   if ~isempty(fieldnames(INI)) % use rst, ini becomes way too big
     if OPT.write.rst
       if exist(                  [OPT.d3ddir,filesep,'tri-rst.',MDF.keywords.restid],'file')
       delete  (                  [OPT.d3ddir,filesep,'tri-rst.',MDF.keywords.restid])
       warning(['Overwritten: ',  [OPT.d3ddir,filesep,'tri-rst.',MDF.keywords.restid]])
       delft3d_io_restart('write',[OPT.d3ddir,filesep,'tri-rst.',MDF.keywords.restid],INI,'linux');
       end
     end %OPT.write.rst    
   end
   
   delft3d_io_mdf('write',[OPT.d3ddir,filesep,OPT.RUNID,'.mdf'],MDF.keywords); % updated and overwritten after each new addition
   
%% BAROTROPIC and BAROCLINIC BOUNDARY LOCATIONS AND CONDITIONS
%  boundary positions not truly generic yet, should be via az matrix to remove 
%  internal corners at connections of vertical e/w and horizontal n/s boundaries
   
   B.time         = ncread(getm.m2d.bdyfile_2d ,'time');
   B.datenum      = udunits2datenum(B.time,ncreadatt(getm.m2d.bdyfile_2d ,'time','units'));
   B.minutes      = (B.datenum-OPT.reference_time)*24*60;
   B.minutes      = roundoff(B.minutes,OPT.dt.bct,'round','multiple');  %make sure times are multiple of time step
   B.minutes(end) = B.minutes(end) + MDF.keywords.dt; % make sure to keep full time range

   warning([mfilename,' 3D z/sigma interpolation not validated: check up/down and relation to getm.domain.maxdepth'])

   C.zax          = ncread(getm.m3d.bdyfile_3d,'zax'); % POSITIVE DOWN
   C.time         = ncread(getm.m3d.bdyfile_3d,'time');
   C.datenum      = udunits2datenum(C.time,ncreadatt(getm.m3d.bdyfile_3d,'time','units'));
   C.minutes      = (C.datenum-OPT.reference_time)*24*60;
   C.minutes      = roundoff(C.minutes,OPT.dt.bcc,'round','multiple');  %make sure times are multiple of time step
   C.minutes(end) = C.minutes(end) + MDF.keywords.dt; % make sure to keep full time range
   C.kmax         = MDF.keywords.mnkmax(3);

% fill NaN gaps (drying overall model) with linear interpolation in time
      
   if isempty(OPT.ntmax)
   bctmask = find(B.datenum >= datenum(getm.time.start,'yyyy-mm-dd hh:MM:ss') & ...
                  B.datenum <= datenum(getm.time.stop ,'yyyy-mm-dd hh:MM:ss'));
   if MDF.keywords.tstart < B.minutes(bctmask(  1)); error('start time before first 2D boundary data');end
   if MDF.keywords.tstop  > B.minutes(bctmask(end)); error('start time after  last  2D boundary data');end
   else
   bctmask = 1:min(length(B.minutes),OPT.ntmax);
   end

   if isempty(OPT.ntmax)
    bccmask = find(C.datenum >= datenum(getm.time.start,'yyyy-mm-dd hh:MM:ss') & ...
                   C.datenum <= datenum(getm.time.stop ,'yyyy-mm-dd hh:MM:ss'));
    if MDF.keywords.tstart < C.minutes(bccmask(  1))
        if OPT.bdy3d_nudge
           warning([mfilename,' shifted bdy3d time from ',datestr(C.datenum(bccmask(  1))),' to ',datestr(datenum(getm.time.start,'yyyy-mm-dd hh:MM:ss'))]);
           C.datenum(1:bccmask(1)) = datenum(getm.time.start,'yyyy-mm-dd hh:MM:ss');
           C.minutes(1:bccmask(1)) = MDF.keywords.tstart;
        else
           error('start time after  last  3D boundary data');
        end
    end
    if MDF.keywords.tstop  > C.minutes(bccmask(end));
        if OPT.bdy3d_nudge
           warning([mfilename,' shifted bdy3d time from ',datestr(C.datenum(bccmask(  1))),' to ',datestr(datenum(getm.time.start,'yyyy-mm-dd hh:MM:ss'))]);
           C.datenum(bccmask(end):end) = datenum(getm.time.stop ,'yyyy-mm-dd hh:MM:ss');
           C.minutes(bccmask(end):end) = MDF.keywords.tstop;
        else
           error('start time after  last  3D boundary data');
        end
    end    
   else
   bccmask = 1:min(length(C.minutes),OPT.ntmax);
   end

   nsub = getm.m3d.calc_salt + getm.m3d.calc_temp;
   
   for dbnd = max(OPT.points_per_bnd,2); % we recommend 2 for best preventing unnecesarry duplication in bct columns

      fid       = fopen(getm.domain.bdyinfofile,'r');
      sidenames = {'west', 'north', 'east', 'south'};
      bndtype   = {'N','','Z','Z',''}; % ZERO_GRADIENT,SOMMERFELD,CLAMPED,FLATHER_ELEV
      nbnd.getm = 0; % total number of getm bnd points                for entire model
      nbnd.d3d  = 0; % total number of d3d  bnd segments              for entire model
      nbnd.loc  = 0; % local number of d3d  bnd segments              for entire model for current  side
      nbnd.cum  = 0; % local number of individual getm boundary cells for entire model for previous sides
      for iside = 1:4 % compass directions
         rec = fgetl_no_comment_line(fid,'#!');
         n4  = str2num(strtok(rec));
         for i4=1:n4
             
            nbnd.getm = nbnd.getm + 1;
            rec  = fgetl_no_comment_line(fid,'#!');
            vals = str2num(rec);
      
            if odd(iside)
      
            % vertical boundaries: East + West
                mn = [vals(1) vals(2) vals(1) vals(3)];mn0 = mn;
      
                nbnd.dcum = length(mn(2):mn(4)); % number of point in this section, incl. corners that are irelevant for Delft3D
                
                % remove 'corners' for Delt3D *.bnd file, but NOTE they are still indices of bdy files
                mn(2) = max(mn(2),     2);
                mn(4) = min(mn(4),MDF.keywords.mnkmax(2)-1);
                n  = mn(2):mn(4);
                m  = repmat(mn(1),size(n));
      
            else
      
            % horizontal boundaries: North + South
                mn = [vals(2) vals(1) vals(3) vals(1)];mn0 = mn;

                nbnd.dcum = length(mn(1):mn(3)); % number of point in this section
      
                % remove 'corners' for Delt3D *.bnd file, but NOTE they are still indices of bdy files
                mn(1) = max(mn(1),     2);
                mn(3) = min(mn(3),MDF.keywords.mnkmax(1)-1);
                m  = mn(1):mn(3);
                n  = repmat(mn(2),size(m));

            end % odd
            
            if OPT.write.dep
            % extract depth at boundary locations for interpolation 3D boundaries
            if mn0(1)==mn0(3);
            C.bathymetry(nbnd.cum + [1:nbnd.dcum]) = D.bathymetry(mn0(2):mn0(4),mn0(1)       );
            else
            C.bathymetry(nbnd.cum + [1:nbnd.dcum]) = D.bathymetry(mn0(2)       ,mn0(1):mn0(3));                
            end
            end
      
         % all grid cells per segment for quick overview
         % and ASCII comparison of GETM bdyinfo file with Delft3D bnd file
            Bnd0.DATA(nbnd.getm).name         = [sidenames{iside},num2str(i4)];
            Bnd0.DATA(nbnd.getm).bndtype      = bndtype{vals(4)}; %'{Z} | C | N | Q | T | R'
            Bnd0.DATA(nbnd.getm).datatype     = 'T';              %'{A} | H | Q | T'
            Bnd0.DATA(nbnd.getm).mn           = mn;
            Bnd0.DATA(nbnd.getm).alfa         = 0;
      
         % multiple grid cells per segment: as bct has two columns, we recommend
         % to merge at least 2 seperate GETM points into one 2-point Delft3D segment
            nbnd.d3d = nbnd.d3d  + nbnd.loc;
            nbnd.loc = ceil(length(m)./dbnd); % note CEIL, it extends beyond local GETM section
            tmp.m    = pad(m,nbnd.loc*dbnd,m(end)); % make array artificially somewhat larger if dseg does not fit integer # times in boundary.
            tmp.n    = pad(n,nbnd.loc*dbnd,n(end));

            for ibnd1 = 1:nbnd.loc
            
            ind0    =     (ibnd1-1)*dbnd+1;          % 1-based indices into (m,n) indices from local GETM section
            ind1    = min((ibnd1  )*dbnd,nbnd.dcum); % 1-based indices into (m,n) indices from local GETM section
            ibndcum = nbnd.d3d + ibnd1;
            ipnt0   = nbnd.cum + ind0;  % 1-based indices into (m,n) indices of overall GETM bdy file
            ipnt1   = nbnd.cum + ind1;  % 1-based indices into (m,n) indices of overall GETM bdy file
            
            disp([mfilename, ': processing bc* side:',num2str(iside),'/4  sctn: ',num2str(i4),'/',num2str(n4),'  pnt: ',sprintf('%4d',ibnd1), '/', sprintf('%-4d',nbnd.loc),'  getm-bdy-idx: ',sprintf('%4d',ipnt0),'..',sprintf('%-4d',ipnt1)])

            Bnd.DATA(ibndcum).name               = [sidenames{iside},'_',num2str(i4),'_',num2str(ibnd1)];
            Bnd.DATA(ibndcum).bndtype            = bndtype{vals(4)}; %'{Z} | C | N | Q | T | R'
            Bnd.DATA(ibndcum).datatype           = 'T';              %'{A} | H | Q | T'
            Bnd.DATA(ibndcum).mn                 = [tmp.m(ind0) tmp.n(ind0) tmp.m(ind1) tmp.n(ind1)];
            Bnd.DATA(ibndcum).alfa               = 0;
      
         % data table header
            Bxt.Table(1).Name               = ['Boundary Section : ',num2str(ibnd1)];
            Bxt.Table(1).Contents           = []; % differ for bct and bcc
            Bxt.Table(1).Location           = [sidenames{iside},'_',num2str(i4),'_',num2str(ibnd1)];
            Bxt.Table(1).TimeFunction       = 'non-equidistant';
            Bxt.Table(1).ReferenceTime      = str2num(datestr(OPT.reference_time,'yyyymmdd'));
            Bxt.Table(1).TimeUnit           = 'minutes';
            Bxt.Table(1).Interpolation      = 'linear';
            Bxt.Table(1).Parameter(1).Name  = 'time';
            Bxt.Table(1).Parameter(1).Unit  = '[min]';
            Bxt.Table(1).Data               = [];
            Bxt.Table(1).Format             = '';

         % load subset waterlevel data and interpolate to bcc time vector (for z2sigma interpolation)
         % NB stride is smaller at end of section so do not use stride=dbnd !!!
         
            if OPT.write.bct
            if ipnt0==ipnt1
            B.elev(:,2) = ncread(getm.m2d.bdyfile_2d,'elev',[ipnt0,bctmask(1)],[1,length(bctmask)],[1,1])';
            B.elev(:,1) = B.elev(:,2);
            else
            B.elev = ncread(getm.m2d.bdyfile_2d,'elev',[ipnt0,bctmask(1)],[2,length(bctmask)],[(ipnt1-ipnt0),1])';
            end
            for itmp=1:2
               mask = isnan(B.elev(:,itmp));
               if any(mask)
                  if isempty(OPT.nan.bct)
                    if any(isnan(B.elev([1 end],itmp)))
                       error('leading /trailing NaNs cannot be filled with linear interpolation')
                    end
                    B.elev(:,itmp) = interp1(B.time(bctmask(~mask)),B.elev(~mask,itmp),B.time(bctmask));
                  else
                    B.elev(:,itmp) = OPT.nan.bct;
                  end
               end
            end
            end %OPT.write.bct
            if OPT.write.bcc
            C.elev(:,1) = interp1(B.datenum(bctmask),B.elev(:,1), C.datenum,'linear');
            C.elev(:,2) = interp1(B.datenum(bctmask),B.elev(:,2), C.datenum,'linear');

         %% fill any leading and trailing nans due to non-overlapping 2D elev and 3D temp/salt period
            for itmp=1:2
            mask = isnan(C.elev(:,itmp)); %if any(mask)
            ind=find(mask);
            if any(ind==1) % leading
                tr = find(diff(ind)>1);
                if isempty(tr)
                    tr = length(ind);
                elseif length(tr) > 1
                   error('non-leading/trailing NaN values in bcc elev data')
                end
                C.elev(ind(1:tr),itmp) = C.elev(ind(tr)+1,itmp);
            end
            if any(ind==length(mask)) % trailing
                tr = find(diff(ind)>1);
                if isempty(tr)
                    tr = 1;
                elseif length(tr) > 1
                   error('non-leading/trailing NaN values in bcc elev data')
                end
                C.elev(ind(tr+1:end),itmp) = C.elev(ind(tr+1)-1,1);        
            end
            end
            end %OPT.write.bcc
            
         % fill bct object
            if OPT.write.bct
            Bct.Table(ibndcum)                   = Bxt.Table;
            Bct.Table(ibndcum).Contents          = 'Uniform';
            Bct.Table(ibndcum).Parameter(2).Name = 'water elevation (z)  end A';
            Bct.Table(ibndcum).Parameter(2).Unit = '[m]';
            Bct.Table(ibndcum).Parameter(3).Name = 'water elevation (z)  end B';
            Bct.Table(ibndcum).Parameter(3).Unit = '[m]';
            Bct.Table(ibndcum).Data              = ([B.minutes(bctmask),B.elev(:,1),B.elev(:,2)]);
            fmt = ['%15.7f',repmat(OPT.fmt.elev,[1 2])];
            Bct.Table(ibndcum).Format            = fmt; 
            end %OPT.write.bct
          
            if OPT.write.bcc
            
            % ----------------------------------------------------------------------------
            % contents             'Uniform   '
            % interpolation        'linear'
            % parameter            'Salinity             end A uniform'       unit '[ppt]'
            % parameter            'Salinity             end B uniform'       unit '[ppt]'
            % ----------------------------------------------------------------------------
            % contents             'Linear    '
            % parameter            'Salinity             end A surface'       unit '[ppt]'
            % parameter            'Salinity             end A bed'           unit '[ppt]'
            % parameter            'Salinity             end B surface'       unit '[ppt]'
            % parameter            'Salinity             end B bed'           unit '[ppt]'
            % ----------------------------------------------------------------------------
            % table-name           'Boundary Section : 1'
            % contents             'Step      '
            % interpolation        'linear'
            % parameter            'Salinity             end A surface'       unit '[ppt]'
            % parameter            'Salinity             end A bed'           unit '[ppt]'
            % parameter            'Salinity             end B surface'       unit '[ppt]'
            % parameter            'Salinity             end B bed'           unit '[ppt]'
            % parameter            'discontinuity'                            unit '[m]'
            % ----------------------------------------------------------------------------
            % contents             '3d-profile'
            % interpolation        'linear'
            % parameter            'Salinity             end A layer 1  '     unit '[ppt]'
            % parameter            'Salinity             end A layer 2  '     unit '[ppt]'
            % parameter            'Salinity             end A layer .. '     unit '[ppt]'
            % parameter            'Salinity             end A layer kmax'    unit '[ppt]'
            % parameter            'Salinity             end B layer 1  '     unit '[ppt]'
            % parameter            'Salinity             end B layer 2  '     unit '[ppt]'
            % parameter            'Salinity             end B layer .. '     unit '[ppt]'
            % parameter            'Salinity             end B layer kmax'    unit '[ppt]'
            % ----------------------------------------------------------------------------
            
         % fill bcc object with salt
         
            if ipnt0==ipnt1
            C.raw(:,2,:) = permute(ncread(getm.m3d.bdyfile_3d,'salt',[1,ipnt0,bccmask(1)],[Inf,1,length(bccmask)],[1,1,1]),[3 2 1]);
            C.raw(:,1,:) = C.raw(:,2,:);
            else
            C.raw  = permute(ncread(getm.m3d.bdyfile_3d,'salt',[1,ipnt0,bccmask(1)],[Inf,2,length(bccmask)],[1,(ipnt1-ipnt0),1]),[3 2 1]);
            end
            
            if any(C.raw(:)) < 0;error('salt < 0'); end
            C.data(:,1,:) = interp_z2sigma(-C.zax,C.raw(:,1,:),(d3d_sigma(MDF.keywords.thick./100)),C.elev(:,1),-C.bathymetry([ipnt0]));
            C.data(:,2,:) = interp_z2sigma(-C.zax,C.raw(:,2,:),(d3d_sigma(MDF.keywords.thick./100)),C.elev(:,2),-C.bathymetry([ipnt1]));
            if any(C.data(:) < OPT.min_salt);
            warning('salt < min_salt: all set to min_salt (>0) so delft3d at least starts up.');
            C.data(C.data(:)<OPT.min_salt)=0;
            end

            if getm.m3d.calc_salt
            js = (ibndcum-1)*nsub+1;
            Bcc.Table(js)          = Bxt.Table;
            Bcc.Table(js).Contents = '3d-profile';
            for k=1:C.kmax
            Bcc.Table(js).Parameter(1+k         ).Name = ['Salinity             end A  layer ',num2str(k)];
            Bcc.Table(js).Parameter(1+k         ).Unit = '[ppt]';
            end
            for k=1:C.kmax
            Bcc.Table(js).Parameter(1+k+C.kmax).Name = ['Salinity             end B  layer ',num2str(k)];
            Bcc.Table(js).Parameter(1+k+C.kmax).Unit = '[ppt]';
            end
            fmt = ['%15.7f',repmat(OPT.fmt.salt,[1 C.kmax*2])];
            Bcc.Table(js).Data              = [C.minutes(bccmask),permute(C.data(:,1,:),[1 3 2]),permute(C.data(:,2,:),[1 3 2])];
            Bcc.Table(js).Format            = fmt; 
            end

         % fill bcc object with temp

            if ipnt0==ipnt1
            C.raw(:,2,:) = permute(ncread(getm.m3d.bdyfile_3d,'temp',[1,ipnt0,bccmask(1)],[Inf,1,length(bccmask)],[1,1,1]),[3 2 1]);
            C.raw(:,1,:) = C.raw(:,2,:);                
            else
            C.raw  = permute(ncread(getm.m3d.bdyfile_3d,'temp',[1,ipnt0,bccmask(1)],[Inf,2,length(bccmask)],[1,(ipnt1-ipnt0),1]),[3 2 1]);
            end
            if any(C.raw(:)) < 0;warning('temp < 0');end
            C.data(:,1,:) = interp_z2sigma(-C.zax,C.raw(:,1,:),(d3d_sigma(MDF.keywords.thick./100)),C.elev(:,1),-C.bathymetry([ipnt0]));
            C.data(:,2,:) = interp_z2sigma(-C.zax,C.raw(:,2,:),(d3d_sigma(MDF.keywords.thick./100)),C.elev(:,2),-C.bathymetry([ipnt1]));
            if any(C.data(:) < OPT.min_temp);
            warning('temp < min_temp: all set to min_temp (>0) so delft3d at least starts up.');
            C.data(C.data(:)<OPT.min_temp)=0;
            end
      
            if getm.m3d.calc_temp
            jt = (ibndcum-1)*nsub+1+getm.m3d.calc_temp;
            Bcc.Table(jt)           = Bxt.Table;
            Bcc.Table(jt).Contents = '3d-profile';
            for k=1:C.kmax
            Bcc.Table(jt).Parameter(1+k         ).Name =['Temperature          end A  layer ',num2str(k)];
            Bcc.Table(jt).Parameter(1+k         ).Unit = '[°C]';
            end
            for k=1:C.kmax
            Bcc.Table(jt).Parameter(1+k+C.kmax).Name =['Temperature          end B  layer ',num2str(k)];
            Bcc.Table(jt).Parameter(1+k+C.kmax).Unit = '[°C]';
            Bcc.Table(jt).Data              = [C.minutes(bccmask),permute(C.data(:,1,:),[1 3 2]),permute(C.data(:,2,:),[1 3 2])];
            end
            fmt = ['%15.7f',repmat(OPT.fmt.temp,[1 C.kmax*2])];
            Bcc.Table(jt).Format            =fmt; 
            end
            end %OPT.write.bcc
            
            end % ibnd1 = 1:nbnd.loc

            BND.NTables = length(Bnd.DATA);
            nbnd.cum = nbnd.cum + nbnd.dcum;
            disp(['nbnd.cum:',num2str(nbnd.cum)])
         end % i4=1:n4
      end % iside
      
      struct2nc([OPT.d3ddir,filesep,filename(getm.m2d.bdyfile_2d),'_bathymetry.nc'],C); % for debugging
      
      fclose(fid);
      
      MDF.keywords.filbnd  = [OPT.RUNID,'_',num2str(dbnd),'.bnd']; %[filename(getm.domain.bdyinfofile),'_',num2str(dbnd),'.bnd'];
      MDF.keywords.filbct  = [OPT.RUNID,'_',num2str(dbnd),'.bct']; %[filename(getm.domain.bdyinfofile),'_',num2str(dbnd),'.bct'];
      MDF.keywords.filbcc  = [OPT.RUNID,'_',num2str(dbnd),'.bcc']; %[filename(getm.domain.bdyinfofile),'_',num2str(dbnd),'.bcc'];
      MDF.keywords.commnt  = [filename(getm.domain.bdyinfofile),                 '_0.bnd'];
 
      delft3d_io_bnd('write',[OPT.d3ddir,filesep,MDF.keywords.commnt],Bnd0);
      delft3d_io_bnd('write',[OPT.d3ddir,filesep,MDF.keywords.filbnd],Bnd);
      if OPT.write.bct;
          save([OPT.d3ddir,filesep,MDF.keywords.filbct,'.mat'],'Bct'); % for debugging or modified re-serialisation
          bct_io('write',[OPT.d3ddir,filesep,MDF.keywords.filbct],Bct);
      end %OPT.write.bct
      if OPT.write.bcc;
         save([OPT.d3ddir,filesep,MDF.keywords.filbcc,'.mat'],'Bcc'); % for debugging or modified re-serialisation
         bct_io('write',[OPT.d3ddir,filesep,MDF.keywords.filbcc],Bcc);
      end %OPT.write.bcc
      
      clear Bct Bcc Bnd

   end % dbnd

   MDF.keywords.rettis  = repmat(MDF.keywords.rettis,[BND.NTables 1]);
   MDF.keywords.rettib  = repmat(MDF.keywords.rettib,[BND.NTables 1]);
   if isfield(MDF.keywords,'ilaggr') % No delwaq layer aggregation
   MDF.keywords.ilaggr  = repmat(MDF.keywords.ilaggr,[OPT.kmax 1]);
   end
   
   delft3d_io_mdf('write',[OPT.d3ddir,filesep,OPT.RUNID,'.mdf'],MDF.keywords); % updated and overwritten after each new addition
   
%% discharge locations

      fid      = fopen(getm.rivers.river_info,'r');
      rec      = fgetl(fid);
      nriver = str2num(strtok(rec));

      rec    = fgetl(fid);
      ipnt = 0;
      name0  = '';
      
      while ~(isnumeric(rec)|isempty(strtok(rec)))
         [m   ,rec] = strtok(rec);
         [n   ,rec] = strtok(rec);
         [name,rec] = strtok(rec);

          ipnt = ipnt + 1;
          R(ipnt).getm_name     = name; % for access of netCDF file
          R(ipnt).name          = name;
          R(ipnt).interpolation = 'Y';
          R(ipnt).m             = str2num(m);
          R(ipnt).n             = str2num(n);
          R(ipnt).k             = 0;
          R(ipnt).type          = 'n';

         %if ~strcmpi(name,name0);
         %   a = iriver + 1;
         %   R(iriver).m    = [];
         %   R(iriver).n    = [];
         %   R(iriver).name = name;
         %end
         %R(iriver).m(end+1)    = str2num(m);
         %R(iriver).n(end+1)    = str2num(n);
         %name0 = name;

         rec      = fgetl(fid);
      end
      
      fclose(fid);
      
     [Dis.station_names,~,Dis.station_indices] = unique({R.name});
     
      for i=1:length(Dis.station_names)
         ind = find(Dis.station_indices==i);
         for j=1:length(ind)
         R(ind(j)).ipeer = j;
         R(ind(j)).npeer = length(ind);
         R(ind(j)).peers = ind;
         if R(ind(j)).npeer > 1
         R(ind(j)).name  = [R(ind(j)).name,'_',num2str(R(ind(j)).ipeer)]; % unique names required in Delft3D
         end
         end
      end
      
      MDF.keywords.filsrc = [filename(getm.rivers.river_info),'.src'];
      MDF.keywords.fildis = [filename(getm.rivers.river_data),'.dis'];
      delft3d_io_src('write',[OPT.d3ddir,filesep,MDF.keywords.filsrc],R);

%% discharge data 
%  first create file without T/S and last one with T/S
   firstQ = 0;
   for iq=1:2

   if iq==1
      getm0               = getm;
      getm.m3d.calc_temp  = 0;
      getm.m3d.calc_salt  = 0;
      MDF.keywords.fildis = [OPT.RUNID,'_Q_only.dis']; %[filename(getm.rivers.river_data),'_Q_only.dis'];
   else
      MDF.keywords.fildis = [OPT.RUNID,'.dis']; %[filename(getm.rivers.river_data),'.dis'];
   end
   
   if OPT.write.dis
   Q.time      = ncread   (getm.rivers.river_data,'time');
   Q.timeunits = ncreadatt(getm.rivers.river_data,'time','units');
   Q.datenum   = udunits2datenum(Q.time,Q.timeunits);
   Q.minutes   = (Q.datenum - OPT.reference_time)*24*60;
   Q.minutes   = roundoff(Q.minutes,OPT.dt.dis,'round','multiple');  % make sure times are multiple of time step

   mask = Q.minutes >= 0;
   if any(mask)
      warning(['data skipped before reference data ',datestr(OPT.reference_time),' : ',datestr(Q.datenum(1))])
   end

   for ipnt=1:length(R)

      Q.Q             = ncread(getm.rivers.river_data,R(ipnt).getm_name)./R(ipnt).npeer; % distribute evenly over peers
      Q.Q(isnan(Q.Q)) = OPT.nan.dis;

      Dis.Table(ipnt).Name             = ['Discharge:',num2str(ipnt),' ',R(ipnt).name,' (',num2str(R(ipnt).ipeer),'/',num2str(R(ipnt).npeer),')'];
      Dis.Table(ipnt).Contents         = 'regular';
      Dis.Table(ipnt).Location         = R(ipnt).name;
      Dis.Table(ipnt).TimeFunction     = 'non-equidistant';
      Dis.Table(ipnt).ReferenceTime    = str2num(datestr(OPT.reference_time,'yyyymmdd'));
      Dis.Table(ipnt).TimeUnit         = 'minutes';
      Dis.Table(ipnt).Interpolation    = 'linear';
      Dis.Table(ipnt).Parameter(1)     = struct('Name','time'               ,'Unit','[min]');
      Dis.Table(ipnt).Parameter(2)     = struct('Name','flux/discharge rate','Unit','[m3/s]');

      if getm.m3d.calc_salt;
         Dis.Table(ipnt).Parameter(end+1) = struct('Name','Salinity'        ,'Unit','[ppt]');
         if ~(getm.rivers.use_river_salt)
         Q.salt = Q.Q.*0;
         else
         Q.salt = Q.Q.*0;
         if firstQ
            firstQ = 0;
            warning([mfilename,' river salinity from file not implemented yet'])
         end
         end
         Q.salt = Q.salt(mask);
      else
         Q.salt = [];
      end

      if getm.m3d.calc_temp;
         Dis.Table(ipnt).Parameter(end+1) = struct('Name','Temperature'     ,'Unit','[°C]');
         if ~(getm.rivers.use_river_temp)
         Q.temp = Q.Q.*0 + MDF.keywords.t0(1);
         else
         Q.temp = Q.Q.*0;
         warning([mfilename,' river temperature from file not implemented yet'])
         end
         Q.temp = Q.temp(mask);
      else
         Q.temp = [];
      end
      
      Dis.Table(ipnt).Data          = [Q.minutes(mask), Q.Q(mask), Q.salt, Q.temp];
      Dis.Table(ipnt).Format        = '%d %0.5g';
   
   end % R
   
   save([OPT.d3ddir,filesep,MDF.keywords.fildis,'.mat'],'Dis'); % for debugging or modified re-serialisation
   bct_io('write',[OPT.d3ddir,filesep,MDF.keywords.fildis],Dis);
   
   if iq==1;getm = getm0;
   end % restore getm after 1st call
   
   end % if OPT.write.dis
   
   end % iq
   
   delft3d_io_mdf('write',[OPT.d3ddir,filesep,OPT.RUNID,'.mdf'],MDF.keywords); % updated and overwritten after each new addition

%% output
%  flow

   MDF.keywords.flmap  = [MDF.keywords.tstart OPT.dt.map MDF.keywords.tstop];
   MDF.keywords.flhis  = [MDF.keywords.tstart OPT.dt.his MDF.keywords.tstop];
   MDF.keywords.flpp   = [MDF.keywords.tstart OPT.dt.com MDF.keywords.tstop];

%  waq
save
   if OPT.dt.waq > 0
   MDF.keywords.ilaggr = ones([1 OPT.kmax]); % flwq automatically
   MDF.keywords.waqagg = 'active only';
   MDF.keywords.flwq   = [MDF.keywords.tstart OPT.dt.waq MDF.keywords.tstop];
   end
                      
   delft3d_io_mdf('write',[OPT.d3ddir,filesep,OPT.RUNID,'.mdf'],MDF.keywords);

%% save config file for ready-start linux simulation: flow kernel V5

   fid = fopen([OPT.d3ddir,filesep,'config_flow2d3d.ini'],'w');
   fprintf(fid,'%s \n', '[FileInformation]');
   fprintf(fid,'%s \n', '   FileCreatedBy    = $Id: getm2delft3d.m 9087 2013-08-20 15:12:47Z boer_g $');
   t = now;[d,w]=weekday(now);
   fprintf(fid,'%s \n',['   FileCreationDate = ',w, datestr(t,' mmm dd HH:MM:SS yyyy')]);
   fprintf(fid,'%s \n', '   FileVersion      = 00.01');
   fprintf(fid,'%s \n', '[Component]');
   fprintf(fid,'%s \n', '   Name    = flow2d3d');
   fprintf(fid,'%s \n',['   MDFfile = ',OPT.RUNID]);
   fclose(fid);

%% save config file for ready-start linux simulation: flow kernel V6
% https://svn.oss.deltares.nl/repos/delft3d/trunk/examples/01_standard/config_d_hydro.xml
% <?xml version="1.0" encoding="iso-8859-1"?>
% <deltaresHydro xmlns="http://schemas.deltares.nl/deltaresHydro"
% xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
% xsi:schemaLocation="http://schemas.deltares.nl/deltaresHydro
% http://content.oss.deltares.nl/schemas/d_hydro-1.00.xsd">
% <control>
% <sequence>
% <start>myNameFlow</start>
% </sequence>
% </control>
% <flow2D3D name="myNameFlow">
% <library>flow2d3d</library>
% <mdfFile>f34.mdf</mdfFile>
% </flow2D3D>
% </deltaresHydro>

   fid = fopen([OPT.d3ddir,filesep,'config_flow2d3d.xml'],'w');
   fprintf(fid,'%s \n', '<?xml version="1.0" encoding="iso-8859-1"?>');
   fprintf(fid,'%s \n', '<deltaresHydro xmlns="http://schemas.deltares.nl/deltaresHydro"');
   fprintf(fid,'%s \n', ' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"');
   fprintf(fid,'%s \n', ' xsi:schemaLocation="http://schemas.deltares.nl/deltaresHydro');
   fprintf(fid,'%s \n', ' http://content.oss.deltares.nl/schemas/d_hydro-1.00.xsd">');
   fprintf(fid,'%s \n', ' <control>');
   fprintf(fid,'%s \n', '  <sequence>');
   fprintf(fid,'%s \n', '   <start>myNameFlow</start>');
   fprintf(fid,'%s \n', '  </sequence>');
   fprintf(fid,'%s \n', ' </control>');
   fprintf(fid,'%s \n', ' <flow2D3D name="myNameFlow">');
   fprintf(fid,'%s \n', '  <library>flow2d3d</library>');
   fprintf(fid,'%s \n',['  <mdfFile>',OPT.RUNID,'.mdf</mdfFile>']);
   fprintf(fid,'%s \n', ' </flow2D3D>');
   fprintf(fid,'%s \n', '</deltaresHydro>');

   fclose(fid);

