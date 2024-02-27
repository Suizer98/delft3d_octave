function [data, netcdf_index, OPT] = ncgentools_get_data_in_box(netcdf_index, varargin)
%NCGENTOOLS_GET_DATA_IN_BOX  Selection of z data in elevation type of netcdf datasets. 
%
%   Function retrieves z data from the netcdf files of the type elevation data.
%   These datasets contain geospatial data and is stored in tiles.
%   The z data is stored in the 3D dimension.
%
%   Syntax:
%   ncgentools_get_data_in_box(netcdf_index, varargin)
%
%   Input:
%       netcdf_index = netcdf netcdf_index structure, or a path
%       $varargin    =
%
%   where the following <keyword,value> pairs have been implemented (values indicated are the current default settings):
%       'x_range'       , []                = selection range for x [min max]
%       'y_range'       , []                = dito for y
%       'lat_range'     , []                = dito for latitude
%       'lon_range'     , []                = dito for longitude
%       't_range'       , []                = dito for time (in matlab datenum)
%       't_method'      , 'last_in_range'   = method of collecting/selecting
%                                             the z values in time:
%                         'last_in_range'       -> the last dataset (per file) is put in a 2D z matrix
%                         'all_in_range'        -> all data is retrieved in a 3D z matrix
%                         'merged_in_range'     -> all data is merged to a 2D z matrix where newer values overwrites the older values
%                         'statFcn'             -> the z data is the outcome of the statistical function (see 'statFcn')
%                         'linear_interpolated' -> not inplemented (yet)
%       'x_stride'      , 1                 = stride for x
%       'y_stride'      , 1                 = stride for y 
%       'lat_stride'    , 1                 = stride for lat
%       'lon_stride'    , 1                 = stride for lon
%       'include_xy'    , false             = flag for including the x and y values in the output
%       'include_latlon', false             = flag for including the lat and lon values in the output
%       'statFcn'       , []                = function handle of 1D statistical calculation on z like:
%                                               @(z) max(z) 
%                                               @(z) min(z) 
%                                               @(z) nanmean(z) 
%                                               @(z) nanmedian(z) 
%                                               @(z) sum(~isnan(z)) %calculates the count   
%                                       Functions like mean and median FAILS because of the presents of nan's 
%   Output:
%       data            = structure with the fields:
%           'z'   ,  z values in meshgrid format
%                    2D matrix for t_method 'last_in_range' 'merged_in_range' 'statFcn' 
%                    3D matrix (x,y,t)for 'all_in_range'
%           'x'   ,  x values in meshgrid format (optional)         
%           'y'   ,  y values in meshgrid format (optional)
%           'lat' ,  latitude values in meshgrid format (optional)
%           'lon' ,  longitude values in meshgrid format (optional)
%           't'   ,  time array (optional, when t_method 'all_in range' or 'statFcn' is used)
%       netcdf_index    = structure with the contens of the netcdf_index
%       OPT             = structure with used OPT fields.
%
%   Remarks:
%       For the geospatial selection only one pair of coordinates system must be given, like x y OR lat lon
%       When a statFcn is given, the t_method is automatically set to 'statFcn'
%
%   Example
%   ncgentools_get_data_in_box
%
%     netcdf_index = ncgentools_get_data_in_box('D:\products\nc\rijkswaterstaat\vaklodingen\combined');
%     [data, netcdf_index, OPT] = ncgentools_get_data_in_box(netcdf_index,...
%         'x_range' ,[-inf inf],...
%         'y_range' ,[-inf inf],...
%         't_range' ,[-inf inf],...
%         'x_stride',20,...
%         'y_stride',20);
%   surf(data.x,data.y,data.z)
%   view(2)
%   shading flat
%
%   See also
%      
%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Van Oord
%       Thijs Damsma
%       Ronald van der Hout
%
%          tda@vanoord.com
%          ronald.vanderhout@vanoord.com
%   
%       Schaardijk 211
%       3063 NH
%       Rotterdam
%       Netherlands
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

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 12 Jun 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id: ncgentools_get_data_in_box.m 9203 2013-09-09 14:49:33Z rho.x $
% $Date: 2013-09-09 22:49:33 +0800 (Mon, 09 Sep 2013) $
% $Author: rho.x $
% $Revision: 9203 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ncgen/ncgentools/ncgentools_get_data_in_box.m $
% $Keywords: $

