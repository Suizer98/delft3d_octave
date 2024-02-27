function [curvatures radii relativeAngle distances x y cross_shore] = jarkus_curvature(transects, varargin)
%JARKUS_CURVATURE  Derives the coastal curvature from JARKUS data
%
%   Calculates the coastal curvature based on JARKUS data struct resulting
%   from the jarkus_transects function. Two calculation methods are
%   available. The first method assumes the transects to be perpendicular
%   to the shoreline and calculates the curvature by dividing the
%   difference in direction between two transects by the difference in
%   distance. The second method fits a circle in a certain number of points
%   on the shoreline around the transect of interest.
%
%   Syntax:
%   [curvatures radii relativeAngle distances] = jarkus_curvature(transects, varargin)
%
%   Input:
%   varargin    = key/value pairs of optional parameters
%                 method            = calculation method to be used
%                                     ('angle' for angle bases, 'circle'
%                                     for circle based, default: 'angle')
%                 z                 = altitude of shoreline (default: 0)
%                 numPoints         = number of shoreline points to be
%                                     included in calculation method
%                                     'circle' (default: 10)
%                 Rmin              = minimum radius to be included in
%                                     calculation method 'circle' (default:
%                                     1000)
%                 Rmax              = maximum radius to be included in
%                                     calculation method 'circle' (default:
%                                     20000)
%                 dR                = step size in which the radius should
%                                     be varied in calculation method
%                                     'circle' (default: 100)
%                 angleThreshold    = maximum angle in degrees between two 
%                                     transects, larger angles are
%                                     considered gaps (default: 25)
%                 distanceThreshold = maximum distance between two
%                                     transects, larger distances are
%                                     considered gaps (default: 400)
%                 maxCurvature      = upper limit of curvature plot
%                                     (default: 50)
%                 plot              = flag to enable plotting of the
%                                     derived angles, distances and
%                                     curvatures (default: false)
%                 plotMap           = flag to enable plotting of a coastal
%                                     map with transects, shoreline and
%                                     possibly curvatures (default: false)
%                 verbose           = flag to enable progress bar (default:
%                                     false)
%                 christmas         = flag to enable all visual effects
%                                     (default: false)
%
%   Output:
%   curvatures      = array of curvatures in degrees per kilometer
%   radii           = array of curvatures in curvature radii in meter
%   relativeAngle   = array with angles between transects
%   distances       = array with distances between transects at shoreline
%
%   Example
%   jarkus_curvature(transects, 'christmas', true)
%
%   See also circlefit

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       Rotterdamseweg 185
%       2629HD Delft
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

% $Id: jarkus_curvature.m 8811 2013-06-14 07:19:54Z heijer $
% $Date: 2013-06-14 15:19:54 +0800 (Fri, 14 Jun 2013) $
% $Author: heijer $
% $Revision: 8811 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/jarkus/jarkus_curvature.m $
% $Keywords: $

%% settings

OPT = struct( ...
    'method', 'angle', ...
    'z', 0, ...
    'numPoints', 10, ...
    'Rmin', 1000, ...
    'Rmax', 20000, ...
    'dR', 100, ...
    'angleThreshold', 25, ...
    'distanceThreshold', 400, ...
    'maxCurvature', 50, ...
    'plot', false, ...
    'plotMap', false, ...
    'verbose', false, ...
    'christmas', false ...
);

OPT = setproperty(OPT, varargin{:});

% show all
if OPT.christmas
    OPT.plot = true;
    OPT.plotMap = true;
    OPT.verbose = true;
end

if OPT.verbose; wb = waitbar(0, 'Initializing'); end;

%% check

if ~jarkus_check(transects, 'id', 'time', 'x', 'y', 'cross_shore', 'altitude')
    error('Invalid jarkus transect structure');
end

%% read transects

x = NaN(size(transects.id));
y = NaN(size(transects.id));
cross_shore = NaN(size(transects.id));
a = NaN(size(transects.id));

if length(transects.time) > 1
    disp('Multiple timestamps given, using first one found');
end

t = 1;

if OPT.verbose; waitbar(0, wb, 'Determining shoreline'); end;

% loop through al transects to determine cross-shore position of shoreline
% for each transect
for i = 1:length(transects.id)
    
    notnan = squeeze(~isnan(transects.altitude(t,i,:)));
    
    % check whether transect is valid
    if any(notnan)
        
        % find crossing of coastal profile with a given reference level
        % assuming this to be the shoreline
        crossing = max(findCrossings( ...
            transects.cross_shore(notnan), ...
            squeeze(transects.altitude(t,i,notnan))', ...
            [ min(transects.cross_shore(notnan)) ...
            max(transects.cross_shore(notnan)) ], ...
            [OPT.z OPT.z] ...
        ));
        
        % check whether a crossing has been found
        if isempty(crossing)
            crossing = NaN;
        else
            
            % translate cross-shore coordinate to global x-corodinate
            x(i) = interp1(transects.cross_shore(notnan), ...
                transects.x(i,notnan), crossing);
            
            % translate cross-shore coordinate to global y-coordinate
            y(i) = interp1(transects.cross_shore(notnan), ...
                transects.y(i,notnan), crossing);
            
            cross_shore(i) = crossing;
            
            % calculate direction angle of transect with respect to north
            a(i) = xy2degN(transects.x(i,end), transects.y(i,end), ...
                transects.x(i,1), transects.y(i,1));
        end
    end
    
    if OPT.verbose; waitbar(i/length(transects.id), wb); end;
