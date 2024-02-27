function [x y z] = xb_grid_finalise(x, y, z, varargin)
%XB_GRID_FINALISE  Performs several finalisation actions on an XBeach grid
%
%   Performs several finalisation actions on an XBeach grid, like extending
%   and flattening boundaries to prevent numerical instabilities in the
%   calculation.
%
%   Syntax:
%   [x y z] = xb_grid_finalise(x, y, z, varargin)
%
%   Input:
%   x           = x-coordinates of grid to be finalised
%   y           = y-coordinates of grid to be finalised
%   z           = elevations of grid to be finalised
%   varargin    = actions:  cell array containing strings indicating the
%                           order and actions to be performed
%
%                           currently available actions:
%                               lateral_extend:     copy lateral boundaries
%                               lateral_sandwalls:   close dry lateral
%                                                   boundaries with
%                                                   sandwalls
%                               seaward_flatten:    flatten offshore
%                                                   boundary
%                               landward_extend:    extend landward border
%                                                   with specified
%                                                   elevation 
%                               landward_polder:    add polder at -5 at
%                                                   landward side of model
%                               seaward_extend:     extend seaward border
%                                                   to a certain depth
%
%                 cells:    number of cells to use in each action
%
%   Output:
%   x           = x-coordinates of finalised grid
%   y           = y-coordinates of finalised grid
%   z           = elevations of finalised grid
%
%   Preferences:
%   grid_finalise   = Cell array with finalisation options (see options)
%
%               Preferences overwrite default options (not explicitly
%               defined options) and can be set and retrieved using the
%               xb_setpref and xb_getpref functions.
%
%   Example
%   [x y z] = xb_grid_finalise(x, y, z)
%   [x y z] = xb_grid_finalise(x, y, z, 'actions', {'landward_polder' 'lateral_sandwalls' 'lateral_extend' 'seaward_flatten'})
%
%   See also xb_generate_grid

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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 17 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_grid_finalise.m 16129 2019-12-13 22:34:47Z l.w.m.roest.x $
% $Date: 2019-12-14 06:34:47 +0800 (Sat, 14 Dec 2019) $
% $Author: l.w.m.roest.x $
% $Revision: 16129 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_modelsetup/xb_grid/xb_grid_finalise.m $
% $Keywords: $

%% read options

xb_verbose(1,'Performing finalizing actions');

OPT = struct( ...
    'actions', {{'lateral_extend' 'seaward_flatten' 'seaward_extend'}}, ...
    'n', 3, ...
    'z0', 5, ...
    'zmin', -20, ...
    'slope', 1/50 ...
);

if length(varargin) <= 2
    varargin = [varargin xb_getpref('grid_finalise')];
end

OPT = setproperty(OPT, varargin{:});

%% finalise grid

for i = 1:length(OPT.actions)
    action = OPT.actions{i};
    
    if exist(action, 'file') == 2 && nargin(action) == 4
        [x y z] = eval([action '(x, y, z, OPT);']);
    else
        warning('OET:xbeach:finalise', ['Ignoring non-existing grid finalisation option [' action ']']);
    end
end

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [x y z] = lateral_extend(x, y, z, OPT)
    if min(size(z)) > 3
        n = OPT.n;
        
        dy1 = y(2,1)-y(1,1);
        dy2 = y(end,1)-y(end-1,1);

        x = [ones(n,1)*x(1,:) ; x ; ones(n,1)*x(end,:)];
        y = [(y(1,1)-[n*dy1:-dy1:dy1])'*ones(1,size(y,2)) ; y ; (y(end,1)+[dy2:dy2:n*dy2])'*ones(1,size(y,2))];
        z = [ones(n,1)*z(1,:) ; z ; ones(n,1)*z(end,:)];
        
        xb_verbose(2,'Extend in lateral direction');
        xb_verbose(3,'Cells',n);
    end
    
