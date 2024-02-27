function tc=wes2(trackinput,format,spwinput,outputfile,varargin)

% The tc structure contains all information about the track, as well as
% some conversion factors, e.g. in order to get to 10-minutes averaged wind
% speeds in m/s and some physical and numerical constants (spiralling angle etc.)

% The spw structure ONLY contains info of the spiderweb grid (radius, nr bins,
% etc.).

% Defaults (only used if tc structure does not have these values!)
rhoa=1.15;
phi_spiral=20;
cs.name='WGS 84';
cs.type='geographic';

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'rhoa','rhoair','rho_air'}
                rhoa=varargin{ii+1};
            case{'phi_spiral','phispiral'}
                phi_spiral=varargin{ii+1};
        end
    end
end

% Set conversion constants
kts2ms=0.514;
nm2km=1.852;

switch lower(format)
    case{'tcstructure'}
        tc=trackinput;
        % Replace -999 with NaN
        for it=1:length(tc.track)
            tc.track(it).vmax(tc.track(it).vmax==-999)=NaN;
            tc.track(it).pdrop(tc.track(it).pdrop==-999)=NaN;
            tc.track(it).rmax(tc.track(it).rmax==-999)=NaN;
            if isfield(tc.track(it),'quadrant')
                for iq = 1:length(tc.track(it).quadrant)
                    tc.track(it).quadrant(iq).a(tc.track(it).quadrant(iq).a==-999)=NaN;
                    tc.track(it).quadrant(iq).b(tc.track(it).quadrant(iq).b==-999)=NaN;
                    tc.track(it).quadrant(iq).radius(tc.track(it).quadrant(iq).radius==-999)=NaN;
                end
            else
                tc.track(it).quadrant=[];
            end
        end
    case{'jmv30'}
        tc=readjmv30_02(trackinput);
    case{'jtwc_best_track'}
        tc=read_jtwc_best_track(trackinput);
end

if isstruct(spwinput)
    spw=spwinput;
else
    % Read spw input file
end

tc.use_relative_speed=1;

% Add stuff to tc structure
if ~isfield(tc,'rhoa')
    tc.rhoa=rhoa;
end
if ~isfield(tc,'phi_spiral')
    tc.phi_spiral=phi_spiral;
end
if ~isfield(tc,'cs')
    tc.cs=cs;
end

%% Cut off parts of track that have a wind speed lower than 30 kts (15 m/s)

ifirst=[];
for it=1:length(tc.track)
    if tc.track(it).vmax>=spw.cut_off_speed && isempty(ifirst)
        ifirst=it;
        break
    end
end
tc.track=tc.track(ifirst:end);
ilast=[];
for it=length(tc.track):-1:1
    if tc.track(it).vmax>spw.cut_off_speed && isempty(ilast)
        ilast=it;
        break
    end
end
if ~isempty(ilast)
    tc.track=tc.track(1:ilast);
end

if ~isfield(spw,'reference_time')
    spw.reference_time=tc.track(1).time;
end

nt=length(tc.track);

%% Convert units

% Convert wind speeds to m/s
switch lower(tc.wind_speed_unit)
    case{'kts','kt','knots'}
        tc.radius_velocity=tc.radius_velocity*kts2ms*tc.wind_conversion_factor; % Convert to m/s
        for it=1:nt
            tc.track(it).vmax=tc.track(it).vmax*kts2ms*tc.wind_conversion_factor; % Convert to m/s
        end
end

% Convert radii to km
for it=1:nt
    switch lower(tc.radius_unit)
        case{'nm'}
            for iq=1:length(tc.track(it).quadrant)
                for irad=1:length(tc.track(it).quadrant(iq).radius)
                    tc.track(it).quadrant(iq).radius(irad)=tc.track(it).quadrant(iq).radius(irad)*nm2km; % Convert to km
                end
            end
            tc.track(it).rmax=tc.track(it).rmax*nm2km; % Convert to km
    end
end

tc.vprop_max=500; % m/s, limiter for forward speed

%% Determine forward speed vx and vy