end

%% calculate curvatures

% calculate angles and distances between transects
relativeAngle = diff(a);
distances = sqrt(diff(x).^2 + diff(y).^2);

% skip gaps larger than thresholds
iisGap = abs(relativeAngle) > OPT.angleThreshold | abs(distances) > OPT.distanceThreshold;
iisNaN = isnan(distances) | isnan(relativeAngle);

relativeAngle(iisGap) = 0;
relativeAngle(iisNaN) = 0;
distances(iisGap) = mean(abs(distances(~iisGap & ~iisNaN)));
distances(iisNaN) = mean(abs(distances(~iisGap & ~iisNaN)));

err = [];
circles = [];

if OPT.verbose; waitbar(0, wb, 'Calculating curvatures'); end;

% select calculation method
switch OPT.method
    case 'angle'
        % calculate curvatures directly from distances and angles between
        % transects assuming that all transects are perpendicular to the
        % shoreline
        curvatures = relativeAngle ./ abs(distances) .* 1000;
        radii = 1000 * 180 ./ pi ./ curvatures;
    case 'circle'
        d = [0:0.1:2*pi];
        radii = [];
        curvatures = [];
        
        % loop through transects and calculate curvatures by fitting a
        % circle to a certain number of shoreline points surrounding the
        % observed transect
        for i = 1:length(transects.id)
            
            % fit circle
            [R a rms center] = circlefit(x,y,'point',i,'numPoints',OPT.numPoints,'Rmin',OPT.Rmin,'Rmax',OPT.Rmax,'dR',OPT.dR);
            
            radii(i) = R;
            curvatures(i) = 180/pi/R*1000;
            err(i) = 180/pi/(R-rms)*1000-curvatures(i);
            circles(i,:,:) = [center(1)+R*sin(d) ; center(2)+R*cos(d)]';
            
            if OPT.verbose; waitbar(i/length(transects.id), wb); end;
        end
        
        err(isinf(err)|isnan(err)) = 0;
        curvatures(isinf(curvatures)|isnan(curvatures)) = 0;
    otherwise
        if OPT.verbose; close(wb); end;
        error(['Invalid method supplied (' OPT.method ')']);
end

if OPT.verbose; waitbar(1, wb); end;

%% plot stuff

if OPT.verbose; close(wb); end;

% plot angles, distances and curvatures, if requested
if OPT.plot
    
    % create subplots
    f1 = figure;
    s1=subplot(3,1,1); hold on;
    s2=subplot(3,1,2); hold on;
    s3=subplot(3,1,3); hold on;

    % plot angles, distances and curvatures with their mean values
    plot(s1,abs(relativeAngle),'-b'); plot(s1,[0 length(curvatures)],mean(abs(relativeAngle))*ones(1,2),'-r');
    plot(s2,abs(distances),'-b'); plot(s2,[0 length(curvatures)],mean(abs(distances))*ones(1,2),'-r');
    plot(s3,abs(curvatures),'-b'); plot(s3,[0 length(curvatures)],mean(abs(curvatures))*ones(1,2),'-r');
    if ~isempty(err); plot(s3,abs(curvatures)+err,':b'); plot(s3,abs(curvatures)-err,':b'); end;

    % set plot settings
    set(s1,'YLim',[0 min(OPT.angleThreshold,max(relativeAngle))]); title(s1,'relative angle'); xlabel(s1,'jarkus nr [-]'); ylabel(s1,'angle [^o]');
    set(s2,'YLim',[0 min(OPT.distanceThreshold,max(distances))]); title(s2,'relative distance'); xlabel(s2,'jarkus nr [-]'); ylabel(s2,'distance [m]');
    set(s3,'YLim',[0 min(180/pi/OPT.Rmin*1000,max(curvatures))]); title(s3,['curvature (error: ' num2str(mean(err)) ')']); xlabel(s3,'jarkus nr [-]'); ylabel(s3,'curvature [^o/km]');

    % plot maximum curvature known in current regulations
    plot(s3,[0 length(curvatures)],24*ones(1,2),'-g');
    
end

% plot coastal map with transects, shoreline and possibly fitted circles,
% if requested
if OPT.plotMap
    
    f2 = figure;
    
    % plot circles
    if ~isempty(circles); plot(circles(:,:,1)', circles(:,:,2)', '-g'); hold on; end;
    
    % plot transects
    plot(transects.x', transects.y', '-k'); hold on;
    
    % plot shoreline
    scatter(x,y,'or','MarkerFaceColor','r'); hold on;
    
    % set plot settings
    set(gca, 'XLim', [min(min(transects.x)) max(max(transects.x))], 'YLim', [min(min(transects.y)) max(max(transects.y))]);
    
    grid on;
    axis equal;
    
end