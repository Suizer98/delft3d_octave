function [tc,spw]=wes4(trackinput,format,spwinput,outputfile,varargin)

% The tc structure contains ONLY information about the track.
% The spw structure contains info of the spiderweb grid (radius, nr bins,
% etc.) as well as the methods (spiralling angle, WPRs etc.) to create the
% wind field.

% Note:
% Input wind in knots -> can, assumed 1 minute-averaged
% Input wind in m/s will not be converted + assumed to be 10 minute-averaged

%% 1) Read in track data (time, lat, lon, vmax, rmax etc.)
tc=wes_read_track_data(trackinput,format);

%% 2) Read spiderweb data (rhoa, phi_spiral, methods, etc.)
spw=wes_read_spw_input(spwinput,tc);

%% 3) Convert units in track to km and m/s
tc=wes_convert_units(tc,spw);

%% 4) Cut off track points with low wind speeds at beginning and end of track
tc=wes_cut_off_low_wind_speeds(tc,spw);

%% 5) Determine forward speed vtx and vty and relative speeds at the different radii in the quadrants
tc=wes_compute_forward_speed(tc,spw);

%% 6) Land decay
tc=wes_land_decay(tc,spw);

%% 7) Estimate missing values for Vmax, Pc, Rmax and R35
tc=wes_estimate_missing_values(tc,spw);

%% 8) Compute relative Vmax
tc=wes_compute_relative_wind_speeds(tc,spw);
    
%% 9) Create (finally) the spiderweb winds
[tc,r]=wes_compute_spiderweb_winds_and_pressure(tc,spw,spwinput);

%% 10. Determine rainfall if requested
[tc,spw,include_precip]=wes_compute_rainfall(tc,spw,r);


%% 11. Write spiderweb
if ~isfield(spw,'merge_frac')
    spw.merge_frac=[];
end
if ~isfield(spw,'tdummy')
    spw.tdummy=[];
end

if ~isempty(outputfile)
    
    % Coordinate system
    switch lower(spw.cs.type(1:3))
        case{'geo'}
            gridunit='degree';
        otherwise
            gridunit='m';
    end      
    
    % Write spiderweb
    write_spiderweb_file_delft3d(outputfile, tc, gridunit, spw.reference_time, spw.radius, 'merge_frac',spw.merge_frac,'tdummy',spw.tdummy,'include_precipitation',include_precip);
end

%% 1) Read the track data
function tc=wes_read_track_data(tc,format)

switch lower(format)
    case{'tcstructure'}
        
        % First convert to wes structure        
        trackinput=tc.track;
        tc=rmfield(tc,'track');
        
        % Set dummy values
        for it=1:length(trackinput.time)
            tc.track(it).time=0;
            tc.track(it).x=0;
            tc.track(it).y=0;
            tc.track(it).vmax=0;
            tc.track(it).pc=-999;
            tc.track(it).rmax=-999;
            tc.track(it).r35ne=-999;
            tc.track(it).r35se=-999;
            tc.track(it).r35sw=-999;
            tc.track(it).r35nw=-999;
            tc.track(it).r50ne=-999;
            tc.track(it).r50se=-999;
            tc.track(it).r50sw=-999;
            tc.track(it).r50nw=-999;
            tc.track(it).r65ne=-999;
            tc.track(it).r65se=-999;
            tc.track(it).r65sw=-999;
            tc.track(it).r65nw=-999;
            tc.track(it).r100ne=-999;
            tc.track(it).r100se=-999;
            tc.track(it).r100sw=-999;
            tc.track(it).r100nw=-999;
        end
        
        for it=1:length(trackinput.time)
            tc.track(it).time=trackinput.time(it);
            tc.track(it).x=trackinput.x(it);
            tc.track(it).y=trackinput.y(it);
            tc.track(it).vmax=trackinput.vmax(it);
            if isfield(trackinput,'pc')
                tc.track(it).pc=trackinput.pc(it);
            end
            if isfield(trackinput,'rmax')
                tc.track(it).rmax=trackinput.rmax(it);
            end
            if isfield(trackinput,'r35ne')
                tc.track(it).quadrant(1).radius(1)=trackinput.r35ne(it);
            end
            if isfield(trackinput,'r35se')
                tc.track(it).quadrant(2).radius(1)=trackinput.r35se(it);
            end
            if isfield(trackinput,'r35sw')
                tc.track(it).quadrant(3).radius(1)=trackinput.r35sw(it);
            end
            if isfield(trackinput,'r35nw')
                tc.track(it).quadrant(4).radius(1)=trackinput.r35nw(it);
            end
            if isfield(trackinput,'r50ne')
                tc.track(it).quadrant(1).radius(2)=trackinput.r50ne(it);
            end
            if isfield(trackinput,'r50se')
                tc.track(it).quadrant(2).radius(2)=trackinput.r50se(it);
            end
            if isfield(trackinput,'r50sw')
                tc.track(it).quadrant(3).radius(2)=trackinput.r50sw(it);
            end
            if isfield(trackinput,'r50nw')
                tc.track(it).quadrant(4).radius(2)=trackinput.r50nw(it);
            end
            if isfield(trackinput,'r65ne')
                tc.track(it).quadrant(1).radius(3)=trackinput.r65ne(it);
            end
            if isfield(trackinput,'r65se')
                tc.track(it).quadrant(2).radius(3)=trackinput.r65se(it);
            end
            if isfield(trackinput,'r65sw')
                tc.track(it).quadrant(3).radius(3)=trackinput.r65sw(it);
            end
            if isfield(trackinput,'r65nw')
                tc.track(it).quadrant(4).radius(3)=trackinput.r65nw(it);
            end
            if isfield(trackinput,'r100ne')
                tc.track(it).quadrant(1).radius(4)=trackinput.r100ne(it);
            end
            if isfield(trackinput,'r100se')
                tc.track(it).quadrant(2).radius(4)=trackinput.r100se(it);
            end
            if isfield(trackinput,'r100sw')
                tc.track(it).quadrant(3).radius(4)=trackinput.r100sw(it);
            end
            if isfield(trackinput,'r100nw')
                tc.track(it).quadrant(4).radius(4)=trackinput.r100nw(it);
            end
        end
        
        % Replace -999 with NaN
        for it=1:length(tc.track)
            tc.track(it).vmax(tc.track(it).vmax==-999)=NaN;
            tc.track(it).pc(tc.track(it).pc==-999)=NaN;
            tc.track(it).rmax(tc.track(it).rmax==-999)=NaN;
            if isfield(tc.track(it),'quadrant')
                for iq = 1:length(tc.track(it).quadrant)
                    tc.track(it).quadrant(iq).radius(tc.track(it).quadrant(iq).radius==-999)=NaN;
                end
            else
                tc.track(it).quadrant=[];
            end
        end
    case{'jmv30'}
        tc=readjmv30_02(tc);
    case{'jtwc_best_track'}
        tc=read_jtwc_best_track(tc);