for it=1:nt
    geofac=1;
    switch lower(tc.cs.type(1:3))
        case{'geo','lat'}
            geofac=111111*cos(tc.track(it).y*pi/180);
    end
    if it==1
        dt=86400*(tc.track(2).time-tc.track(1).time);
        dx=(tc.track(2).x-tc.track(1).x)*geofac;
        dy=(tc.track(2).y-tc.track(1).y)*geofac;
    elseif it==nt
        dt=86400*(tc.track(end).time-tc.track(end-1).time);
        dx=(tc.track(end).x-tc.track(end-1).x)*geofac;
        dy=(tc.track(end).y-tc.track(end-1).y)*geofac;
    else
        dt=86400*(tc.track(it+1).time-tc.track(it-1).time);
        dx=(tc.track(it+1).x-tc.track(it-1).x)*geofac;
        dy=(tc.track(it+1).y-tc.track(it-1).y)*geofac;
    end
    
    % Use Schwerdt (1979) to compute u_prop and v_prop
    ux=dx/dt;
    uy=dy/dt;
    uabs=sqrt(ux^2+uy^2);
    c=uabs*1.944; % Convert to kts
    a=1.5*c^0.63; % Schwerdt (1979)
    a=a/1.944;    % Convert to m/s
    u_prop=a*ux/uabs;
    v_prop=a*uy/uabs;
    
    tc.track(it).u_prop=u_prop;
    tc.track(it).v_prop=v_prop;
    vmag=sqrt(tc.track(it).u_prop^2 + tc.track(it).v_prop^2);
    if vmag>tc.vprop_max
        % Limit forward speed
        fac=tc.vprop_max/vmag;
        tc.track(it).u_prop=tc.track(it).u_prop*fac;
        tc.track(it).v_prop=tc.track(it).v_prop*fac;
    end
end

%% Compute max wind speed relative to propagation speed
for it=1:nt
    tc.track(it).vmax_rel=tc.track(it).vmax-sqrt(tc.track(it).u_prop^2+tc.track(it).v_prop^2);
end

% And now for the real work, determining A and B (and Pdrop) for each track
% point

for it=1:nt
    
%     if sum(~isnan(tc.track(it).quadrant(1).radius))>0
%         tc.track(it).method=2;
%     else
%         tc.track(it).method=7;
%     end
    
%    tc.track(it).method=4;

    % First check whether R35 etc. are present
    switch tc.track(it).method
        case 2
            trk=tc.track(it);
            ok=1;
            for iq=1:length(trk.quadrant)
                notnan=find(~isnan(trk.quadrant(iq).radius));
                if length(notnan)<1
                    ok=0;
                end
            end
            if ~ok
                tc.track(it).method=8;
            end
    end
    
    switch tc.track(it).method
        case 1
            % Vmax, A and B (odd combo)
            tc=method1(tc,it);
        case 2
            % Vmax, R35 etc.
            tc=method2(tc,it);
        case 3
            % Vmax, Pdrop, Rw
            tc=method3(tc,it);
        case 4
            % Vmax, Pdrop
            tc=method4(tc,it);
        case 5
            % Pdrop based on US storm statistics
            tc=method5(tc,it);
        case 6
            % Pdrop based on Indian storm statistics
            tc=method6(tc,it);
        case 7 % Obsolete
            % Just Vmax
            tc=method7(tc,it);
        case 8
            % Just Vmax, estimate Rmax and Pdrop using Knaff and Zehr (2007)
            tc=method8(tc,it);
        case 9
            % Vmax, Pdrop, Rmax estimated using Knaff and Zehr (2007)
            tc=method9(tc,it);
    end
end

%% Spiderweb file

