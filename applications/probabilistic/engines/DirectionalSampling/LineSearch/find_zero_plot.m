function find_zero_plot(OPT,b0,b,z,bs,zs,bn,zn,p)
%FIND_ZERO_PLOT  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = find_zero_plot(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   find_zero_plot
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       Rotterdamseweg 185
%       2629HD Delft
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
% Created: 11 Oct 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id: find_zero_plot.m 8605 2013-05-10 10:35:08Z hoonhout $
% $Date: 2013-05-10 18:35:08 +0800 (Fri, 10 May 2013) $
% $Author: hoonhout $
% $Revision: 8605 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/engines/DirectionalSampling/LineSearch/find_zero_plot.m $
% $Keywords: $

%% plot progress

brange = max(abs([b0 b bn]))+1;
zrange = 5; %max(abs([z zn]))+1;

fh = findobj('Tag','LSprogress');

% initialize plot
if isempty(fh)
    fh = figure('Tag','LSprogress'); hold on;
end

ax  = findobj(fh,'Type','axes','Tag','');

% original data
ph = findobj(ax,'Tag','LSpath1');
if isempty(ph)
    ph = plot(ax,b,z,'xk');
    set(ph,'Tag','LSpath1','DisplayName','initial');
else
    set(ph,'XData',b,'YData',z);
end

% added data
ph = findobj(ax,'Tag','LSpath2');
if isempty(ph)
    ph = plot(ax,bn,zn,'xr');
    set(ph,'Tag','LSpath2','DisplayName',sprintf('added (%d)',length(zn)));
else
    set(ph,'XData',bn,'YData',zn,'DisplayName',sprintf('added (%d)',length(zn)));
end

% selected data
ph = findobj(ax,'Tag','LSpath3');
if isempty(ph)
    ph = plot(ax,bs,zs,'og');
    set(ph,'Tag','LSpath3','DisplayName','selected');
else
    set(ph,'XData',bs,'YData',zs);
end

% poly fit
if ~isempty(p)
    grb = linspace(-brange,brange,100);
    grz = polyval(p, grb);

    ph = findobj(ax,'Tag','LSpoly');
    if isempty(ph)
        ph = plot(ax, grb, grz, '-b','DisplayName','fit');
        set(ph,'Tag','LSpoly');
    else
        set(ph,'XData',grb,'YData',grz);
    end
end

% zero location
ph = findobj(ax,'Tag','LSzero');
if isempty(ph)
    ph = plot(ax,b0,0,'or','MarkerFaceColor','r');
    set(ph,'Tag','LSzero','DisplayName','root');
else
    set(ph,'XData',b0,'YData',0);
end

% layout
grid(ax,'on');
xlabel(ax,'\beta');
ylabel(ax,'z');

title(ax,func2str(OPT.zFunction));

legend(ax,'-DynamicLegend','Location','NorthWest');
legend(ax,'show');

set(ax,'XLim',brange*[-1 1],'YLim',zrange*[-1 1]);

drawnow;