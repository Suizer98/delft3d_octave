function [D,M] = nc_cf_grid(ncfile,varargin)
%NC_CF_GRID   load/plot one variable from netCDF grid file
%
%  [D,M] = nc_cf_grid(ncfile)
%  [D,M] = nc_cf_grid(ncfile,varname)
%
% plots/loads timeseries of variable varname from netCDF 
% file ncfile and returns data and meta-data where 
% ncfile  = name of local file, OPeNDAP address, or result of ncfile = nc_info()
% D       = contains the data struct
% M       = the metadata struct (attributes)
% varname = the variable name to be extracted (must have dimension time)
%           When varname is not supplied, a dialog box is offered.
%
% A netCDF (curvi-linear) grid file is defined in
%   <a href="http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/ch04.html">http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/ch04.html</a>
% and must have global attributes:
%  *  Conventions   : CF-1.4
% the following assumption must be valid:
%  * lat, lon and time coordinates must always exist as defined in the CF convenctions.
%
% The plot contains (ncfile) in title and (long_name, units) on colorbar.
%
%  [D,M] = nc_cf_grid(ncfile,varname,<keyword,value>)
%
% The following <keyword,value> are implemented
% * plot   (default 1)
%
% Examples:
%
%    directory = 'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/'  % either remote [OpenEarth OPeNDAP THREDDS server test]
%    directory = 'http://opendap.deltares.nl:8080/thredds/dodsC/opendap/'  %               [OpenEarth OPeNDAP THREDDS server production]
%    directory = 'P:\mcdata\opendap\'                                      % or local
%
%    [D,M]=nc_cf_grid([directory,'knmi/NOAA/mom/1990_mom/5/N19900501T025900_SST.nc'],'SST')
%
%See also: SNCTOOLS, nc_cf_timeseries

% HYRAX does not work, nor does it show tree in ncBrowse, but does plot in ncBrowse.
%    directory = 'http://opendap.deltares.nl:8080/opendap/'                %               [OpenEarth OPeNDAP HYRAX production server]
%    directory = 'http://opendap.deltares.nl:8080/opendap/dodsC/opendap/'  %               [OpenEarth OPeNDAP HYRAX production server]

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
% $Id: nc_cf_grid.m 8596 2013-05-08 16:08:39Z boer_g $
% $Date: 2013-05-09 00:08:39 +0800 (Thu, 09 May 2013) $
% $Author: boer_g $
% $Revision: 8596 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/nctools/nc_cf_grid.m $
% $Keywords$

%TO DO: permute x, y and t
%TO DO: allow to get all time related parameters, and plot them on by one (with pause in between)
%TO DO: document <keyword,value> pairs
%TO DO: also extract x and y vectors
%TO DO: make it work when more lat and lon matrices are present
%TO DO: add keywords lon, lat, dlon, dlat to use for subsetting:  [D,M] = nc_cf_grid(ncfile,varname,<keyword,value>)

%% Keyword,values

   OPT.plot    = 1;
   OPT.oned    = 0;
   OPT.varname = []; % one if dimensions are (latitude,longitude), 0 if variables are (latitude,longitude)
   OPT.stride  = 1;
   OPT.debug   = 0;

   if nargin > 1
   OPT.varname = varargin{1};
   end
   
   OPT = setproperty(OPT,varargin{2:end});

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
   
%% Check whether is grid

   index = findstrinstruct(fileinfo.Attribute,'Name','Conventions');
   if isempty(index)
      warning(['netCDF file might not be a grid: needs Attribute Conventions=CF-1.4'])
   end