for it=1:nt
    
    dx=spw.radius/spw.nr_radial_bins;
    r=dx:dx:spw.radius;
    r=r/1000; % km
    dphi=360.0/spw.nr_directional_bins;
    phi=90:-dphi:-270+dphi;
    
    % Initialize arrays
    wind_speed=zeros(length(phi),length(r));
    wind_to_direction_cart=zeros(length(phi),length(r));
    pressure_drop=zeros(length(phi),length(r));
    
    if length(tc.track(it).quadrant)==1 || tc.track(it).method~=2 % FIX THIS
        
        % A and B used for entire circle
        a=tc.track(it).quadrant(1).a;
        b=tc.track(it).quadrant(1).b;
        
        for iphi=1:length(phi)
            wind_speed(iphi,:) = sqrt(a*b*tc.track(it).pdrop*exp(-a./r.^b)./(tc.rhoa*r.^b));
            if tc.track(it).y>0.0
                % Northern hemisphere
                dr=90+phi(iphi)+tc.phi_spiral;
            else
                % Southern hemisphere
                dr=-90+phi(iphi)-tc.phi_spiral;
            end
            wind_to_direction_cart(iphi,:)=dr;
            pd=tc.track(it).pdrop.*exp(-a./r.^b);
            pd=max(pd)-pd;
            pressure_drop(iphi,:) = pd;
        end
        
    else
        
        % First linear interpolation of A and B
        
        aa=[];
        bb=[];
        
        for iq=1:length(tc.track(it).quadrant)
            aa(iq)=tc.track(it).quadrant(iq).a;
            bb(iq)=tc.track(it).quadrant(iq).b;
        end
        
        aa=[aa aa aa];
        bb=[bb bb bb];
        dd=[45 -45 -135 -225];
        dd=[dd+360 dd dd-360];
        a=interp1(dd,aa,phi);
        b=interp1(dd,bb,phi);

        for iphi=1:length(phi)
            wind_speed(iphi,:) = sqrt(a(iphi)*b(iphi)*tc.track(it).pdrop_fit*exp(-a(iphi)./r.^b(iphi))./(tc.rhoa*r.^b(iphi)));
            if tc.track(it).y>0.0
                % Northern hemisphere
                dr=90+phi(iphi)+tc.phi_spiral;
            else
                % Southern hemisphere
                dr=-90+phi(iphi)-tc.phi_spiral;
            end
            wind_to_direction_cart(iphi,:)=dr;
            pd=tc.track(it).pdrop.*exp(-a(iphi)./r.^b(iphi));
            pd=max(pd)-pd;
            pressure_drop(iphi,:) = pd;
        end
        
    end
    
    vx=wind_speed.*cos(wind_to_direction_cart*pi/180)+tc.track(it).u_prop;
    vy=wind_speed.*sin(wind_to_direction_cart*pi/180)+tc.track(it).v_prop;
    dr=atan2(vy,vx);
    dr=1.5*pi-dr;
    wind_speed=sqrt(vx.^2 + vy.^2);
    wind_from_direction=180*dr/pi;
    wind_from_direction=mod(wind_from_direction,360);
    
    % Limit wind speed to 65 m/s in order to avoid errors in SWAN related
    % to Cd computation
%    wind_speed=min(wind_speed,65);
    
    tc.track(it).wind_speed=wind_speed;
    tc.track(it).wind_from_direction=wind_from_direction;
    tc.track(it).pressure_drop=pressure_drop;
    
end

if ~isempty(outputfile)
    switch lower(spw.cs.type(1:3))
        case{'geo'}
            gridunit='degree';
        otherwise
            gridunit='m';
    end
    write_spiderweb_file_delft3d(outputfile, tc, gridunit, spw.reference_time, spw.radius);
end


%%
function tc=method1(tc,it)

% Vmax, A and B (somewhat odd combo, but okay)

tc.track(it).pdrop=tc.rhoa*exp(1)*tc.track(it).vmax_rel/tc.track(it).quadrant(1).b;


%%
function tc=method2(tc,it)

% Where do we expect to see the largest wind speeds?
angles0b{1}=90:10:180;
angles0b{2}=0:10:90;
angles0b{3}=270:10:360;
angles0b{4}=180:10:270;
tc.phi_spiral=20;

for iq=1:4
    if tc.track(it).y>0
        anglesb{iq}=angles0b{iq}+tc.phi_spiral;        % Include spiralling effect
    else
        anglesb{iq}=angles0b{iq}-tc.phi_spiral;        % Include spiralling effect
    end
    anglesb{iq}=anglesb{iq}*pi/180;                    % Convert to radians
end

for iq=1:length(tc.track(it).quadrant)
    uabs=tc.radius_velocity(1)*cos(anglesb{iq});
    vabs=tc.radius_velocity(1)*sin(anglesb{iq});
    uabs=uabs+tc.track(it).u_prop;
    vabs=vabs+tc.track(it).v_prop;
    abs_speed=sqrt(uabs.^2+vabs.^2);
    imax=find(abs_speed==max(abs_speed));
    imax=imax(1);
    angles(iq)=angles0b{iq}(imax)*pi/180;                    % This is the angle where the maximum winds are blowing to in each quadrant (cartesian, radians)
end

% Get rid of 0 radii (found in some tc files)
for iq=1:length(tc.track(it).quadrant)
    for irad=1:length(tc.track(it).quadrant(iq).radius)
        if tc.track(it).quadrant(iq).radius(irad)<1
            tc.track(it).quadrant(iq).radius(irad)=NaN;
        end
    end
