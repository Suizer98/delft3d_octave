function [transects, dimensions] = jarkus_transects(varargin)
%JARKUS_TRANSECTS  Retrieves a selection of JARKUS data from repository
%
%   Retrieves JARKUS data based on NetCDF protocol and stores it into a
%   plain struct. The retrieved data can be controlled using filters.
%   Filters narrow the range of data in all available dimensions. The
%   filters match to the actual JARKUS data and translates the result to
%   the available dimensions. JARKUS data that is filtered should be
%   present in the output variable list in order for the filter to show any
%   effect. Currently the following dimensions are available: time,
%   alongshore, cross-shore. The dimension filters are source independent.
%   The introduction of new dimensions does not need any modification of
%   this script. The execution of the filters is optimized for speed by
%   filtering the small datasets first. Furthermore it is checked whether
%   the resulting ranges for all dimensions are equidistant. If so, strides
%   are determined to limit the number of requests needed. Finally all
%   JARKUS data within the determined ranges is retrieved and stored in a
%   plain struct.
%   Special filters do not exist in the actual NetCDF file, but are
%   translated to a field that does exist. Special filter fields cannot be
%   part of the output variable list, but the field to which the special
%   filter is translated should. Special filters currently available are:
%   year (translated to time).
%
%   Syntax:
%   transects = jarkus_transects(varargin)
%
%   Input:
%   varargin    = key/value pairs of optional parameters
%                 url       = url to JARKUS repository (default:
%                               jarkus_url)
%                 output    = cell array with names of JARKUS variables
%                               that should be returned in the struct. the
%                               names are source independent. (default:
%                               {{'id' 'time' 'cross_shore' 'altitude'}})
%                 precision = precision of the filter matching in a power
%                               of 10 using roundn (default: -4)
%                 verbose   = flag to enable verbose output (default:
%                               false)
%
%                 OTHER VARARGIN PARAMETERS ARE CONSIDERED TO BE FILTERS
%                 AND SHOULD MATCH THE SOURCE INDEPENDENT JARKUS FIELD
%                 NAMES. THE FILTER "YEAR" IS AN EXCEPTION WHEREAS THIS
%                 FILTER IS TRANSLATED TO THE "TIME" FILTER.
%
%   Output:
%   transects   = struct with JARKUS data
%
%   Example
%   transects = jarkus_transects('year', [2001:2003 2008], 'id', 17000071)
%   transects = jarkus_transects('year', [2001:2008], 'areacode', 13)
%   transects = jarkus_transects('year', 2008, 'id', 17000000:17000500, 'altitude', 0:20, 'precision', 0)
%
%   See also jarkus_decurve

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       Rotterdamseweg 185
%       2629HG Delft
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

% This tool is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 21 Dec 2009
% Created with Matlab version: 7.5.0.338 (R2007b)

% $Id: jarkus_transects.m 8692 2013-05-27 06:32:18Z hoonhout $
% $Date: 2013-05-27 14:32:18 +0800 (Mon, 27 May 2013) $
% $Author: hoonhout $
% $Revision: 8692 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/jarkus/jarkus_transects.m $
% $Keywords$

%% settings

OPT = struct( ...
    'url', jarkus_url, ...
    'output', {{'id','time','x','y','cross_shore','altitude'}}, ...
    'precision', -4, ...
    'verbose', false ...
);

FLTR = struct();

% update option struct and interpret other arguments as jarkus filters
varargin1 = {};
varargin2 = {};
for i = 1:2:length(varargin)
    if ~isfield(OPT, varargin{i})
        FLTR.(varargin{i}) = [];
        varargin2 = [varargin2 varargin(i:i+1)];
    else
        varargin1 = [varargin1 varargin(i:i+1)];
    end
end

OPT = setproperty(OPT, varargin1{:});
FLTR = setproperty(FLTR, varargin2{:});

%% retrieve jarkus info

transects = struct('url', OPT.url);
dimensions = struct();