end

%% 2) Read the spiderweb
function spw=wes_read_spw_input(spwinput,tc)
if isstruct(spwinput)
    spw=spwinput;
else
    % Read spw input file
end

if ~isfield(spw,'wind_profile')
    spw.wind_profile='holland2010';
end
if ~isfield(spw,'wind_pressure_relation')
    spw.wind_pressure_relation='holland2008';
end
if ~isfield(spw,'rmax_relation')
    spw.rmax_relation='nederhoff2019';
end

spw.use_relative_speed=1;

% Add stuff to tc structure
if ~isfield(spw,'rhoa')
    spw.rhoa=1.15;
end
if ~isfield(spw,'phi_spiral')
    spw.phi_spiral=15;
end
if ~isfield(spw,'cs')
    spw.cs.name='WGS 84';
    spw.cs.type='geographic';
end

% Asymmetry (use Schwedt 1979 as default
if ~isfield(spw,'asymmetry_option')
    spw.asymmetry_option='mvo';
end

% switch lower(spw.asymmetry_option) % To be adjusted, this has nothing to do with asymmetry
%     case{'schwerdt1979'}
%         spw.phi_spiral=15;
%     case{'jma'}
%         spw.phi_spiral=30;
% end

if ~isfield(spw,'reference_time')
    spw.reference_time=tc.track(1).time;
end

%% 3) Cut off track points with low wind speeds at beginning and end of track
function tc=wes_cut_off_low_wind_speeds(tc,spw)

% Cut off parts of track that have a wind speed lower than 30 kts (15 m/s)
if isfield(spw,'cut_off_speed')
    if spw.cut_off_speed  > 0
        
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
    end
end

%% 4) Convert units
function tc=wes_convert_units(tc,spw)

% Convert units
kts2ms=0.514;
nm2km=1.852;
nt=length(tc.track);

% Convert wind speeds to m/s
switch lower(tc.wind_speed_unit)
    case{'kts','kt','knots','knts'}
        tc.radius_velocity=tc.radius_velocity*kts2ms*spw.wind_conversion_factor;    % Convert to m/s
        for it=1:nt
            tc.track(it).vmax=tc.track(it).vmax*kts2ms*spw.wind_conversion_factor;  % Convert to m/s
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

%% 5) Determine forward speed vtx and vty and relative speeds at the different radii in the quadrants
function tc=wes_compute_forward_speed(tc,spw)

% Computes forward motion (in m/s) and wind speeds relative to storm motion  
nt=length(tc.track);