%% Get coordinate variables
%  might be multiple due to bounds variables, so we use cellstr throughout

   lonname          = nc_varfind(ncfile, 'attributename', 'standard_name', 'attributevalue', 'longitude');
   if isempty(lonname);disp('no longitude present');end

   latname          = nc_varfind(ncfile, 'attributename', 'standard_name', 'attributevalue', 'latitude');
   if isempty(latname);disp('no latitude present');end

   xname            = nc_varfind(ncfile, 'attributename', 'standard_name', 'attributevalue', 'projection_x_coordinate');
   if isempty(xname);disp('no x present');end
   
   yname            = nc_varfind(ncfile, 'attributename', 'standard_name', 'attributevalue', 'projection_y_coordinate');
   if isempty(yname);disp('no y present');end
   
   tname            = nc_varfind(ncfile, 'attributename', 'standard_name', 'attributevalue', 'time');
   if isempty(tname);disp('no times present');end
   
   if ischar(lonname);lonname = cellstr(lonname);end
   if ischar(latname);latname = cellstr(latname);end
   if ischar(xname  );xname   = cellstr(xname  );end
   if ischar(yname  );yname   = cellstr(yname  );end
   if ischar(tname  );tname   = cellstr(tname  );end

   
   if OPT.debug
    lonname
    latname
    xname
    yname
    tname
   end
   
