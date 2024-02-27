function variables = xb_read_netcdf(fname, varargin)
%XB_READ_NETCDF  Reads NetCDF formatted output files from XBeach
%
%   Reads NetCDF formatted output file from XBeach in the form of an
%   XBeach structure. Specific variables can be requested in the varargin
%   by means of an exact match, dos-like filtering or regular expressions
%   (see strfilter)
%
%   Syntax:
%   variables = xb_read_netcdf(fname, varargin)
%
%   Input:
%   fname       = filename of the netcdf file
%   varargin    = vars:     variable filters
%                 start:    Start positions for reading in each dimension,
%                           first item is zero
%                 length:   Number of data items to be read in each
%                           dimension, negative is unlimited
%                 stride:   Stride to be used in each dimension
%                 index:    Cell array with indices to read in each
%                           dimension (overwrites start/length/stride)
%
%   Output:
%   variables   = XBeach structure array
%
%   Example
%   xb = xb_read_netcdf('xboutput.nc')
%   xb = xb_read_netcdf('xboutput.nc', 'vars', 'H')
%   xb = xb_read_netcdf('xboutput.nc', 'vars', 'H*')
%   xb = xb_read_netcdf('xboutput.nc', 'vars', '/_mean$')
%   xb = xb_read_netcdf('path_to_model/xboutput.nc', 'vars', {'H', 'u*', '/_min$'})
%
%   See also xb_read_output, xb_read_dat, strfilter

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Fedor Baart
%
%       fedor.baart@deltares.nl	
%
%       Rotterdamseweg 185
%       2629HD Delft
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 19 Nov 2010
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id: xb_read_netcdf.m 11942 2015-05-08 07:58:54Z geer $
% $Date: 2015-05-08 15:58:54 +0800 (Fri, 08 May 2015) $
% $Author: geer $
% $Revision: 11942 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_io/xb_read_netcdf.m $
% $Keywords: $

%% read options

OPT = struct( ...
    'vars', {{}}, ...
    'start', [], ...
    'length', [], ...
    'stride', [], ...
    'index', [] ...
);

OPT = setproperty(OPT, varargin{:});

if ~iscell(OPT.vars); OPT.vars = {OPT.vars}; end;

%% read netcdf file

if isdir(fname)
    ncfiles = dir(fullfile(fname, '*.nc'));
    if ~isempty(ncfiles)
        fname   = fullfile(fname, ncfiles(1).name);
    end
end

if ~exist(fname, 'file')
	error(['File does not exist [' fname ']'])
end

variables = xs_empty();

info = nc_info(fname);

% allocate dims in xbeach struct
xb = xs_empty();
xb = xs_set(xb, 'START', OPT.start, 'LENGTH', OPT.length, 'STRIDE', OPT.stride, 'INDEX', OPT.index);
xb = xs_meta(xb, mfilename, 'dimensions', fname);
variables = xs_set(variables, 'DIMS', xb);

% read all variables that match filters
names = xb_get_vars(fname, 'vars', OPT.vars);

c = 2;
DIMSid = struct();
for i = find(ismember({info.Dataset.Name}, names))
    
    [start len stride] = xb_index(info.Dataset(i).Size, OPT.start, OPT.length, OPT.stride);
   
    % read data
    variables.data(c).name = info.Dataset(i).Name;
    variables.data(c).value = nc_varget(fname, info.Dataset(i).Name, start, len, stride);
    sz = len;
     if size(len) == 1
        sz = [len, 1];
    end
    variables.data(c).value = reshape(variables.data(c).value, sz);
    
    % read units, if available
    unitsid = strcmp('units', {info.Dataset(i).Attribute.Name});
    if any(unitsid)
        variables.data(c).units = info.Dataset(i).Attribute(unitsid).Value;
    end
    
    variables.data(c).dimensions = info.Dataset(i).Dimension;
    
    for j = 1:length(start)
        if start(j) ~= 0 || len(j) ~= info.Dataset(i).Size(j) || stride(j) ~= 1
            % if not all data in a dimension is retreived
            % store dims data in order to modify DIMS accordingly
            DIMSid.([variables.data(c).dimensions{j} '_DATA']) = 1 + linspace(start(j), start(j) + (len(j)-1) * stride(j), len(j));
        end
    end
    
    c = c+1;
end

% store dims in xbeach struct
XBdims = xb_read_dims(fname);
f = fieldnames(XBdims);
for i = 1:length(f)
    xb = xs_set(xb, f{i}, XBdims.(f{i}));
    if any(strcmp(f{i}, fieldnames(DIMSid)))
        try
            % reduce DIMS data in this dimension in correspondence with the
            % actual data
            xb = xs_set(xb, f{i}, XBdims.(f{i})(DIMSid.(f{i})));
        end
    end
end
variables = xs_set(variables, 'DIMS', xb);

% set meta data
variables = xs_meta(variables, mfilename, 'output', fname);