for it=1:nt
    geofacx=1;
    geofacy=1;
    switch lower(spw.cs.type(1:3))
        case{'geo','lat'}
            geofacy=111111;
            geofacx=geofacy*cos(tc.track(it).y*pi/180);
    end
    if it==1
        dt=86400*(tc.track(2).time-tc.track(1).time);
        dx=(tc.track(2).x-tc.track(1).x)*geofacx;
        dy=(tc.track(2).y-tc.track(1).y)*geofacy;
    elseif it==nt
        dt=86400*(tc.track(end).time-tc.track(end-1).time);
        dx=(tc.track(end).x-tc.track(end-1).x)*geofacx;
        dy=(tc.track(end).y-tc.track(end-1).y)*geofacy;
    else
        dt=86400*(tc.track(it+1).time-tc.track(it-1).time);
        dx=(tc.track(it+1).x-tc.track(it-1).x)*geofacx;
        dy=(tc.track(it+1).y-tc.track(it-1).y)*geofacy;
    end
    ux=dx/dt;
    uy=dy/dt;
    
    if ux==0 && uy ==0
       error(['ux or uy became 0, timesteps it+1 and it-1 have exactly the same coordinate for it= ',num2str(it)]) 
    end
    
    tc.track(it).vtx=ux;
    tc.track(it).vty=uy;
end

if length(tc.track)>2
    for it2=2:length(tc.track)-1
        tc.track(it2).dpcdt=(tc.track(it2+1).pc-tc.track(it2-1).pc)/(24*(tc.track(it2+1).time-tc.track(it2-1).time));
    end
    tc.track(1).dpcdt=tc.track(2).dpcdt;
    tc.track(end).dpcdt=tc.track(end-1).dpcdt;
else
    tc.track(1).dpcdt=(tc.track(2).pc-tc.track(1).pc)/(24*(tc.track(2).time-tc.track(1).time));
    tc.track(2).dpcdt=(tc.track(2).pc-tc.track(1).pc)/(24*(tc.track(2).time-tc.track(1).time));
end

%% 6) Land decay
function tc=wes_land_decay(tc,spw)

if ~isfield(spw,'xland')
    return
end
if isempty(spw.xland)
    return
end
xland=spw.xland; % Land polygon
yland=spw.yland; % Land polygon

rs=110000;

vb=26.7;      % knots!
alfa=0.095;   % 1/h
kts2ms=0.514;

% Convert structure to vector arrays
fldnames=fieldnames(tc.track);
for ifld=1:length(fldnames)
    for it=1:length(tc.track)
        fldname=fldnames{ifld};
        if ~strcmpi(fldname,'quadrant')
            track.(fldname)(it)=tc.track(it).(fldname);
        end
    end
        if ~strcmpi(fldname,'quadrant')
        track.(fldname)(track.(fldname)==-999)=NaN;
        end
end

tt=track.time(1):1/24:track.time(end);
xt=interp1(track.time,track.x,tt);
yt=interp1(track.time,track.y,tt);

ilandsea=zeros(1,length(tt));
for it=1:length(tt)
    xx=xt(it)-rs:5000:xt(it)+rs;
    yy=yt(it)-rs:5000:yt(it)+rs;
    [xg,yg]=meshgrid(xx,yy);
    xg=reshape(xg,[1 size(xg,1)*size(xg,2)]);
    yg=reshape(yg,[1 size(yg,1)*size(yg,2)]);
    dst=sqrt((xg-xt(it)).^2 + (yg-yt(it)).^2);
    xg=xg(dst<rs);
    yg=yg(dst<rs);
    ninp=sum(inpolygon(xg,yg,xland,yland));
    if ninp==0
        % Storm completely over water
        F(it)=0.0;
        ilandsea(it)=0;        
    else    
        F(it)=ninp/length(xg); % Percentage of storm over land
        ilandsea(it)=1;        
    end    
end

% Simplification!!! Assume just one landfall
it1=find(ilandsea==0,1,'last'); % time index when storm was last over the sea
it2=find(F==1,1,'first');       % time index when storm is completely over land

itlast  = find(track.time<tt(it1)); % last index in original track when storm was completely over sea 
itfirst = find(track.time>tt(it2)); % first index in original track when storm is completely over land

% Now interpolate original storm properties to hourly data
tt=tt(it1:it2);
F=F(it1:it2);
for ifld=1:length(fldnames)
    fldname=fldnames{ifld};
    if ~strcmpi(fldname,'quadrant')
        track1.(fldname)=interp1(track.time,track.(fldname),tt);
    end
end
track1.vmax=track1.vmax/kts2ms;   % convert to knots
track1.vmax=track1.vmax/0.9;      % 1 min sustained winds
vmax(1)=track1.vmax(1);
for it=2:length(tt)
    vmax(it) = vb + (vmax(it-1) - vb)*exp(-F(it)*alfa); 
end
track1.vmax=vmax*kts2ms*0.9;

track.vmax(itfirst:end)=track1.vmax(end);
for ifld=1:length(fldnames)
    fldname=fldnames{ifld};
    if ~strcmpi(fldname,'quadrant')
        track.(fldname)=[track.(fldname)(1:itlast) track1.(fldname) track.(fldname)(itfirst:end)];
    end
