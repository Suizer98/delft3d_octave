function TS = generate_time_series_from_spectra(spec,xout,yout,tout,hmean,varargin)
% generate water surface and depth-average velocity time series based on
% input spectra

%

%% defaults
OPT.convention  = 'nautical';
OPT.spreading   = 'degrees';
OPT.nCompFreq   = 25;%100 old value
OPT.thetamin    = 0;
OPT.thetamax    = 360;
OPT.nCompDir    = round((OPT.thetamax-OPT.thetamin)/5); % approx 5 deg bins
OPT.g           = 9.81;
OPT             = setproperty(OPT, varargin{:});

%% check input
if ~isstruct(spec)
    error('input ''spec'' should be structure');
end
nspec = length(spec);

% check that all structures have the same fields
fn = fieldnames(spec(1));
for i=2:nspec
    fn2 = fieldnames(spec(i));
    inboth = intersect(fn,fn2);
    if length(fn2) ~= length(fn) || length(inboth)<length(fn)
        error('input structures must have the same fields');
    end
end

% spectrum structures must contain at least these fields
checkfields = {'x';'y';'f';'v'};
inboth = intersect(fn,checkfields);
if length(inboth)<length(checkfields)
    error('input structures must contain at least x,y,f and v');
end

% check output points length
if ~(isequal(size(xout), size(yout)) || (isvector(xout) && isvector(yout) && numel(xout) == numel(yout)))
    error('input ''xout'' and ''yout'' must be the same size');
end

% set t axis to row vector
if ndims(tout)>2 || min(size(tout))>1
    error('output time ''tout'' must be vector');
end
tout = [tout(:)]';

% check that thetamin <thetamax
if OPT.thetamin >= OPT.thetamax
    error('thetamin must be smaller than thetamax');
end

% check that convention is understood
if ~strcmpi(OPT.convention,'cartesian') && ~strcmpi(OPT.convention,'nautical')
    error('''convention'' must be ''nautical'' or ''cartesian''');
end

% check that spreading format is understood
if ~strcmpi(OPT.spreading,'degrees') && ~strcmpi(OPT.spreading,'s') && ~strcmpi(OPT.spreading,'m')
    error('''spreading'' must be ''degrees'', ''s'', or ''m''');
end
%% coordinates of input spectra
xspec = zeros(nspec,1);
yspec = 0*xspec;
for i=1:nspec
    xspec(i) = spec(i).x;
    yspec(i) = spec(i).y;
end

%% standardize input vf spectrum
if ~isfield(spec(1),'dir')
    waveDirectionType = 'none';
    for i=1:nspec
        if length(spec(i).f) ~= length(spec(i).v)
            error('spectrum frequency and variance must be same size');
        end
        spec(i).vf = spec(i).v;
    end
else
    if ndims(spec(1).v)>2
        error('variance density in spectrum structure should not have dimension greater than 2');
    end
    if min(size(spec(1).v))==1
        if ~isfield(spec(1),'spread')
            error('for 1D spectra, structure must contain ''spread'' field')
        end
        waveDirectionType = '1D';
        for i=1:nspec
            if length(spec(i).f) ~= length(spec(i).v) || ...
                    length(spec(i).f) ~= length(spec(i).dir) || ...
                    length(spec(i).f) ~= length(spec(i).spread)
                error('spectrum frequency, direction, spread and variance must be same size');
            end
            spec(i).vf = spec(i).v;
        end
    else
        waveDirectionType = '2D';
        for i=1:nspec
            if length(spec(i).f) ~= size(spec(i).v,1) || ...
                    length(spec(i).dir) ~= size(spec(i).v,2)
                error('spectrum variance must meet size f in dim 1 and size dir in dim 2');
            end
            dd = median(abs(diff(spec(i).dir)));
            spec(i).vf = sum(spec(i).v,2)*dd;
        end
    end
end

