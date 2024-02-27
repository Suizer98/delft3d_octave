function [vnor,vtan,r,r0]=compute_wind_v03(xc,yc,phi_c,xe,ye,vt,phi_t,vmax,rmax,r35,phi_in,lat,cshift,ashift,varargin)
% Computes normal and tangential wind speeds (in m/s) at location along the coast

% t      = row vector with times                    (matlab times)

% xc      = column vector with x positions along coast  (km)
% yc      = column vector with y positions along coast  (km)
% phi_c  = column vector with shore normal orientation (degrees)

% te      = row vector with times of the track         (matlab times)
% xe      = row vector with x positions of the eye     (km)
% ye      = row vector with y positions of the eye     (km) 
% vmax    = row vector with vmax (km/h)
% rmax    = row vector with rmax (km)
% r35     = row vector with r35 (km)
% phi_in  = row vector with inflow angle (deg)
% lat     = row vector with latitude (deg)
% cshift  = row vector with cross-track shift (km)
% ashift  = row vector with along-track shift (km)

nt=1;
nx=length(xc);

e=exp(1);
rhoa=1.15; % This also also used in WES3!!!
asymfac=0.6;
phi_a=0;

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'rhoa'}
                rhoa=varargin{ii+1};
            case{'asymfac'}
                asymfac=varargin{ii+1};
            case{'asymangle'}
                phi_a=varargin{ii+1};
        end
    end
end

% Convert angles to radians
phi_c  = phi_c*pi/180;
phi_in = phi_in*pi/180;
phi_a  = phi_a*pi/180;
phi_t  = phi_t*pi/180;

% if length(te)>2
%     for it=2:length(te)-1        
%         dx1=xe(it)-xe(it-1);
%         dy1=ye(it)-ye(it-1);
%         dt1=(te(it)-te(it-1))*24; % hours
%         dx2=xe(it+1)-xe(it);
%         dy2=ye(it+1)-ye(it);
%         dt2=(te(it+1)-te(it))*24; % hours
%         
%         v1=sqrt(dx1^2+dy1^2)/dt1;
%         v2=sqrt(dx2^2+dy2^2)/dt2;
%         vtt(it)=0.5*(v1+v2);
%         dxt(it)=0.5*(dx1+dx2);
%         dyt(it)=0.5*(dy1+dy2);
%         
%     end
%     vtt(1)=vtt(2);
%     dxt(1)=dxt(2);
%     dyt(1)=dyt(2);
%     vtt(end+1)=vtt(end);
%     dxt(end+1)=dxt(end);
%     dyt(end+1)=dyt(end);
%     
% else
%     dx1=xe(2)-xe(1);
%     dy1=ye(2)-ye(1);
%     dt1=(te(2)-te(1))*24; % hours
%     v1=sqrt(dx1^2+dy1^2)/dt1;
%     vtt=[v1;v1];
%     dxt=[dx1;dx1];
%     dyt=[dy1;dy1];
% end
% 
% % First compute foreward speed and angle for each required time point
% for it=1:nt
%     it0=find(te<t(it),1,'last');
%     if it0>=length(te)
%         vt(it,1)=vtt(it-1);
% %        phi_t(it,1)=phi_t(it-1);
%         phi_t(it,1)=atan2(dyt(end),dxt(end));
%     else
% %         dx=xe(it0+1)-xe(it0);
% %         dy=ye(it0+1)-ye(it0);
% %         dt=(te(it0+1)-te(it0))*24; % hours
% %         vt(it,1)=sqrt(dx^2+dy^2)/dt;
% %         phi_t(it,1)=atan2(dy,dx);
%         
%         dxr=interp1(te,dxt,t(it));
%         dyr=interp1(te,dyt,t(it));
%         vt(it,1)=interp1(te,vtt,t(it));
%         phi_t(it,1)=atan2(dyr,dxr);
%         
%     end
% end
% 
% % Interpolate track data to output times
% xe=interp1(te,xe,t);
% ye=interp1(te,ye,t);
% vmax=interp1(te,vmax,t);
% rmax=interp1(te,rmax,t);
% r35=interp1(te,r35,t);
% if length(phi_in)>1
%     phi_in=interp1(te,phi_in,t);
% else
%     phi_in=repmat(phi_in,[nt 1]);
% end
% if length(lat)>1
%     lat=interp1(te,lat,t);
% else
%     lat=repmat(lat,[nt 1]);
% end
% te=t;