end

% And store data back in original track structure
for ifld=1:length(fldnames)
    fldname=fldnames{ifld};
    if ~strcmpi(fldname,'quadrant')
%        track.(fldname)(isnan(track.(fldname)))=-999;
        for it=1:length(track.time)
            tc.track(it).(fldname)=track.(fldname)(it);
        end
    end
end



%% 7) Estimate missing values for Vmax, Pc and Rmax
function tc=wes_estimate_missing_values(tc,spw)

% Estimate missing values for Vmax, Pc and Rmax
for it=1:length(tc.track)

    use_vmax=0;
    use_pc=0;
    use_rmax=0;
    use_r35=0;
    % Determine which parameters are required
    switch lower(spw.wind_profile)
        case{'holland1980','holland2010'}
            use_vmax=1;
            use_pc=1;
            use_rmax=1;
            use_r35=spw.r35estimate;
        case{'fujita1952'}
            use_pc=1;
            use_rmax=1; % We actually need R0, not Rmax!!!
    end
    
    % Vmax
    if use_vmax
        if isnan(tc.track(it).vmax)
            switch lower(spw.wind_pressure_relation)
                case{'holland2008'}
                    vt=sqrt(tc.track(it).vtx^2+tc.track(it).vty^2);
                    tc.track(it).vmax=wpr_holland2008('pc',tc.track(it).pc,'pn',spw.pn,'lat',tc.track(it).y,'dpcdt',tc.track(it).dpcdt,'vt',vt,'rhoa',spw.rhoa);
                case{'kz2007'}
                    % TODO
                case{'vatvani'}
                    % pd=2*v^2
                    pd=100*(spw.pn-tc.track(it).pc);
                    tc.track(it).vmax=sqrt(0.5*pd);
            end
        end
    end
    
    % Pc
    if use_pc
        if isnan(tc.track(it).pc)
            switch lower(spw.wind_pressure_relation)
                case{'holland2008'}
                    % Problem: pc not given, so dpcdt not known. Let's try to
                    % estimate it first.
                    for it2=1:length(tc.track)
                        vt=sqrt(tc.track(it2).vtx^2+tc.track(it2).vty^2);
                        if strcmpi(tc.cs.type,'geographic')
                            lat=tc.track(it2).y;
                        else
                            if isfield(tc,'latitude')
                                lat=tc.latitude;
                            else
                                lat=20;
                            end
                        end
                        pc(it2)=wpr_holland2008('vmax',tc.track(it2).vmax,'pn',spw.pn,'lat',lat,'dpcdt',0,'vt',vt,'rhoa',spw.rhoa);
                    end
                    dpcdt=zeros(size(pc));
                    for it2=2:length(tc.track)-2
                        dpcdt(it)=(pc(it2+1)-pc(it2-1))/(24*(tc.track(it2+1).time-tc.track(it2-1).time));
                    end
                    dpcdt(1)=dpcdt(2);
                    dpcdt(end)=dpcdt(end-1);
                    % And now compute pc for real
                    vt=sqrt(tc.track(it).vtx^2+tc.track(it).vty^2);
                    if strcmpi(tc.cs.type,'geographic')
                        lat=tc.track(it2).y;
                    else
                        if isfield(tc,'latitude')
                            lat=tc.latitude;
                        else
                            lat=20;
                        end
                    end
                    tc.track(it).pc=wpr_holland2008('vmax',tc.track(it).vmax,'pn',spw.pn,'lat',lat,'dpcdt',dpcdt(it),'vt',vt,'rhoa',spw.rhoa);
                case{'vatvani'}
                    % pd=2*v^2
                    tc.track(it).pc=spw.pn-0.01*2*tc.track(it).vmax_rel^2;
            end
        end
    end

    % Radius of maximum winds (Rmax)
    if use_rmax
        if isnan(tc.track(it).rmax)
            switch lower(spw.rmax_relation)
                case{'gross2004'}
                    tc.track(it).rmax       = rmax_gross2004(tc.track(it).vmax,tc.track(it).y);
                case{'25nm'}
                    tc.track(it).rmax       = 25*1.852;
                case{'pagasajma'}
                    tc.track(it).rmax       = rmax_jma_pagasa(tc.track(it).pc);
                case{'nederhoff2019'}
                    [rmax,dr35]             = wind_radii_nederhoff(tc.track(it).vmax,tc.track(it).y,7, 0);  
                    [tc.track(it).rmax]     = rmax.mode;
            end
        end
    end
    
    % Radius of gale force winds (R35)
    if use_r35 
        if tc.track(it).vmax > 20   % if gale force winds (note 20 m/s not kn/s)
            if isnan(tc.track(it).quadrant(1).radius(1)) && isnan(tc.track(it).quadrant(2).radius(1)) && isnan(tc.track(it).quadrant(3).radius(1)) && isnan(tc.track(it).quadrant(4).radius(1))
                [rmax,dr35]                            = wind_radii_nederhoff(tc.track(it).vmax,tc.track(it).y,7, 0);
                tc.track(it).quadrant(1).radius(1)     = rmax.mode + dr35.mode;
                tc.track(it).quadrant(2).radius(1)     = rmax.mode + dr35.mode;
                tc.track(it).quadrant(3).radius(1)     = rmax.mode + dr35.mode;
                tc.track(it).quadrant(4).radius(1)     = rmax.mode + dr35.mode;
            end
        end
    end

