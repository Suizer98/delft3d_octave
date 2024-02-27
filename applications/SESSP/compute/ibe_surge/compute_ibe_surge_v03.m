function surge=compute_ibe_surge(x,y,xe,ye,vmax,rmax,r35,foreward_speed,phi,phi_spiral,shelf_width,a,manning,latitude,varargin)

if ~isempty(varargin)
    beta=varargin{1};
    ibefac=beta.ibefac;
else
    ibefac=compute_ibe_surge_ibefac(a,foreward_speed,vmax,rmax,r35,shelf_width,latitude);
end

% x in km
% t in hours

% nt=length(t);
% nx=length(x);
% 
% t=t*24;
% % x=repmat(x,[nt 1]);
% % t=repmat(t,[1 nx]);
% y=zeros(size(x));
% 
% xe    = t.*foreward_speed.*cos((90+phi)*pi/180);
% ye    = t.*foreward_speed.*sin((90+phi)*pi/180);
% 
r=sqrt((xe-x).^2 + (ye-y).^2);

e=exp(1);  % Base of natural logarithms

dp=0.00592*(1-0.0687*foreward_speed.^0.33).*(1+0.00285*abs(latitude).^1.35).*vmax.^1.81; % Holland 20008 (uses 10-minute averaged vmax (in km/h))

rhoa=1.15; % This is also used in WES3

vmax=vmax/3.6; % convert to m/s
vmax=vmax-0.6*foreward_speed/3.6;  % relative vmax

b=rhoa*e*vmax.^2./(100*dp);

rhow=1024;
g=9.81;

pr  = 100*(dp-dp.*exp(-(rmax./r).^b))/(rhow*g);

pr=pr.*ibefac;


% Total
surge=pr;
