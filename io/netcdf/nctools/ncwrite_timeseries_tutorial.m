function varargout = ncwrite_timeseries_tutorial(ncfile,varargin);
%ncwrite_timeseries_tutorial tutorial for writing timeseries on disconnected platforms to netCDF-CF file
%
% For too legacy matlab releases, plase see instead: see nc_cf_timeseries.
%
%  Tutorial of how to make a netCDF file with CF conventions of a 
%  variable that is a timeseries. In this special case 
%  the main dimension coincides with the time axis.
%
%  This case is described in CF: http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/ch09.html
%
%See also: nc_cf_timeseries_write_tutorial, nc_cf_timeseries,
%          netcdf, ncwriteschema, ncwrite, 
%          ncwritetutorial_grid
%          ncwritetutorial_trajectory

%%  --------------------------------------------------------------------
%   Copyright (C) 2013 DeltaresNUS
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
%  $Id: ncwrite_timeseries_tutorial.m 12592 2016-03-17 08:36:52Z gerben.deboer.x $
%  $Date: 2016-03-17 16:36:52 +0800 (Thu, 17 Mar 2016) $
%  $Author: gerben.deboer.x $
%  $Revision: 12592 $
%  $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/nctools/ncwrite_timeseries_tutorial.m $
%  $Keywords: $

   ncfile0         = [mfilename('fullpath'),'.nc'];

%% Required spatio-temporal fields

   OPT.title          = '';
   OPT.institution    = 'DeltaresNUS';
   OPT.version        = '';
   OPT.references     = '';
   OPT.email          = '';

   OPT.datenum        = datenum(2009,1:12,1);
   OPT.lon            = 103.2:.2:103.8;
   OPT.lat            = 1.2:.1:1.5;
   OPT.platform_names = {'RLS','RLD','KUS','HTF'};

   OPT.var            = repmat(20+15*cos(2*pi*(OPT.datenum - OPT.datenum(1))./(365.25)),[length(OPT.lon) 1]);
   OPT.var            = OPT.var + 5*rand(size(OPT.var));

%% Required data fields
   
   OPT.Name           = 'TSS';
   OPT.standard_name  = 'mass_concentration_of_suspended_matter_in_sea_water';
   OPT.long_name      = 'TSS';
   OPT.units          = 'kg m-3';
   OPT.Attributes     = {};

%% Required settings

   OPT.Format         = 'classic'; % '64bit','classic','netcdf4','netcdf4_classic'
   OPT.refdatenum     = datenum(0000,0,0); % matlab datenumber convention: A serial date number of 1 corresponds to Jan-1-0000. Gives wring date sin ncbrowse due to different calenders. Must use doubles here.
   OPT.refdatenum     = datenum(1970,1,1); % linux  datenumber convention
   OPT.fillvalue      = typecast(uint8([0    0    0    0    0    0  158   71]),'DOUBLE'); % ncetcdf default that is also recognized by ncBrowse % DINEOF does not accept NaNs; % realmax('single'); %
   OPT.timezone       = timezone_code2iso('GMT');
   
   if verLessThan('matlab','7.12.0.635')
      error('At least Matlab release R2011a is required for writing netCDF files due tue NCWRITESCHEMA.')
   end

   OPT      = setproperty(OPT,varargin);

%% CF attributes: add overall meta info
%  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#description-of-file-contents

   ncfile = strrep(ncfile0,'.nc','.nc');

   ncwrite_timeseries(ncfile,OPT)