end

% Compute relative speed of all quadrants and radii
for iq=1:length(tc.track(it).quadrant)
    for irad=1:length(tc.track(it).quadrant(iq).radius)
        if ~isnan(tc.track(it).quadrant(iq).radius(irad))
            uabs=tc.radius_velocity(irad)*cos(angles(iq));
            vabs=tc.radius_velocity(irad)*sin(angles(iq));
            urel=uabs-tc.track(it).u_prop;
            vrel=vabs-tc.track(it).v_prop;
            tc.track(it).quadrant(iq).relative_speed(irad)=sqrt(urel^2+vrel^2);
        else
            tc.track(it).quadrant(iq).relative_speed(irad)=NaN;
        end
    end
    urel=tc.track(it).vmax_rel*cos(angles(iq));
    vrel=tc.track(it).vmax_rel*sin(angles(iq));
    uabs=urel+tc.track(it).u_prop;
    vabs=vrel+tc.track(it).v_prop;
    tc.track(it).quadrant(iq).vmax_abs=sqrt(uabs^2+vabs^2);
end

%% Now fit the data

% Do this in two steps
% 1) Find A, B and Pdrop for each quadrant
% 2) Take average value of Pdrop in the 4 quadrants
% 3) Find A and B for each quadrant, using average Pdrop from previous steps

for iq=1:length(tc.track(it).quadrant)
    
    tc.track(it).quadrant(iq).a=NaN;
    tc.track(it).quadrant(iq).b=NaN;
    tc.track(it).quadrant(iq).pdrop=NaN;
    
    n=0;
    q(iq).rr=[];
    q(iq).vv=[];
    for irad=1:length(tc.track(it).quadrant(iq).radius)
        if ~isnan(tc.track(it).quadrant(iq).radius(irad))
            n=n+1;
            q(iq).rr(n)=tc.track(it).quadrant(iq).radius(irad);
            q(iq).vv(n)=tc.track(it).quadrant(iq).relative_speed(irad);
            q(iq).wgt(n)=1;
        end
    end
    
    % If Rmax is given, also include this in the radii
    if ~isnan(tc.track(it).rmax)
        q(iq).rr(end+1)=tc.track(it).rmax;
        q(iq).vv(end+1)=tc.track(it).vmax_rel;
        q(iq).wgt(end+1)=3;
    end
    
end

%% Find Pdrop
for iq=1:length(tc.track(it).quadrant)
    if ~isempty(q(iq).rr)        
        % Try to fit the data for this quadrant
        [afit,bfit,pfit]=fit_winds(q(iq).rr,q(iq).vv,'vmax',tc.track(it).vmax_rel,'rhoair',tc.rhoa,'weights',q(iq).wgt);        
%        [afit,bfit,pfit]=fit_winds(q(iq).rr,q(iq).vv,'rhoair',tc.rhoa,'weights',q(iq).wgt);        
        tc.track(it).quadrant(iq).pdrop=pfit;        
    end    
end
% Compute mean pdrop of the quadrants
for iq=1:length(tc.track(it).quadrant)
    pd(iq)=tc.track(it).quadrant(iq).pdrop;
end
pdrop=nanmean(pd);

%% And now find A and B again, using Pdrop found in previous step
for iq=1:length(tc.track(it).quadrant)      
    if ~isempty(q(iq).rr)
        % Try to fit the data for this quadrant
        [afit,bfit]=fit_winds(q(iq).rr,q(iq).vv,'vmax',tc.track(it).vmax_rel,'rhoair',tc.rhoa,'pdrop',pdrop,'weights',q(iq).wgt);        
%        [afit,bfit]=fit_winds(q(iq).rr,q(iq).vv,'rhoair',tc.rhoa,'pdrop',pdrop,'weights',q(iq).wgt);        
        tc.track(it).quadrant(iq).a=afit;
        tc.track(it).quadrant(iq).b=bfit;
    end
end

if isnan(tc.track(it).pdrop) % If Pdrop was not available in the track file, use Pdrop found in first step
    tc.track(it).pdrop=pdrop;
end
tc.track(it).pdrop_fit=pdrop; % pdrop computed by fitting procedure, used to make radial wind fields


