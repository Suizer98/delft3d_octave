function [xb_st] = xb_compute_shiptrack(iship,varargin)
% XB_COMPUTE_SHIPTRACK  Computes XBeach ship track (t,x,y) based on ship-xyfile.
%
%   Computes ship track (t,x,y) based on ship-xyfile for simulation of
%   ship-induced waves in XBeach. Output (t,x,y) should be saved in an
%   ascii-file and specified in the XB ship file (keyword: shiptrack)
%
%   Syntax:
%   [t,x,y] = xb_compute_shiptrack('ship_xyfile','track.txt,'dt',10,'v',[.1
%   8 8],'tv',[0 180 600],'tstop',600)
%
%   Input:
%   varargin  =     ship_xyfile:    ship-x,y file (ascii) with x,y points of entire ship
%                                   track
%                   dt:             timestep in ship track t,x,y-file
%                   v:              velocity in time (block mode)
%                   tv:             time points corresponding with velocity
%                                   specified
%                   tstop:          simulation stop time
%                   plot:           make a plot of ship track (1) or not
%                                   (0, default)
%   Output:
%                   t : time vector [s]
%                   x : x(s) ship location
%                   y : y(s) ship location
%
%   Example:
%   [t,x,y] = xb_compute_shiptrack('ship_xyfile','track.txt,'dt',10,'v',[.1
%   8 8],'tv',[0 180 600],'tstop',600)
%   out = [t,x,y];
%   save ship_track.txt out -ascii
%
%  TODO: 
%  - add auto pilot option!
%  - multiple ships
%
%
%   Based on initial code by Dano Roelvink (UNESCO-IHE / Deltares)

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Deltares
%       rooijen
%
%       arnold.vanrooijen@deltares.nl
%
%       Rotterdamseweg 185, Delft, The Netherlands
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
% Created: 18 Feb 2014
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: xb_compute_shiptrack.m 10494 2014-04-07 07:04:59Z rooijen $
% $Date: 2014-04-07 15:04:59 +0800 (Mon, 07 Apr 2014) $
% $Author: rooijen $
% $Revision: 10494 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_modelsetup/xb_ship/xb_compute_shiptrack.m $
% $Keywords: $
%% INPUT
OPT.trackxyt      = sprintf('track%03d.txt', iship); % Ship track filename (t,x,y,z)
OPT.dt            = 10;                              % Timestep [s]
OPT.v             = [.1 8 8];    % Speed [m/s]
OPT.tv            = [0 180 600]; % time points for speed [s]
OPT.z             = [];     % height of ship for flying in
OPT.tstop         = 600;         % Simulation stop time [s]
OPT.plot          = 0;
OPT.trackxy       = '';% Ship track filenames (x,y) 
OPT.autopilot     = false;
OPT.domain        = [];
OPT.tfly          = [];
OPT               = setproperty(OPT,varargin{:});

%% Load ship track file
try
    xy = load(OPT.trackxy);
catch
    xy = landboundary('read',OPT.trackxy);
end

%% Compute track
t = [0:OPT.dt:OPT.tstop];
v = interp1(OPT.tv,OPT.v,t);
s = zeros(size(t));
if length(OPT.z)>1 % if flying option is turned on
    z = interp1(OPT.tv,OPT.z,t);
end

% Compute distance travelled
for i = 2:length(t);
    s(i) = s(i-1)+v(i-1)*OPT.dt;
end

% Compute x,y-locations
xtr = xy(:,1);
ytr = xy(:,2);
str = zeros(size(xtr));
for i = 2:length(xtr);
    str(i) = str(i-1)+sqrt((xtr(i)-xtr(i-1))^2+(ytr(i)-ytr(i-1))^2);
end
s = s(s<=max(str));
x = interp1(str,xtr,s);
y = interp1(str,ytr,s);

tstop = t(length(s));

%% Auto pilot: find point from which ship should be flying
if OPT.autopilot && length(OPT.z) == 1
    if isempty(OPT.domain)
        error('For auto pilot, please specify domain [x_{cornerpoints}; y_{cornerpoints}]')
    end
    inds = find(inpolygon(x,y,OPT.domain(1,:),OPT.domain(2,:)));
    
    t = t(inds);
    x = x(inds);
    y = y(inds);
    s = s(inds);
    
    % compute ship height
    z = zeros(1,length(t));
    % stay away from border
    z (s(end)-s < 500) = abs(OPT.z);
    ii = length(s);
    while z(ii) > 0
        ii = ii-1;
        if z(ii) == 0
            z(ii) = z(ii+1) - OPT.v(end)*OPT.dt/8;
        end
    end
    z = max(z,0);
    z(z>0) = -z(z>0);
elseif length(OPT.z) == 1 && OPT.tfly
        if isempty(OPT.domain)
        error('For auto pilot, please specify domain [x_{cornerpoints}; y_{cornerpoints}]')
    end
    inds = find(inpolygon(x,y,OPT.domain(1,:),OPT.domain(2,:)));
    
    t = t(inds);
    x = x(inds);
    y = y(inds);
    s = s(inds);
    
    z = zeros(1,length(t));
    z = interp1([t(t<= OPT.tfly) t(end)],[z(t<= OPT.tfly),OPT.z],t);
end

%% PLOT SHIP TRACK WITHIN DOMAIN
if OPT.plot 
    figure()
    plot(x,y,'k-o');hold on
    for i = 1:round(60/OPT.dt):length(t)
        text(x(i)+50,y(i),[num2str(t(i)) ' s']);
    end
    if ~isempty(OPT.domain)
        plot([OPT.domain(1,:),OPT.domain(1,1)],[OPT.domain(2,:),OPT.domain(2,1)],'b');
    end
    axis equal;xlabel('X');ylabel('Y');
    title('Ship track');
end
   

%% Save data in xbeach structure
if t(end)<OPT.tstop % make sure ship track is as long as simulation time
    t(end+1) = OPT.tstop;
    x(end+1) = x(end);
    y(end+1) = y(end);
    if ~isempty(OPT.z);
        z(end+1) = z(end);
    end
end
if isempty(OPT.z)
    out = [t;x;y]';
else
    out = [t;x;y;z]';
end

xb_st = xs_empty;
xb_st = xs_meta(xb_st, mfilename, 'ship', sprintf('track%03d.txt', iship));

% check if txy or txyz
if size(out,2) == 3
    xb_st = xs_set(xb_st, 'time', [], 'x', [], 'y', []);
    xb_st = xs_set(xb_st, '-units', 'time', {out(:,1) 's'}, 'x', {out(:,2) 'm'}, 'y', {out(:,3) 'm'});
elseif size(out,2) == 4
    xb_st = xs_set(xb_st, 'time', [], 'x', [], 'y', [], 'z', []);
    xb_st = xs_set(xb_st, '-units', 'time', {out(:,1) 's'}, 'x', {out(:,2) 'm'}, 'y', {out(:,3) 'm'}, 'z', {out(:,4) 'm'});
else
    error(['Error Reading Ship Track File [' filename ']'])
end


