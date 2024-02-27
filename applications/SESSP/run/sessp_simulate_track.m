function [t,xx,lon,lat,stot,snor,spar,srad,sekm,sibe]=sessp_simulate_track(coastfile,trackfile,outputfolder,t0,t1,dt,varargin)

% Defaults
phi_spiral=20;
manning=0.020;
include_tide=1;
outputformat='tek';
% max_omega=1e9;
% min_a=0.01;
tideurl='c:\work\delftdashboard\data\tidemodels\tpxo72.nc';
lonrange=[];
latrange=[];
landdecay=0;
cstype='geographic';
latitude=0;
writeoutput=1;
windspeedconversionfactor=0.88;

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'phi_spiral'}
                phi_spiral=varargin{ii+1};
            case{'manning'}
                manning=varargin{ii+1};
            case{'outputformat'}
                outputformat=varargin{ii+1};
%             case{'max_omega'}
%                 max_omega=varargin{ii+1};
%             case{'min_a'}
%                 min_a=varargin{ii+1};
            case{'tideurl'}
                tideurl=varargin{ii+1};
            case{'include_tide'}
                include_tide=varargin{ii+1};
            case{'lon'}
                lonrange=varargin{ii+1};
            case{'lat'}
                latrange=varargin{ii+1};
            case{'landdecay'}
                landdecay=varargin{ii+1};
            case{'cstype'}
                cstype=varargin{ii+1};
            case{'latitude'}
                latitude=varargin{ii+1};
            case{'writeoutput'}
                writeoutput=varargin{ii+1};
            case{'windspeedconversionfactor'}
                windspeedconversionfactor=varargin{ii+1};
        end
    end
end

%% Pre-processing

% Times
tt=t0:dt/1440:t1;
nt=length(tt);

% Read coast file
s=load(coastfile);
lon=s(:,1);
lat=s(:,2);

xx=pathdistance(lon,lat,cstype)/1000;

ifirst=1;
ilast=length(lon);

% Determine first and last point to be included in computation
if ~isempty(lonrange)
    % first point
    dst=sqrt((lon-lonrange(1)).^2+(lat-latrange(1)).^2);
    ifirst=find(dst==min(dst),1,'first');
    dst=sqrt((lon-lonrange(2)).^2+(lat-latrange(2)).^2);
    ilast=find(dst==min(dst),1,'first');    
end

% ip=244-ifirst;
% ip=62;

s=s(ifirst:ilast,:);
xx=xx(ifirst:ilast);
lon=lon(ifirst:ilast);
lat=lat(ifirst:ilast);

if strcmpi(cstype,'geographic')
    % Determine UTM zone
    utmz = fix( ( mean(lon) / 6 ) + 31);
    utmz = mod(utmz,60);
    if mean(lat)>0
        utmzone=['WGS 84 / UTM zone ' num2str(utmz) 'N'];
    else
        utmzone=['WGS 84 / UTM zone ' num2str(utmz) 'S'];
    end
end

np=size(s,1);

if include_tide
    % generate tide timeseries
    wltide=sessp_get_tides_at_point(tt,lon,lat,tideurl);
end

coast.x=s(:,1)';
coast.y=s(:,2)';
if strcmpi(cstype,'geographic')
    coast.latitude=coast.y;
    [coast.x,coast.y]=convertCoordinates(coast.x,coast.y,'persistent','CS1.name','WGS 84','CS1.type','geographic','CS2.name',utmzone,'CS2.type','projected');
else
    coast.latitude=zeros(size(coast.y))+latitude;    
end
coast.x=coast.x/1000; % convert to km
coast.y=coast.y/1000; % convert to km
coast.phi=s(:,3)'*180/pi;
coast.phi=mod(coast.phi,360);
coast.w=s(:,4)'/1000;
coast.a=s(:,5)';
coast.omega=s(:,6)';
coast.manning=zeros(1,np)+manning;

w00=coast.w;
omega00=coast.omega;
a00=coast.a;
w=w00;
omega=omega00;
a=a00;

% % Smoothing
% for ii=1:nsmooth
%     w1=0.25*(w(1:end-2)) + 0.5*w(2:end-1) + 0.25*w(3:end);
%     w(2:end-1)=w1;
%     omega1=0.25*(omega(1:end-2)) + 0.5*omega(2:end-1) + 0.25*omega(3:end);
%     omega(2:end-1)=omega1;
%     a1=0.25*(a(1:end-2)) + 0.5*a(2:end-1) + 0.25*a(3:end);
%     a(2:end-1)=a1;
% end

% Limit omega and a
% omega=min(omega,max_omega);
% a    =max(a,min_a);

coast.omega=omega;
coast.w=w;
coast.a=a;

%% Read track file
inp=sessp_read_cyclone_file(trackfile);
track=inp.track;
if strcmpi(cstype,'geographic')
    track.latitude=track.y;