% get jarkus info
jInfo = nc_info(OPT.url);

% check jarkus info
if OPT.verbose; disp('Checking JARKUS info:'); end;

required = {'Dimension' 'Dataset'};
missing = ~isfield(jInfo, required);
if any(missing)
    if OPT.verbose; disp(['    ERROR: missing ' [required{missing}]]); end;
    return;
end
if OPT.verbose; disp('    OK'); disp(' '); end;

% show jarkus info attributes
if OPT.verbose && isfield(jInfo, 'Attribute')
    disp('Using JARKUS data:');
    disp(['    ' transects.url]);
    for i = 1:length(jInfo.Attribute)
        fprintf('\t%s: %s\n', jInfo.Attribute(i).Name, jInfo.Attribute(i).Value);
    end
    disp(' ');
end

% read dimensions
if OPT.verbose; disp('Reading dimensions:'); end;

jDims = struct();
for i = 1:length(jInfo.Dimension)
    name = regexprep(jInfo.Dimension(i).Name,'[^\w_]','');
    jDims.(name) = struct( ...
        'length', jInfo.Dimension(i).Length, ...
        'indices', 1:jInfo.Dimension(i).Length ...
    );
    
    if OPT.verbose; disp(['    ' name ': ' num2str(jDims.(name).length)]); end;
end

if OPT.verbose; disp(' '); end;

%% optimize filter generation

sizes = cellfun(@prod, {jInfo.Dataset.Size});

[~, datasetOrder] = sort(sizes);

%% create filters

if OPT.verbose; disp('Creating filters:'); end;

% interpret special filters
if isfield(FLTR, 'year')
    % get available times
    t = nc_varget(OPT.url, 'time');
    % only keep times that correspond to the year filter
    years = t(ismember(year(t+datenum(1970,1,1)), FLTR.year));
    for i = 1:length(years)
        if isfield(FLTR, 'time')
            % append years to the time filter
            FLTR.time = [FLTR.time(:)' years(:)'];
        else
            % create time filter
            FLTR.time = years;
        end
    end
    % remove the year filter, since it is no variable in the netcdf file
    FLTR = rmfield(FLTR, 'year');
end

% create dataset filters
for i = datasetOrder
    name = jInfo.Dataset(i).Name;
    
    % check if filter for current dataset is available
    if isfield(FLTR, name)
        if OPT.verbose; disp(['    ' name]); end;
        
        filter = FLTR.(name);
        
        if ischar(filter); filter = {filter}; end;
        
        dims = length(jInfo.Dataset(i).Dimension);
        
        if islogical(filter)
            % filter is logical, trust it
            indices = find(filter);
        else
            % built simple filter based on already processed filter parts
            start = ones(1,dims);
            count = -1*ones(1,dims);
            
            for j = 1:dims
                dim = jInfo.Dataset(i).Dimension{j};
                
                if isfield(jDims, dim)
                    if isfield(jDims.(dim), 'indices') && ~isempty(jDims.(dim).indices)
                        start(j) = min(jDims.(dim).indices);
                        count(j) = max(jDims.(dim).indices)-start(j)+1;
                    end
                end
            end
            
            % retrieve data
            data = double(nc_varget(OPT.url, name, start-1, count));
            
            % set precision
            if ~ischar(data)
                data = round(data*10^-OPT.precision)/10^-OPT.precision;
                filter = round(filter*10^-OPT.precision)/10^-OPT.precision;
            end
            
            % match filter with data
            indices = find(ismember(data, filter));
            
            % no match, check if filter could be indices already
            if isempty(indices) && min(filter) >= 1 && max(filter) <= numel(data)
                indices = filter;
            end
        end
        
        % get coordinates of hits
        coords = numel2coord(count, indices);
        coords = coords + ones(size(coords,1),1)*(start-1);
        
        % narrow selected indices for each dimension based on filter
        for j = 1:dims
            dim = jInfo.Dataset(i).Dimension{j};
            if isfield(jDims, dim)
                indices = jDims.(dim).indices;
                jDims.(dim).indices = indices(ismember(indices,unique(coords(:,j))));
            end
        end
    end
