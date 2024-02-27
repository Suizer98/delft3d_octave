function varargout = nc_cf_timeseries(ncfile,varargin)
%NC_CF_TIMESERIES   load/plot one variable from TimeSeries netCDF file
%
%  [D,M] = nc_cf_timeseries(ncfile)
%  [D,M] = nc_cf_timeseries(ncfile,<varname>)
%
% plots AND loads timeseries of variable varname from netCDF 
% file ncfile and returns data D and meta-data M where
% ncfile  = name of local file / OPeNDAP address / result of ncfile = nc_info()
% D       = contains the data struct
% M       = the metadata struct (attributes)
% varname = the variable name to be extracted (must have dimension time)
%           When varname is not supplied, a dialog box is offered.
%           when 'standard_name'==time, it is converted to datenum
%
% A TimeSeries netCDF file is defined with:
%   <a href="http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#featureType">CF featureType  attribute</a>
%   <a href="http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#time-series-data">CF Apendix H.2. Time Series Data</a>
% and must have global attributes:
%  *  Conventions="CF-1.6"
%  *  featureType="timeSeries"
% and variable attributes cf_role, and standard_names platform_id and platform_name
% the following assumption <MUST> be valid:
%  * lat, lon and time coordinates must always exist as defined in the CF convenctions.
%
% The plot contains (ncfile, platform_id, lon, lat) in title and (long_name, units) as ylabel.
%
%  [D,M] = nc_cf_timeseries(ncfile,<varname>,<keyword,value>)
%
% The following <keyword,value> pairs are implemented:
% * varname (default []) % can optionally also be supplied as 2nd argument
% * plot    (default: 1 if varname = [], else 0)  % switches of the plot
% * period  period from which to get data (> nc_cf_time_range)
%
% Examples:
%
%    directory = 'F:\opendap\';                                       % either local
%    directory = 'http://opendap.deltares.nl/thredds/dodsC/opendap/'; % or remote
%
%    fname   = '/rijkswaterstaat/waterbase/sea_water_salinity/id559-NOORDWK10.nc';
%    [D1,M1] = nc_cf_timeseries([directory,fname],'sea_water_salinity','plot',1);
%
%    fname   = 'knmi/etmgeg/etmgeg_269.nc';
%    [D2,M2] = nc_cf_timeseries([directory,fname],'wind_speed_mean','plot',1);
%
%See also: SNCTOOLS, NC_CF_GRID, ncwritetutorial_timeseries, ncwrite_timeseries

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

% $Id: nc_cf_timeseries.m 12592 2016-03-17 08:36:52Z gerben.deboer.x $
% $Date: 2016-03-17 16:36:52 +0800 (Thu, 17 Mar 2016) $
% $Author: gerben.deboer.x $
% $Revision: 12592 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/nctools/nc_cf_timeseries.m $
% $Keywords$

%TO DO: handle indirect time mapping where there is no variable time(time)
%TO DO: handle multiple stations in one file: paramter(time,locations)
%TO DO: allow to get all time related parameters, and plot them on by one (with pause in between)
%TO DO: take into account differences between netCDF downloaded from HYRAX and THREDDS OPeNDAP implementation

%DOne: make 'TIME' case insensitive
%DOne: time does not need standard_name time, the dimension name time is
%       sufficient, matching a variable name

%% Keyword,values

   OPT.plot    = 1;
   OPT.varname = [];
   OPT.period  = [];
   OPT.pngname = []; % prints png and closes figure
   
   if nargin==0
      varargout  ={OPT};
      return
   end
   
   if ~odd(nargin)
   OPT.varname = varargin{1};
   nextarg     = 2;
   else
   nextarg     = 1;
   end
   
   if ~isempty(OPT.varname)
      OPT.plot = 0;
   end

   OPT = setproperty(OPT,varargin{nextarg:end});