else
    track.latitude=zeros(size(track.y))+latitude;
end

if strcmpi(cstype,'geographic')
    [track.x,track.y]=convertCoordinates(track.x,track.y,'persistent','CS1.name','WGS 84','CS1.type','geographic','CS2.name',utmzone,'CS2.type','projected');
end
track.r35ne(track.r35ne<0)=NaN;
track.r35se(track.r35se<0)=NaN;
track.r35sw(track.r35sw<0)=NaN;
track.r35nw(track.r35nw<0)=NaN;
track.x=track.x/1000; % convert to km
track.y=track.y/1000; % convert to km
for it=1:length(track.time)
    track.r35(it)=nanmean([track.r35ne(it) track.r35se(it) track.r35sw(it) track.r35nw(it)]);
    track.phi_in(it)=phi_spiral;
end

track.vmax=track.vmax*1.852*windspeedconversionfactor; % convert to km/h
track.rmax=track.rmax*1.852;      % convert to km
track.r35 =track.r35*1.852;       % convert to km

% Compute surge

snor=zeros(nt,np);
spar=zeros(nt,np);
srad=zeros(nt,np);
sekm=zeros(nt,np);
sibe=zeros(nt,np);
stot=zeros(nt,np);
vnor=zeros(nt,np);
vtan=zeros(nt,np);

tic
for it=1:length(tt)
    
    t=tt(it);
    trackt=sessp_interpolate_track_data(track,t);
    
    [xacc,tacc,phi_rel]=sessp_compute_virtual_landfall_coordinates_v02(t,trackt,coast);
    
    [snor0,vnor0,vtan0]=compute_normal_surge_along_coast(coast,trackt,phi_rel,'landdecay',landdecay);
    sekm0=compute_ekman_surge_along_coast(coast,trackt,xacc,tacc,phi_rel);
    spar0=compute_tangential_surge_along_coast(coast,trackt,xacc,tacc,phi_rel);
    srad0=compute_inflow_surge_along_coast(coast,trackt,xacc,tacc,phi_rel);
    sibe0=compute_ibe_surge_along_coast(coast,trackt);
    
    stot0=snor0+sekm0+spar0+srad0+sibe0;
    stot0=stot0.*(1-0.02*stot0);
    
    snor(it,:)=snor0;
    spar(it,:)=spar0;
    srad(it,:)=srad0;
    sekm(it,:)=sekm0;
    sibe(it,:)=sibe0;
    stot(it,:)=stot0;

    vnor(it,:)=vnor0;
    vtan(it,:)=vtan0;
    
    
end
toc

% Add tide
if include_tide
    stot=stot+wltide;
end

if writeoutput
    switch lower(outputformat)
        
        case{'tek'}
            
            if ~exist(outputfolder,'dir')
                mkdir(outputfolder);
            end
            
            for ii=1:np
                
                name=num2str(ii+ifirst-1,'%0.4i');
                fid=fopen([outputfolder filesep name '.tek'],'wt');
                fprintf(fid,'%s\n','* column 1 : Date');
                fprintf(fid,'%s\n','* column 2 : Time');
                fprintf(fid,'%s\n','* column 3 : WL');
                fprintf(fid,'%s\n','BL01');
                fprintf(fid,'%i %i\n',length(tt),3);
                for it=1:length(tt)
                    fprintf(fid,'%s %10.3f\n',datestr(tt(it),'yyyymmdd HHMMSS'),stot(it,ii));
                end
                fclose(fid);
                
                name=num2str(ii+ifirst-1,'%0.4i');
                fid=fopen([outputfolder filesep name '_wind.tek'],'wt');
                fprintf(fid,'%s\n','* column 1 : Date');
                fprintf(fid,'%s\n','* column 2 : Time');
                fprintf(fid,'%s\n','* column 3 : Vmag');
                fprintf(fid,'%s\n','* column 3 : Vdir');
                fprintf(fid,'%s\n','BL01');
                fprintf(fid,'%i %i\n',length(tt),4);
                for it=1:length(tt)
                    vmag=sqrt(vnor(it,ii).^2+vtan(it,ii)^2);
                    fprintf(fid,'%s %10.3f\n',datestr(tt(it),'yyyymmdd HHMMSS'),vmag);
                end
                fclose(fid);
                
            end
            
            fid=fopen([outputfolder filesep 'zmax.tek'],'wt');
            fprintf(fid,'%s\n','* column 1 : x');
            fprintf(fid,'%s\n','* column 2 : Z');
            fprintf(fid,'%s\n','BL01');
            fprintf(fid,'%i %i\n',np,2);
            for ip=1:np
                fprintf(fid,'%10.3f %10.3f\n',xx(ip),max(stot(:,ip)));
            end
            fclose(fid);
            
    end
end