end    

%% 8) Compute relative Vmax
function tc=wes_compute_relative_wind_speeds(tc,spw)

% Computes forward motion (in m/s) and wind speeds relative to storm motion  
nt=length(tc.track);

for it=1:nt
           
    % Compute max wind speed relative to propagation speed
    u_prop=tc.track(it).vtx;
    v_prop=tc.track(it).vty;
    
    % Different relations
    if strcmpi(spw.rmax_relation,'pagasajma')
        spw.asymmetry_option='mvo';
    end
     
    % Different options
    switch lower(spw.asymmetry_option)
        case{'schwerdt1979'}
            
            % Use Schwerdt (1979) to compute u_prop and v_prop
            uabs=sqrt(u_prop^2+v_prop^2);
            c=uabs*1.944; % Convert to kts
            a=1.5*c^0.63; % Schwerdt (1979)
            a=a/1.944;    % Convert to m/s
            u_prop=a*u_prop/uabs;
            v_prop=a*v_prop/uabs;
        case{'jma'}
            c2=0.57143;
            u_prop=c2*ux;
            v_prop=c2*uy;
        case{'mvo'}
            c2=0.6;
            u_prop=c2*u_prop;
            v_prop=c2*u_prop;
        case{'none'}
            u_prop=0.0;
            v_prop=0.0;
    end
    tc.track(it).vmax_rel=tc.track(it).vmax-sqrt(u_prop^2+v_prop^2);
    
    % And now compute relative speed for radii
    % First find directions of maximum wind speed in each quadrant
    angles0b{1}=90:10:180;    % NE
    angles0b{2}=0:10:90;      % SE
    angles0b{3}=270:10:360;   % SW
    angles0b{4}=180:10:270;   % NW
    for iq=1:4
        if tc.track(it).y>0
            anglesb{iq}=angles0b{iq}+spw.phi_spiral;        % Include spiralling effect
        else
            anglesb{iq}=angles0b{iq}-spw.phi_spiral;        % Include spiralling effect
        end
        anglesb{iq}=anglesb{iq}*pi/180;                     % Convert to radians
    end    
    for iq=1:length(tc.track(it).quadrant)
        uabs=tc.radius_velocity(1)*cos(anglesb{iq});
        vabs=tc.radius_velocity(1)*sin(anglesb{iq});
        uabs=uabs+u_prop;
        vabs=vabs+v_prop;
        abs_speed=sqrt(uabs.^2+vabs.^2);
        imax=find(abs_speed==max(abs_speed));
        imax=imax(1);
        angles(iq)=angles0b{iq}(imax)*pi/180;                    % This is the angle where the maximum winds are blowing to in each quadrant (cartesian, radians)
    end
    
    % Compute relative speed of all quadrants and radii
    for iq=1:length(tc.track(it).quadrant)
        for irad=1:length(tc.track(it).quadrant(iq).radius)
            if ~isnan(tc.track(it).quadrant(iq).radius(irad))
                uabs=tc.radius_velocity(irad)*cos(angles(iq));
                vabs=tc.radius_velocity(irad)*sin(angles(iq));
%                 efold=exp(-pi*tc.track(it).quadrant(iq).radius(irad)/500.0);
%                 urel=uabs-u_prop*efold;
%                 vrel=vabs-v_prop*efold;
%                efold=exp(-pi*tc.track(it).quadrant(iq).radius(irad)/500.0);
                urel=uabs-u_prop;
                vrel=vabs-v_prop;
                tc.track(it).quadrant(iq).relative_speed(irad)=sqrt(urel^2+vrel^2);
            else
                tc.track(it).quadrant(iq).relative_speed(irad)=NaN;
            end
        end
    end
    
end

% % tc.track(it).dpcdt=zeros(size(pc));
% for it2=2:length(tc.track)-1
%     tc.track(it2).dpcdt=(tc.track(it2+1).pc-tc.track(it2-1).pc)/(24*(tc.track(it2+1).time-tc.track(it2-1).time));
% end
% tc.track(1).dpcdt=tc.track(2).dpcdt;
% tc.track(end).dpcdt=tc.track(end-1).dpcdt;

