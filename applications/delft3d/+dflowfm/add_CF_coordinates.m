function varargout = add_CF_coordinates(ncfile,varargin)
%add_CF_coordinates  appends CF coordinates to ncfile
%
%   index = dflowfm.add_CF_coordinates(ncfile,'epsg',28992,<keyword,value>)
%
% where keyword epsg is mandatory.
%
% See also: snctools, convertCoordinates, dflowfm

%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Gerben de Boer
%
%       <g.j.deboer@deltares.nl>
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

% $Id: add_CF_coordinates.m 7052 2012-07-27 12:44:44Z boer_g $
% $Date: 2012-07-27 20:44:44 +0800 (Fri, 27 Jul 2012) $
% $Author: boer_g $
% $Revision: 7052 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/+dflowfm/add_CF_coordinates.m $
% 2009 sep 28: added implementation of WAQ hda files [Yann Friocourt]

   OPT.epsg   = 28992;
   OPT.wgs84  = 4326;
   OPT.coords = {{'NetNode_x'        , 'NetNode_y'        ,'NetNode_lon'        , 'NetNode_lat'        ,'netnodal lon-coordinate'                ,'netnodal lat-coordinate'                },...
                 {'FlowElem_xcc'     , 'FlowElem_ycc'     ,'FlowElem_loncc'     , 'FlowElem_latcc'     ,'Flow element circumcenter lon'          ,'Flow element circumcenter lat'          },...
                 {'FlowElemContour_x', 'FlowElemContour_y','FlowElemContour_lon', 'FlowElemContour_lat','List of lon-points forming flow element','List of lat-points forming flow element'},...
                 {'FlowLink_xu'      , 'FlowLink_yu'      ,'FlowLink_lonu'      , 'FlowLink_latu'      ,'Flow link u-point lon'                  ,'Flow link u-point lat'} ...
                 };

   OPT = setproperty(OPT,varargin{:});
   
   if nargin==0
     varargout ={OPT};
     return
   end
   
%% add meta-data   
   
   if ~nc_isvar(ncfile,'projected_coordinate_system')
   S               = nc_cf_grid_mapping(OPT.epsg);
   nc.Name         = 'projected_coordinate_system';
   nc.Nctype       = nc_int;
   nc.Dimension    = {};
   nc.Attribute    = S;
   nc_addvar(ncfile, nc); 
   nc_varput(ncfile, nc.Name, OPT.epsg); 
   end
   
   if ~nc_isvar(ncfile,'wgs84')
   S               = nc_cf_grid_mapping(OPT.wgs84);
   nc.Name         = 'wgs84';
   nc.Nctype       = nc_int;
   nc.Dimension    = {};
   nc.Attribute    = S;
   nc_addvar(ncfile, nc); 
   nc_varput(ncfile, nc.Name, OPT.epsg);
   else
   error([ncfile,' is perhaps already CF compliant, var ''wgs84'' already exists. Cancelled.'])
   end
   
%% add add matrices

   EPSG = load('EPSG');
   
   for i=1:length(OPT.coords)

      var.x        = OPT.coords{i}{1};
      var.y        = OPT.coords{i}{2};
      var.lon      = OPT.coords{i}{3};
      var.lat      = OPT.coords{i}{4};
      var.lon_name = OPT.coords{i}{5};
      var.lat_name = OPT.coords{i}{6};
      
      if  nc_isvar(ncfile,var.x)   &  nc_isvar(ncfile,var.y) 
      if ~nc_isvar(ncfile,var.lon) & ~nc_isvar(ncfile,var.lat)
      
         x = nc_varget(ncfile,var.x);
         y = nc_varget(ncfile,var.y);
        [lon,lat,log]=convertCoordinates(x,y,EPSG,'CS1.code',OPT.epsg,'CS2.code',OPT.wgs84);
        
         nc = nc_getvarinfo(ncfile,var.x);
         nc = rmfield(nc,'Attribute');
        
         nc.Name             = var.lon;
         nc.Attribute(    1) = struct('Name', 'long_name'      ,'Value', 'longitude');
         nc.Attribute(    2) = struct('Name', 'standard_name'  ,'Value', var.lon_name);
         nc.Attribute(    3) = struct('Name', 'units'          ,'Value', 'degrees_east');
         nc.Attribute(    4) = struct('Name', 'grid_mapping'   ,'Value', 'wgs84');
         nc_addvar(ncfile, nc); 
         nc_varput(ncfile, nc.Name, lon); 

         nc.Name             = var.lat;
         nc.Attribute(    1) = struct('Name', 'long_name'      ,'Value', 'latitude');
         nc.Attribute(    2) = struct('Name', 'standard_name'  ,'Value', var.lat_name);
         nc.Attribute(    3) = struct('Name', 'units'          ,'Value', 'degrees_north');
         nc.Attribute(    4) = struct('Name', 'grid_mapping'   ,'Value', 'wgs84');
         nc_addvar(ncfile, nc); 
         nc_varput(ncfile, nc.Name, lat); 
      else
      error([ncfile,' is perhaps already CF compliant. Cancelled.'])
      end
      end
      
   end   
   
   OPT.var = {'NetNode_x',...
              'NetNode_y',...
              'NetNode_z',...
              'FlowElem_xcc',...
              'FlowElem_ycc',...
              'FlowElemContour_x',...
              'FlowElemContour_y',...
              'FlowElem_bl',...
              'FlowLink_xu',...
              'FlowLink_yu',...
              's1',...
              'sa1',...
              'ucx',...
              'ucy',...
              'unorm'};
   
%% attach meta-data to matrices

   for i=1:length(OPT.var)
      var.z = OPT.var{i};
      if  nc_isvar(ncfile,var.z)
      nc_attput(ncfile,var.z,'grid_mapping','wgs84');
      end
   end   
   
%% notify file users that we modified it
   
   history = nc_attget(ncfile,nc_global,'history');
   history = [history, ' [appended CF coordinates with $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/+dflowfm/add_CF_coordinates.m $ $Id: add_CF_coordinates.m 7052 2012-07-27 12:44:44Z boer_g $ on ',datestr(now),']']
   nc_attput(ncfile,nc_global,'history',history);
   
   
   