function [x y z] = lateral_extend_curvi(x, y, z, OPT)
    
    g           = xb_stagger(x, y);
    
    n           = OPT.n;
    nx          = size(x,1);
    
    L1          = sqrt(diff(x([1 end],1)).^2+diff(y([1 end],1)).^2);
    L2          = sqrt(diff(x([1 end],end)).^2+diff(y([1 end],end)).^2);
        
    % 1: dalfav bepalen
    phi1a       = atan2((y(1,1)-y(end,1)),(x(1,1)-x(end,1)));
    phi1b       = atan2((y(1,2)-y(end,2)),(x(1,2)-x(end,2)));
    phi2a       = atan2((y(1,end)-y(end,end)),(x(1,end)-x(end,end)));
    phi2b       = atan2((y(1,end-1)-y(end,end-1)),(x(1,end-1)-x(end,end-1)));
    dphi1       = phi1a-phi1b;
    dphi2       = phi2a-phi2b;
    
    % 2: orientatie nieuwe cross-shore gridlijnen bepalen
    dphi1_ext   = dphi1 * linspace(1-1/n, 0, n+1);
    dphi2_ext   = dphi2 * linspace(1-1/n, 0, n+1);
    
    phi1_ext    = repmat(phi1a, 1, n+1) + fliplr(cumsum(dphi1_ext, 2));
    phi2_ext    = repmat(phi2a, 1, n+1) + cumsum(dphi2_ext, 2);
    
    phi1_ext    = [repmat(phi1_ext(1),1,n-1) phi1_ext];
    phi2_ext    = [phi2_ext repmat(phi2_ext(end),1,n-1)];
    
    % 3: orientatie nieuwe longshore gridlijnen bepalen
    gam1_ext    = mean([[phi1_ext(2:end) phi1a];phi1_ext(1:end)])+.5*pi;
    gam2_ext    = mean([phi2_ext(1:end);[phi2a phi2_ext(1:end-1)]])+.5*pi;
    
    % 4: afstand nieuwe grid lijnen bepalen
    dn1m        = mean(g.dnz([1 end],1));
    dn2m        = mean(g.dnz([1 end],end));
    
    dn1         = dn1m + (g.dnz(1,1)-dn1m) * linspace(1-1/n, 0, n+1);
    dn2         = dn2m + (g.dnz(1,end)-dn2m) * linspace(1-1/n, 0, n+1);
    
    dn1         = [repmat(dn1(end),1,n-1) fliplr(dn1)];
    dn2         = [dn2 repmat(dn2(end),1,n-1)];
    
    % 5: gridlijnkromming correctie bepalen
    dy1         = (y(:,1)-y(1,1));
    dx1         = (x(:,1)-x(1,1));
    dy2         = (y(:,end)-y(1,end));
    dx2         = (x(:,end)-x(1,end));
    
    A1          = sqrt(dx1.^2+dy1.^2);
    A2          = sqrt(dx2.^2+dy2.^2);
    
    alpha1      = phi1a - atan2(dy1,dx1);
    alpha2      = phi2a - atan2(dy2,dx2);
    
    alpha1(isnan(alpha1)) = 0;
    alpha2(isnan(alpha2)) = 0;
    
    corr1       = fliplr((A1.*sin(alpha1))*[linspace(1-1/n, 0, n+1) zeros(1,n-1)]);
    corr2       = (A2.*sin(alpha2))*[linspace(1-1/n, 0, n+1) zeros(1,n-1)];
    
    % 6: build grid extends
    x1a = x(1,1)+fliplr(cumsum(fliplr(dn1.*cos(gam1_ext))));
    y1a = y(1,1)+fliplr(cumsum(fliplr(dn1.*sin(gam1_ext))));
    x1b = x1a-L1*cos(phi1_ext);
    y1b = y1a-L1*sin(phi1_ext);
    
    x2a = x(1,end)-cumsum(dn2.*cos(gam2_ext));
    y2a = y(1,end)-cumsum(dn2.*sin(gam2_ext));
    x2b = x2a-L2*cos(phi2_ext);
    y2b = y2a-L2*sin(phi2_ext);
    
    x1_ext = repmat(x1a,nx,1)+A1.*cos(alpha1)*cos(phi1_ext);
    y1_ext = repmat(y1a,nx,1)+A1.*cos(alpha1)*sin(phi1_ext);
    x2_ext = repmat(x2a,nx,1)+A2.*cos(alpha2)*cos(phi2_ext);
    y2_ext = repmat(y2a,nx,1)+A2.*cos(alpha2)*sin(phi2_ext);
    
    x1_ext = x1_ext+corr1.*repmat(cos(phi1_ext-.5*pi),nx,1);
    y1_ext = y1_ext+corr1.*repmat(sin(phi1_ext-.5*pi),nx,1);
    x2_ext = x2_ext+corr2.*repmat(cos(phi2_ext-.5*pi),nx,1);
    y2_ext = y2_ext+corr2.*repmat(sin(phi2_ext-.5*pi),nx,1);
    
    z1_ext = repmat(z(:,1),1,size(x1_ext,2));
    z2_ext = repmat(z(:,end),1,size(x2_ext,2));
    
    % 7: build grids
    
    x = [x1_ext x x2_ext];
    y = [y1_ext y y2_ext];
    z = [z1_ext z z2_ext];
    
    xb_verbose(2,'Extend in lateral direction (curvilinear)');
    xb_verbose(3,'Cells',n);
    
