function varargout = vs_trim2nc_statistics(vsfile,varargin)
%VS_TRIM2NC_STATISTICS template to save statistics of variables to netCDF-CF
%
%  vs_trim2nc_statistics(vsfile,'times',{[t0 t1],[t1 t2],0},'var',values}
%
% saves average of salinity for period t0-t1, period t2-t2 and entire
% time period in trim file (0) to netCDF file.
%
% Example:
%   vs_trim2nc_statistics('d:\Delft3D\project\trim-ub40.dat',...
%                         'times',{[2:25],[26:51],[52:75]},...
%                         'var'  ,{'waterlevel','velocity','salinity','temperature'})
%
%See also: vs_trim2nc
%%  --------------------------------------------------------------------
%   Copyright (C) 2013 www.Deltares.nl
%
%       Gerben J. de Boer <gerben.deboer@deltares.nl>
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

%% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
%  OpenEarthTools is an online collaboration to share and manage data and 
%  programming tools in an open source, version controlled environment.
%  Sign up to recieve regular updates of this function, and to contribute 
%  your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
%  $Id: vs_trim2nc_statistics.m 8797 2013-06-11 06:36:08Z boer_g $
%  $Date: 2013-06-11 14:36:08 +0800 (Tue, 11 Jun 2013) $
%  $Author: boer_g $
%  $Revision: 8797 $
%  $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/vs_trim2nc_statistics.m $
%  $Keywords: $

   OPT.suffix = '_mean';
   OPT.times  = {[1 2]};
   OPT.var    = {'waterlevel','velocity','salinity','temperature','grid_x','grid_y'};
   
   if nargin==0
      varargout = {OPT};
      return
   end   
   
   if ~odd(nargin)
      ncfile   = varargin{1};
      varargin = {varargin{2:end}};
   else
      ncfile   = fullfile(fileparts(vsfile),[filename(vsfile) '.nc']);
      ncfile   = fullfile(fileparts(vsfile),[filename(vsfile) '_statistics.nc']);
   end   
   
   OPT = setproperty(OPT,varargin);

%% define time period

   F          = vs_use (vsfile);
   T          = vs_time(F);

%% generate empty netCDF file with correct structure

   vs_trim2nc(vsfile,ncfile,'var',OPT.var,'time',1:length(OPT.times),'empty',1);

%% get statistics of data and add to existing netCDF file

   I          = vs_get_constituent_index(F);
   G.cen.mask = vs_let_scalar(F,'map-const','KCS'   ,'quiet'); G.cen.mask(G.cen.mask~=1) = NaN; % -1/0/1/2 Non-active/Non-active/Active/Boundary water level point (fixed)
   
   for its = 1:length(OPT.times)
   
   %% per parameter reuse tmparray1/2 and stat1/2 for memory efficiency
       
      disp([mfilename,' processing  time windows # ',num2str(its)]);
       
      OPT.time = OPT.times{its};
      if OPT.time==0;OPT.time=1:length(T.datenum);end
      
      ncwrite   (ncfile,'time'       ,T.datenum(OPT.time( 1     )) -datenum(1970,1,1), [its  ]);
      ncwrite   (ncfile,'time_bounds',T.datenum(OPT.time([1 end]))'-datenum(1970,1,1), [its,1]);
   
   %% zwl
      
      first = 1;
      for it= OPT.time;
         tmparray1 = apply_mask(vs_let_scalar(F,'map-series',{it},'S1', {0 0},'quiet'),G.cen.mask);
         if first
         first = 0;
         stat1 = tmparray1;
         else
         stat1 = stat1 + tmparray1;
         end
      end
   
      stat1 = stat1/length(OPT.time);
      ncwrite   (ncfile,'waterlevel', stat1,[2,2,its]); % 1-based
      ncwriteatt(ncfile,'waterlevel', 'actual_range',[min(stat1(:)) max(stat1(:)) ]); % 1-based
      ncwriteatt(ncfile,'waterlevel', 'cell_methods','time: mean');
      
   %% sal
      
      first = 1;
      for it= OPT.time;
         tmparray1 = apply_mask(vs_let_scalar(F,'map-series',{it},'R1', {0 0 0 I.salinity.index},'quiet'),G.cen.mask);
         if first
         first = 0;
         stat1 = tmparray1;
         else
         stat1 =  stat1 + tmparray1;
         end
      end
   
      stat1 = stat1/length(OPT.time);
      ncwrite   (ncfile,'salinity', stat1,[2,2,1,its]); % 1-based
      ncwriteatt(ncfile,'salinity', 'actual_range',[min(stat1(:)) max(stat1(:)) ]); % 1-based
      ncwriteatt(ncfile,'salinity', 'cell_methods','time: mean');
   
   %% tem
      
      first = 1;
      for it= OPT.time;
         tmparray1 = apply_mask(vs_let_scalar(F,'map-series',{it},'R1', {0 0 0 I.temperature.index},'quiet'),G.cen.mask);
   
         if first
         first = 0;
         stat1 = tmparray1;
   
         else
         stat1 = stat1 + tmparray1;
   
         end
      end
   
      stat1 = stat1/length(OPT.time);
      ncwrite   (ncfile,'temperature', stat1,[2,2,1,its]); % 1-based
      ncwriteatt(ncfile,'temperature', 'actual_range',[min(stat1(:)) max(stat1(:)) ]); % 1-based
      ncwriteatt(ncfile,'temperature', 'cell_methods','time: mean');
   
   %% u,v
      
      first = 1;
      for it= OPT.time;
   
        [tmparray1,tmparray2] = vs_let_vector_cen(F, 'map-series',{it},{'U1','V1'}, {0,0,0},'quiet');
         tmparray1            = apply_mask(permute(tmparray1,[2 3 4 1]),G.cen.mask); % y x z
         tmparray2            = apply_mask(permute(tmparray2,[2 3 4 1]),G.cen.mask); % y x z
   
         if first
         first = 0;
         stat1 = tmparray1;
         stat2 = tmparray2;
         else
         stat1 = stat1 + tmparray1;
         stat2 = stat2 + tmparray2;
         end
      end
   
      stat1 = stat1/length(OPT.time);
      stat2 = stat2/length(OPT.time);
      ncwrite   (ncfile,'velocity_x', stat1,[2,2,1,its]); % 1-based
      ncwrite   (ncfile,'velocity_y', stat2,[2,2,1,its]); % 1-based
      ncwriteatt(ncfile,'velocity_x', 'actual_range',[min(stat1(:)) max(stat1(:)) ]); % 1-based
      ncwriteatt(ncfile,'velocity_x', 'cell_methods','time: mean');
      ncwriteatt(ncfile,'velocity_y', 'actual_range',[min(stat2(:)) max(stat2(:)) ]); % 1-based
      ncwriteatt(ncfile,'velocity_y', 'cell_methods','time: mean');
      
   end % time

function tmparray = apply_mask(tmparray,mask)

   for k=1:size(tmparray,3)
      tmparray(:,:,k) = tmparray(:,:,k).*mask;
   end