% % Compute forward speed and track angle
% 
% if nt==1
%     % Just one time step requested
%     it=find(te>=t,1,'first');
%     vt=forewardspeed;
%     phi_t=trackangle;
% else
%     vt=zeros(length(te),1);
%     for it=2:length(te)-1
%         dx=xe(it+1)-xe(it-1);
%         dy=ye(it+1)-ye(it-1);
%         dt=(te(it+1)-te(it-1))*24; % hours
%         vt(it)=sqrt(dx^2+dy^2)/dt;
%         phi_t=atan2(dy,dx);
%     end
%     vt(1)=vt(2);
%     vt(end)=vt(end-1);
% end

% Compute forward speed and relative vmax in m/s 
vtms      = vt/3.6;                % forward speed in m/s
vmax1     = vmax/3.6-asymfac*vtms; % relative vmax in m/s

%% Storm shape
dp=0.00592*(1-0.0687*vt.^0.33).*(1+0.00285*abs(lat).^1.35).*vmax.^1.81; % Estimate of Holland (2008)

% For very weak storms, adjust dp
bmin=1.2;
bmin=0.0;

dp=min(dp, 0.01*rhoa*e*(vmax1.^2)/bmin);


b=rhoa*e*(vmax1).^2./(100*dp);

if vmax1>1.2*35*1.852/3.6 && r35>1.2*rmax   
    c=(100*b.*dp.*(rmax./r35).^b)./(rhoa*exp((rmax./r35).^b));
    ah=(logn(35*1.852/3.6,c)-0.5)./(r35-rmax);
else
    ah=0;
end

%% Eye shift
% phishift=atan2(ashift,cshift);
% magshift=sqrt(ashift.^2+cshift.^2);
% xshift=cos(phi_t+phishift).*magshift;
% yshift=sin(phi_t+phishift).*magshift;

phishift=atan2(cshift,ashift);
magshift=sqrt(ashift.^2+cshift.^2);
xshift=cos(phi_t+phishift).*magshift;
yshift=sin(phi_t+phishift).*magshift;


xeacc=xe+xshift;
yeacc=ye+yshift;

% Matrix of coast line position
xc=repmat(xc,[nt 1]);
yc=repmat(yc,[nt 1]);
phi_c=repmat(phi_c,[nt 1]);

% Matrix of storm data
xe=repmat(xe,[1 nx]);
ye=repmat(ye,[1 nx]);
% xeacc=repmat(xeacc,[1 nx]);
% yeacc=repmat(yeacc,[1 nx]);
rmax=repmat(rmax,[1 nx]);
phi_t=repmat(phi_t,[1 nx]);
phi_in=repmat(phi_in,[1 nx]);
dp=repmat(dp,[1 nx]);
b=repmat(b,[1 nx]);
ah=repmat(ah,[1 nx]);
vtms=repmat(vtms,[1 nx]);

% Distance r and r0 of shoreline points to eye of the storm
r0=sqrt((xc-xe).^2 + (yc-ye).^2);
r=sqrt((xc-xeacc).^2 + (yc-yeacc).^2);
alfa=atan2(yc-yeacc,xc-xeacc);

%% Beta adjustment in within Rmax
xh=0.5+(r-rmax).*ah;
xh(r<=rmax)=0.5;
b0=0.75;
b0=0.50;
br=b0+r.*(b-b0)./rmax;
br(r>rmax)=b(r>rmax);
%br(r>rmax)=b;
br=b;
% br=max(br,0.5);
%xh=min(xh,1);

% Wind profile
vrms  = ((100*br.*dp.*abs(rmax./r).^br)./(rhoa*exp(abs(rmax./r).^br))).^xh; % in m/s
vrms  = max(vrms,0.1);

% Storm without asymmetry
beta1=alfa+pi/2+phi_in;  % wind speed direction at coast (cartesian)
vx1 = vrms.*cos(beta1);
vy1 = vrms.*sin(beta1);

% Asymmetry
ff=min(r./rmax,1);
vx2=ff*asymfac.*vtms.*cos(phi_t + phi_a);
vy2=ff*asymfac.*vtms.*sin(phi_t + phi_a);

% Combined wind speeds
vx=vx1+vx2;
vy=vy1+vy2;
vrms=sqrt(vx.^2+vy.^2);
phi_w=atan2(vy,vx);

% Shore normal component
theta=phi_w-phi_c; % wind angle wrt shore normal
% shore normal component
vnor=vrms.*cos(theta);
% shore tangential component
vtan=-vrms.*sin(theta);

% disp(vnor(84))
% disp(vrms(84))
% disp(br(1))
% disp(theta(84))
% disp(phi_w(84))
% disp(phi_c(84))


