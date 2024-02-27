function tc=wes3(trackinput,format,spwinput,outputfile,varargin)

% The tc structure contains ONLY information about the track.

% The spw structure contains info of the spiderweb grid (radius, nr bins,
% etc.) as well as the methods (spiralling angle, WPRs etc.) to create the
% wind field.

%% Read in track data (time, lat, lon, vmax, rmax etc.)
tc=wes_read_track_data(trackinput,format);

%% Read spiderweb data (rhoa, phi_spiral, methods, etc.)
spw=wes_read_spw_input(spwinput,tc);

%% Convert units in track to km and m/s
tc=wes_convert_units(tc,spw);

% %% Cut off track points with low wind speeds at beginning and end of track
% tc=wes_cut_off_low_wind_speeds(tc,spw);

%% Determine forward speed vtx and vty and relative speeds at the different radii in the quadrants
tc=wes_compute_forward_speed(tc,spw);

%% Land decay
tc=wes_land_decay(tc,spw);

%% Estimate missing values for Vmax, Pc and Rmax
tc=wes_estimate_missing_values(tc,spw);

%% Compute relative wind speeds
tc=wes_compute_relative_wind_speeds(tc,spw);
    
%% Create spiderweb winds

dx=spw.radius/spw.nr_radial_bins;
r=dx:dx:spw.radius;
r=r/1000; % km
dphi=360.0/spw.nr_directional_bins;
phi=90:-dphi:-270+dphi;

errs=[];

for it=1:length(tc.track)
    
    
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
    
    vrel=tc.track(it).vmax_rel;
    pc=tc.track(it).pc;
    rmax=tc.track(it).rmax;
    pn=spw.pn;
    rhoa=spw.rhoa;
    lat=tc.track(it).y;
    
    xn=0.5;
    rn=150;

    if ~unidir && strcmpi(spw.wind_profile,'holland2010')
        % Try to compute average Xn from the four quadrants
        xn_fit=[NaN NaN NaN NaN];
        iok=0;
        for iq=1:length(tc.track(it).quadrant)
            robs=[];
            vobs=[];
            n=0;
            for j=1:2 % Only use R34 and R50
                if ~isnan(tc.track(it).quadrant(iq).radius(j))
                    n=n+1;
                    robs(n)=tc.track(it).quadrant(iq).radius(j);
                    vobs(n)=tc.track(it).quadrant(iq).relative_speed(j);
                end
            end
            if ~isempty(robs)
                [vr,pr,rn,xn,rmf]=holland2010(robs,vrel,pc,rmax,'pn',pn,'rhoa',rhoa,'robs',robs,'vobs',vobs);
                xn_fit(iq)=xn;
                iok=1;
            end
        end
        if iok
            xn=nanmean(xn_fit);
        end
    end
        
    switch spw.wind_profile
        case{'holland1980'}
            [vr,pr]=holland1980(r,pn,pc,vrel,rmax,'rhoa',rhoa);
        case{'holland2010'}
            [vr,pr]=holland2010(r,vrel,pc,rmax,'pn',pn,'rhoa',rhoa,'xn',xn,'rn',rn);
        case{'fujita1952'}
            r0=rmax; % Should adjust here to r0!!!
            c1=0.7;
            [vr,pr]=fujita(r,pn,pc,r0,abs(lat),c1,'rhoa',rhoa);
    end
    pd=pn-pr;
    
    for iphi=1:length(phi)
        wind_speed(iphi,:) = vr;
        if strcmpi(tc.cs.type,'geographic')
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
        pressure_drop(iphi,:) = pd*100;
    end

    ux=tc.track(it).vtx;
    uy=tc.track(it).vty;    
    switch lower(spw.asymmetry_option)
        case{'schwerdt1979'}
            % Use Schwerdt (1979) to compute u_prop and v_prop
            uabs=sqrt(ux^2+uy^2);
            c=uabs*1.944; % Convert to kts
            a=1.5*c^0.63; % Schwerdt (1979)
            a=a/1.944;    % Convert to m/s
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
            c2=0.6;
            ff=[0 0.6 0.6];
            rr=[0 rmax 5000];
            f=interp1(rr,ff,r);
            f=repmat(f,[spw.nr_directional_bins 1]);
            ux=c2*ux*f;
            uy=c2*uy*f;
        case{'none'}
            ux=0.0;
            uy=0.0;
    end
    