% %% Log
% if it==17    
%     for iq=1:length(tc.track(it).quadrant)
%         afit=tc.track(it).quadrant(iq).a;
%         bfit=tc.track(it).quadrant(iq).b;
%         rrr=0:1:300;
%         vc  = sqrt(afit.*bfit.*pdrop.*exp(-afit./rrr.^bfit)./(tc.rhoa*rrr.^bfit));
%         figure(it+100)
%         subplot(2,2,iq);
%         plot(rrr,vc);hold on
%         plot(tc.track(it).rmax,tc.track(it).vmax_rel,'o');
%         r=tc.track(it).quadrant(iq).radius;
%         plot(r,tc.track(it).quadrant(iq).relative_speed,'o');
%     end
% end

%     % Compute errors
%     
%     % R34
%     disp(['Quadrant : ' num2str(iq)]);
% 
%     vmaxopt = sqrt(bopt.*pdrop./(tc.rhoa*exp(1)));
%     urel=vmaxopt*cos(angles(iq));
%     vrel=vmaxopt*sin(angles(iq));
%     uabs=urel+tc.track(it).u_prop;
%     vabs=vrel+tc.track(it).v_prop;
%     vmaxopt=sqrt(uabs^2+vabs^2);
%     rrr=0:1:300;
%     vc  = sqrt(aopt.*bopt.*pdrop.*exp(-aopt./rrr.^bopt)./(tc.rhoa*rrr.^bopt));
%     if it==17
%         figure(it+100)
%         subplot(2,2,iq);
%         plot(rrr,vc);hold on
%         plot(tc.track(it).rmax,tc.track(it).vmax_rel,'o');
%         r=tc.track(it).quadrant(iq).radius;
%         %     v=sqrt(aopt.*bopt.*pdrop.*exp(-aopt./r.^bopt)./(tc.rhoa*r.^bopt));
%         plot(r,tc.radius_velocity,'o');
%     end
% 
%     vmaxopt=vmaxopt*1.95/0.9;
%     vmaxtrk=tc.track(it).vmax*1.95/0.9;
%     disp(['VMax : ' num2str(vmaxtrk) ' (from track file) - ' num2str(vmaxopt)]);
    
%    disp(['R35      : ' num2str(iq)]);
%     %     vc  = sqrt(aopt*bopt*pdrop.*exp(-aopt./rr.^bopt)./(tc.rhoa*rr.^bopt));
        

%%
function tc=method3(tc,it)

% Vmax, Pdrop, Rmax
tc.track(it).quadrant(1).b=tc.rhoa*exp(1)*tc.track(it).vmax_rel^2/tc.track(it).pdrop;
tc.track(it).quadrant(1).a=tc.track(it).rmax^tc.track(it).quadrant(1).b;

%%
function tc=method4(tc,it)

% Vmax, Pdrop, Rmax=25NM
nm2km=1.852;
tc.track(it).rmax=25*nm2km;
tc.track(it).quadrant(1).b=tc.rhoa*exp(1)*tc.track(it).vmax_rel^2/tc.track(it).pdrop;
tc.track(it).quadrant(1).a=tc.track(it).rmax^tc.track(it).quadrant(1).b;

%%
function tc=method5(tc,it)

% Vmax, Rmax (Pdrop based on US storm statistics)
tc.track(it).pdrop=2*tc.track(it).vmax_rel^2;
tc.track(it).quadrant(1).b=tc.rhoa*exp(1)*tc.track(it).vmax_rel^2/tc.track(it).pdrop;
tc.track(it).quadrant(1).a=tc.track(it).rmax^tc.track(it).quadrant(1).b;

%%
function tc=method6(tc,it)

% Vmax, Rmax (Pdrop based on Indian storm statistics)
tc.track(it).pdrop=2*tc.track(it).vmax_rel^2;
tc.track(it).pdrop_fit=tc.track(it).pdrop;
tc.track(it).quadrant(1).b=tc.rhoa*exp(1)*tc.track(it).vmax_rel^2/tc.track(it).pdrop;
%tc.track(it).quadrant(1).b=1.563;
tc.track(it).quadrant(1).a=tc.track(it).rmax^tc.track(it).quadrant(1).b;

%%
function tc=method7(tc,it)

% Vmax (assuming Rmax is 25 NM)
nm2km=1.852;
tc.track(it).rmax=25*nm2km;
tc.track(it).pdrop=2*tc.track(it).vmax_rel^2;
tc.track(it).pdrop_fit=tc.track(it).pdrop;
tc.track(it).quadrant(1).b=1.563;
tc.track(it).quadrant(1).a=tc.track(it).rmax^tc.track(it).quadrant(1).b;