%%
OPT.x_range    = [];
OPT.y_range    = [];
OPT.lat_range  = [];
OPT.lon_range  = [];
OPT.t_range    = [];
OPT.t_method   = 'last_in_range';
OPT.x_stride   = 1;
OPT.y_stride   = 1;
OPT.lat_stride = 1;
OPT.lon_stride = 1;
OPT.include_xy = false;
OPT.include_latlon = false;
OPT.statFcn    = [];

OPT = setproperty(OPT,varargin{:});

if nargin==0;
    data = OPT;
    return;
end
%% error check and initialization

if nargin>1;
    % check if varargins were parsed correctly
    mode_xy = ...
        numel(OPT.x_range) == 2 &&  ...
        numel(OPT.y_range) == 2 && ...
        numel(OPT.lat_range) == 0 &&  ...
        numel(OPT.lon_range) == 0;
    mode_latlon = ...
        numel(OPT.x_range) == 0 &&  ...
        numel(OPT.y_range) == 0 && ...
        numel(OPT.lat_range) == 2 &&  ...
        numel(OPT.lon_range) == 2;
    assert(...
        xor(mode_xy,mode_latlon) && ... % one or the other, not both   
        numel(OPT.t_range) == 2,'x, y, lat, lon and t range must all be specified as two element vectors. Furthermore, you should specify either x and y, or lat and lon');
    assert(~strcmp(OPT.t_method, 'statFcn')||...
        strcmp(OPT.t_method, 'statFcn') && isa(OPT.statFcn,'function_handle'), 'No statistical function handle is passed, see help on function') 
    assert(...
        ismember(OPT.t_method,{'last_in_range' 'all_in_range' 'merged_in_range' 'statFcn'}), 'No valid t_method is given, see help on function')
end

% check if netcdf index is a path or a 
if ischar(netcdf_index)
    % build index if a path is specified 
    netcdf_index = generate_netcdf_index(netcdf_index);
else
    assert(isstruct(netcdf_index))
    assert(all(ismember({
    'urlPath'
    'var_x'
    'resolution_x'
    'var_y'
    'resolution_y'
    'var_lat'
    'var_lon'
    'var_z'
    'var_t'
    'dim_x'
    'dim_y'
    'dim_t'
    'projectionCoverage_x'
    'projectionCoverage_y'
    'timeCoverage'
    'geospatialCoverage_eastwest'
    'geospatialCoverage_northsouth'
    },fieldnames(netcdf_index))),...
    'The format of the netcdf_index is wrong, perhaps it was generated by a previous version of ncgentools, please generate it again')
end

if nargin == 1
    % if the fnction is called with a single argument, return the netcdf_index
    data = netcdf_index;
    return
end

if isa(OPT.statFcn,'function_handle')
    OPT.t_method = 'statFcn';
end

% replace -inf / +inf ranges in x and y with smallest/largest actual range

coverage_x = netcdf_index.projectionCoverage_x;
coverage_y = netcdf_index.projectionCoverage_y;

if mode_xy
    range_x     = OPT.x_range;
    range_y     = OPT.y_range;
    range_x     = [min(range_x) max(range_x)];
    range_y     = [min(range_y) max(range_y)];
    stride_x    = OPT.x_stride;
    stride_y    = OPT.y_stride;
    if isempty(OPT.include_latlon)
        OPT.include_xy = true;
        OPT.include_latlon = false;
    end