%    vx=wind_speed.*cos(wind_to_direction_cart*pi/180)+tc.track(it).vtx*efold;
%    vy=wind_speed.*sin(wind_to_direction_cart*pi/180)+tc.track(it).vty*efold;
%     vx=wind_speed.*cos(wind_to_direction_cart*pi/180)+tc.track(it).vtx;
%     vy=wind_speed.*sin(wind_to_direction_cart*pi/180)+tc.track(it).vty;
    vx=wind_speed.*cos(wind_to_direction_cart*pi/180)+ux;
    vy=wind_speed.*sin(wind_to_direction_cart*pi/180)+uy;

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
    tc.track(it).pressure_drop=pressure_drop;

%     %% 
%     wndall=wind_speed;
%     wndall(end+1,:)=wndall(end,:);
%     wnd1=wndall(1:10,:);
%     wnd2=wndall(10:19,:);
%     wnd3=wndall(19:28,:);
%     wnd4=wndall(28:37,:);
%     [mxwnd]=max(wnd1,[],2);
%     imx=find(mxwnd==max(mxwnd),1,'first');
%     w1=wnd1(imx,:);
%     [mxwnd]=max(wnd2,[],2);
%     imx=find(mxwnd==max(mxwnd),1,'first');
%     w2=wnd2(imx,:);
%     [mxwnd]=max(wnd3,[],2);
%     imx=find(mxwnd==max(mxwnd),1,'first');
%     w3=wnd3(imx,:);
%     [mxwnd]=max(wnd4,[],2);
%     imx=find(mxwnd==max(mxwnd),1,'first');
%     w4=wnd4(imx,:);
% %     figure(it+20)
% %     clf
% %     subplot(2,2,1)
% %     plot(r,w1);hold on;
% %     plot(tc.track(it).quadrant(1).radius,tc.radius_velocity,'ro');
% %     plot([0 500],[tc.track(it).vmax tc.track(it).vmax],'k--');
% %     plot([tc.track(it).rmax tc.track(it).rmax],[0 100],'k--');
% %     title(datestr(tc.track(it).time))
% %     set(gca,'xlim',[0 250],'ylim',[0 100]);
%     radc=interp1(r,w1,tc.track(it).quadrant(1).radius);
%     err=tc.radius_velocity-radc;
%     errs=[errs err];
%     
% %     subplot(2,2,2)
% %     plot(r,w2);hold on;
% %     plot(tc.track(it).quadrant(2).radius,tc.radius_velocity,'ro');
% %     plot([0 500],[tc.track(it).vmax tc.track(it).vmax],'k--');
% %     plot([tc.track(it).rmax tc.track(it).rmax],[0 100],'k--');
% %     title(datestr(tc.track(it).time))
% %     set(gca,'xlim',[0 250],'ylim',[0 100]);
%     radc=interp1(r,w2,tc.track(it).quadrant(2).radius);
%     err=tc.radius_velocity-radc;
%     errs=[errs err];
%     
% %     subplot(2,2,3)
% %     plot(r,w3);hold on;
% %     plot(tc.track(it).quadrant(3).radius,tc.radius_velocity,'ro');
% %     plot([0 500],[tc.track(it).vmax tc.track(it).vmax],'k--');
% %     plot([tc.track(it).rmax tc.track(it).rmax],[0 100],'k--');
% %     title(datestr(tc.track(it).time))
% %     set(gca,'xlim',[0 250],'ylim',[0 100]);
%     radc=interp1(r,w3,tc.track(it).quadrant(3).radius);
%     err=tc.radius_velocity-radc;
%     errs=[errs err];
%     
% %     subplot(2,2,4)
% %     plot(r,w4);hold on;
% %     plot(tc.track(it).quadrant(4).radius,tc.radius_velocity,'ro');
% %     plot([0 500],[tc.track(it).vmax tc.track(it).vmax],'k--');
% %     plot([tc.track(it).rmax tc.track(it).rmax],[0 100],'k--');
% %     title(datestr(tc.track(it).time))
% %     set(gca,'xlim',[0 250],'ylim',[0 100]);
%     radc=interp1(r,w4,tc.track(it).quadrant(4).radius);
%     err=tc.radius_velocity-radc;
%     errs=[errs err];
    
end

errs=errs(~isnan(errs));
rmserr=sqrt(mean(errs.^2));

if ~isfield(spw,'merge_frac')
    spw.merge_frac=[];
