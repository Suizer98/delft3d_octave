function [X Y Z alfa propertyVar] = XBeach_GridOrientation(xw, yw, Zbathy, varargin)
%XBEACH_GRIDORIENTATION  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = XBeach_GridOrientation(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   XBeach_GridOrientation
%
%   See also

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Dano Roelvink / Ap van Dongeren / C.(Kees) den Heijer
%
%       Kees.denHeijer@Deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% Created: 03 Feb 2009
% Created with Matlab version: 7.6.0.324 (R2008a)

% $Id: XBeach_GridOrientation.m 4592 2011-05-24 12:39:11Z roelvin $
% $Date: 2011-05-24 20:39:11 +0800 (Tue, 24 May 2011) $
% $Author: roelvin $
% $Revision: 4592 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/.old/xb_grid/XBeach_GridOrientation.m $

%% default properties
OPT = struct(...
    'manual',             false, ...
    'dx',                     2, ...
    'dy',                     2, ...
    'xori',                   0, ...
    'yori',                   0, ...
    'xend_y0', [max(xw(:)) 0], ...
    'x_yend',  [0 max(yw(:))]);

% apply custom properties
OPT = setproperty(OPT, varargin{:});

%% show data, for selection
if OPT.manual
    figure;
    ids = convhull(xw, yw);
    lh = line(xw(ids),yw(ids),Zbathy(ids));
    set(lh,'color','r')
    hold on
    if length(xw)<=10000
        scatter(xw, yw, 5, Zbathy, 'filled');
    else
        try
            rd_ids = randi(length(xw),10000,1);
            scatter(xw(rd_ids), yw(rd_ids), 5, Zbathy(rd_ids), 'filled');
        catch
            scatter(xw, yw, 5, Zbathy, 'filled');
        end
    end
    axis([min(xw)-.5*(max(xw)-min(xw)) ...
        max(xw)+.5*(max(xw)-min(xw)) ...
        min(yw)-.5*(max(yw)-min(yw)) ...
        max(yw)+.5*(max(yw)-min(yw)) ])
    axis equal;
    axis manual
    colorbar
    hold on
    
    % Loop, picking up the points.
    fprintf(1, '%s\n',...
    	'Click grid corner x=0,y=0 (corner at seaside)',...
    	'Then click point x=xn,y=0 (corresponding corner at landside)',...
    	'Finally click to select extent of y (arbitrary point at other alongshore side of the domain)')
    fprintf(1, '\n')
    
    [xi yi]     = select_oblique_rectangle
    
    OPT.xori    = xi(1);
    OPT.yori    = yi(1);
    OPT.xend_y0 = [xi(2) yi(2)];
    OPT.x_yend  = [xi(3) yi(3)];
end

alfa        = atan2(OPT.xend_y0(2) - OPT.yori, OPT.xend_y0(1) - OPT.xori);
Xbathy      =  cos(alfa) * (xw - OPT.xori) + sin(alfa) * (yw - OPT.yori);
Ybathy      = -sin(alfa) * (xw - OPT.xori) + cos(alfa) * (yw - OPT.yori);
xn          =  cos(alfa) * (OPT.xend_y0(1) - OPT.xori) + sin(alfa) * (OPT.xend_y0(2) - OPT.yori);
yn          = -sin(alfa) * (OPT.x_yend(1)  - OPT.xori) + cos(alfa) * (OPT.x_yend(2)  - OPT.yori);
xx          = (0:OPT.dx:xn)';
yy          =  0:OPT.dy:yn;
X           = repmat( xx, 1,          length(yy) );
Y           = repmat( yy, length(xx), 1          );

try
    Z       = griddata(Xbathy, Ybathy, Zbathy, X, Y);
catch
    Err     = lasterror;
    if strcmp(Err.identifier, 'MATLAB:qhullmx:UndefinedError')
        Z   = griddata(Xbathy,Ybathy,Zbathy,X,Y,'linear',{'QJ'});
    else
        rethrow(Err)
    end
end

propertyVar = {...
    'dx', OPT.dx,...
    'dy', OPT.dy,...
    'xori', OPT.xori,...
    'yori', OPT.yori,...
    'bathy', {Xbathy Ybathy Zbathy}};