%% 9) Create (finally) the spiderweb winds
function [tc,r]=wes_compute_spiderweb_winds_and_pressure(tc,spw,spwinput)

dx=spw.radius/spw.nr_radial_bins;
r=dx:dx:spw.radius;
r=r/1000; % km
dphi=360.0/spw.nr_directional_bins;
phi=90:-dphi:-270+dphi;

errs=[];

for it=1:length(tc.track)
    
    % A) Get values from tc and spw
    dp     = spw.pn - tc.track(it).pc;
    vrel   = tc.track(it).vmax_rel;
    pc     = tc.track(it).pc;
    rmax   = tc.track(it).rmax;
    pn	   = spw.pn;
    rhoa   = spw.rhoa;
    xn     = 0.5;
    lat    = abs(tc.track(it).y);
    vt     = (tc.track(it).vtx.^2 + tc.track(it).vty.^2).^0.5;
    phit   = atan2(tc.track(it).vty,tc.track(it).vtx)*180/pi;
    ux     = tc.track(it).vtx;
    uy     = tc.track(it).vty;
    
    % Initialize arrays
    wind_speed=zeros(length(phi),length(r));
    wind_to_direction_cart=zeros(length(phi),length(r));
    pressure_drop=zeros(length(phi),length(r));
    
    % First compute wind speeds relative to forward motion of the cyclone
    % Two options: either directionally uniform, or using R34, R50, R64, R100 
    unidir=0;
    for iq=1:length(tc.track(it).quadrant)
        n=0;
        for j=1:length(tc.track(it).quadrant(iq).radius)
            if ~isnan(tc.track(it).quadrant(iq).radius(j))
                n=n+1;
            end
        end
        if n==0
            unidir=1;
        end
    end
    
    % C) Holland (2008) related
    % If not known than we assume NOT Holland (2008) values
    if isfield(spwinput, 'holland2008')
        spw.holland2008 = spwinput.holland2008;
    else
        spw.holland2008 = 0;
    end
    
    % D) Holland 2010 related: find fit for xn and asymmetry vector
    if strcmpi(spw.wind_profile,'holland2010')
        % Some default values (will be overwritten when there is quadrant data)
        if spw.holland2008 == 1
            xn  = 0.6*(1-dp/215);
        end
        vtcor = 0.6*vt;        
        if ~unidir
            obs.quadrant=tc.track(it).quadrant;
            wrad=tc.radius_velocity;
            [xn,vtcor,phia]=fit_wind_field_holland2010(tc.track(it).vmax,tc.track(it).rmax,tc.track(it).pc,vt,phit,pn,spw.phi_spiral,lat,tc.track(it).dpcdt,obs,wrad);
            ux=vtcor*cos((phit+phia)*pi/180);
            uy=vtcor*sin((phit+phia)*pi/180);
        end
    end
    
    % E). Modified rankine
    xopt=[];
    aopt=[];
    theta0opt=[];
    if ~unidir && strcmpi(spw.wind_profile,'modifiedrankinevortex')
        robs=[];
        vobs=[];
        tobs=[];
        n=0;
        theta0=[45 135 225 315];
        for iq=1:length(tc.track(it).quadrant)
            for j=1:4 % Only use R34 and R50
                if ~isnan(tc.track(it).quadrant(iq).radius(j))
                    n=n+1;
                    robs(n)=tc.track(it).quadrant(iq).radius(j);
                    vobs(n)=tc.track(it).quadrant(iq).relative_speed(j);
                    tobs(n)=theta0(iq);
                end
            end
        end
        [xopt,aopt,theta0opt]=fit_modified_rankine_vortex(tc.track(it).vmax,rmax,robs,tobs,vobs);
    end
        
    % F) Different wind profiles
    switch spw.wind_profile
        case{'holland1980'}
            [vr,pr]=holland1980(r,pn,pc,vrel,rmax,'rhoa',rhoa);
        case{'holland2010'}
            vms     = tc.track(it).vmax - vtcor;
            pc      = tc.track(it).pc;
            rmax    = tc.track(it).rmax;
            dpdt    = tc.track(it).dpcdt;
            [vr,pr] = holland2010_v02(r,vms,pc,pn,rmax,dpdt,lat,vt,xn);
        case{'fujita1952'}
            r0=rmax; % Should adjust here to r0!!!
            c1=0.7;
            [vr,pr]=fujita(r,pn,pc,r0,abs(lat),c1,'rhoa',rhoa);
        case{'modifiedrankinevortex'}
            % Pr from Holland (1980), Vr ma be overwritten if observations
            % are available
            [vr,pr]=holland1980(r,pn,pc,vrel,rmax,'rhoa',rhoa);            
    end
    
    pd=pn-pr;
    
    % F) Some standard stuff
    for iphi=1:length(phi)
         
        switch spw.wind_profile
            case{'modifiedrankinevortex'}
                if ~isempty(xopt)
                    vr=modified_rankine_vortex(r,phi(iphi)*pi/180,tc.track(it).vmax,rmax,xopt,aopt,theta0opt);            
                end
        end
        
        wind_speed(iphi,:) = vr;
        if strcmpi(spw.cs.type,'geographic')
            lat=tc.track(it).y;
        else
            if isfield(tc,'latitude')
                lat=tc.latitude;
            else
                lat=20;
            end
        end
        
        if lat>=0.0
            % Northern hemisphere
            dr=90+phi(iphi)+spw.phi_spiral;
        else
            % Southern hemisphere
            dr=-90+phi(iphi)-spw.phi_spiral;
        end
        wind_to_direction_cart(iphi,:)=dr;
        pressure_drop(iphi,:) = pd*100;     % convert from hPa to Pa
    end

    % G. Asymmetry
    switch lower(spw.asymmetry_option)
        case{'schwerdt1979'}
            % Use Schwerdt (1979) to compute u_prop and v_prop
            uabs=sqrt(ux^2+uy^2);
            c=uabs*1.944;   % Convert to kts
            a=1.5*c^0.63;   % Schwerdt (1979)
            a=a/1.944;      % Convert to m/s
            ux=a*ux/uabs;
            uy=a*uy/uabs;
        case{'jma'}
            % Decrease with e-folding scale from eye
            c2=0.57143;
            efold=exp(-pi*r/500.0);
            efold=repmat(efold,[spw.nr_directional_bins 1]);
            ux=c2*ux*efold;
            uy=c2*uy*efold;
        case{'mvo'}
            % Let factor increase from 0 to rmax, and then keep it constant
            if ~unidir && strcmpi(spw.wind_profile,'holland2010')
                % Use wind vector from Holland (2010) fit without correction
                c2=1.0;
            else
                c2=0.6;
            end
            ff=[0 c2 c2];
            rr=[0 rmax 5000];
            f=interp1(rr,ff,r);
            f=repmat(f,[spw.nr_directional_bins 1]);
            ux=c2*ux*f;
            uy=c2*uy*f;
        case{'none'}
            ux=0.0;
            uy=0.0;
    end
    vx=wind_speed.*cos(wind_to_direction_cart*pi/180)+ux;
    vy=wind_speed.*sin(wind_to_direction_cart*pi/180)+uy;

    % H. Save all values
    dr=atan2(vy,vx);
    dr=1.5*pi-dr;
    wind_speed=sqrt(vx.^2 + vy.^2);
    wind_from_direction=180*dr/pi;
    wind_from_direction=mod(wind_from_direction,360);
       
    tc.track(it).wind_speed=wind_speed;
    tc.track(it).wind_from_direction=wind_from_direction;
    if isfield(spw,'include_pdrop')
        if ~spw.include_pdrop
            pressure_drop=zeros(size(pressure_drop));
        end
    end
    tc.track(it).pressure_drop  	= pressure_drop;
    tc.track(it).pressure           = spw.pn-pressure_drop/100;
    tc.track(it).wind_speed_plain   = wind_speed(1,:);

