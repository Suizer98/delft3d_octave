function varargout = errorshade(x,y,err,varargin)
%ERRORSHADE  Plot error area around a curve.
%
%   Plots a semi-transparent shade around a curve x,y with one-sided error
%   err. Optionally the lower and upper error can be input serarately.
%   The error is assumed in y-direction.
%   The shading is plotted as patch. Patch face color follows line color of
%   the data.
%
%   Syntax:
%   handles = errorshade(x,y,err)
%
%   Input: For <keyword,value> pairs call errorshade() without arguments.
%   varargin  =
%       ax: axes handle for plottiing. Default gca.
%       
%       Marker: plot marker, default: '.'
%       Color: plot color, default: 'k'
%
%   Output:
%   varargout =
%       h_patch: patch handle.
%       h_line: line handle.
%
%   Example
%   errorshade
%
%   See also: plot, patch, 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2019 KU Leuven
%       Bart Roest
%
%       bart.roest@kuleuven.be
%       l.w.m.roest@tudelft.nl
%
%       Spoorwegstraat 12
%       8200 Bruges
%       Belgium
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
% Created: 02 Oct 2019
% Created with Matlab version: 9.5.0.1178774 (R2018b) Update 5

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
OPT.ax=gca;
OPT.linestyle='-';
OPT.marker='.';
% OPT.Color='k';
OPT.err_up=nan;
OPT.err_down=nan;
% return defaults (aka introspection)
if nargin==0;
    varargout = {OPT};
    return
end
% overwrite defaults with user arguments
OPT = setproperty(OPT, varargin);
%% Prepare xy-data
x=x(:);
y=y(:);
err=err(:);

if any(~isnan(OPT.err_up)) && any(~isnan(OPT.err_down));
    err_up=abs(OPT.err_up);
    err_down=abs(OPT.err_down);
else
    err_up=err;
    err_down=err;
end

patch_x=[x;flipud(x)];
patch_y=[y+err_up;flipud(y-err_down)];


%% Plot
h_patch=patch(OPT.ax,'XData',patch_x,'YData',patch_y,...
    'EdgeColor','none','FaceColor','none','FaceAlpha',0.5);
hold on;
h_line=plot(OPT.ax,x,y,'LineStyle',OPT.linestyle,'Marker',OPT.marker);
h_patch.FaceColor=h_line.Color;

varargout={h_patch,h_line};
end
%EOF