%     figure; pcolor(x,y,z); hold on; axis image;
%     plot([x2a;x2b],[y2a;y2b])
%     plot([x1a;x1b],[y1a;y1b])
%     plot(x2_ext,y2_ext,'o')
%     plot(x1_ext,y1_ext,'o')

function [x y z] = lateral_sandwalls(x, y, z, OPT)
    if min(size(z)) > 3
        n = OPT.n;
        z0 = OPT.z0;
        
        z1 = 0; z2 = 0;
        for i = 1:size(z,2)
            if z(1,i) > z0 || z1 > 0
                z1 = max(z1,z(1,i));
                z(1:n,i) = interp1(y([1 n+1],i),[z1 z(n+1,i)],y(1:n,i));
            end
            if z(end,i) > z0 || z2 > 0
                z2 = max(z2,z(end,i));
                z(end-n+1:end,i) = interp1(y([end end-n],i),[z2 z(end-n,i)],y(end-n+1:end,i));
            end
        end
        
        xb_verbose(2,'Add sand walls to lateral boundaries');
        xb_verbose(3,'Cells',n);
        xb_verbose(3,'Height',z0);
    end

function [x y z] = seaward_flatten(x, y, z, OPT)
    n = OPT.n;
    
    z0 = min(z(:,1));
    
    z(:,1) = z0;
    for i = 1:size(z,1)
        z(i,2:n) = interp1(x(i,[1 n+1]),[z0 z(i,n+1)],x(i,2:n));
    end
    
    xb_verbose(2,'Flatten offshore boundaries');
    xb_verbose(3,'Cells',n);
    xb_verbose(3,'Level',z0);

function [x y z] = landward_extend(x, y, z, OPT)
    n = OPT.n;
    dx = x(1,end)-x(1,end-1);
    
    zn = [z ones(size(y,1),n)*OPT.z0];
    xn = [x x(1,end)+repmat([1:1:n],size(y,1),1)*dx];
    yn = [y repmat(y(:,1),1,n)];
    
    x = xn;
    y = yn;
    z = zn;
    
    xb_verbose(2,'Extend in landward direction until given level');
    xb_verbose(3,'Cells',n);
    xb_verbose(3,'Level',OPT.z0);
    
function [x y z] = landward_polder(x, y, z, OPT)
    n = OPT.n;
    z0 = -OPT.z0;
    
    for i = 1:size(z,1)
        z(i,end-n:end) = interp1(x(i,[end-n end]),[z0 z(i,end)],x(i,end-n:end));
        z(i,end-2*n-1:end-n-1) = interp1(x(i,[end-2*n-1 end-n-1]),[z(i,end-2*n-1) z0],x(i,end-2*n-1:end-n-1));
    end
    
    xb_verbose(2,'Add polder to landward boundary');
    xb_verbose(3,'Cells',n);
    xb_verbose(3,'Level',OPT.z0);
    
function [xn yn zn] = seaward_extend(x, y, z, OPT)
    zmin = min(min(z(:,1)),OPT.zmin);

    z0 = max(z(:,1));
    dx = x(1,2)-x(1,1);
    dn = ceil(max(z0-zmin,0)/(OPT.slope*dx));

    zt = nan(size(x,1), size(x,2)-dn+OPT.n);
    zt(:,1:OPT.n)     = zmin;
    zt(:,OPT.n+1:end) = z(:,dn+1:end); 
    
    [xt yt] = meshgrid([x(1,1)-[OPT.n:-1:1]*dx x(1,dn+1:end)] ,y(:,1));
    [xn yn] = meshgrid([xt(1,1:OPT.n) x(1,:)]                 ,y(:,1));

    zn = interp2(xt,yt,zt,xn,yn);
    
    xb_verbose(2,'Extend in seaward direction until given level');
    xb_verbose(3,'Cells',OPT.n);
    xb_verbose(3,'Level',zmin);