function varargout = readMap(ncfile,varargin)
%readMap   Reads solution data on a D-Flow FM unstructured net.
%
%     D = dflowfm.readMap(ncfile,<mapformat>,<it>) 
%     D = dflowfm.readMap(G     ,<mapformat>,<it>) 
%     D = dflowfm.readMap(G     [,mapformat,it [,opt, val [, opt, val ...]] ]) 
%
%   reads flow circumcenter(cen) data from an D-Flow FM NetCDF file. 
%   By default is the LAST timestep is read (it=last).
%
%   For plotting also use G = dflowfm.readNet(ncfile)
%
% See also: dflowfm, delft3d 

%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Arthur van Dam & Gerben de Boer
%
%       <Arthur.vanDam@deltares.nl>; <g.j.deboer@deltares.nl>
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
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

%   $Id: readMap.m 15376 2019-05-01 07:58:38Z kimberley.koudstaal.x $

% TO DO make D a true object with methods etc.
% TO DO read only data in OPT.axis box

%% input

   OPT.zwl       = 1; % whether to load data 
   OPT.sal       = 0; % whether to load data 
   OPT.dep       = 0; % whether to load data 
   OPT.vel       = 1; % whether to load data 
   OPT.spir      = 0; % whether to load data
   OPT.lyrcc     = 1; % whether to calculate 
                      % layer pressure point vertical coordinates
   if (OPT.lyrcc==1)
       OPT.dep = 1;
       OPT.zwl = 1;
   end

   if nargin==0
      varargout = {OPT};
      return
   end
   
   if isstruct(ncfile)
      G      = ncfile;
      ncfile = G.file.name;
   else
       conv = ncreadatt(ncfile,'/','Conventions');
       if strcmp(conv,'UGRID-0.9')% mapformat 1
           G      = dflowfm.readNetOld(ncfile);% edited by BS
           prefix = '';
           varname_waterdepth = 'waterdepth';
           varname_layerdim = 'laydim';
           varname_layercoord = 'LayCoord_cc';
       elseif strcmp(conv,'CF-1.6 UGRID-1.0/Deltares-0.8')% mapformat 4
           G      = dflowfm.readNet(ncfile);% edited by BS
           prefix = 'mesh2d_';
           varname_waterdepth = 'waterdepth';
           varname_layerdim = 'nmesh2d_layer';
           varname_layercoord = 'mesh2d_layer_sigma';
       else 
           sprintf('Current version of this script does not recognize mapformat %d',conv)% use default (mapformat 1)
           G      = dflowfm.readNetOld(ncfile);% edited by BS
           prefix = '';
           varname_waterdepth = 'water depth';
           varname_layerdim = 'laydim';
           varname_layercoord = 'LayCoord_cc';
       end
   end
   
    if odd(nargin)
      tmp     = nc_getvarinfo(ncfile,[prefix 's1']);
      it      = tmp.Size(1);
      face.FlowElemSize   = tmp.Size(2);
      nextarg = 1;
   else
      it      = varargin{1};
      nextarg = 2;
   end
    
%     if nargin == 2
%       if mapformat == 1
%           prefix = '';
%       elseif mapformat == 4
%           
%           prefix = 'mesh2d_';
%       else
%           sprintf('Error: current version of this script does not support mapformat %d',mapformat)
%           return
%       end
%       tmp     = nc_getvarinfo(ncfile,[prefix 's1']);
%       it      = tmp.Size(1);
%       face.FlowElemSize   = tmp.Size(2);
%       nextarg = 1;
%    else
%       it      = varargin{2};
%       nextarg = 2;
%    end   

   if nargin==0
      varargout = {OPT};
      return
   else
      OPT = setproperty(OPT,varargin{nextarg:end});
   end

%% read time data

   D.datenum = nc_cf_time(ncfile, 'time');
   D.datenum = D.datenum(it);
   D.datestr = datestr(D.datenum,31);
   
%% 3D: number of layers
   L3D = false;
   if nc_isdim(ncfile, varname_layerdim)
       dum = nc_getdiminfo(ncfile, varname_layerdim);
       laydim = dum.Length;
       D.laydim = laydim;
   end

