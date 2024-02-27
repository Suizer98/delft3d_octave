function [xgr zgr] = xb_grid_xgrid_flipped(xin, zin, varargin)
% Simple function similar to xb_grid_xgrid but flipped (land to offshore)

% Defaults
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
    'minh', 0.01 ...       % minimum water depth used in dispersion relation
    );

%% Overrule defaults
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

%% set boundaries
xend    = xin(1);
xstart  = xin(end);

% prepare wave length
hin      = max(OPT.wl-zin,0.01);
if OPT.nonh
    k       = disper(2*pi/OPT.Tm, hin(1), OPT.g);
    Lwave = 2*pi/k;
else
    k       = disper(2*pi/(OPT.Tm), hin(1), OPT.g);
    Lshort  = 2*pi/k;
    Lwave   = 4*Lshort;
end
x       = xin;

% grid settings
ii = 1;
xgr(ii) = xstart;
zgr(ii) = zin(end);
hgr(ii) = hin(end);
xlast   = xgr(ii);
while xlast > xend
    
    % what is the minimum grid size in this area
    localmin    = OPT.dxmin;
    
    % compute dx; minimum value dx (on dry land) = dxmin
    dxmax       = Lwave/OPT.ppwl;
    dxmax       = min(dxmax,OPT.dxmax);
    dx(ii)      = sqrt(OPT.g*hgr(ii))*OPT.dtref/OPT.CFL;
    dx(ii)      = min(dx(ii),OPT.depthfac*hgr(ii));
    dx(ii)      = max(dx(ii),localmin);
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
    ii              = ii+1;
    xgr(ii)         = xgr(ii-1)-dx(ii-1);
    hgr(ii)         = interp1(xin,hin,xgr(ii));
    zgr(ii)         = interp1(xin,zin,xgr(ii));
    xlast           = xgr(ii);
    
    % need to recompute k for changing water depth
    hlast = hgr(ii-1);
    if hlast>OPT.minh
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
end

% chop off last grid cell, if limit is exceeded
if xlast > xend
    xgr = xgr(1:end-1);
    zgr = zgr(1:end-1);
end

% Flip grid again
xgr       = fliplr(xgr);
zgr       = fliplr(zgr);

xb_verbose(2,'Grid cells',length(xgr));
