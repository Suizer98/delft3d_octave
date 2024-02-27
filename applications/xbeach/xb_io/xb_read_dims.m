function XBdims = xb_read_dims(filename)
%XB_READ_DIMS  read dimensions from xbeach output
%
%   Routine to read the dimension from either netcdf of .dat xbeach output.
%   The input argument "filename" can be the directory of the xbeach
%   output, the "dims.dat" file or the "xboutput.nc" file. In case
%   "filename" is a directory, it is assumed that the dimensions should be
%   read from the "dims.dat" file inside the given directory.
%
%   Syntax:
%   XBdims   = xb_read_dims(filename)
%
%   Input:
%   filename = file name. This can either be a output folder, a dims.dat file
%              or a xboutput.nc file.
%
%   Output:
%   XBdims   = structure containing the dimensions of xbeach output
%              variables
%
%   Example
%   xb_read_dims
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Kees den Heijer
%
%       Kees.denHeijer@Deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
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
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_read_dims.m 13841 2017-10-19 13:23:38Z hoonhout $
% $Date: 2017-10-19 21:23:38 +0800 (Thu, 19 Oct 2017) $
% $Author: hoonhout $
% $Revision: 13841 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_io/xb_read_dims.m $
% $Keywords: $

%% read dims

if nargin == 0 || isempty(filename)
    % the current working directory is taken by default
    filename = pwd;
end

if isdir(filename)
    % assume the filename to be the dims.dat or a netcdf file in the given directory
    dimsfile = fullfile(filename, 'dims.dat');
    
    if exist(dimsfile, 'file')
        filename = dimsfile;
    else
        ncfiles = dir(fullfile(filename, '*.nc'));
        for i = 1:length(ncfiles)
            ncfile = fullfile(filename, ncfiles(i).name);
            if true % FIXME: check for read xbeach output file
                filename = ncfile;
                break;
            end
        end
        
        if isdir(filename)
            error(['"' filename '" is not found.'])
        end
    end
end

% derive extension
[fpath fname extension] = fileparts(filename);

if strcmpi(extension, '.nc')
    % obtain info from netcdf file
    info = nc_info(filename);
    
    % pre-allocate XBdims
    XBdims = struct();
    
    % put dimensions in structure
    for ivar = 1:length(info.Dimension)
        name = info.Dimension(ivar).Name;
        if strcmpi(name, 'nx')
            name = 'globalx';
        elseif strcmpi(name, 'ny')
            name = 'globaly';
        end
        XBdims.(name) = info.Dimension(ivar).Length;
    end
    
    % read dimension data from structure
    datadimensionids = cellfun(@length, {info.Dataset.Dimension}) < 3;
    for i = find(datadimensionids)
        if info.Dataset(i).Name(1) == '_'
            continue
        end
        XBdims.([info.Dataset(i).Name '_DATA']) = nc_varget(filename, info.Dataset(i).Name);
    end
    
elseif strcmpi(extension, '.dat')
    
    fid = fopen(filename);
    v = fread(fid,1,'double');
    fclose(fid);
    if (v > 1e8)
        psize = 'single';
    else
        psize = 'double';
    end
    
    dims = struct();
    
    % read dimensions from dims.dat file
    fid = fopen(filename, 'r');
    dims.nt = fread(fid, 1, psize);
    dims.nx = fread(fid, 1, psize);
    dims.ny = fread(fid, 1, psize);
    dims.ntheta = fread(fid, 1, psize);
    dims.kmax = fread(fid, 1, psize);
    dims.ngd = fread(fid, 1, psize);
    dims.nd = fread(fid, 1, psize);
    dims.ntp = fread(fid, 1, psize);
    dims.ntc = fread(fid, 1, psize);
    dims.ntm = fread(fid, 1, psize);
    dims.tsglobal = fread(fid, [dims.nt], psize);
    dims.tspoints = fread(fid, [dims.ntp], psize);
    dims.tscross = fread(fid, [dims.ntc], psize);
    dims.tsmean = fread(fid, [dims.ntm], psize);
    fclose(fid);
    
    % read dimensions from xy.dat file
    xyfile = fullfile(fpath,'xy.dat');
    fidxy = fopen(xyfile ,'r');
    dims.x = fread(fidxy, [dims.nx dims.ny] + 1, psize);
    dims.y = fread(fidxy, [dims.nx dims.ny] + 1, psize);
    dims.xc = fread(fidxy, [dims.nx dims.ny] + 1, psize);
    dims.yc = fread(fidxy, [dims.nx dims.ny] + 1, psize);
    fclose(fidxy);
    
    XBdims = struct();
    
    % convert to netcdf-like dimension struct
    XBdims.globalx = dims.nx+1;
    XBdims.globaly = dims.ny+1;
    XBdims.globaltime = dims.nt;
    XBdims.sediment_classes = dims.ngd;
    XBdims.wave_angle = dims.ntheta;
    XBdims.bed_layers = dims.nd;
    XBdims.inout = nan;                 % TODO: find out what this is, see ncoutput.f90
    XBdims.points = nan;
    XBdims.pointtime = dims.ntp;
    XBdims.meantime = dims.ntm;
    XBdims.tidetime = nan;
    XBdims.tidecorners = nan;
    XBdims.windtime = nan;
    
    XBdims.globalx_DATA = dims.x';
    XBdims.globaly_DATA = dims.y';
    XBdims.globaltime_DATA = dims.tsglobal;
    XBdims.meantime_DATA = dims.tsmean;
    XBdims.pointtime_DATA = dims.tspoints;
    XBdims.pointx_DATA = nan;
    XBdims.pointy_DATA = nan;
    XBdims.xpointindex_DATA = nan;
    XBdims.pointtypes_DATA = nan;
    
else
    error(['directory or file "' filename '" does not exist'])
end

%% jaap's convenience attributes (not officially supported)

XBdims.nx = XBdims.globalx-1;
XBdims.ny = XBdims.globaly-1;
XBdims.nt = XBdims.globaltime;

XBdims.x = XBdims.globalx_DATA;
XBdims.y = XBdims.globaly_DATA;
XBdims.t = XBdims.globaltime_DATA;
