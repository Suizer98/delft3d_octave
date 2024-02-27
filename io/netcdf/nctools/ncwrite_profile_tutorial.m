function ncwrite_profile_tutorial(ncfile0,varargin)
%ncwrite_profile_tutorial tutorial for writing timeSeriesProfile to netCDF-CF file
%
%  Tutorial of how to use ncwrite_profile to create a netCDF file with 
%  CF conventions of a variable that is a timeSeriesProfile. In this 
%  special case the main dimensions coincides with the time axis and the z axis.
%
%  This case is described in CF: http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/ch09.html
%
% An example of a timeSeriesProfile is repeated CTD data at the same spot.
%
%See also: netcdf, ncwriteschema, ncwrite, 
%          ncwritetutorial_grid_lat_lon_curvilinear
%          ncwrite_timeseries_tutorial
%          ncwrite_trajectory_tutorial

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

   OPT.datenum1       = datenum(2009,1:3:12,1); % nominal times per profile, e.g. beginning or mean, quaterly values
   
   % 0D nominal/target location which will not be exactly matched by realization.
   OPT.lon0           =  3;
   OPT.lat0           = 52;
   
   % 1D we allow for some discrepancy between target location and realized lcoation
   OPT.lon1           =  3 + .02*cos(2*pi*OPT.datenum1./365);  
   OPT.lat1           = 52 + .01*cos(4*pi*OPT.datenum1./365+pi/2);
   
   % 1D: centres of fixed 4 m binned data (processed, L2) data
   OPT.z1             = 20:40:180; 
  
   %% optional full 2D z and t matrices for ragged (unprocessed, L1) data
  [XTR.datenum2,XTR.z2  ] = meshgrid(OPT.datenum1,OPT.z1);
   XTR.z2 =       [ 2   2.1   2.5   2 ;
                    6   6.2   6.4   6 ;
                   10  10.3  10.3  10 ;
                   14  14.4  14.2  14 ;
                   18  18.5  18.1  18 ];
   XTR.datenum2 = [00  00    00    00 ;
                   10  20    10    20 ;
                   20  40    30    50 ;
                   30  60    40    70 ;
                   40  80    50    80 ]./24./3600 + XTR.datenum2; % add seconds needed for free fall
  [XTR.lon2,~]            = meshgrid(OPT.lon1    ,OPT.z1);
  [XTR.lat2,~]            = meshgrid(OPT.lat1    ,OPT.z1);
   OPT.var = exp(-XTR.z2./5).*2.*cos(2.*pi.*XTR.datenum2./365);

%% Required data fields
   
   OPT.Name           = 'TSS';
   OPT.standard_name  = 'mass_concentration_of_suspended_matter_in_sea_water';
   OPT.long_name      = 'TSS';
   OPT.units          = 'kg m-3';

%% Cases

   for dz = [0 1 2 3]; % amplitude of z undulation: 0=2D, otherwise=3D

      if dz==0 % same z per profile: dimension(z)=variable(z)
         ncfile = strrep(ncfile0,'.nc','_zbinned_fast.nc');
         OPT.Attributes     = {'xy_comment'  ,'fixed (lat,lon) position, e.g. platform, moored vessel',...
                               'z_comment'   ,'fixed z levels for all profiles, e.g. after binning, or moored thermistor string',...
                               'time_comment','negligible time span during one profile, e.g. free fall in shallow water'};
      elseif dz==1
         ncfile = strrep(ncfile0,'.nc','_zragged_fast.nc');
         OPT.z2 = XTR.z2;
         OPT.Attributes     = {'xy_comment'  ,'fixed (lat,lon) position, e.g. platform, moored ship',...
                               'z_comment'   ,'varying z levels per profile, e.g. real z positions during of free fall',...
                               'time_comment','negligible time span during one profile, e.g. free fall in shallow water'};
      elseif dz==2
         ncfile = strrep(ncfile0,'.nc','_zragged_slow.nc');
         OPT.z2 = XTR.z2;
         OPT.datenum2 = XTR.datenum2;
         OPT.Attributes     = {'xy_comment'  ,'fixed (lat,lon) position, e.g. platform, moored ship',...
                               'z_comment'   ,'varying z levels per profile, e.g. real z positions during of free fall',...
                               'time_comment','significant time span during one profile, e.g. CTD dangling behind ship for an hour, of slow mechanical lowering'};
      else
         ncfile = strrep(ncfile0,'.nc','_zragged_trajectory.nc');
         OPT = mergestructs('overwrite',OPT,XTR);     
         OPT.Attributes     = {'xy_comment'  ,'varying (lat,lon) position per profile, e.g. moving vessel',...
                               'z_comment'   ,'varying z levels per profile, e.g. undulating z mab due to waves/tides interacting with ship',...
                               'time_comment','significant time span during one profile, e.g. CTD dangling behind ship for an hour, '};
      end

      ncwrite_profile(ncfile,OPT)

   end % dz