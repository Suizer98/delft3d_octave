function [Ropt aOpt RMSopt center] = circlefit(x,y,varargin)
%CIRCLEFIT  Fits a circle to a selection of points
%
%   Fits a circle to a selection of points in x-y-space by variation of the
%   direction and length of the radius with respect to a certain point of
%   interest. The combination of a direction and length of the radius with
%   the smallest root-mean-square error for the points included in the
%   calculation is chosen as best fit. The direction is chosen zero in the
%   positive direction of the y-axis.
%
%   Syntax:
%   [Ropt aOpt RMSopt center] = circlefit(x,y,varargin)
%
%   Input:
%   x           = x-coordinates of series of points in x-y-space
%   y           = y-coordinates of series of points in x-y-space
%   varargin    = key/value pairs of optional parameters
%                 point     = index number of point of interest (default:
%                             2)
%                 numPoints = number of points to be included in
%                             calculation of root-mean-square error
%                             (default: 3)
%                 amin      = minimum direction angle in degrees to be
%                             included in calculation (default: 0)
%                 amax      = maximum direction angle in degrees to be
%                             included in calculation (default: 360)
%                 da        = step size of direction angle in degrees in
%                             which the direction angle should be varied
%                             (default: 1)
%                 Rmin      = minimum radius to be included in calculation
%                             (default: 0)
%                 Rmax      = maximum radius to be included in calculation
%                             (default: 10)
%                 dR        = step size of radius in which the radius
%                             should be varied (default: 0.01)
%                 plot      = flag to plot the calculated circle,
%                             direction, radius and development of the
%                             error (default: false)
%
%   Output:
%   Ropt        = radius of fitted circle
%   aOpt        = direction of fitted circle
%   RMSopt      = root-mean-square error of fit
%   center      = coordinates of center of circle
%
%   Example
%   circlefit(x,y)
%
%   See also jarkus_deriveCurvature

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Bas Hoonhout
%
%       bas@hoonhout.com
%
%       Stevinweg 1
%       2628CN Delft
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 23 Nov 2009
% Created with Matlab version: 7.5.0.338 (R2007b)

% $Id: circlefit.m 2616 2010-05-26 09:06:00Z geer $
% $Date: 2010-05-26 17:06:00 +0800 (Wed, 26 May 2010) $
% $Author: geer $
% $Revision: 2616 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/poly_fun/circlefit.m $
% $Keywords: $

%% settings

OPT = struct( ...
    'point', 2, ...
    'numPoints', 3, ...
    'amin', 0, ...
    'amax', 360, ...
    'da', 1, ...
    'Rmin', 0, ...
    'Rmax', 10, ...
    'dR', 0.01, ...
    'plot', false ...
);

OPT = setproperty(OPT, varargin{:});

% tranlate degrees to radians
OPT.amin = OPT.amin/180*pi;
OPT.amax = OPT.amax/180*pi;
OPT.da = OPT.da/180*pi;

% make sure point of interest is not included
if mod(OPT.numPoints,2) == 1; OPT.numPoints = OPT.numPoints-1; end;

% make sure number of points is at least two
OPT.numPoints = max(2,OPT.numPoints);

% define circle segments
d = [0:0.1:2*pi];

% define output variables
Ropt = 0;
aOpt = 0;
RMSopt = 0;
center = [0 0];

% check given points
if length(x) ~= length(y) || length(x) < OPT.numPoints+1; return; end;

% remove NaN's
if isnan(x(OPT.point)) || isnan(y(OPT.point)); return; end;

isnanx = isnan(x);
OPT.point = OPT.point - sum(isnanx(1:OPT.point));
x = x(~isnanx); y = y(~isnanx);

isnany = isnan(y);
OPT.point = OPT.point - sum(isnany(1:OPT.point));
x = x(~isnany); y = y(~isnany);

%% determin radius

rms =  [];

% define point of interest
point = [x(OPT.point) y(OPT.point)];

% define points to be included in fitting
points = max(1,OPT.point-OPT.numPoints/2):min(length(x),OPT.point+OPT.numPoints/2);

% define ranges of angles and radii
a = OPT.amin:OPT.da:OPT.amax;
R = OPT.Rmin:OPT.dR:OPT.Rmax;

% define calculation matrices for points
pointsx = repmat(reshape(x(points),[1 1 length(points)]),[length(a) length(R) 1]);
pointsy = repmat(reshape(y(points),[1 1 length(points)]),[length(a) length(R) 1]);

% define calculation matrices for angles and radii
ai = repmat(a'*ones(1,length(R)),[1 1 length(points)]);
Rj = repmat(ones(length(a),1)*R,[1 1 length(points)]);

% define calculation matrices for circle centres
centerx = point(1) - Rj.*sin(ai);
centery = point(2) - Rj.*cos(ai);

% calculate root-mean-square error for each combination of angle and radius
rms = sqrt(mean((sqrt((pointsx - centerx).^2 + (pointsy - centery).^2) - Rj).^2,3));

% determine minimal root-mean-square error
RMSopt = min(min(rms));
RMSi = find(rms == RMSopt); if length(RMSi) > 1; RMSi = RMSi(1); end;
iOpt = mod(RMSi,size(rms,1)); if iOpt == 0; iOpt = size(rms,1); end;
jOpt = ceil(RMSi/size(rms,1));

% determine angle, radius and circle center for minimal root-mean-square error
aOpt = a(iOpt);
Ropt = R(jOpt);
center = point - Ropt*[sin(aOpt) cos(aOpt)];

%% plot

if OPT.plot
    
    % create figure with subplots
    figure;
    s1 = subplot(1,2,1); hold on; axis equal;
    s2 = subplot(1,2,2); hold on;

    % plot points, optimal circle and optimal radius
    plot(s1,x,y,'-b');
    plot(s1,[point(1) center(1)],[point(2) center(2)],'-g');
    plot(s1,center(1)+Ropt*sin(d),center(2)+Ropt*cos(d),'-r');
    title(s1,{'Circle fit' ['\alpha: ' num2str(aOpt/pi*180) '^o ; R: ' num2str(Ropt) ' ; RMS error: ' num2str(RMSopt)]});
    xlabel(s1,'x'); ylabel(s1,'y');

    % plot rms errors
    plot(s2,R,rms,'-b');
    title(s2,{'RMS error' ['Number of points: ' num2str(OPT.numPoints+1)]});
    xlabel(s2,'R'); ylabel(s2,'RMS error');
    
end