%%
function tc=method8(tc,it)

% Vmax
%tc.track(it).rmax= 35.37 - 0.11100*tc.track(it).vmax_rel + 0.5700*(abs(tc.track(it).y)-25); % Gross (from A New Method for Determining Tropical Cyclone Wind Forecast Probabilities)
tc.track(it).rmax=rmax_gross_2004(1.944*tc.track(it).vmax_rel,tc.track(it).y);
%tc.track(it).rmax=rmax_knaff_and_zehr_2007(1.944*tc.track(it).vmax_rel,tc.track(it).y);
%tc.track(it).pdrop=2*tc.track(it).vmax_rel^2;
tc.track(it).pdrop=-wpr_knaff_and_zehr_2007(1.11*1.944*tc.track(it).vmax_rel,tc.track(it).y,1,0);
tc.track(it).pdrop_fit=tc.track(it).pdrop;
tc.track(it).quadrant(1).b=1.563;
tc.track(it).quadrant(1).a=tc.track(it).rmax^tc.track(it).quadrant(1).b;

%%
function tc=method9(tc,it)

% Vmax, Pdrop (Rmax Knaff and Zehr 2007)
tc.track(it).rmax=rmax_knaff_and_zehr_2007(1.944*tc.track(it).vmax_rel,tc.track(it).y);
tc.track(it).quadrant(1).b=tc.rhoa*exp(1)*tc.track(it).vmax_rel^2/tc.track(it).pdrop;
tc.track(it).quadrant(1).a=tc.track(it).rmax^tc.track(it).quadrant(1).b;

%%
function [afit,bfit,pfit]=fit_winds(rr,vv,varargin)

pfit=[];

vmax=[];
pdrop=[];
rhoa=1.15;
wgt=[];

% Set search ranges
aa=0:5:500;     % Holland A
bb=0.5:0.05:3;    % Holland B
pp=0:200:12000;  % Pressure drop

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'vmax'}
                vmax=varargin{ii+1};
            case{'rhoa','rhoair'}
                rhoa=varargin{ii+1};
            case{'pdrop'}
                pdrop=varargin{ii+1};
            case{'weights'}
                wgt=varargin{ii+1};
        end
    end
end

if isempty(wgt)
    % Set all weights the same
    wgt=zeros(length(rr),1)+1;
end

if isempty(pdrop)
    [aaa,bbb,ppp]=meshgrid(aa,bb,pp);
else
    [aaa,bbb]=meshgrid(aa,bb);
    ppp=pdrop;
end
meanerr2=zeros(size(aaa));
nr=length(rr);

for ir=1:nr
    vc  = sqrt(aaa.*bbb.*ppp.*exp(-aaa./rr(ir).^bbb)./(rhoa*rr(ir).^bbb));
    err2 = (vc-vv(ir)).^2;
    meanerr2=meanerr2+err2*wgt(ir);
end

% Compute RMSE of all radii
if ~isempty(vmax)
    % Also take into account Vmax error
    vmaxr = sqrt(bbb.*ppp./(rhoa*exp(1)));
    err2  = (vmaxr - vmax).^2;
    wgt(end+1)=wgt(end);
    meanerr2=meanerr2+err2*wgt(end);
end
meanerr2=meanerr2/(sum(wgt));
rmse=sqrt(meanerr2);

% And now find the minimum RMSE

if isempty(pdrop)
    ind=find(rmse==min(min(min(rmse))));
    [ib,ia,ip]=ind2sub(size(rmse),ind);
    afit=aa(ia);
    bfit=bb(ib);
    pfit=pp(ip);
else
    ind=find(rmse==min(min(rmse)));
    [ib,ia]=ind2sub(size(rmse),ind);
    afit=aa(ia);
    bfit=bb(ib);
end

% try
% rrr=1:300;
% if isempty(pfit)
% vvv  = sqrt(afit.*bfit.*pdrop.*exp(-afit./rrr.^bfit)./(rhoa*rrr.^bfit));
% else
% vvv  = sqrt(afit.*bfit.*pfit.*exp(-afit./rrr.^bfit)./(rhoa*rrr.^bfit));
% end
% figure(20)
% plot(rrr,vvv);hold on
% plot(rr,vv,'o');
% catch
%     shite=1
% end