%% standardized frequency range
fmin = Inf;
fmax = 0;
minthres = 1e-4;
for i=1:nspec
    ftemp   = spec(i).f(spec(i).vf>minthres*max(spec(i).vf));
    fmin    = min(fmin,min(ftemp));
    fmax    = max(fmax,max(ftemp));
end
if fmin==0
    fmin = fmax/OPT.nCompFreq;
end
if isnan(OPT.nCompFreq)
    df              = (ftemp(2)-ftemp(1));
    f               = fmin:df:fmax;
    disp([' PS: we are using the highest resolution possible (n=', num2str(length(f)) '). This might take a while']);
else
    f               = linspace(fmin,fmax,OPT.nCompFreq)';
end
df = median(diff(f));
nf = length(f);

%% standardize directional space
if ~strcmpi(waveDirectionType,'none')
    
    dir = linspace(OPT.thetamin,OPT.thetamax,OPT.nCompDir);
    % convert to cartesian if necessary
    if strcmpi(OPT.convention,'nautical')
        dir = 270-dir;
    end
    % put all into 0-360 range
    dir = mod(dir,360);
    % remove duplicates (e.g., 0 deg and 360 deg)
    dir = unique(dir);
    %     dir = linspace(0,360-360/(OPT.nCompDir),OPT.nCompDir);
    ddir = abs(median(diff(dir)));
    nd = length(dir);
    % all computations are in cartesian convention
    
end

%% interpolate spectra to standard space
switch waveDirectionType
    case 'none'
        for i=1:nspec
                  
            % Interpolate
            spec(i).vfi = interp1(spec(i).f,spec(i).vf,f,'linear');
            spec(i).vfi(isnan(spec(i).vfi)) = 0;     
            
            % Check variance density
            spec(i).Hs1 = swan_hs(spec(i).f, spec(i).v);
            spec(i).Hs2  = swan_hs(f, spec(i).vfi);
            
            % Factor on vfi to get same Hs
            factor      = spec(i).Hs1./spec(i).Hs2;
            if factor > 1.01 & factor < 0.99
                spec(i).vfi = spec(i).vfi*factor^2;
                spec(i).Hs2 = swan_hs(f, spec(i).vfi);
                factor      = spec(i).Hs1./spec(i).Hs2;
            end
        end

    otherwise
        F = repmat(f,1,nd);
        DIR = repmat(dir,nf,1);
        for i=1:nspec
            fspec = spec(i).f;
            % set to column vector
            fspec = fspec(:);
            nfspec = length(fspec);
            switch waveDirectionType
                case '1D'
                    dirspec = dir;
                    ndspec = length(dirspec);
                    if strcmpi(OPT.convention,'nautical')
                        spec(i).dir = 270-spec(i).dir;
                    end
                case '2D'
                    dirspec = spec(i).dir;
                    % all computations in cartesian
                    if strcmpi(OPT.convention,'nautical')
                        dirspec = 270-dirspec;
                    end
                    dirspec = mod(dirspec,360);
                    ndspec = length(dirspec);
                    % set to row vector
                    dirspec = [dirspec(:)]';
            end
            
            % repmat
            dirspec = repmat(dirspec,nfspec,1);
            fspec = repmat(fspec,1,ndspec);
            switch waveDirectionType
                case '1D'
                    % per frequency determin spreading function
                    vspec = zeros(nfspec,ndspec);
                    if strcmpi(OPT.spreading,'degrees')
                        sig = spec(i).spread./180.*pi;
                        s = 2./sig.^2-1;
                    elseif strcmpi(OPT.spreading,'s')
                        s = spec(i).spread;
                    else
                        md = spec(i).spread;
                    end
                    
                    for m=1:nfspec
                        deltadir = spec(i).dir(m)-dirspec(m,:);
                        %                         deltadir = mod(deltadir,360);
                        if strcmpi(OPT.spreading,'degrees') || strcmpi(OPT.spreading,'s')
                            deltadir = deltadir./2;
                            dd = cosd(deltadir).^(2*round(s(m)));
                            dd = dd./trapz(dir,dd);
                        else
                            dd=cosd(deltadir).^md(m);
                            dd(abs(deltadir)>90) = 0;
                            dd = dd./trapz(dir,dd);
                        end
                        dd = [dd(:)]';
                        vspec(m,:) = spec(i).v(m)*dd;
                    end
                case '2D'
                    % variance density
                    vspec = spec(i).v;
            end
            
            % now copy all but for angles between -360 and 0 and 360-720
            dirspec = [dirspec+360 dirspec dirspec-360];
            fspec = [fspec fspec fspec];
            vspec = [vspec vspec vspec];
            
            % set up interpolant
            Ispec = scatteredInterpolant(fspec(:),dirspec(:),vspec(:),'linear','none');
            
            % project onto regular grid
            spec(i).vi = Ispec(F,DIR);
            spec(i).vi = max(spec(i).vi,0);
            
        end