end
if mode_latlon
    % find the tiles that contain the corners of the lat/lon box
    range_x     = OPT.lon_range;
    range_y     = OPT.lat_range;
    if isinf(range_x(1)); range_x(1) = min(netcdf_index.geospatialCoverage_eastwest(:)); end
    if isinf(range_x(2)); range_x(2) = max(netcdf_index.geospatialCoverage_eastwest(:)); end
    if isinf(range_y(1)); range_y(1) = min(netcdf_index.geospatialCoverage_northsouth(:)); end
    if isinf(range_y(2)); range_y(2) = max(netcdf_index.geospatialCoverage_northsouth(:)); end
    [range_x,range_y] = convertCoordinates(range_x([1 1 2 2]),range_y([1 2 1 2]),'persistent','CS1.code',4326,'CS2.code',netcdf_index.epsg_code);
    range_x     = [min(range_x) max(range_x)];
    range_y     = [min(range_y) max(range_y)];
    stride_x    = OPT.lon_stride;
    stride_y    = OPT.lat_stride;
    if isempty(OPT.include_latlon)
        OPT.include_xy     = false;
        OPT.include_latlon = true;
    end
end

range_x(1) = max(range_x(1),min(coverage_x(:))); 
range_x(2) = min(range_x(2),max(coverage_x(:))); 
range_y(1) = max(range_y(1),min(coverage_y(:))); 
range_y(2) = min(range_y(2),max(coverage_y(:))); 

%% search data
files_to_search = find(...
coverage_x(:,1) <= range_x(2) & ...
coverage_x(:,2) >= range_x(1) & ...
coverage_y(:,1) <= range_y(2) & ...
coverage_y(:,2) >= range_y(1))';

if isempty(files_to_search)
    data.z = nan;
    return
end
% allocate a grid of the size of x and y


% 
% for the x_grid the projection 
x = min(coverage_x) + .5 * netcdf_index.resolution_x : netcdf_index.resolution_x * stride_x : range_x(2);
x(x<range_x(1)) = [];
y = min(coverage_y) + .5 * netcdf_index.resolution_y : netcdf_index.resolution_y * stride_y : range_y(2);
y(y<range_y(1)) = [];


%% Preparations
    % last before
    % linear interpolated
    % merged in range 
if any(strcmp(OPT.t_method,{'all_in_range' 'statFcn'}))
    t_nc_all = {};
    files_to_search_in_time_range = [];
    for ii = files_to_search
        ncfile   = netcdf_index.urlPath{ii};
        t_nc     = nc_cf_time(ncfile,netcdf_index.var_t);
        t_nc(t_nc<OPT.t_range(1) | t_nc>OPT.t_range(2)) = [];
        if isempty(t_nc) 
            % do nothing
        else
            files_to_search_in_time_range = [files_to_search_in_time_range ii]; %#ok<AGROW>
            t_nc_all{end+1} = t_nc;                                             %#ok<AGROW>
        end
    end
    t_nc_all = unique(vertcat(t_nc_all{:}));
    t_nc_all(t_nc_all<OPT.t_range(1) | t_nc_all>OPT.t_range(2)) = [];
    data.z = nan(length(y),length(x),length(t_nc_all));
    data.t = t_nc_all;
    files_to_search = files_to_search_in_time_range;
else
    data.z = nan(length(y),length(x));
end
         
if OPT.include_latlon
    data.lat = nan(length(y),length(x));
    data.lon = nan(length(y),length(x));
end            

%% Read the data
for ii = files_to_search
    ncfile   = netcdf_index.urlPath{ii};
   
    x_nc     = ncread    (ncfile,netcdf_index.var_x);
    y_nc     = ncread    (ncfile,netcdf_index.var_y);
    t_nc     = nc_cf_time(ncfile,netcdf_index.var_t);
    
    % determine     t_start;
    t_sorted = issorted(t_nc);
    
    switch OPT.t_method
        case 'last_in_range'
            t_found = max(t_nc(t_nc>=OPT.t_range(1) & t_nc<=OPT.t_range(2)));
            if ~isempty(t_found)
                t_start = find(t_nc == max(t_nc(t_nc<=OPT.t_range(2))));
            else
                t_start = [];
            end
            t_count = 1;
        case {'all_in_range' 'statFcn' 'merged_in_range'}
            t_found = find(t_nc>=OPT.t_range(1) & t_nc<=OPT.t_range(2));
            if ~isempty(t_found)
                t_start = min(t_found);
            else
                t_start = [];
            end
            t_count = max(t_found) + 1 - min(t_found);
        case 'linear_interpolated'
            assert(t_sorted)
