function varargout = nc_cf_time(ncfile,varargin)
%NC_CF_TIME   reads time variables from a netCDF file into Matlab datenumber
%
%  [datenumbers,<zone>] = nc_cf_time(ncfile);
%  [datenumbers,<zone>] = nc_cf_time(ncfile,<varname>,<start,count,stride>);
%
% extract all time vectors from netCDF file ncfile as Matlab datenumbers
% parsing the units string "units since yyy-mm-dd HH:MN:SC"
% ncfile  = name of local file, OPeNDAP address, or result of ncfile = nc_info()
% time    = defined according to the CF convention as in:
% varname = optional name of specific time vector
% zone    = time zone (optional output 2nd argument)
%
% http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#time-coordinate
% http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/ch04s04.html
% http://www.unidata.ucar.edu/support/help/MailArchives/udunits/msg00253.html
%
% When there is only one time variable, an array is returned, otherwise
% a warning is thrown. All arguments beyond the 2nd are passed to nc_varget.
%
% Uses snctools as backend, for pure matlab libraries uses ncread_cf_time.
%
% Example:
%
%  base              = 'http://opendap.deltares.nl:8080/thredds/dodsC';
% [D.datenum,D.zone] = nc_cf_time([base,'/opendap/knmi/potwind/potwind_343_2001.nc'],'time')
%
%See also: nc_varget, nc_cf_timeseries, NC_CF_GRID, UDUNITS2DATENUM, ncread_cf_time

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
%       Gerben J. de Boer
%
%       gerben.deboer@deltares.nl
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: nc_cf_time.m 11177 2014-10-06 15:09:39Z gerben.deboer.x $
% $Date: 2014-10-06 23:09:39 +0800 (Mon, 06 Oct 2014) $
% $Author: gerben.deboer.x $
% $Revision: 11177 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/nctools/nc_cf_time.m $
% $Keywords: $

%% get info from ncfile

%% deal with name change in scntools: DataSet > Dataset

%% cycle Dimensions

   % index = [];
   % for idim=1:length(fileinfo.Dimension)
   %    if strcmpi(fileinfo.Dimension(idim).Name,'TIME');
   %    index = [index idim];
   %    end
   % end
   
   if isstruct(ncfile)
      fileinfo = ncfile;
   else
      fileinfo.Filename = ncfile;
   end
   
   % if no variable is specified, look for a time variable
   if nargin==1

      if isstruct(ncfile)
         fileinfo = ncfile;
      else
         fileinfo = nc_info(ncfile);
      end
   
      if     isfield(fileinfo,'Dataset'); % new
        fileinfo.DataSet = fileinfo.Dataset;
      elseif isfield(fileinfo,'DataSet'); % old
        fileinfo.Dataset = fileinfo.DataSet;
        disp(['warning: please use newer version of snctools (e.g. ',which('matlab\io\snctools\nc_info'),') instead of (',which('nc_info'),')'])
      else
         error('neither field ''Dataset'' nor ''DataSet'' returned by nc_info')
      end

      %% cycle Datasets
      %  all time datasets must have an associated time Dimension
      index = [];
      name  = {};
      nt    = 0;
      for idim=1:length(fileinfo.Dataset)
         if     strcmpi(fileinfo.Dataset(idim).Name     ,'time') && ...
            any(strcmpi(fileinfo.Dataset(idim).Dimension,'time'));
         nt        = nt+1;
         index(nt) =                   idim;
         name {nt} =  fileinfo.Dataset(idim).Name;
         end
      end
      
      %% get data
      for ivar=1:length(index)
         try
         M(ivar).datenum.units         = nc_attget(fileinfo.Filename,name{ivar},'units');
         D(ivar).datenum               = nc_varget(fileinfo.Filename,name{ivar});
        [D(ivar).datenum,D(ivar).zone] = udunits2datenum(double(D.datenum),M.datenum.units); % prevent integers from generating stairs in larger units
         catch
             error(['variable ',fileinfo.Filename,':',name{ivar},' has no units'])
         end
      end
   else
      if ischar(varargin{1})
         varname  = varargin{1};
         varargin = varargin(2:end);
      end
      try
      M.datenum.units   = nc_attget(fileinfo.Filename,varname,'units');
      D.datenum         = nc_varget(fileinfo.Filename,varname,varargin{:});
     [D.datenum,D.zone] = udunits2datenum(double(D.datenum),M.datenum.units); % prevent integers from generating stairs in larger units
      catch
          error(['variable ',fileinfo.Filename,':',varname,' has no units'])
          D.datenum = [];
      end         
      index = 1;
   end
   
%% output
   
   if nargout<3
      if     isempty(index)
         warning('no time vectors present.') %#ok<WNTAG>
         varargout = {[]};
      elseif length(index)==1
         if     nargout==0 || nargout==1
            varargout = {D(1).datenum};
         elseif nargout==2
            varargout = {D(1).datenum,D(1).zone};
         else
            error('to much output parameters')
         end
      else
         warning('multiple time vectors present, please specify furter.') %#ok<WNTAG>
         varargout = {D};
      end
   end

%% EOF