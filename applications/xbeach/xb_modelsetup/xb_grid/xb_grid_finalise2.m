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
%                               lateral_seawalls:   close dry lateral
%                                                   boundaries with
%                                                   sandwalls
%                               seaward_flatten:    flatten offshore
%                                                   boundary
%                               landward_extend:    extend lanward border
%                                                   with specified
%                                                   elevation 
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

% $Id: xb_grid_finalise2.m 8605 2013-05-10 10:35:08Z hoonhout $
% $Date: 2013-05-10 18:35:08 +0800 (Fri, 10 May 2013) $
% $Author: hoonhout $
% $Revision: 8605 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_modelsetup/xb_grid/xb_grid_finalise2.m $
% $Keywords: $

%% read options

OPT = struct( ...
    'actions', {{'lateral_extend' 'seaward_flatten'}}, ...
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
    end
    
function [x y z] = lateral_extend_curvi(x, y, z, OPT)
    n           = OPT.n;
    r           = .15;
    
    % TODO
    % - use separate n value for curvi correction DONE
    % - determine n value for curvi corr. based on cross-shore curvature DONE, but not perfect
    % - support individual orientation of grid cells (gradually decrease divergence/convergence of grids and grid cells) DONE, but not perfect
    % - add transition area (see warning). consider gamma part to be extended to each grid line
    
    % EXPLANATION
    % 1 and 2 refer to right and left lateral boundary respectively
    % a and b refer to offshore and nearshore boundary respectively
    % _ext refers to the extension grids
    % phi refers to the orientation of the cross-shore grid lines
    % gam refers to the orientation of the longshore grid lines
    % alpha refers to other angles
    % dx, dy, dn refers to distances in world coordinates (x,y) or longshore grid coordinates (n)
    % n refers to a number of longshore grid cells
    
    % WARNING
    % only use with mildly curved grids! curvatures are immediately
    % corrected, without transitional area. a negative turning rate may
    % become a positive one immediately. grid cell sizes are based on 
    % averages, which means that large grid cells become small relatively
    % fast and small grid cells become large relatively fast in order to
    % obtain equally sized grid cells in only a few steps.

    g           = xb_stagger(x, y);
    nx          = size(x,1);
    
    % determine the orientation of the last two cross-shore grid lines and
    % use the difference as rate of curvature
    phi1a       = atan2((y(1,1)-y(end,1)),(x(1,1)-x(end,1)));
    phi1b       = atan2((y(1,2)-y(end,2)),(x(1,2)-x(end,2)));
    phi2a       = atan2((y(1,end)-y(end,end)),(x(1,end)-x(end,end)));
    phi2b       = atan2((y(1,end-1)-y(end,end-1)),(x(1,end-1)-x(end,end-1)));
    dphi1       = phi1a-phi1b;
    dphi2       = phi2a-phi2b;
    
    % determine correction for curved cross-shore grid lines with respect
    % to a arbitrary straight cross-shore grid line
    dn1m        = mean(g.dnz(1:end,1));
    dn2m        = mean(g.dnz(1:end,end));
    
    dy1         = (y(:,1)-y(1,1));
    dx1         = (x(:,1)-x(1,1));
    dy2         = (y(:,end)-y(1,end));
    dx2         = (x(:,end)-x(1,end));
    
    A1          = sqrt(dx1.^2+dy1.^2);
    A2          = sqrt(dx2.^2+dy2.^2);
    
    L1          = A1(end);
    L2          = A2(end);
    
    alpha1      = phi1a - atan2(dy1,dx1);
    alpha2      = phi2a - atan2(dy2,dx2);
    
    alpha1(isnan(alpha1)) = 0;
    alpha2(isnan(alpha2)) = 0;
    
    corr1       = A1.*sin(alpha1);
    corr2       = A2.*sin(alpha2);
    
    % determine number of steps necessary to phase out all curvatures in
    % the grid
    mn1         = min(g.dnz(:,1)+abs(corr1));
    mx1         = max(g.dnz(:,1)+abs(corr1));
    mn2         = min(g.dnz(:,end)+abs(corr2));
    mx2         = max(g.dnz(:,end)+abs(corr2));
    
    n1a         = log10(dn1m/mn1)/log10(1+r);
    n1b         = log10(dn1m/mx1)/log10(1-r);
    n1          = ceil(max(n1a,n1b));
    
    n2a         = log10(dn2m/mn2)/log10(1+r);
    n2b         = log10(dn2m/mx2)/log10(1-r);
    n2          = ceil(max(n2a,n2b));
    
    % create a correction matrix for the curvatures in the cross-shore grid
    % lines
    corr1       = fliplr(corr1*[linspace(1-1/(n1+1), 0, n1+1) zeros(1,n-1)]);
    corr2       = corr2*[linspace(1-1/(n2+1), 0, n2+1) zeros(1,n-1)];
    
    % determine orientation of cross-shore grid lines of grid extension and
    % determine the orientation of the cross-shore grid lines in the
    % extension grids necessary to phase out the total grid curvature
    dphi1_ext   = dphi1 * linspace(1-1/(n1+1), 0, n1+1);
    dphi2_ext   = dphi2 * linspace(1-1/(n2+1), 0, n2+1);
    
    phi1_ext    = repmat(phi1a, 1, n1+1) + fliplr(cumsum(dphi1_ext, 2));
    phi2_ext    = repmat(phi2a, 1, n2+1) + cumsum(dphi2_ext, 2);
    
    gam1_ref    = mean([[phi1_ext(2:end) phi1a];phi1_ext(1:end)])+.5*pi;
    gam2_ref    = mean([phi2_ext(1:end);[phi2a phi2_ext(1:end-1)]])+.5*pi;
    
    phi1_ext    = [repmat(phi1_ext(1),1,n-1) phi1_ext];
    phi2_ext    = [phi2_ext repmat(phi2_ext(end),1,n-1)];
    
    % determine the distance of the cross-shore grid lines in the grid
    % extension based on the average cell size of the border cells
    dn1m        = mean(g.dnz([1 end],1));
    dn2m        = mean(g.dnz([1 end],end));
    
    dn1         = dn1m + (g.dnz(1,1)-dn1m) * linspace(1-1/(n1+1), 0, n1+1);
    dn2         = dn2m + (g.dnz(1,end)-dn2m) * linspace(1-1/(n2+1), 0, n2+1);
    
    dn1         = [repmat(dn1(end),1,n-1) fliplr(dn1)];
    dn2         = [dn2 repmat(dn2(end),1,n-1)];
    
    % determine the curvature of the seaward and landward boundaries and
    % compute the curvatures of the extension grids necessary to phase out
    % the curvature of these boudaries
    gam1a       = atan2((y(1,1)-y(1,2)),(x(1,1)-x(1,2)));
    gam1b       = atan2((y(end,1)-y(end,2)),(x(end,1)-x(end,2)));
    gam2a       = atan2((y(1,end-1)-y(1,end)),(x(1,end-1)-x(1,end)));
    gam2b       = atan2((y(end,end-1)-y(end,end)),(x(end,end-1)-x(end,end)));
    
    %gam1a_ext   = gam1a * linspace(1, 1/(n1+1), n1+1) - gam1_ref;
    
    gam1a_ext   = gam1a * ones(1,n1+1); linspace(1, 1/(n1+1), n1+1); - gam1_ref;
    gam1b_ext   = gam1b * ones(1,n1+1); linspace(1, 1/(n1+1), n1+1); - gam1_ref;
    gam2a_ext   = gam2a * ones(1,n2+1); linspace(1, 1/(n2+1), n2+1); - gam2_ref;
    gam2b_ext   = gam2b * ones(1,n2+1); linspace(1, 1/(n2+1), n2+1); - gam2_ref;
    
%     gam1a_ext   = gam1_ref + gam1a_ext;
%     gam1b_ext   = gam1_ref - gam1b_ext;
%     gam2a_ext   = gam2_ref + fliplr(gam2a_ext);
%     gam2b_ext   = gam2_ref - fliplr(gam2b_ext);
    
    gam1a_ext   = [repmat(gam1a_ext(1),1,n-1) gam1a_ext];
    gam1b_ext   = [repmat(gam1b_ext(1),1,n-1) gam1b_ext];
    gam2a_ext   = [gam2a_ext repmat(gam2a_ext(end),1,n-1)];
    gam2b_ext   = [gam2b_ext repmat(gam2b_ext(end),1,n-1)];
    
%   THIS CODE COMPUTES THE DEVURVATURE PER GRID CELL INSTEAD OF PER
%   CROSSSHORE GRID LINE. THIS IS NOT BUILD INTO THE GRID BUILD LINES
%   BELOW YET
%     gam1        = atan2((y(:,1)-y(:,2)),(x(:,1)-x(:,2)));
%     gam2        = atan2((y(:,end-1)-y(:,end)),(x(:,end-1)-x(:,end)));
%     
%     gam1t       = gam1(1) + .5*diff(gam1([1 end]));
%     gam2t       = gam2(1) + .5*diff(gam2([1 end]));
%     
%     dgam1       = gam1t-gam1;
%     dgam2       = gam2t-gam2;
%     
%     gam1_ext    = dgam1 * linspace(1, 1/(n1+1), n1+1);
%     gam2_ext    = dgam2 * linspace(1, 1/(n2+1), n2+1);
%     
%     gam1_ext    = repmat(gam1, 1, n1+1) + gam1_ext;
%     gam2_ext    = fliplr(repmat(gam2, 1, n2+1) + gam2_ext);
%     
%     gam1_ext    = [repmat(gam1_ext(:,1),1,n-1) gam1_ext];
%     gam2_ext    = [gam2_ext repmat(gam2_ext(:,end),1,n-1)];
    
    % build grid extensions
    x1a = x(1,1)+fliplr(cumsum(fliplr(dn1.*cos(gam1a_ext))));
    y1a = y(1,1)+fliplr(cumsum(fliplr(dn1.*sin(gam1a_ext))));
    x1b = x(end,1)+fliplr(cumsum(fliplr(dn1.*cos(gam1b_ext))));
    y1b = y(end,1)+fliplr(cumsum(fliplr(dn1.*sin(gam1b_ext))));
    
    x2a = x(1,end)-cumsum(dn2.*cos(gam2a_ext));
    y2a = y(1,end)-cumsum(dn2.*sin(gam2a_ext));
    x2b = x(end,end)-cumsum(dn2.*cos(gam2b_ext));
    y2b = y(end,end)-cumsum(dn2.*sin(gam2b_ext));
    
    Ln1 = sqrt((x1a-x1b).^2+(y1a-y1b).^2);
    Ln2 = sqrt((x2a-x2b).^2+(y2a-y2b).^2);
    
%     x1_ext = repmat(x1a,nx,1)+A1/L1.*cos(alpha1)*(cos(phi1_ext).*Ln1);
%     y1_ext = repmat(y1a,nx,1)+A1/L1.*cos(alpha1)*(sin(phi1_ext).*Ln1);
%     x2_ext = repmat(x2a,nx,1)+A2/L2.*cos(alpha2)*(cos(phi2_ext).*Ln2);
%     y2_ext = repmat(y2a,nx,1)+A2/L2.*cos(alpha2)*(sin(phi2_ext).*Ln2);
    
%interp1([x1a;x1b],[y1a;y1b],
    x1_ext = repmat(x1a,nx,1)+A1/L1.*cos(alpha1)*(cos(phi1_ext).*Ln1);
    y1_ext = repmat(y1a,nx,1)+A1/L1.*cos(alpha1)*(sin(phi1_ext).*Ln1);
    x2_ext = repmat(x2a,nx,1)+A2/L2.*cos(alpha2)*(cos(phi2_ext).*Ln2);
    y2_ext = repmat(y2a,nx,1)+A2/L2.*cos(alpha2)*(sin(phi2_ext).*Ln2);
    
    x1_ext = x1_ext+corr1.*repmat(cos(phi1_ext-.5*pi),nx,1);
    y1_ext = y1_ext+corr1.*repmat(sin(phi1_ext-.5*pi),nx,1);
    x2_ext = x2_ext+corr2.*repmat(cos(phi2_ext-.5*pi),nx,1);
    y2_ext = y2_ext+corr2.*repmat(sin(phi2_ext-.5*pi),nx,1);
    
    z1_ext = repmat(z(:,1),1,size(x1_ext,2));
    z2_ext = repmat(z(:,end),1,size(x2_ext,2));
    
    % build grids
    x = [x1_ext x x2_ext];
    y = [y1_ext y y2_ext];
    z = [z1_ext z z2_ext];

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
    end

function [x y z] = seaward_flatten(x, y, z, OPT)
    n = OPT.n;
    
    z0 = min(z(:,1));
    
    z(:,1) = z0;
    for i = 1:size(z,1)
        z(i,2:n) = interp1(x(i,[1 n+1]),[z0 z(i,n+1)],x(i,2:n));
    end

function [x y z] = landward_extend(x, y, z, OPT)
    n = OPT.n;
    dx = x(1,end)-x(1,end-1);
    
    zn = [z ones(size(y,1),OPT.n)*OPT.z0];
    xn = [x x(1,end)+repmat([1:1:OPT.n],size(y,1),1)*dx];
    yn = [y repmat(y(:,1),1,OPT.n)];
    
    x = xn;
    y = yn;
    z = zn;
    
function [xn yn zn] = seaward_extend(x, y, z, OPT)

z0 = max(z(:,1));
dxoff = x(1,2)-x(1,1);
dn = ceil(max(z0-OPT.zmin,0)/(OPT.slope*dxoff))+OPT.n;
zt = NaN*zeros(size(x,1), size(x,2)+OPT.n);
zt(:,1:OPT.n) = OPT.zmin;
zt(:,OPT.n+1:end) = z; 
% extended xbeach grid
xn = [ x(1,1)+[-dn:1:-1]*dxoff x(1,:)]; 
[xn,yn] = meshgrid(xn,y(:,1));
% temporary xbeach grid
xt = [xn(1,1:OPT.n) x(1,:)]; 
[xt,yt] = meshgrid(xt,y(:,1));
% interpolate
zn = interp2(xt,yt,zt,xn,yn);