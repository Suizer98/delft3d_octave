function vars = xb_get_vars(fname, varargin)
%XB_GET_VARS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_get_vars(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_get_vars
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl	
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
% Created: 18 Jan 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_get_vars.m 11942 2015-05-08 07:58:54Z geer $
% $Date: 2015-05-08 15:58:54 +0800 (Fri, 08 May 2015) $
% $Author: geer $
% $Revision: 11942 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_io/xb_get_vars.m $
% $Keywords: $

%% read options

OPT = struct( ...
    'vars', {{}} ...
);

OPT = setproperty(OPT, varargin{:});

%% get variables

if strcmpi(fname(end-3:end), '.dat')
    vars = get_vars_dat(fname, OPT.vars);
elseif strcmpi(fname(end-2:end), '.nc')
    vars = get_vars_netcdf(fname, OPT.vars);
elseif isdir(fname)
    if ~isempty(dir(fullfile(fname,'*.nc')))
        vars = get_vars_netcdf(fname, OPT.vars);
    elseif ~isempty(dir(fullfile(fname,'*.dat')))
        vars = get_vars_dat(fname, OPT.vars);
    else
        error(['Output type not recognised [' fname ']']);
    end
else
    error(['Output type not recognised [' fname ']']);
end

end

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function vars = get_vars_dat(fname, filter)
    vars = {};

    % get filelist
    if length(fname) > 3 && strcmpi(fname(end-3:end), '.dat')
        names = dir(fname);
    else
        names = dir([fname filesep '*.dat']);
    end
    
    % read dat files one-by-one
    for i = 1:length(names)
        varname = names(i).name(1:length(names(i).name)-4);

        % skip, if not requested
        if isempty(filter) || any(strfilter(varname, filter))
            if ~any(strcmpi(varname, {'xy', 'dims'}))
                vars = [vars{:} {varname}];
            end
        end
    end
end

function vars = get_vars_netcdf(fname, filter)
    vars = {};
    
    if isdir(fname)
        ncfiles = dir(fullfile(fname, '*.nc'));
        if ~isempty(ncfiles)
            fname   = fullfile(fname, ncfiles(1).name);
        end
    end
    
    info = nc_info(fname);
    for i = 1:length({info.Dataset.Name})
        if isempty(filter) || any(strfilter(info.Dataset(i).Name, filter))
            if ~any(strcmpi(info.Dataset(i).Name, {'parameter', 'globalx', 'globaly', 'globaltime', 'meantime'}))
                vars = [vars{:} {info.Dataset(i).Name}];
            end
        end
    end
end