%% Load file info

   %% get info from ncfile
   
   if isstruct(ncfile)
      fileinfo = ncfile;
   else
      fileinfo = nc_info(ncfile);
   end
   
   %% deal with name change in scntools: DataSet > Dataset
   
   if     isfield(fileinfo,'Dataset'); % new
     fileinfo.DataSet = fileinfo.Dataset;
   elseif isfield(fileinfo,'DataSet'); % old
     fileinfo.Dataset = fileinfo.DataSet;
     disp(['warning: please use newer version of snctools (e.g. ',which('matlab\io\snctools\nc_info'),') instead of (',which('nc_info'),')'])
   else
      error('neither field ''Dataset'' nor ''DataSet'' returned by nc_info')
   end
   
%% Check whether is indeed time series

   index = findstrinstruct(fileinfo.Attribute,'Name','featureType');
   if isempty(index)
      warning(['netCDF file might not be a proper CF timeSeries, it lacks CF-1.6 Attribute featureType'])
   else
       if ~strcmpi(fileinfo.Attribute(index).Value,'timeSeries')
          warning(['netCDF file might not be a proper CF timeSeries, it lacks CF-1.6 Attribute featureType=timeSeries'])
       end
   end

%% Get datenum

   if isempty(OPT.period)
  [D.datenum,              M.datenum.timezone] = nc_cf_time      (ncfile);
   start = [];
   count = [];
   else
  [D.datenum,start0,count0,M.datenum.timezone] = nc_cf_time_range(fileinfo,'time',OPT.period);
   end
   
%% Get location coords

   lonname         = nc_varfind(fileinfo, 'attributename', 'standard_name', 'attributevalue', 'longitude');
   if ~isempty(lonname)
   M.lon.units     = nc_attget(ncfile,lonname,'units');
   D.lon           = nc_varget(ncfile,lonname);
   else
   D.lon           = [];
   disp('warning: no longitude specified')
   end

   latname         = nc_varfind(fileinfo, 'attributename', 'standard_name', 'attributevalue', 'latitude');
   if ~isempty(latname)
   M.lat.units     = nc_attget(ncfile,latname,'units');
   D.lat           = nc_varget(ncfile,latname);
   else
   D.lat           = [];
   disp('warning: no latitude specified')
   end
   
%% Get location info   

   D.platform_id = ''; % default
   idname          = nc_varfind(fileinfo, 'attributename', 'standard_name', 'attributevalue', 'platform_id');%   CF-1.6
   if isempty(idname)
   idname          = nc_varfind(fileinfo, 'attributename', 'standard_name', 'attributevalue', 'station_id'); % < CF-1.6
   end
   if ~isempty(idname)
    D.platform_id   = nc_varget(ncfile,idname);
    if isnumeric(D.platform_id)
    D.platform_id   = num2str(D.platform_id);
    else
    D.platform_id   =         D.platform_id;
    end
   elseif nc_isvar(ncfile,'platform_id')
    D.platform_id   = nc_varget(ncfile,'platform_id');    
   else
    disp('warning: no unique platform id specified')
   end

   D.platform_name = D.platform_id(:)'; % default
   stname          = nc_varfind(fileinfo, 'attributename', 'standard_name', 'attributevalue', 'platform_name'); %  CF-1.6
   if isempty(stname)
   stname          = nc_varfind(fileinfo, 'attributename', 'standard_name', 'attributevalue', 'station_name'); % < CF-1.6
   end
   if isempty(stname)
   stname          = nc_varfind(fileinfo, 'attributename', 'long_name'    , 'attributevalue', 'station_name'); % < CF-1.6
   end
   if ~isempty(stname)
    D.platform_name = nc_varget(ncfile,stname);
   elseif nc_isvar(ncfile,'platform_name')
    D.platform_name = nc_varget(ncfile,'platform_name');  
   else
    idname         = nc_varfind(fileinfo, 'attributename', 'long_name', 'attributevalue', 'platform_name');
    if ~isempty(stname)
    D.platform_name = nc_varget(ncfile,stname);
    end
   end

