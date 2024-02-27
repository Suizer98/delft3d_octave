function subplot_rearrange(varargin)
%SUBPLOT_REARRANGE  Rearranges the subplots in a figure window in a new grid
%
%   Rearranges the subplots in a figure window in a new grid
%
%   Syntax:
%   subplot_rearrange(varargin)
%
%   Input:
%   varargin  = figure handle (optional)
%               number of subplots vertically
%               number of subplots horizontally
%
%   Output:
%   none
%
%   Example
%   subplot_rearrange(3,4)
%   subplot_rearrange(gcf,3,4)
%   subplot_rearrange(fh,3,4)
%
%   See also subplot

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
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
% Created: 22 Sep 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: subplot_rearrange.m 5261 2011-09-22 16:05:20Z hoonhout $
% $Date: 2011-09-23 00:05:20 +0800 (Fri, 23 Sep 2011) $
% $Author: hoonhout $
% $Revision: 5261 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/plot_fun/subplot_rearrange.m $
% $Keywords: $

%% get handle

if isempty(varargin)
    error('Invalid input');
end

if ishandle(varargin{1})
    fh = varargin{1};
    varargin(1) = [];
else
    fh = gcf;
end

if isempty(fh)
    error('Invalid input');
end

%% get dimensions

if length(varargin)<2
    error('Invalid input');
end

y = varargin{1};
x = varargin{2};

%% rearrange axes

rf = figure('visible','off');

axs = flipud(findobj(fh,'Type','Axes'));

if length(axes)>x*y
    error('Insufficient number of subplots');
end

for i = 1:length(axs)
    figure(rf); set(rf,'visible','off');
    g = subplot(y,x,i);
    set(axs(i),'Position',get(g,'Position'));
end

delete(rf);
