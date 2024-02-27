function hydrus1d_plot_observations(S, N, M, T, varargin)
%HYDRUS1D_PLOT_OBSERVATIONS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = hydrus1d_plot_observations(varargin)
%
%   Input: For <keyword,value> pairs call hydrus1d_plot_observations() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   hydrus1d_plot_observations
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       Rotterdamseweg 185
%       2629 HD Delft
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
% Created: 27 Feb 2014
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: hydrus1d_plot_observations.m 10314 2014-03-03 08:02:57Z hoonhout $
% $Date: 2014-03-03 16:02:57 +0800 (Mon, 03 Mar 2014) $
% $Author: hoonhout $
% $Revision: 10314 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/aeolian/HYDRUS1D/hydrus1d_plot_observations.m $
% $Keywords: $

%% settings

OPT = struct( ...
    'z',0);
OPT = setproperty(OPT, varargin);

t = ([0:length(M.precipitation_amount_sum)-1] - 1) / 24;

%% plot

fig = figure;
set(fig,'windowbuttonmotionfcn',{@draw_line, N});

F = double([1;1]*(2*(T(1:length(t))>OPT.z)-1));
F(F<0) = nan;

s1 = subplot(4,4,[1:3 5:7]); hold on;
pcolor(t, [0 .5], F);
for i = size(S.data.theta,2):-1:1
    f = i / size(S.data.theta,2);
    plot(S.time, S.data.theta(:,i), '-', 'Color', [1,f,f]);
end
plot([0 0], get(s1,'YLim'), '-g', 'Tag', 'indicator');
ylabel('Moisture contents [-]');
shading flat;
box on;

s2a = subplot(4,4,9:11); hold on;
bar(t, M.precipitation_amount_sum);
pos = get(s2a,'Position');
ylabel('Precipitation [mm]');

s2b = axes('Position',pos); hold on;
plot(t, M.global_radiation, '-', 'Color', [1 .8 0]);
plot([0 0], get(s2b,'YLim'), '-g', 'Tag', 'indicator');
ylabel('Global radiation [MJ/m2/day]');
set(s2b,'Color','none','YAxisLocation','right');
box on;

s3 = subplot(4,4,13:15); hold on;
plot(t, T(1:length(t)), '-b');
plot(t([1 end]), OPT.z*[1 1], '-r');
plot([0 0], get(s3,'YLim'), '-g', 'Tag', 'indicator');
xlabel('Time [days]');
ylabel('Tidal elevation [cm]');
box on;

s4 = subplot(4,4,[4 8 12 16]);
plot(N.data.Depth(1,:), 0*N.data.Moisture(1,:));
set(s4,'XLim',minmax(N.data.Depth(1,:)),'YLim',[0 .5],'XAxisLocation','top','XDir','reverse','Tag','profile');
view(90,90);
xlabel('Depth [cm]');
ylabel('Moisture contents [-]');
box on;

linkaxes([s1 s2a s2b s3],'x');
set(s1,'XLim',[0,max(S.time)]);

%% private functions

function draw_line(obj, ~, N)
    axs = findobj(obj,'Type','Axes');
    
    for i = 1:length(axs)
        ind = findobj(axs(i),'Tag','indicator');
        if ~isempty(ind)
            xyz = get(axs(i), 'CurrentPoint');
            set(ind,'XData',xyz(1,1)*[1 1]);
        end
    end

    ax = findobj(obj,'Type','Axes','Tag','profile');
    ln = findobj(ax,'Type','line');
    [~,i] = closest(xyz(1,1), N.time);
    set(ln,'YData',N.data.Moisture(i,:));
    title(sprintf('t = %3.1f days', N.time(i)));