%         case 'merged_in_range'
%             assert(t_sorted)
    end
    if isempty(t_start); continue; end
    
    flip_x   = x_nc(1)>x_nc(end);
    flip_y   = y_nc(1)>y_nc(end);
    
    if flip_x; x_nc = x_nc(end:-1:1); end
    if flip_y; y_nc = y_nc(end:-1:1); end   
  
    % find the first index of x in range of nc_file
    try
        ix(1)    = find(x >= x_nc(1  ),1,'first');
        ix(2)    = find(x <= x_nc(end),1, 'last');
        iy(1)    = find(y >= y_nc(1  ),1,'first');
        iy(2)    = find(y <= y_nc(end),1, 'last');
    catch %#ok<CTCH>
        % this is when the is no relevant data in the nc file, even though
        % it seemed so from the projectionCoverage
        continue
    end
    
    % find indices in nc file
    ix_nc(1) = find(x_nc>=x(ix(1)),1,'first');
    ix_nc(2) = find(x_nc<=x(ix(2)),1, 'last');
    iy_nc(1) = find(y_nc>=y(iy(1)),1,'first');
    iy_nc(2) = find(y_nc<=y(iy(2)),1, 'last');
    
    % find indices in data.z
    nz_i(1)  = find(x == x_nc(ix_nc(1)),1);
    nz_i(2)  = find(x == x_nc(ix_nc(2)),1);
    mz_i(1)  = find(y == y_nc(iy_nc(1)),1);
    mz_i(2)  = find(y == y_nc(iy_nc(2)),1);
    
    % initialize
    start        = [nan nan nan];
    count        = [nan nan nan];
    stride       = [nan nan nan];
    
    % set start
    start(netcdf_index.dim_x) = ix_nc(1);
    start(netcdf_index.dim_y) = iy_nc(1);
    start(netcdf_index.dim_t) = t_start;
    
    % calculate count and stride
    count(netcdf_index.dim_x) = ix_nc(2) - start(netcdf_index.dim_x);
    count(netcdf_index.dim_y) = iy_nc(2) - start(netcdf_index.dim_y);
    count(netcdf_index.dim_t) = t_count;
    
    stride(netcdf_index.dim_x) = stride_x;
    stride(netcdf_index.dim_y) = stride_y;
    stride(netcdf_index.dim_t) = 1;
    
    % correct flipped dimensions for start and count
    if flip_x; start(netcdf_index.dim_x) = length(x_nc) + 1 - start(netcdf_index.dim_x) - count(netcdf_index.dim_x); end
    if flip_y; start(netcdf_index.dim_y) = length(y_nc) + 1 - start(netcdf_index.dim_y) - count(netcdf_index.dim_y); end
    
    count = count ./ stride + 1;
    count(netcdf_index.dim_t) = t_count;
    
    %% z data
        % read data from nc file
        z_tmp = ncread(ncfile,netcdf_index.var_z,start,count,stride);

        % permute data in correct order
        z_tmp = permute(z_tmp,[netcdf_index.dim_y,netcdf_index.dim_x,netcdf_index.dim_t]);

        % correct flipped dimensions for start and count
        if flip_x; z_tmp = flipdim(z_tmp,2); end
        if flip_y; z_tmp = flipdim(z_tmp,1); end
        
        if any(strcmp(OPT.t_method,{'all_in_range' 'statFcn'})) && t_count >= 1  %prev:  >1
            [~,z_ind] = ismember(t_nc,t_nc_all);
            z_ind(z_ind == 0) = [];
            data.z(mz_i(1):mz_i(2),nz_i(1):nz_i(2),z_ind) = z_tmp;
            
        elseif strcmp(OPT.t_method,'merged_in_range')
            %Only overwrite non Nan values = last known filled value (=last time)
            z_merged    = data.z(mz_i(1):mz_i(2),nz_i(1):nz_i(2));
            for nt = 1:size(z_tmp,3)
                tempdat  = z_tmp(:,:,nt);
                isfilled = ~isnan(tempdat);
                z_merged(isfilled) = tempdat(isfilled);
            end
            data.z(mz_i(1):mz_i(2),nz_i(1):nz_i(2)) = z_merged;
            
        else % Last in range
            data.z(mz_i(1):mz_i(2),nz_i(1):nz_i(2)) = z_tmp;            
        end
        
    if OPT.include_latlon
        start(netcdf_index.dim_t) = [];
        count(netcdf_index.dim_t) = [];
        stride(netcdf_index.dim_t) = [];
        
        %% lon data
            % read data from nc file
            lon_tmp = ncread(ncfile,netcdf_index.var_lon,start,count,stride);

            % permute data in correct order
            lon_tmp = permute(lon_tmp,[netcdf_index.dim_y,netcdf_index.dim_x]);

            % correct flipped dimensions for start and count
            if flip_x; lon_tmp = flipdim(lon_tmp,2); end
            if flip_y; lon_tmp = flipdim(lon_tmp,1); end
            
            data.lon(mz_i(1):mz_i(2),nz_i(1):nz_i(2)) = lon_tmp;
        %% lat data
            % read data from nc file
            lat_tmp = ncread(ncfile,netcdf_index.var_lat,start,count,stride);

            % permute data in correct order
            lat_tmp = permute(lat_tmp,[netcdf_index.dim_y,netcdf_index.dim_x]);

            % correct flipped dimensions for start and count
            if flip_x; lat_tmp = flipdim(lat_tmp,2); end
            if flip_y; lat_tmp = flipdim(lat_tmp,1); end
            
            data.lat(mz_i(1):mz_i(2),nz_i(1):nz_i(2)) = lat_tmp;
    end