end

%% generate random wave trains
switch waveDirectionType
    case 'none'
        nWaveTrains = nf;
        phi = rand(nf,1)*2*pi;
        w = 2*pi*f;
        k=disper(w,hmean,OPT.g);
        kx=k;
        ky=[];
    otherwise
        nWaveTrains = nf*nd;
        phi = rand(nf,nd)*2*pi;
        w = 2*pi*repmat(f,1,nd);
        k = disper(w,hmean,OPT.g);
        kx = k.*cosd(DIR);
        ky = k.*sind(DIR);
end


%% get time series per component per output point
szout = size(xout);
xout = xout(:);
yout = yout(:);

% pre-allocate TS struct by pre-setting maximum size
TS(length(xout)).x = xout(length(xout));

w = w(:);
phi = phi(:);
k = k(:);
kx=kx(:);
ky=ky(:);

T = repmat(tout,length(w),1);

w = repmat(w,1,length(tout));
phi = repmat(phi,1,length(tout));
k = repmat(k,1,length(tout));
kx = repmat(kx,1,length(tout));
ky = repmat(ky,1,length(tout));

switch waveDirectionType
    case 'none'
        % no info needed
    otherwise
        wavedirs = repmat(DIR(:),1,length(tout));
        coswavedirs = cosd(wavedirs);
        sinwavedirs = sind(wavedirs);
end

