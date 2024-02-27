function [x, y, z, result, mess] = ncgen_checkFcn_surface(x, y, z, varargin)
%NCGEN_CHECKFCN_SURFACE  Checks raw surface data for meeting the ncgen requirements.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = ncgen_checkFcn_surface(varargin)
%
%   Input: For <keyword,value> pairs call ncgen_checkFcn_surface() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   ncgen_checkFcn_surface
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Deltares
%       Kees den Heijer
%
%       kees.denheijer@deltares.nl
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
% Created: 04 Jul 2014
% Created with Matlab version: 8.2.0.701 (R2013b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
OPT = struct(...
    'fname', '',... % file name of raw file
    'grid_cellsize', [NaN NaN],... % schema gridsize [x y]
    'grid_offset', [0 0],... % schema offset [x y]
    'sort', true,... % switch to sort grid in ascending order
    'adjust_offset', false,... % adjust offset to schema, if not matching
    'zmin', [],... % lower z threshold, values below this level are set to nan
    'zmax', [],... % upper z threshold, values above this level are set to nan
    'filter', false ... % apply filter and keep only points that are on schema grid
    );
% return defaults (aka introspection)
% if nargin==0;
%     varargout = {OPT};
%     return
% end
% overwrite defaults with user arguments
OPT = setproperty(OPT, varargin);

%%
if isa(OPT.adjust_offset, 'function_handle')
    % evaluate adjust_offset function that should result in a boolean
    OPT.adjust_offset = feval(OPT.adjust_offset, OPT.fname);
    if ~islogical(OPT.adjust_offset)
        error('adjust_offset option does not result in boolean')
    end
end

%% code
result = struct(...
    'issorted_x', {{false, 'order of x not checked'}},...
    'issorted_y', {{false, 'order of y not checked'}},...
    'equidistant_x', {{false, 'equidistance of x not checked'}},...
    'equidistant_y', {{false, 'equidistance of y not checked'}},...
    'match_x', {{false, 'matching of x not checked'}},...
    'match_y', {{false, 'matching of y not checked'}});

%% check whether x is in ascending order
if ~issorted(x)
    result.issorted_x = {issorted(x) 'x not in ascending order'};
    if OPT.sort(1)
        % make sure X is sorted in ascending order
        [x, ix] = sort(x);
        z = z(:,ix);
        result.issorted_x = {issorted(x) 'x sorted in ascending order and z changed accordingly'};
    end
else
    result.issorted_x = {issorted(x) 'x is in ascending order'};
end

%% derive cell size and check wheter x grid is equidistant
cellsizex = unique(diff(x));
if ~isscalar(cellsizex)
    result.equidistant_x = {false, sprintf('cellsize in x direction is not constant, ranging from %g to %g', min(cellsizex), max(cellsizex))};
else
    result.equidistant_x = {true, sprintf('cellsize in x direction is constant (value = %g)', cellsizex)};
end

%% check whether y is in ascending order
if ~issorted(y)
    result.issorted_y = {issorted(y) 'y not in ascending order'};
    if OPT.sort(end)
        % make sure y is sorted in ascending order
        [y, iy] = sort(y);
        z = z(iy,:);
        result.issorted_y = {issorted(y) 'y sorted in ascending order and z changed accordingly'};
    end
else
    result.issorted_y = {issorted(y) 'y is in ascending order'};
end

%% derive cell size and check wheter y grid is equidistant
cellsizey = unique(diff(y));
if ~isscalar(cellsizey)
    result.equidistant_y = {false, sprintf('cellsize in y direction is not constant, ranging from %g to %g', min(cellsizey), max(cellsizey))};
else
    result.equidistant_y = {true, sprintf('cellsize in y direction is constant (value = %g)', cellsizey)};
end

%% check whether data cell size matches supposed size
if ~isequal(cellsizex, OPT.grid_cellsize(1))
    result.match_x = {false, sprintf('x cellsize (%g) differs from the supposed size (%g)', cellsizex, OPT.grid_cellsize(1))};
    if OPT.filter(1)
        TODO('try to filter the x values')
    end
else
    result.match_x = {true, sprintf('cell size in x direction is %g', cellsizex)};
end

%% check whether data cell size matches supposed size
if ~isequal(cellsizey, OPT.grid_cellsize(end))
    result.match_y = {false, sprintf('y cellsize (%g) differs from the supposed size (%g)', cellsizey, OPT.grid_cellsize(end))};
    if OPT.filter(end)
        TODO('try to filter the x values')
    end
else
    result.match_y = {true, sprintf('cell size in y direction is %g', cellsizey)};
end

%%
offset_x = unique(mod(x, cellsizex));
if offset_x ~= OPT.grid_offset(1)
    result.offset_x = {false, sprintf('x offset (%g) differs from the supposed offset (%g)', offset_x, OPT.grid_offset(1))};
    if OPT.adjust_offset(1)
        if offset_x <= cellsizex/2
            offset_x_corr = -offset_x;
        else
            offset_x_corr = cellsizex-offset_x;
        end
        x = x + offset_x_corr;
        result.offset_x = {true, sprintf('x offset modified by %g; original %s', offset_x_corr, result.offset_x{end})};
    end
end

offset_y = unique(mod(y, cellsizey));
if offset_y ~= OPT.grid_offset(end)
    result.offset_y = {false, sprintf('y offset (%g) differs from the supposed offset (%g)', offset_y, OPT.grid_offset(end))};
    if OPT.adjust_offset(end)
        if offset_y <= cellsizey/2
            offset_y_corr = -offset_y;
        else
            offset_y_corr = cellsizex-offset_y;
        end
        y = y + offset_y_corr;
        result.offset_y = {true, sprintf('x offset modified by %g; original %s', offset_y_corr, result.offset_y{end})};
    end
end

%% check for z values outside threshold range
if ~isempty(OPT.zmin) && any(z(:)<OPT.zmin)
    z(z<OPT.zmin) = NaN;
end

if ~isempty(OPT.zmax) && any(z(:)>OPT.zmax)
    z(z>OPT.zmax) = NaN;
end

%%
idx = cell2mat(struct2cell(structfun(@(d) d{1}, result, 'uniformoutput', false)));

if any(~idx)
    mess = sprintf('%s\n', OPT.fname);
    fnames = fieldnames(result);
    for i = 1:length(fnames)
        if ~result.(fnames{i}){1}
            mess = sprintf('%s  %s\n', mess, result.(fnames{i}){2});
        end
    end
    result = false;
elseif offset_x ~= OPT.grid_offset(1) || offset_y ~= OPT.grid_offset(end)
    svninfo = svn_info(OPT.fname);
    [~, svnrev] = system(sprintf('svnversion %s', OPT.fname));
    mess = sprintf('offset adjusted of "%s" revision %s', svninfo.url, strtrim(svnrev));
    if offset_x ~= OPT.grid_offset(1)
        mess = sprintf('%s\n %s', mess, result.offset_x{end});
    end
    if offset_y ~= OPT.grid_offset(end)
        mess = sprintf('%s\n %s', mess, result.offset_y{end});
    end
    result = true;
else
    mess = '';
    result = true;
end