end

%% Post process z
if strcmp(OPT.t_method,'statFcn') 
    [nx, ny, ~ ]= size(data.z);
    z_stat = nan(nx,ny);
    %Proces stat function on the gridcells
%     tic
%     for n = 1:nx
%         for  m = 1:ny
%             z_stat(n,m) = OPT.statFcn(data.z(n,m,:));
%         end
%     end 
%     toc
    
    %Convert to column vectors 
    for m = 1:ny
        tmp = squeeze(data.z(:,m,:))';
        z_stat(:,m) = OPT.statFcn(tmp);
    end       
    
    data.z = z_stat;
end


if OPT.include_xy
    [data.x,data.y] = meshgrid(x,y);
end

function netcdf_index = generate_netcdf_index(netcdf_path)

%% run ncinfo command on all files and store in structure info.
netcdf_index.urlPath = opendap_catalog(netcdf_path);
for ii = length(netcdf_index.urlPath):-1:1
    info(ii) = ncinfo(netcdf_index.urlPath{ii});
    multiWaitbar('Building catalog',(length(netcdf_index.urlPath)+1-ii)/length(netcdf_index.urlPath))
end
multiWaitbar('Building catalog','close');

%% collect attributes of interest from the structure
for ii = 1:length(info(1).Variables)
    var_att_names   = {info(1).Variables(ii).Attributes.Name};
    var_att_values  = {info(1).Variables(ii).Attributes.Value};
    n_stdname       = strcmp(var_att_names,'standard_name');
    if any(n_stdname)
        switch var_att_values{n_stdname}
            case 'longitude';                netcdf_index.var_lon   = info(1).Variables(ii).Name;
            case 'latitude';                 netcdf_index.var_lat   = info(1).Variables(ii).Name;  
            case 'projection_x_coordinate';  netcdf_index.var_x     = info(1).Variables(ii).Name;
                n_resolution = strcmp({info(1).Variables(ii).Attributes.Name},'resolution');
                netcdf_index.resolution_x = info(1).Variables(ii).Attributes(n_resolution).Value;
            case 'projection_y_coordinate';  netcdf_index.var_y     = info(1).Variables(ii).Name;
                n_resolution = strcmp({info(1).Variables(ii).Attributes.Name},'resolution');
                netcdf_index.resolution_y = info(1).Variables(ii).Attributes(n_resolution).Value;
            case 'time';                     netcdf_index.var_t     = info(1).Variables(ii).Name;
            case {'elevation','altitude'};   netcdf_index.var_z     = info(1).Variables(ii).Name;
        end
    end