end

if OPT.verbose; disp(' '); end;

%% determine stride

if OPT.verbose; disp('Determining strides:'); end;

% determine if selected indices for any dimension are equidistant, if so,
% use stride for fast data retrieval
cnt = 0;
dims = fieldnames(jDims);
for i = 1:length(dims)
    dim = dims{i};
    
    % no optimization if only one index is selected
    if length(jDims.(dim).indices) > 1
        
        % optimize for equidistant indices
        if max(diff(jDims.(dim).indices)) == min(diff(jDims.(dim).indices))
            jDims.(dim).stride = min(diff(jDims.(dim).indices));
            cnt = cnt + 1;
        else
            jDims.(dim).stride = false;
        end
    else
        jDims.(dim).stride = 1;
    end
end

if OPT.verbose; disp(['    ' num2str(cnt) ' found']); end;
if OPT.verbose; disp(' '); end;

%% retrieve jarkus data

if OPT.verbose; disp('Retrieving JARKUS data:'); end;

% collect extra info about dimensions in order to be able to retrieve and
% store the data easily
dims = fieldnames(jDims);
for i = 1:length(dims)
    dim = dims{i};
    
    jDims.(dim).resultLength = length(jDims.(dim).indices);
end

% loop through output variables
for i = 1:length(OPT.output)
    
    % determine output variable name and index
    var = OPT.output{i};
    ivar = find(strcmpi({jInfo.Dataset.Name},var));
    
    if ~isempty(ivar)
        % determine output variable dimensions
        dims = length(jInfo.Dataset(ivar).Dimension);

        % allocate return variable size and number of requests necessary
        gets = ones(1,dims);
        start = ones(1,dims);
        count = zeros(1,dims);
        stride = ones(1,dims);
        rsize = ones(1,dims);

        % select relevant dimension data
        for j = 1:dims
            dim = regexprep(jInfo.Dataset(ivar).Dimension{j},'[^\w_]','');

            rsize(j) = jDims.(dim).resultLength;

            % determine number of requests needed
            if jDims.(dim).stride == false
                gets(j) = jDims.(dim).resultLength;
                count(j) = 1;
                stride(j) = 1;
            else
                gets(j) = 1;

                if jDims.(dim).resultLength > 0
                    start(j) = min(jDims.(dim).indices);
                    count(j) = length(jDims.(dim).indices);
                    stride(j) = jDims.(dim).stride;
                end
            end
        end

        % allocate output variable
        if length(rsize) == 1; rsize = [1 rsize]; end;
        transects.(var) = zeros(rsize);
        dimensions.(var) = jInfo.Dataset(ivar).Dimension;

        % execute number of requests necessary
        n = prod(gets);
        for j = 1:n
            if OPT.verbose; disp(['    ' var ' ' num2str(j) ' of ' num2str(n) '...']); end;

            % determine coordinates in output variable for current request
            coords = numel2coord(gets, j);

            % allocate output mapping struct
            idx = cell(1,dims);

            % determine non-stride selection
            for k = 1:dims
                dim = regexprep(jInfo.Dataset(ivar).Dimension{k},'[^\w_]','');

                if jDims.(dim).stride == false
                    start(k) = jDims.(dim).indices(coords(k));
                    idx{k} = coords(k);
                else
                    idx{k} = ':';
                end
            end

            % retrieve data
            if ~any(count<1)
                data = nc_varget(OPT.url, var, start-1, count, stride);

                % distribute data over output variables
                transects.(var)(idx{:}) = data;
            end
        end
        
        if jInfo.Dataset(ivar).Nctype == nc_char
            % make sure type char is stored as such
            transects.(var) = char(transects.(var));
        end
    end
end