%% Find specified (or all parameters) that have latitude AND longitude as either
%  * dimension
%  * coordinates attribute
%  and select one.

   coord.varindex = [];
   coord.vartype  = {};
   coord.vardim   = {};
   
   for ivar=1:length(fileinfo.Dataset)
   
     direct.lat = false;
     direct.lon = false;
     direct.x   = false;
     direct.y   = false;       
      
     %%  (lon,lat) direct mapping: find dimension latitude, longitude OR ...
     for idim=1:length(fileinfo.Dataset(ivar).Dimension)
         for icell=1:length(latname)
           if any(cell2mat((strfind(fileinfo.Dataset(ivar).Dimension(idim),latname{icell}))));
             direct.lat = idim;
             fileinfo.Dataset(ivar).latname    = latname{icell};
             break
           end
         end
         for icell=1:length(lonname)
           if any(cell2mat((strfind(fileinfo.Dataset(ivar).Dimension(idim),lonname{icell}))));
             direct.lon = idim;
             fileinfo.Dataset(ivar).lonname    = lonname{icell};
             break
           end
         end
     end
      
     %%  (x,y) direct mapping: find dimension x, y OR ...
     if ~isempty(xname)
     for idim=1:length(fileinfo.Dataset(ivar).Dimension)
         for icell=1:length(xname)
           if any(cell2mat((strfind(fileinfo.Dataset(ivar).Dimension(idim),xname{icell}))));
             direct.x = idim;
             fileinfo.Dataset(ivar).xname    = xname{icell};
             break
           end
         end
         for icell=1:length(yname)
           if any(cell2mat((strfind(fileinfo.Dataset(ivar).Dimension(idim),yname{icell}))));
             direct.y = idim;
             fileinfo.Dataset(ivar).yname    = yname{icell};
             break
           end
         end
     end
     end
     
     if (direct.lat && direct.lon) | (direct.x && direct.y)
          coord.varindex = [coord.varindex  ivar];
          if (direct.x && direct.y) & (direct.lon && direct.lat)
             coord.vartype{end+1} = {'(lat,lon) orthogonal','(x,y) orthogonal'};
             coord.vardim {end+1} = {[direct.x direct.y],[direct.lon direct.lat]};
          elseif (direct.x && direct.y)
             coord.vartype{end+1} = '(x,y) orthogonal';
             coord.vardim {end+1} = {[direct.x direct.y]};
          elseif (direct.lon && direct.lat)
             coord.vartype{end+1} = '(lat,lon) orthogonal';
             coord.vardim {end+1} = {[direct.lon direct.lat]};
          end
     end
               
     %% indirect mapping: find index of coordinates attribute

     atrindex = nc_atrname2index(fileinfo.Dataset(ivar),'coordinates');

     if ~isempty(atrindex)

       % check whether coordinates attribute refers to variables that have
       % (x,y) or (lat,lon) standard_name 
       % Note: there can be multiple pairs of coordinates, e.g.: "x y lon lat"
       % Here we assume they are grouped.
       
       coord.varnames = strtokens2cell(fileinfo.Dataset(ivar).Attribute(atrindex).Value);

       for ii=1:2:length(coord.varnames)
         indirect.lat = false;
         indirect.lon = false;
         indirect.x   = false;
         indirect.y   = false;
         for iii=0:1

           varindex = nc_varname2index(fileinfo,coord.varnames{ii+iii});

           % find index of standard_name attribute
           atrindex = nc_atrname2index(fileinfo.Dataset(varindex),'standard_name');

           if ~isempty(atrindex)
              if strcmpi(fileinfo.Dataset(varindex).Attribute(atrindex).Value,'latitude')
              indirect.lat=true;
              fileinfo.Dataset(varindex).latname    = latname{icell};
              end
              if strcmpi(fileinfo.Dataset(varindex).Attribute(atrindex).Value,'longitude')
              indirect.lon=true;
              fileinfo.Dataset(varindex).lonname   = lonname{icell};
              end
              if strcmpi(fileinfo.Dataset(varindex).Attribute(atrindex).Value,'projection_x_coordinate')
              indirect.x=true;
              fileinfo.Dataset(varindex).xname    = xname{icell};
              end
              if strcmpi(fileinfo.Dataset(varindex).Attribute(atrindex).Value,'projection_y_coordinate')
              indirect.y=true;
              fileinfo.Dataset(varindex).yname    = yname{icell};
              end                       
           end
        end
      end

      if (indirect.lat && indirect.lon) | (indirect.x && indirect.y)
         coord.varindex = [coord.varindex  ivar];
         if (indirect.x && indirect.y) & (indirect.lon && indirect.lat)
            coord.vartype{end+1} = {'(lat,lon) curvilinear','(x,y) curvilinear'};
            coord.vardim {end+1} = {[indirect.x indirect.y],[indirect.lon indirect.lat]};
         elseif (indirect.x && indirect.y)
            coord.vartype{end+1} = '(x,y) curvilinear';
            coord.vardim {end+1} = {[indirect.x indirect.y]};
         elseif (indirect.lon && indirect.lat)
            coord.vartype{end+1} = '(lat,lon) curvilinear';
            coord.vardim {end+1} = {[indirect.lon indirect.lat]};
         end
      end
    end % if ~isempty(atrindex)
      
  end % for ivar=1:length(fileinfo.Dataset)
   
  coord.varnames = cellstr(char(fileinfo.Dataset(coord.varindex).Name));
   
  coord.varlist = cellfun(@(x,y) [x, ' ',y],coord.varnames, coord.vartype','UniformOutput',0);

  if isempty(OPT.varname)
   
      if OPT.debug
          var2evalstr(coord)
      end
      
      %% ad coords to name
      [ii, ok] = listdlg('ListString', coord.varlist, .....
                      'SelectionMode', 'single', ...
                       'PromptString', 'Select one variable', ....
                               'Name', 'Selection of variable',...
                           'ListSize', [500, 300]); 

      varindex    = coord.varindex(ii);
      vardim      = coord.vardim  {ii};
      vartype     = coord.vartype {ii};
      OPT.varname = coord.varnames{ii};
      
  else
   
   %% get index of chosen variable name
   
      nvar = length(coord.varnames);
      for ivar=1:nvar
         if strcmp(coord.varnames{ivar},OPT.varname)
         varindex = ivar;
         vardim   = coord.vardim  {ivar};
         vartype  = coord.vartype {ivar};
         % TO DO: check for multiple occurences of same matrix: f(x,y) or z(lon,lat)
         break
         end
      end
      
  end
  
%% get data

%fileinfo.Dataset(varindex).Dimension
%nc_isatt (ncfile,OPT.varname,'coordinates')
%nc_attget(ncfile,OPT.varname,'coordinates')
% add coordinates and dimension variables
%pausedisp

if length(lonname) > 1;error(['multiple lonname found:',str2line(lonname,'s',',')])
else;lonname = char(lonname);end

if length(latname) > 1;error(['multiple lonname found:',str2line(latname,'s',',')])
else;latname = char(latname);end

if length(xname) > 1;error(['multiple lonname found:',str2line(xname,'s',',')])
else;xname = char(xname);end

if length(yname) > 1;error(['multiple lonname found:',str2line(yname,'s',',')])
else;yname = char(yname);end

   M.lon.units     = nc_attget(ncfile,lonname,'units');
   M.lat.units     = nc_attget(ncfile,latname,'units');

   I = nc_getvarinfo(ncfile,lonname);
   start  = I.Size.*0;
   count  = I.Size.*0 -1;
   stride = I.Size.*0 + OPT.stride;
   if strfind(vartype,'(lat,lon)')
   D.lon           = nc_varget(ncfile,lonname );AXx='lon';dimtype='ll';
   D.lat           = nc_varget(ncfile,latname );AXy='lat';
   elseif strfind(vartype,'(x,y)')
   D.x             = nc_varget(ncfile,xname   );AXx='x';dimtype='xy';
   D.y             = nc_varget(ncfile,yname   );AXy='y';
   end

%TO DO check for time dimension here and permute to [t,y,x] or [t,x,y]
%% Get datenum

   D.datenum = nc_cf_time(ncfile); % choose dimension name of variable in case there are more time vectors
   if isempty(D.datenum)
      disp(['no time present'])
   end

%% Get data

   I      = nc_getvarinfo(ncfile,OPT.varname);
   start  = I.Size.*0;
   count  = I.Size.*0 -1;
   stride = I.Size.*0 + OPT.stride;

   D.(OPT.varname) = nc_varget(ncfile,OPT.varname,start,count,stride);

%% get coordinates
     if nc_isatt(ncfile,OPT.varname,'coordinates');
     coordinates = nc_attget(ncfile,OPT.varname,'coordinates');
     end
     
     % use lat, lon as specified in coordinates (when nmore lats are there)
     
     if isvector(D.(AXx)) & isvector(D.(AXy))
        OPT.oned    = 1;
        D.(AXx)     = D.(AXx)(:)';
        D.(AXy)     = D.(AXy)(:)';
     end
      
%% get Attributes

      nAttr = length(fileinfo.Dataset(varindex).Attribute);
      for iAttr = 1:nAttr
      Name  = mkvar(fileinfo.Dataset(varindex).Attribute(iAttr).Name);
      Value =       fileinfo.Dataset(varindex).Attribute(iAttr).Value;
      M.(OPT.varname).(Name) = Value; % get all  % TO DO
      end

%% Plot
   
   if OPT.plot
   if ~isempty(OPT.varname)

      try
         if OPT.oned &  length(size(D.(OPT.varname)))==2
            pcolorcorcen(D.(AXx),D.(AXy),D.(OPT.varname)')
         elseif OPT.oned
            if getpref('SNCTOOLS','PRESERVE_FVD')
            pcolorcorcen(D.(AXx),D.(AXy),D.(OPT.varname)(:,:,1))
            else
            pcolorcorcen(D.(AXx),D.(AXy),D.(OPT.varname)(1,:,:))
            end
         elseif length(size(D.(OPT.varname)))==2
            pcolorcorcen(D.(AXx),D.(AXy),D.(OPT.varname))
         else % figure out proper x and y dimensions (there might also be z or t dimensions)
            if getpref('SNCTOOLS','PRESERVE_FVD')
            pcolorcorcen(D.(AXx),D.(AXy),D.(OPT.varname)(:,:,1))
            else
            pcolorcorcen(D.(AXx),D.(AXy),D.(OPT.varname)(1,:,:))
            end
         end
      catch
         error('not all permutations of (x,y,t) yet implemented')
      end
      tickmap (dimtype)
      if strcmp(dimtype,'ll')
      axislat
      end
      grid     on
      if isfield(D,'datenum')
      if  ~isempty(D.datenum); % static data do not have a timestamp
      title   ({mktex(fileinfo.Filename),...
                datestr(D.datenum(1))}); % TO DO: there might be more times or none at all
      end
      else
      title   ({mktex(fileinfo.Filename)})
      end
      
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
      
      colorbarwithvtext([mktex(long_name),' [',mktex(units),']']);
   
   end
   end
   
%% Output

   if     nargout==1
      varargout = {D};
   elseif nargout==2
      varargout = {D};
   end
   
%% EOF   
