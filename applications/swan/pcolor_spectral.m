function tick = pcolor_spectral(frequency, directions, EnDens,varargin)
%pcolor_spectral plots radial wave 2D spectrum
%
%   pcolor_spectral(frequency, directions, EnDens, <keyword,value>)
%
%See also: wind_rose

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2015 TU Delft ; Van Oord
%       Gerben J de Boer <g.j.deboer@tudelft.nl> ; <gerben.deboer@vanoord.com>
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

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

OPT.ax    = gca;
OPT.debug = 0;
OPT.units = '?/Hz/deg';

OPT = setproperty(OPT,varargin);

%% make circle
[f,d]=meshgrid(frequency,degN2deguc(directions));
[x,y]=pol2cart(deg2rad((d)+180),f);

axes(OPT.ax)
if OPT.debug
    TMP = figure
    pcolorcorcen(frequency,directions,EnDens);
    set(gca,'ytick',[0:90:360])
    set(ax(1),'yticklabel',{'v N','< E','^ S','> W','v N'})
    set(ax(1),'xtick',tick.f)
    xlim([nanmin(frequency) nanmax(frequency)])
end

%% plot
axes(OPT.ax)
pcolorcorcen(x,y,EnDens);
axis equal;
axis tight;
noaxis(OPT.ax)

%% ticks anf f-axis
%tick.T =    [nanmin(1./frequency) 4 5 6 7 9 11 14 nanmax(1./frequency)];
tick.T = 1./sort([nanmin(frequency) .1 .15 .2 .25 .3 nanmax(frequency)]);
tick.f = 1./tick.T;
text(-tick.f,  0.*tick.f,num2str(tick.T','%0.3g s')     ,'rotation',90,'horizontal','cen')
text( tick.f, 0.*tick.f,num2str((1./tick.T)','%0.2g Hz'),'rotation',90,'horizontal','cen')

drad = [10:165];
for i =1:length(tick.f)
    hold on
    [xleg, yleg] = pol2cart(deg2rad(drad),repmat(tick.f(i),[1 length(drad)]));
    plot(xleg,yleg,'k--')
end

drad = [195:350];
for i =1:length(tick.f)
    hold on
    [xleg, yleg] = pol2cart(deg2rad(drad),repmat(tick.f(i),[1 length(drad)]));
    plot(xleg,yleg,'k--')
end