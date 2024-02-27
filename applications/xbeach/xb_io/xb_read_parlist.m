function parlist = xb_read_parlist(fname, varargin)
%XB_READ_PARLIST  Read list of available parameters from output file or directory
%
%   Read list of available parameters from output file or directory.
%   Returns a cell array with names.
%
%   Syntax:
%   parlist = xb_read_parlist(fname, varargin)
%
%   Input:
%   fname     = output file or directory
%   varargin  = None
%
%   Output:
%   parlist   = cell array with parameter names
%
%   Example
%   parlist = xb_read_parlist(pwd);
%
%   See also xb_read_output

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
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

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 16 Feb 2012
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: xb_read_parlist.m 8605 2013-05-10 10:35:08Z hoonhout $
% $Date: 2013-05-10 18:35:08 +0800 (Fri, 10 May 2013) $
% $Author: hoonhout $
% $Revision: 8605 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_io/xb_read_parlist.m $
% $Keywords: $

%% read options

OPT = struct( ...
);

OPT = setproperty(OPT, varargin{:});

%% read netcdf file

if isdir(fname)
    ncfiles = dir(fullfile(fname, '*.nc'));
    datfiles = dir(fullfile(fname, '*.dat'));
    if ~isempty(ncfiles)
        fname   = fullfile(fname, ncfiles(1).name);
    elseif ~isempty(datfiles)
        
    end
end

if ~exist(fname, 'file')
	error(['File does not exist [' fname ']'])
end

info = nc_info(fname);

idx = ~cellfun(@isempty,{info.Dataset.Dimension});

parlist = {info.Dataset(idx).Name};