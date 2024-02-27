function [x_ds3,y_ds3]=northarrow(d,x0,y0,theta0,varargin)
%NORTHARROW Plots a 'North arrow' for a map on axes.
%
%   Puts an arrow indicating the North on axes, using patch. Works best on
%   cartesian grids (eg. RD).
%
%   Syntax:
%   [x_ds3,y_ds3]=northarrow(d,x0,y0,theta0,c)
%
%   Input: For <keyword,value> pairs call Untitled() without arguments.
%       d: diameter in axis coordinates
%       x0: x-coordinate centre
%       y0: y-coordinate centre
%       theta0: orientation of the arrow in current axis (0=up, 90=right);
%       varargin:
%           ax: axis to plot on
%           c: color of arrow (string or triplet)
%           fontsize (font size of N)
%       OR
%       'auto' (default values are used)
%
%
%   Output:
%       x_ds3= arrow x-coordinates
%       y_ds3= arrow y-coordinates
%
%   Example
%       figure;
%       x0=600;      
%       y0=400;
%       theta0 =-48;
%       d=100;
%       c='k';
%       northarrow(d,x0,y0,theta0,'c',c);
%       figure;
%       northarrow('auto');
%
%   See also: plot, patch, text

% Bart Roest 2017

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2017 TUDelft
%       Bart Roest
%
%       l.w.m.roest@tudelft.nl
%
%
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
% Created: 04 Jul 2017
% Created with Matlab version: 8.6.0.267246 (R2015b)

% $Id: northarrow.m 17123 2021-03-24 09:39:12Z l.w.m.roest.x $
% $Date: 2021-03-24 17:39:12 +0800 (Wed, 24 Mar 2021) $
% $Author: l.w.m.roest.x $
% $Revision: 17123 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/plot_fun/northarrow.m $
% $Keywords: $

%%
OPT.ax=gca;
OPT.c='k';
OPT.fontsize=14;
% return defaults (aka introspection)
if nargin==0;
    x_ds3 = {OPT};
    return
end
% overwrite defaults with user arguments
OPT = setproperty(OPT, varargin);
%% code
if nargin==1 %'auto' Automatically scale and place.
    xl=get(gca,'XLim');
    yl=get(gca,'YLim');
    d=min([abs(diff(xl)),abs(diff(yl))]).*0.1;
    x0=xl(2)-0.7*d;
    y0=yl(2)-0.8*d;
    theta0=48;
    
else
    % use inputparams.
end
    x_ds=[ 0  1 0 -1  0 0]*(d/5);
    y_ds=[-1 -2 3 -2 -1 3]*(d/5);

    x_ds2 = +(x_ds).*cosd(0-theta0) - (y_ds)*sind(0-theta0); 
    y_ds2 = +(x_ds) *sind(0-theta0) + (y_ds)*cosd(0-theta0);   

    x_ds3=x_ds2+x0;
    y_ds3=y_ds2+y0;

    patch(OPT.ax,'XData',x_ds3([1:3,5]),'YData',y_ds3([1:3,5]),'FaceColor','k','EdgeColor',OPT.c);
    patch(OPT.ax,'XData',x_ds3([3:6])  ,'YData',y_ds3([3:6])  ,'FaceColor','w','EdgeColor',OPT.c);

    %plot(x_ds3,y_ds3,c,'linewidth',2);
    t1=text(OPT.ax,x0,y0-0.5*d,'N');
    set(t1,'Fontsize',OPT.fontsize,'color',OPT.c);
end
%EOF