for j=1:length(xout)
    %display(['Computing time series for point ' num2str(j) ' of ' num2str(length(xout)) '.']);
    specind = [];
    smooth= polyfit(xout, yout, 10);
    smoothy=polyval(smooth, xout);
    if length(spec)>1
        % find closest spectrum location 
        %{
        dist = pyth(xspec-xout(j),yspec-yout(j));
        specind(1) = find(dist==min(dist),1,'first');
        % find distance between other spectra and first spectrum
        dist2 = pyth(xspec-xspec(specind(1)),yspec-yspec(specind(1)));
        % find the next nearest spectrum point for which the distance to
        % the output point is less than to the first spectrum. Only returns
        % a value if there is a second spectrum to use.
        if any(dist2>dist)
            mindist = min(dist(dist2>dist));
            specind(2) = find(dist==mindist,1,'first');
        end
        find distance output location to spectra old
        dist = pyth(xspec-xout(j),yspec-yout(j));
        [out,idx]=sort(dist);
        specind(1)=idx(1); specind(2)=idx(2);
        %}

        % find distance output location to spectra based on grid 
        
        % smooth xgrid to find normal line to grid
        if j<length(xout)
            slopegrid= (atan2d((xout(j+1)-xout(j)),(smoothy(j)-smoothy(j+1))));
        else
            slopegrid= (atan2d((xout(j)-xout(j-1)),(smoothy(j-1)-smoothy(j))));
        end
        slopegrid= slopegrid + 360*(slopegrid<0);

        % find slope and distance between gridpoint & all spectrum locations
        for jj=1:numel(xspec)
            slopespec(jj)= (atan2d((yspec(jj)-yout(j)), (xspec(jj)-xout(j))));
            slopespec= slopespec + 360*(slopespec<0);
        end
        dist = sqrt((xspec - xout(j)).^2 + (yspec - yout(j)).^2);
        
        % identify spectrum locations; nearest location to left and right of normal
        % line to grid
        bins=sort([slopegrid mod(slopegrid+180,360)]);

        clear specind; count=0;
        specinside= slopespec>=bins(1) & slopespec<bins(2);
        if any(specinside)==1
            count=count+1;
            TMP           = find(dist==min(dist(specinside)));
            specind(count)= TMP(1);
        end
        specoutside= slopespec<bins(1) | slopespec>=bins(2);
        if any(specoutside)==1
            count= count+1;
            TMP           = find(dist==min(dist(specoutside)));
            specind(count)= TMP(1);;
        end
        
        %check in figure
        %{
        if (j==100 || j==300 || j==500 || j==800)
            figure; hold on;
            plot(xout(j), yout(j), 'rx')
            plot(xout(j+1), yout(j+1), 'rd')
            xplot= [xout(j) xout(j)+0.01e6];
            slopegridplot= -(1/((smoothy(j+1)-smoothy(j))/(xout(j+1)-xout(j))));
            slopegridcheck=  (atand(slopegridplot));
            yplot= [yout(j) yout(j)+ (xplot(2)-xplot(1))*slopegridplot];
            plot(xplot, yplot, 'b')
            scatter(xspec, yspec, 'g')
            scatter(xspec(specind), yspec(specind), 'r', 'filled')
            plot(xout, smoothy)
            plot(xout, yout, 'c')
            axis equal
        end
        %}

    else
        specind(1) = 1;
    end
    
    interpolateSpectra = length(specind)>1;
    if ~interpolateSpectra
        fac(1) = 1;
    else
        fac(1) = 1-dist(specind(1))/(dist(specind(1))+dist(specind(2)));
        fac(2) = 1-fac(1);
    end
    
    switch waveDirectionType
        case 'none'
            a1 = sqrt(2*spec(specind(1)).vfi*df);
        otherwise
            a1 = sqrt(2*spec(specind(1)).vi*df*ddir);
    end
    
    if interpolateSpectra
        switch waveDirectionType
            case 'none'
                a2 = sqrt(2*spec(specind(2)).vfi*df);
            otherwise
                a2 = sqrt(2*spec(specind(2)).vi*df*ddir);
        end
        a = fac(1)*a1 + fac(2)*a2;
    else
        a = a1;
    end
    a = a(:);
    a = repmat(a,1,length(tout));
    
    zs = 0*a;
    u = 0*zs;
    v = 0*zs;
    
    switch waveDirectionType
        case 'none'
            %             for m=1:length(w)
            %                 zs(m,:) = a(m)*sin(w(m)*tout+phi(m));
            %                 u(m,:) = 1/hmean*w(m)/k(m)*a(m)*sin(w(m)*tout+phi(m));
            %             end
            zs = a.*sin(w.*T+phi);
            u = 1/hmean.*w./kx.*a.*sin(w.*T+phi);
        otherwise
            zs = a.*sin(w.*T ...
                -ky.*yout(j) ...
                -kx.*xout(j) ...
                +phi);
            vel = 1/hmean.*w./k.*a.*sin(w.*T ...
                -ky.*yout(j) ...
                -kx.*xout(j) ...
                +phi);
            u = vel.*coswavedirs;
            v = vel.*sinwavedirs;
            
    end
    
    TS(j).x = xout(j);
    TS(j).y = yout(j);
    TS(j).zs = sum(zs,1);
    TS(j).u = sum(u,1);
    TS(j).v = sum(v,1);
    
end