end

%
dimensions = {info(1).Variables(strcmp(netcdf_index.var_z,{info(1).Variables.Name})).Dimensions.Name};
netcdf_index.dim_x      = find(strcmp(dimensions,netcdf_index.var_x));
netcdf_index.dim_y      = find(strcmp(dimensions,netcdf_index.var_y));
netcdf_index.dim_t      = find(strcmp(dimensions,netcdf_index.var_t));

att_names  = cellfun(@(s) {s.Name},{info.Attributes},'UniformOutput',false);
att_names  = vertcat(att_names {:});
att_values = cellfun(@(s) {s.Value},{info.Attributes},'UniformOutput',false);
att_values = vertcat(att_values{:});

% % THIS SECTION GOES SOMEHOW WRONG, THE INDEX SEEMS OK BUT THE RESULT IS NOT CORRECTLY RETURNED
% % See also:  find(strcmp(att_names,'projectionCoverage_x'))
% % and        find(strcmp(att_names(1,:),'projectionCoverage_x'))

% netcdf_index.projectionCoverage_x           = att_values(strcmp(att_names,'projectionCoverage_x'));
% netcdf_index.projectionCoverage_x           = vertcat(netcdf_index.projectionCoverage_x{:});
% 
% netcdf_index.projectionCoverage_y           = att_values(strcmp(att_names,'projectionCoverage_y'));
% netcdf_index.projectionCoverage_y           = vertcat(netcdf_index.projectionCoverage_y{:});
% 
% netcdf_index.timeCoverage                   = att_values(strcmp(att_names,'timeCoverage'));
% 
% netcdf_index.geospatialCoverage_eastwest    = att_values(strcmp(att_names,'geospatialCoverage_eastwest'));
% netcdf_index.geospatialCoverage_eastwest    = vertcat(netcdf_index.geospatialCoverage_eastwest{:});
% 
% netcdf_index.geospatialCoverage_northsouth  = att_values(strcmp(att_names,'geospatialCoverage_northsouth'));
% netcdf_index.geospatialCoverage_northsouth  = vertcat(netcdf_index.geospatialCoverage_northsouth{:});

for n = 1:size(att_names,1)
    netcdf_index.projectionCoverage_x(n,:)          = att_values{n,strcmp(att_names(n,:),'projectionCoverage_x')};
    netcdf_index.projectionCoverage_y(n,:)          = att_values{n,strcmp(att_names(n,:),'projectionCoverage_y')};
    netcdf_index.timeCoverage(n,:)                  = att_values(n,strcmp(att_names(n,:),'timeCoverage'));
    netcdf_index.geospatialCoverage_eastwest(n,:)   = att_values{n,strcmp(att_names(n,:),'geospatialCoverage_eastwest')};
    netcdf_index.geospatialCoverage_northsouth(n,:) = att_values{n,strcmp(att_names(n,:),'geospatialCoverage_northsouth')};  
end

crs_ind         = strcmp('crs',{info(1).Variables.Name});
if sum(crs_ind==1)
    crs_atts        = info(1).Variables(crs_ind).Attributes;
    crs_att_names   = {crs_atts.Name};
    crs_att_values  = {crs_atts.Value};
    netcdf_index.epsg_code = sscanf(cell2mat(crs_att_values(strcmpi(crs_att_names,'EPSG_code'))),'EPSG:%d');
else
    netcdf_index.epsg_code = nan;
end