function [xgr zgr] = xb_grid_xgrid(xin, zin, varargin)
%XB_GRID_XGRID  Creates a model grid in x-direction based on bathymetry
%
%   Function to interpolate (no extrapolation) profile measurements to
%   cross shore consant or varying grid for an XBeach profile model. Cross
%   shore grid size is limited by user-defined minimum grid size in shallow
%   water and land, long wave resolution on offshore boundary, depth to
%   grid size ratio and grid size smoothness constraints. The function uses
%   the Courant condition to find the optimal grid size given these
%   constraints.
%
%   Syntax:
%   [xgr zgr] = xb_grid_xgrid(xin, zin, varargin)
%
%   Input:
%   xin   = vector with cross-shore coordinates; increasing from zero
%   towards shore
%   zin   = vector with bed levels; positive up
% 
%   Optional input in keyword,value pairs
%     - xgrid    :: [m] vector which defines the variable xgrid
%     - Tm       :: [s] incident short wave period (used for maximum grid size at offshore boundary) 
%                       if you impose time series of wave conditions use the min(Tm) as input (default = 5)
%     - dxmin    :: [m] minimum required cross shore grid size (usually over land) (default = 1)
%     - dxmax    :: [m] user-specified maximum grid size, when usual wave
%                       period / CFL condition does not suffice (default Inf)
%     - vardx    :: [-] 0 = constant dx, 1 = varying dx (default = 1)
%     - g        :: [ms^-2] gravity constant (default = 9.81)
%     - CFL      :: [-] Courant number in grid generator (default = 0.9)
%     - dtref    :: [-] Ref value for dt in computing dx from CFL (default = 4)
%     - maxfac   :: [-] Maximum allowed grid size ratio between adjacent cells (default = 1.15)
%     - dy, 5    :: [m] dy (default = 5)
%     - wl,0     :: [m] water level elevation relative to bathymetry used to estimate water depth (default = 0)
%     - ppwl     :: [-] numer of points per wave length
%     - depthfac :: [-] Maximum gridsize to water depth ratio (default = 2)
%     - nonh     :: [-] Switch option for generation of non-hydrostatic
%                       model grid
%     - dxdry    :: [m] grid size for dry points
%     - zdry     :: [m] elevation above which points are dry 
%     - xdry     :: [m] cross-shore distance from which points are dry
%     - minh     :: [m] minimum water depth used in dispersion relation
%
%   Output:
%   xgr   = x-grid coordinates
%   zgr   = bed elevations
%
%   Example
%   [xgr zgr] = xb_grid_xgrid([0:1:200], 0.1*[0:1:200]-15);
%
%   See also xb_generate_grid, xb_grid_ygrid

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Robert McCall / Jaap van Thiel de Vries
%
%       robert.mccall@deltares.nl	
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
% Created: 01 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_grid_xgrid.m 15718 2019-09-11 18:07:40Z asmaa.bakr90.x $
% $Date: 2019-09-11 20:07:40 +0200 (wo, 11 sep 2019) $
% $Author: asmaa.bakr90.x $
% $Revision: 15718 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_modelsetup/xb_grid/xb_grid_xgrid.m $
% $Keywords: $

% Change log:
% modified by Marlies van der Lugt June 2020
% - reversed profile building order from offshore--> onshore towards
%   onshore--> offshore to ensure steep beach profiles are actually
%   appropriately resolved towards minimum grid resolution dxmin
% - replace opt.hmin by opt.eps for treshold of using dispersion relation
% - replace hardcoded minimum waterdepth with opt.eps

%% settings

OPT = struct(...
    'xgrid', [],...        % predefined xgrid vector
    'Tm',5,...             % incident short wave period (used for maximum grid size at offshore boundary) if you impose time series of wave conditions use the min(Tm) as input
    'dxmin',.5,...          % minimum required cross shore grid size (usually over land)
    'dxmax',Inf,...        % user-specified maximum grid size, when usual wave period / CFL condition does not suffice
    'vardx',1,...          % 0 = constant dx, 1 = varying dx
    'g', 9.81,...          % gravity constant
    'CFL', 0.9,...         % Courant number
    'dtref', 4,...         % Ref value for dt in computing dx from CFL
    'maxfac', 1.15,...     % Maximum allowed grid size ratio
    'wl',0,...             % Water level elevation used to estimate water depth
    'depthfac', 2, ...     % Maximum gridsize to depth ratio
    'ppwl', 12 ,...        % desired points per wavelength
    'nonh', false, ...     % setting grid to solve individual short waves instead of infragravity waves
    'dxdry', [], ...       % grid size to use for dry cells
    'zdry', [],...         % vertical level above which cells should be considered dry
    'xdry', [],...         % horizontal (cross-shore) level from which cells should be considered dry
    'minh', 0.01, ...       % minimum water depth used in dispersion relation
    'eps',[0.01] ...       % minimum water depth on a cell.
    );
%% 

% overrule default settings by propertyName-propertyValue pairs, given in varargin
%% 
OPT = setproperty(OPT, varargin{:});
if isempty(OPT.dxdry)
    OPT.dxdry = OPT.dxmin;