%% read cen data

   face.mask = G.face.FlowElemSize; % not an index array yet as nc_varget can only handle one range

   if OPT.zwl && nc_isvar (ncfile, [prefix 's1'])
      D.face.zwl  = nc_varget(ncfile, [prefix 's1'] ,[it-1 0],[1 face.mask]); % Waterlevel
   end
   
   if OPT.dep && nc_isvar (ncfile, [prefix varname_waterdepth])
      D.face.dep  = nc_varget(ncfile, [prefix varname_waterdepth] ,[it-1 0],[1 face.mask]); % Waterdepth
   end
   if OPT.lyrcc
      info=nc_getvarinfo(ncfile,[prefix 'ucx']);
      NDIM=length(info.Size);
      if ( NDIM==2 )   % safety, in principle (see unstruc_netcdf.f90) not possible
         D.face.z_cc = (D.face.zwl-0.5*D.face.dep);
      elseif (NDIM==3)
          z_cc = flipud(abs(nc_varget(ncfile,varname_layercoord,[0],[laydim])));
          dep = repmat(squeeze(D.face.dep),1,laydim);
          for jj = face.mask:-1:1     % dynamically pre-allocate
             res(jj,:) = z_cc'.*dep(jj,:); 
             D.face.z_cc(jj,:) = (D.face.zwl(jj)-D.face.dep(jj))+res(jj,:);
          end
      end
   end
   if OPT.sal && nc_isvar (ncfile, [prefix 'sa1'])
       info=nc_getvarinfo(ncfile,[prefix 'sa1']);
       NDIM=length(info.Size);
       if ( NDIM==2 )
           D.face.sal  = nc_varget(ncfile, [prefix 'sa1'],[it-1 0],[1 face.mask]); % Salinity
       else
           if ( NDIM==3 )
              D.face.sal  = nc_varget(ncfile, [prefix 'sa1'],[it-1 0 0],[1 face.mask laydim]); % Salinity
           end
       end
   end
   
   if OPT.vel && nc_isvar (ncfile, [prefix 'ucx'])
      info=nc_getvarinfo(ncfile,[prefix 'ucx']);
      NDIM=length(info.Size);
      if ( NDIM==2 )
%        2D          
         D.face.u    = nc_varget(ncfile, [prefix 'ucx'],[it-1 0],[1 face.mask]); % x velocity at cell center
         if nc_isvar (ncfile, [prefix 'ucy']);
            D.face.v    = nc_varget(ncfile, [prefix 'ucy'],[it-1 0],[1 face.mask]); % y velocity at cell center
         end
      else
         if ( NDIM==3 )
            D.face.u    = nc_varget(ncfile, [prefix 'ucx'],[it-1 0 0],[1 face.mask laydim]); % x velocity at cell center
            if nc_isvar (ncfile, [prefix 'ucy']);
               D.face.v    = nc_varget(ncfile, [prefix 'ucy'],[it-1 0 0],[1 face.mask laydim]); % y velocity at cell center
            end
            if nc_isvar (ncfile, [prefix 'ucz']);
               D.face.w    = nc_varget(ncfile, [prefix 'ucz'],[it-1 0 0],[1 face.mask laydim]); % y velocity at cell center
            end            
         end
      end
   end
   if OPT.spir && nc_isvar (ncfile, [prefix 'spircrv']);
      D.face.crv  = nc_varget(ncfile, [prefix 'spircrv'] ,[it-1 0],[1 face.mask]); % Curvature [1/m]
   end  
   if OPT.spir && nc_isvar (ncfile, [prefix 'spirint']);
      D.face.I    = nc_varget(ncfile, 'spirint' ,[it-1 0],[1 face.mask]); % Secondary flow intensity [m/s]
   end  
   if OPT.spir && nc_isvar (ncfile, [prefix 'spirang']);
      D.face.Iang = nc_varget(ncfile, [prefix 'spirang'] ,[it-1 0],[1 face.mask]); % Secondary flow intensity [m/s]
   end  

%% < read face data >

%   face.mask = cen.n; % not an index array yet as nc_varget cna only handle one range
%   
%   if OPT.vel & nc_isvar (ncfile, 'unorm');
%   D.face.un  = nc_varget(ncfile, 'unorm',[it-1 0],[1 face.mask]);
%   end



varargout = {D};