%% Find specified (or all parameters) that have time as dimension
%  and select one.

   if isempty(OPT.varname)
   
      timevar = [];
      for ivar=1:length(fileinfo.Dataset)
         index = any(strcmpi(fileinfo.Dataset(ivar).Dimension,'time')); % use any if for case like {'locations','time'}
         if index==1
            timevar = [timevar ivar];
         end
      end
      
      timevarlist = cellstr(char(fileinfo.Dataset(timevar).Name));


      [ii, ok] = listdlg('ListString', timevarlist, .....
                      'SelectionMode', 'single', ...
                       'PromptString', 'Select one variable', ....
                               'Name', 'Selection of variable',...
                           'ListSize', [500, 300]); 
      
      varindex    = timevar(ii);
      OPT.varname = timevarlist{ii};
      
   else
   
      % get index
      nvar = length(fileinfo.Dataset);
      
      for ivar=1:nvar
         if strcmp(fileinfo.Dataset(ivar).Name,OPT.varname)
         varindex = ivar;
         break
         end
      end
   end
   
%% get data

   if ~isempty(OPT.period) % take care of multiple dimensions
      I         = nc_getvarinfo(ncfile,OPT.varname);
      start     = zeros(1,length(I.Dimension));
      count     = ones (1,length(I.Dimension));
      i         = strmatch('time',I.Dimension);
      if ~isempty(count0)
        count(i)  = count0;
        start(i)  = start0;
        D.(OPT.varname) = nc_varget(ncfile,OPT.varname,start,count);
      else
        D.(OPT.varname) = [];
      end
   else
      D.(OPT.varname) = nc_varget(ncfile,OPT.varname);
   end
      
%% get Attributes

      nAttr = length(fileinfo.Dataset(varindex).Attribute);
      for iAttr = 1:nAttr
      Name  = mkvar(fileinfo.Dataset(varindex).Attribute(iAttr).Name);
      Value =       fileinfo.Dataset(varindex).Attribute(iAttr).Value;
      M.(OPT.varname).(Name) = Value; % get all  % TO DO
      end
      if ~isfield(M,'long_name')
         M.(OPT.varname).long_name = OPT.varname;
      end

%% Plot
   
   if OPT.plot
    if ~isempty(OPT.varname)
    
      if OPT.plot < 0
        FIG = figure('Visible','off');
      else
        FIG = figure;
      end
      
      count = length(D.datenum);
      
      if     count < 100 % use large marker
      plot    (D.datenum,D.(OPT.varname),'displayname',[mktex(M.(OPT.varname).long_name),' [',...
                                                        mktex(M.(OPT.varname).units    ),']'],'marker','o','markerfacecolor','b')
      elseif count < 1000 % use small marker
      plot    (D.datenum,D.(OPT.varname),'displayname',[mktex(M.(OPT.varname).long_name),' [',...
                                                        mktex(M.(OPT.varname).units    ),']'],'marker','.')
      else % continuous
      plot    (D.datenum,D.(OPT.varname),'displayname',[mktex(M.(OPT.varname).long_name),' [',...
                                                        mktex(M.(OPT.varname).units    ),']'])

      end
      datetick('x')
      grid     on
      title   ({mktex(filenameext(fileinfo.Filename)),...
               ['"',mktex(D.platform_name(:)'),'" (id:',mktex(D.platform_id(:)'),')',...
                ' (',num2str(D.lon(1)),'\circE',...
                 ',',num2str(D.lat(1)),'\circN)']})
              
      if     isfield(M.(OPT.varname),'long_name')
         long_name = M.(OPT.varname).long_name;
      elseif isfield(M.(OPT.varname),'standard_name')
         long_name = M.(OPT.varname).standard_name;
      else
         long_name = OPT.varname;
      end
      
      if     isfield(M.(OPT.varname),'units')
         units = M.(OPT.varname).units;
      else
         units = '?';
      end
              
      ylabel  ([mktex(long_name),' [',mktex(units),']']);
      if OPT.plot==1 % this allows to pass 2 and to overrule credit
      text(1,0,'Created with: www.OpenEarth.eu','rotation',90,'fontsize',8,'units','normalized','verticalalignment','top')
      end
      
      if ~isempty(OPT.pngname)
         print2screensizeoverwrite(OPT.pngname)
         delete(FIG)
      end
   
    end
   end
   
%% Output

   if     nargout==1
      varargout = {D};
   elseif nargout==2
      varargout = {D,M};
   end
   
%% EOF   
