function varargout = delwaq_map2nc(varargin)
%DELWAQ_MAP2NC  convert delwaq map file layer to netCDF file
%
%   DELWAQ_MAP2NC(<keyword,value>);
%
% saves one layer from one variable in a delwaq map file to netCDF file.
% This file is written using L2BIN2NC, and hence can be used as DINEOF input.
%
% The delwaq map files can optionally be passed as cellstr list
% to concatenate % data from diferent files (PROVIDED THEY
% ARE DEFINED ON THE SAME GRID).
%
% Example: extract bed shear stresses (only present in last layer)
%
%   workdir = 'F:\delft3d\project007\'
%
%   OPT.grdfile       = [workdir,filesep,'MyWaqSimulation.lga'];
%   OPT.mapfile       = [workdir,filesep,'MyWaqSimulation.map'];
%   OPT.ncfile        = [workdir,filesep,'MyWaqSimulation_Tau_kmax.nc'];
%   OPT.SubsName      = 'Tau';
%   OPT.standard_name = 'magnitude_of_surface_downward_stress'; % see http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/20/cf-standard-name-table.html: 
%   OPT.long_name     = '|bed shear stress|';
%   OPT.units         = 'N/m2'; % Pa
%   OPT.k             = Inf; % integer, use Inf for last layer index: kmax
%   OPT.epsg          = 28992;
%   OPT.Fcn           = log10positive(x); % optionally log10-transform data
%   OPT.Attributes    = {'log10',1};
%
%   delwaq_map2nc(OPT)
%
%See also: delwaq, L2BIN2NC, WAQ, VS_TRIM2NC, DINEOF, nc_dimension_subset

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: delwaq_map2nc.m 10627 2014-04-30 12:52:01Z boer_g $
% $Date: 2014-04-30 20:52:01 +0800 (Wed, 30 Apr 2014) $
% $Author: boer_g $
% $Revision: 10627 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/waq/delwaq_map2nc.m $
% $Keywords: $

   OPT.grdfile       = 'MyWaqSimulation.cco';
   OPT.mapfile       ={'MyWaqSimulation_2003.map',...
                       'MyWaqSimulation_2004.map',...
                       'MyWaqSimulation_2005.map'};% 'TIM','dcTIM','Chlfa','dcChlfa','CDOM','dcCDOM','Kd490','dcKd490','nPixels'
   OPT.ncfile        = 'MyWaqSimulation_2003_2005.nc';
   OPT.SubsName      = 'Chlfa';
   OPT.varname       = ''; % name of variable in netCDF, e.g with pre/postfixes due to OPT.Fcn operation
   OPT.standard_name = 'mass_concentration_of_chlorophyll_a_in_sea_water'; % see http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/20/cf-standard-name-table.html
   OPT.long_name     = 'Chlorophyll a';
   OPT.units         = 'ug/l'; % Pa
   OPT.Fcn           = @(x) x; % @(x) log10(x)
   OPT.Attributes    = {'comment',''}; % {'log10',1}
   
   OPT.k             = Inf; % Inf is replaced with last layer index
   OPT.epsg          = 28992;

   OPT = setproperty(OPT,varargin);
   
   if nargin==0
      varargout = {OPT};
      return
   end

%% read static meta-data

   G = delwaq('open',OPT.grdfile); % needs both lga and cco
  [G.cor.lon,G.cor.lat] = convertCoordinates(G.X(1:end-1,1:end-1),G.Y(1:end-1,1:end-1),'CS1.code',OPT.epsg,'CS2.code',4326);

%% insert dry points into center mask (ESSENTIAL)
  
   G.cen.mask = G.Index(2:end-1,2:end-1,1); % ~isnan(G.cen.lon) is not OK, because it still contains dry points
   G.cen.mask(G.cen.mask> 0)=  1;
  %G.cen.mask(G.cen.mask==0)=NaN; % [0/1] for netCDF
   nanmask = G.cen.mask;
   nanmask(nanmask==0)=NaN;       % [nan/1] for multiplication
   G.cen.lon  = corner2center(G.cor.lon).*nanmask; % this is essential as WAQ aggregation can put ...
   G.cen.lat  = corner2center(G.cor.lat).*nanmask; % ... non-connected corners next to each other in the matrix

   h = pcolorcorcen(G.cor.lon,G.cor.lat,G.cen.mask,[.5 .5 .5]);
   title('Active grid points mask as written to netCDF-CF for DINEOF mask. Check dry points.')

%% read map-file dependent meta-data

   if ischar(OPT.mapfile)
      OPT.mapfile = cellstr(OPT.mapfile);
   end
   
   T.datenum = []; % for case of scalars only
   for im=1:length(OPT.mapfile)
      D(im) = delwaq('open',OPT.mapfile{im}); % needs both lga and cco
      if im==1
         T(im)     = delwaq_time(D(im));
      else
         T.datenum = [T.datenum,delwaq_time(D(im),'datenum',1)];
      end
   end

%% create netCDF file (no data yet, only meta-data)

   if isempty(OPT.varname)
      OPT.varname = OPT.SubsName;
   end

   L2bin2nc(OPT.ncfile,...
             'lon',G.cen.lon,...
             'lat',G.cen.lat,...
            'mask',G.cen.mask,...
       'lonbounds',G.cor.lon,...
       'latbounds',G.cor.lat,...
            'time',T.datenum,...
            'epsg',4326,...
            'Name',OPT.varname,...
   'standard_name',OPT.standard_name,...
       'long_name',OPT.long_name,...
           'units',OPT.units,...
      'Attributes',OPT.Attributes);

   fid = fopen(strrep(OPT.ncfile,'.nc','.cdl'),'w');
   nc_dump(OPT.ncfile,fid);
   fclose(fid);
                          
%% fill netCDF file (add data)
%  per time slice, to avoid memory issues.
   
   if isinf(OPT.k)
      OPT.k=G.MNK(3);
   end
   
   IT = 0;
   for im=1:length(OPT.mapfile)
    disp(['source file: ',num2str(im),' ',D(im).FileName])
    for it=1:D(im).NTimes
       IT = IT+1;

       disp([num2str(it,'%0.4d'),'/',num2str(D(im).NTimes,'%0.4d'),'=',num2str(100*it/D(im).NTimes,'%05.1f'),'%'])
       
      [t,vector] = delwaq('read',D(im),OPT.SubsName,0,it);
      
       matrix = waq2flow3d(vector,G.Index,'center');
       
       matrix = OPT.Fcn(matrix);
       
     %pcolorcorcen(G.cor.lon,G.cor.lat,permute(matrix(:,:,OPT.k),[1 2 3]))
       
       ncwrite(OPT.ncfile,OPT.varname,permute(matrix(:,:,OPT.k),[2 1 3]),[1 1 IT]); % 1-based indices       
        
    end
   end
