function figaligntogrid(varargin)
%FIGALIGNTOGRID  Arrange multiple figures on screen in regular order
%
%   Function to easily arrange one or more figures on the screen.
%
%   Syntax:
%   varargout = figaligntogrid(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   figaligntogrid % distribute all available figures over the screen
%   figaligntogrid(gcf) % make current figure full screen
%   figaligntogrid(2,2) % arrange figures in two rows and two columns
%   figaligntogrid(gcf, 2, 2) % arrange current figure in the upper left
%                               corner of the screen
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Delft University of Technology
%       Kees den Heijer
%
%       C.denHeijer@TUDelft.nl
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
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
% Created: 30 Mar 2012
% Created with Matlab version: 7.13.0.564 (R2011b)

% $Id: figaligntogrid.m 6714 2012-06-29 11:23:34Z heijer $
% $Date: 2012-06-29 19:23:34 +0800 (Fri, 29 Jun 2012) $
% $Author: heijer $
% $Revision: 6714 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/plot_fun/figaligntogrid.m $
% $Keywords: $

%%
OPT = struct(...
    'monitor', 'primary',...
    'screensize', 0,...
    'bottommargin', .04,...
    'rightmargin', 0,...
    'leftmargin', 0);

error(nargchk(0, 3+length(fieldnames(OPT))*2, nargin))

pnid = find(ismember(cellfun(@class, varargin, 'UniformOutput', false), 'char'), 1, 'first');
OPT = setproperty(OPT, varargin{pnid:end});
varargin(pnid:end) = [];

if ~ismember(lower(OPT.monitor), {'primary' 'secondary' 'both'})
    error('Unknown monitor option "%s"', OPT.monitor)
end

%%
lowermargin = .04; % normalized value

fh = sort(findall(0, 'type', 'figure'));
[nrow mcolumn] = deal([]);
if ismember(length(varargin), [1 3])
    fh = varargin{1}(ishandle(varargin{1}));
    if isempty(fh)
        return
    end
    fh = fh(:);
end
if ismember(length(varargin), 2:3)
    [nrow mcolumn] = deal(varargin{end-1:end});
end

nfig = length(fh);
if isempty(nrow)
    nrow = floor(sqrt(nfig));
    mcolumn = ceil(nfig / nrow);
end

if ~strcmpi(OPT.monitor, 'primary')
    if size(get(0, 'MonitorPositions'), 1) == 1
        error('No secondary monitor found')
    end
    if ispc
        units = get(0, 'units');
        set(0, 'units', 'normalized')
        MonitorPositions = get(0, 'MonitorPositions');
        set(0, 'units', units)
    else
        todo(sprintf('Monitor option "%s" not yet implemented for this platform', OPT.monitor));
    end
    return
end

units = get(fh, 'units');
visible = get(fh, 'visible');
if isscalar(fh)
    [units visible] = deal({units}, {visible});
end
set(fh, 'units', 'normalized')

% prepare elements of outerposition
x0 = repmat(linspace(0, 1-1/mcolumn, mcolumn)', max([nrow nfig]), 1);
y0 = repmat(linspace(1-(1-lowermargin)/nrow, lowermargin, nrow), mcolumn, 1);
y0 = y0(:);
if numel(y0) < nfig
    y0 = repmat(y0, ceil(nfig/numel(y0)), 1);
end
x = repmat(1/mcolumn, nfig, 1);
y = repmat((1-lowermargin)/nrow, nfig, 1);

% construct outerposition matrix
outerposition = [x0(1:nfig) y0(1:nfig) x y];
% set outerposition, restore original units and make all figures visible
set(fh,...
    {'outerposition'}, mat2cell(outerposition, ones(nfig,1), 4),...
    {'units'}, units,...
    {'visible'}, visible);