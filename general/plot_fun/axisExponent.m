function varargout = axisExponent(varargin)
%AXISEXPONENT  Sets the data exponent for an axis or colorbar.
%
%   Set the data exponent (power of 10) of the x, y, z-axis or colorbar to
%   a given number. This adjusts the TickLabels. This function works by
%   default on gca, but axes can be assigned by popertyname-propertyvalue
%   pairs.
%
%   Syntax:
%   axisExponent(axis,exponent);
%   axisExponent('ax',gca,'axis','x','exponent',exponent);
%
%   Input: For <keyword,value> pairs call axisExponent() without arguments.
%   varargin  =
%       ax: axes handle, must be scalar (default: gca).
%       axis: x, y, z-axis or colorbar of ax, string: 'x','y','z','c' (default: 'x').
%       exponent: power of 10 for the Ticklabels on axis, integer (default: 0).
%
%   Output:
%   varargout =
%       <none>
%
%   Example:
%   figure;
%   plot(rand(20,1),rand(20,1).*1000,'.k');
%   axisExponent('y',3);
%
%   See also: plot_fun

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2020 KU Leuven
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
% Created: 19 Jun 2020
% Created with Matlab version: 9.5.0.1265761 (R2018b) Update 6

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
OPT.ax=gca;
OPT.axis='x';
OPT.exponent=0;
% return defaults (aka introspection)
if nargin==0;
    varargout = {OPT};
    return
elseif nargin==2;
    OPT.axis=varargin{1};
    OPT.exponent=varargin{2};
else
    % overwrite defaults with user arguments
    OPT = setproperty(OPT, varargin);
end

%% code
OPT.axis=cellstr(OPT.axis(:));
if any(strcmpi(OPT.axis,'x'));
    set(get(OPT.ax,'XAxis'),'Exponent',OPT.exponent);
    % OPT.ax.XAxis.Exponent=OPT.exponent;
end
if any(strcmpi(OPT.axis,'y'));
    set(get(OPT.ax,'YAxis'),'Exponent',OPT.exponent);
    % OPT.ax.YAxis.Exponent=OPT.exponent;
end
if any(strcmpi(OPT.axis,'z'));
    set(get(OPT.ax,'ZAxis'),'Exponent',OPT.exponent);
    % OPT.ax.ZAxis.Exponent=OPT.exponent;
end
if any(strcmpi(OPT.axis,'c'));
    set(get(get(OPT.ax,'Colorbar'),'Ruler'),'Exponent',OPT.exponent);
    % OPT.ax.Colorbar.Ruler.Exponent=OPT.exponent;
end
end