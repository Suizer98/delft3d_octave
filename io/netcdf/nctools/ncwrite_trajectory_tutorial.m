function ncwrite_trajectory_tutorial(ncfile0,varargin)
%ncwrite_trajectory_tutorial tutorial for writing trajectory to netCDF-CF file
%
%  Tutorial of how to make a netCDF file with CF conventions of a 
%  variable that is a trajectory. In this special case 
%  the main dimension coincides with the time axis.
%
%  This case is described in CF: http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/ch09.html
%
% An example of a 3D trajectory is FerryBox data (http://www.ferrybox.org/)
%
%See also: netcdf, ncwriteschema, ncwrite, 
%          ncwritetutorial_grid
%          ncwritetutorial_timeseries
%          ncwritetutorial_profile

%%  --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares 4 Rijkswaterstaat (SPA Eurotracks)
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
%  $Id: ncwritetutorial_timeseries.m 8921 2013-07-19 06:13:40Z boer_g $
%  $Date: 2013-07-19 08:13:40 +0200 (Fri, 19 Jul 2013) $
%  $Author: boer_g $
%  $Revision: 8921 $
%  $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/nctools/ncwritetutorial_timeseries.m $
%  $Keywords: $

   ncfile0         = [mfilename('fullpath'),'.nc'];
   
%% Required spatio-temporal fields

   OPT.datenum        = datenum(2009,0,1:365);
   OPT.lon            =  3+2*cos(2*pi*OPT.datenum./365); % lissajous
   OPT.lat            = 52+1*cos(4*pi*OPT.datenum./365+pi/2);
   OPT.var            = 3-2*cos(2*pi*OPT.datenum/365);
   OPT.z              = [];

%% Required data fields
   
   OPT.Name           = 'TSS';
   OPT.standard_name  = 'mass_concentration_of_suspended_matter_in_sea_water';
   OPT.long_name      = 'TSS';
   OPT.units          = 'kg m-3';

%% Cases
clc
   for dz = [0 1]; % amplitude of z undulation: 0=2D, otherwise=3D

      if dz==0 % same z per profile: dimension(z)=variable(z)
         ncfile = strrep(ncfile0,'.nc','_2D.nc');
         OPT.z              = 3;
         OPT.Attributes     = {'calibration'  ,'3.141592'};
      elseif dz==1
         ncfile = strrep(ncfile0,'.nc','_3D.nc');
         OPT.z              = 3 + dz*cos(2*pi*OPT.datenum/365);
         OPT.Attributes     = {'calibration'  ,'3.141592'};
      end

      ncwrite_trajectory(ncfile,OPT)
   
   end