end
if isempty(OPT.zdry)
    OPT.zdry = OPT.wl;
end

%% make grid
% fix if z-values contain NaN's
xin = xin(~isnan(zin));
zin = zin(~isnan(zin));
%% 

% set boundaries
xstart  = xin(1);
zstart  = zin(1);
xend    = xin(end);
xlast   = xend;

if OPT.vardx == 0
    
    % constant dx
    xgr = (xin(1):OPT.dxmin:xin(end));
    zgr = interp1(xin, zin, xgr);
    
    xb_verbose(1,'Create equidistant cross-shore grid');
    xb_verbose(2,'Grid size',OPT.dxmin);
    
elseif OPT.vardx == 1 && ~isempty(OPT.xgrid)
    
    % predefined xgrid
    xgr = OPT.xgrid;
    zgr = interp1(xin, zin, xgr);
    
    xb_verbose(1,'Use pre-defined cross-shore grid');
    
elseif OPT.vardx == 1
    
    % prepare
    hin      = max(OPT.wl-zin,OPT.eps); %previous hardcoded: OPT.eps=0.01
    %k       = disper(2*pi/OPT.Tm, hin(1), OPT.g);
    if OPT.nonh
        k       = disper(2*pi/OPT.Tm, hin(1), OPT.g);
        Lwave = 2*pi/k;
    else
        %Llong   = 4*2*pi/k;
        k       = disper(2*pi/(OPT.Tm), hin(1), OPT.g);
        Lshort = 2*pi/k;
        Lwave = 4*Lshort;
    end
    x       = xin;
        
    % grid settings
    ii = 1;
    xgr(ii) = xend;
    zgr(ii) = zin(end);
    hgr(ii) = hin(end);
    while xlast > xstart
        
        % what is the minimum grid size in this area
        if ~isempty(OPT.xdry)
            drycell = xgr(ii)>OPT.xdry;
        else
            drycell = zgr(ii)>OPT.zdry;
        end
        if drycell
            localmin = OPT.dxdry;
        else
            localmin = OPT.dxmin;
        end
        
        % compute dx; minimum value dx (on dry land) = dxmin
        dxmax = Lwave/OPT.ppwl;
        dxmax = min(dxmax,OPT.dxmax);
        % dxmax = sqrt(g*hgr(min(ii)))*Tlong_min/12;
        dx(ii) = sqrt(OPT.g*hgr(ii))*OPT.dtref/OPT.CFL;
        dx(ii) = min(dx(ii),OPT.depthfac*hgr(ii));
        dx(ii) = max(dx(ii),localmin);
        if dxmax > localmin
            dx(ii) = min(dx(ii),dxmax);
        else
            dx(ii) = localmin;
        end
        
        % make sure that dx(ii)<= maxfac*dx(ii-1) or dx(ii)>= 1/maxfac*dx(ii-1)
        if ii>1
            if dx(ii) >= OPT.maxfac*dx(ii-1); dx(ii) = OPT.maxfac*dx(ii-1); end;
            if dx(ii) <= 1./OPT.maxfac*dx(ii-1); dx(ii) = 1./OPT.maxfac*dx(ii-1); end;
        end
        
        % compute x(ii+1)...
        ii = ii+1;
        xgr(ii) = xgr(ii-1)-dx(ii-1);
        [xin2 index] = unique(xin);
		xtemp   = min(xgr(ii),xend);
        hgr(ii) = interp1(xin2,hin(index),xtemp);
        zgr(ii) = interp1(xin2,zin(index),xtemp);
        xlast=xgr(ii);
        
        % need to recompute k for changing water depth
        hlast = hgr(ii);
        if hlast>OPT.eps %used to be minh
            if OPT.nonh
                k       = disper(2*pi/OPT.Tm, hlast, OPT.g);
                Lwave = 2*pi/k;
            else
                %Llong   = 4*2*pi/k;
                k       = disper(2*pi/(OPT.Tm), hlast, OPT.g);
                Lshort = 2*pi/k;
                Lwave = 4*Lshort;
            end
        else
            Lwave = 0;
        end
        abvc = 1;
        
    end
    if all(dx<=OPT.dxmin)
        warning(['Computed dxmax (= ' num2str(dxmax) ' m) is smaller than the user defined dxmin (= ' num2str(localmin) ' m). ',...
            'Grid will be generated using constant dx = dxmin. Please change dxmin if this is not desired.']);
    end
    
    xb_verbose(1,'Optimize cross-shore grid using CFL condition');
    
else
    error('Nope, this is not going to work; vardx = [0 1]');
end

% chop off depth profile, if limit is exceeded
if xlast < xstart
    zgr(end) = zstart;
end

%reverse order back to offshore --> onshore
xgr = flipud(xgr(:));
zgr = flipud(zgr(:));

%make sure horizontal reference is similar to the input profile
xgr = xgr-xgr(end)+xend;

xb_verbose(2,'Grid cells',length(xgr));