end

%% 10) Compute rainfall rate when requested
function [tc,spw,include_precip]=wes_compute_rainfall(tc,spw,r)
if ~isfield(spw,'cut_off_rain')
    spw.cut_off_rain = 0; % mm/hr
end

% Rainfall
include_precip=0;
if spw.rainfall>0

    % Rainfall is included
    include_precip=1;

    %% set defaults for the different options

    rain_info.asymmetrical = 0; %asymmetrical = 0 is no asymmetry, asymmetrical = 1 is asymmetry depending on rainfall relation (not tested yet for BaCla)
    rain_info.random = 0; %random = 1 is mode, random = 1 is stochastic, random = 2 is user specified percentile for BaC
    rain_info.perc = 50;    % default percentile value requested for rain_relation '..._percentile'
    
    % BaCla: (for more info see rain_radii_bacla.m)
    rain_info.bacla.data = 2;     % Stage IV blend data trained model
    rain_info.bacla.split = 4;    % xn forced to get pmax fit, bs based on area under graph
    rain_info.bacla.type = 1;     % vmax based model
    rain_info.bacla.loc = 2;      % land fit (constant pmax till rmax as in IPET, after rmax classic holland fit)
    rain_info.bacla.perc = rain_info.perc;
    
    % in case supplied:
    if isfield(spw,'rain_info') 
        rain_info = spw.rain_info; % use when provided
    end
    
    asymmetrical = rain_info.asymmetrical;
    random = rain_info.random;

    spw.rain_info = rain_info; % save back final settings
    spw.rain_info.rain_relation = spw.rain_relation;
    
    % Loop over track
    randomID = [];
    for it=1:length(tc.track)

        %% Rainfall relation            
        % Use Daan Bader (MSc thesis 2019 copula's):
        if strcmpi(spw.rain_relation(1:4), 'bade')            
            
            % Bader (2019) for pmax and pr
            [pmax_out,pr]               = rain_radii_bader(tc.track(it).vmax, tc.track(it).rmax, r, random, rain_info);

        % Use Judith Claassen (MSc thesis 2021 copula's):
        elseif strcmpi(spw.rain_relation(1:4), 'bacl')  

            % BaCla (2021) for pmax and pr, either vmax or pressure deficit based
            if rain_info.bacla.type == 1 %vmax
                [pmax_out,pr]               = rain_radii_bacla(tc.track(it).vmax, tc.track(it).rmax, r, random, rain_info.bacla);
            elseif rain_info.bacla.type == 2 %pressure deficit
                pdeftmp                     = spw.pn - tc.track(it).pc; %determine pdef first
                [pmax_out,pr]               = rain_radii_bacla(pdeftmp, tc.track(it).rmax, r, random, rain_info.bacla);                   
            end

        % Use IPET parametric rainfall model:
        elseif strcmpi(spw.rain_relation(1:4), 'ipet') 

            rmaxtmp = tc.track(it).rmax;
            pdeftmp = spw.pn - tc.track(it).pc;

            [pr] = rain_radii_ipet(pdeftmp, rmaxtmp, r);

        % Use old default:
        else              
            rs=repmat(r,[spw.nr_directional_bins 1]);
            R0=spw.rainfall; % mm/h
            Rm=spw.rainfall; % mm/h
            rm=50;  % km
            re=250;
            val0=R0+(Rm-R0).*(rs/rm);
            val1=Rm*exp(-(rs-rm)/re);
            pr=val0;
            pr(rs>rm)=val1(rs>rm);
            
%             for it=1:length(tc.track)
%                 tc.track(it).precipitation=pr;
%                 csold.name='WGS 84';
%                 csold.type='geographic';
%                 csnew.name='WGS 84 / UTM zone 17N';
%                 csnew.type='projected';
%                 x0=tc.track(it).x;
%                 y0=tc.track(it).y;
%                 [x1,y1]=ddb_coordConvert(x0,y0,csold,csnew); %conversion still needed somewhere?
%                 tc.track(it).x=x1;
%                 tc.track(it).y=y1;
%             end                            
            
        end
        
        %% Random pmax?
        if strcmpi(spw.rain_relation(1:4), 'ipet') == true
            pr_chosen = pr;
        else
            if random == 1
                if isempty(randomID)
                    randomID            = randi([1,length(pmax_out)],1,1); % random ID for length of pmax (10,000)
                end
                pr_chosen              = pr(:,randomID)';

            elseif random == 0 || random == 2
                pr_chosen              = pr';
            end            
        end
        
        %% fix NaNs and negative values if occuring
        pr_chosen(pr_chosen < 0) = 0;
        pr_chosen(isnan(pr_chosen)) = 0;

        %% Do cut-off of low precipitation rates (e.g. <10 mm/hr) in whole profile
        if spw.cut_off_rain > 0 % mm/hr            
            ids = pr_chosen < spw.cut_off_rain;
            pr_chosen(ids) = 0; % also possible to add alternative reduction with a certain factor like: pr_choosen(ids)/5;
        end

        %% Symmetrical or asymmetrical pr? > different options per rainfall relation
        if asymmetrical == 0
            tc.track(it).precipitation  = repmat(pr_chosen,spw.nr_directional_bins,1);
            
        elseif asymmetrical == 1 && strcmpi(spw.rain_relation(1:5), 'bader')
            factor                      = tc.track(it).wind_speed./tc.track(it).wind_speed_plain;
            tc.track(it).precipitation  = repmat(pr_chosen,spw.nr_directional_bins,1).* factor;
            
        elseif asymmetrical == 1 && strcmpi(spw.rain_relation(1:5), 'bacla')
            factor                      = tc.track(it).wind_speed./tc.track(it).wind_speed_plain;
            tc.track(it).precipitation  = repmat(pr_chosen,spw.nr_directional_bins,1).* factor;
                        
        elseif asymmetrical == 1 && strcmpi(spw.rain_relation(1:4), 'ipet')
            factor = 1.5; % NE and SE for northern hemisphere, NW and SW for southern hemisphere

            if mean(nanmean([tc.track.y])) >= 0 %northern hemisphere % Quadrant 1 = NE, 2 = SE, 3 = SW, 4 = NW
                idquadrant = 1:(ceil(spw.nr_directional_bins / 4) * 2);
            else
                idquadrant = ((ceil(spw.nr_directional_bins / 4) * 2)+1):spw.nr_directional_bins;
            end
            tc.track(it).precipitation  = repmat(pr_chosen,spw.nr_directional_bins,1);
            tc.track(it).precipitation(idquadrant,:) = tc.track(it).precipitation(idquadrant,:) .* factor;

        end          
    end
end