end
if ~isempty(outputfile)
    switch lower(spw.cs.type(1:3))
        case{'geo'}
            gridunit='degree';
        otherwise
            gridunit='m';
    end
    write_spiderweb_file_delft3d(outputfile, tc, gridunit, spw.reference_time, spw.radius, 'merge_frac',spw.merge_frac);
end

%%
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

%%
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
    spw.rmax_relation='gross2004';
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

%%
function tc=wes_cut_off_low_wind_speeds(tc,spw)

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

function tc=wes_convert_units(tc,spw)
%% Convert units
kts2ms=0.514;
nm2km=1.852;
nt=length(tc.track);
% Convert wind speeds to m/s
switch lower(tc.wind_speed_unit)
    case{'kts','kt','knots'}
        tc.radius_velocity=tc.radius_velocity*kts2ms*spw.wind_conversion_factor; % Convert to m/s
        for it=1:nt
            tc.track(it).vmax=tc.track(it).vmax*kts2ms*spw.wind_conversion_factor; % Convert to m/s
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

%%
function tc=wes_compute_forward_speed(tc,spw)

% Computes forward motion (in m/s) and wind speeds relative to storm motion  
nt=length(tc.track);

for it=1:nt
    geofacx=1;
    geofacy=1;
    switch lower(tc.cs.type(1:3))
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
    
%     if strcmpi(spw.rmax_relation,'pagasajma')
%         spw.asymmetry_option='jma';
%     end
%     
%     switch lower(spw.asymmetry_option)
%         case{'schwerdt1979'}
%             % Use Schwerdt (1979) to compute u_prop and v_prop
%             uabs=sqrt(ux^2+uy^2);
%             c=uabs*1.944; % Convert to kts
%             a=1.5*c^0.63; % Schwerdt (1979)
%             a=a/1.944;    % Convert to m/s
%             u_prop=a*ux/uabs;
%             v_prop=a*uy/uabs;
%             u_prop=ux;
%             v_prop=uy;
%         case{'jma'}
%             c2=0.57143;
%             u_prop=c2*ux;
%             v_prop=c2*uy;
%         case{'none'}
%             u_prop=0.0;
%             v_prop=0.0;
%     end
    
    tc.track(it).vtx=ux;
    tc.track(it).vty=uy;

end

% tc.track(it).dpcdt=zeros(size(pc));
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

%%
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

%shite=1

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



%%
function tc=wes_estimate_missing_values(tc,spw)
%% Estimate missing values for Vmax, Pc and Rmax

for it=1:length(tc.track)

    use_vmax=0;
    use_pc=0;
    use_rmax=0;
    
    % Determine which parameters are required
    switch lower(spw.wind_profile)
        case{'holland1980','holland2010'}
            use_vmax=1;
            use_pc=1;
            use_rmax=1;
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

    % Rmax
    if use_rmax
        if isnan(tc.track(it).rmax)
            switch lower(spw.rmax_relation)
                case{'gross2004'}
                    tc.track(it).rmax=rmax_gross2004(tc.track(it).vmax,tc.track(it).y);
                case{'25nm'}
                    tc.track(it).rmax=25*1.852;
                case{'pagasajma'}
                    tc.track(it).rmax=rmax_jma_pagasa(tc.track(it).pc);
            end
        end
    end

end    

%%
function tc=wes_compute_relative_wind_speeds(tc,spw)

% Computes forward motion (in m/s) and wind speeds relative to storm motion  
nt=length(tc.track);

for it=1:nt
    
    u_prop=tc.track(it).vtx;
    v_prop=tc.track(it).vty;
    
    % Compute max wind speed relative to propagation speed
    
    if strcmpi(spw.rmax_relation,'pagasajma')
        spw.asymmetry_option='mvo';
    end
     
    switch lower(spw.asymmetry_option)
        case{'schwerdt1979'}
            % Use Schwerdt (1979) to compute u_prop and v_prop
            uabs=sqrt(ux^2+uy^2);
            c=uabs*1.944; % Convert to kts
            a=1.5*c^0.63; % Schwerdt (1979)
            a=a/1.944;    % Convert to m/s
            u_prop=a*ux/uabs;
            v_prop=a*uy/uabs;
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

% tc.track(it).dpcdt=zeros(size(pc));
for it2=2:length(tc.track)-1
    tc.track(it2).dpcdt=(tc.track(it2+1).pc-tc.track(it2-1).pc)/(24*(tc.track(it2+1).time-tc.track(it2-1).time));
end
tc.track(1).dpcdt=tc.track(2).dpcdt;
tc.track(end).dpcdt=tc.track(end-1).dpcdt;
