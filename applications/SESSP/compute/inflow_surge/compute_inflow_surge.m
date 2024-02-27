function surge=compute_inflow_surge(xc,t,vmax,rmax,r35,foreward_speed,track_angle,phi_spiral,shelf_width,a,manning,latitude,iopt,varargin)

% x in km
% t in hours

if ~isempty(varargin)
    beta=varargin{1};
    amax=beta.a;
    bt=beta.bt;
    ct=beta.ct;
    bx=beta.bx;
    cx=beta.cx;
else
    amax=compute_inflow_surge_amax(vmax,phi_spiral,shelf_width,a,track_angle);
    bt=compute_inflow_surge_bt(shelf_width,track_angle,foreward_speed,a);
    ct=compute_inflow_surge_ct(shelf_width,track_angle,foreward_speed,a,r35);
    bx=compute_inflow_surge_bx(track_angle);
    cx=compute_inflow_surge_cx(shelf_width,r35);
end

% bx=bx-60;

nt=length(t);
nx=length(xc);

t=t*24;

if iopt==1
    xc=repmat(xc,[nt 1]);
    t=repmat(t,[1 nx]);
end

if iopt==1
    xe=-t.*foreward_speed.*sin(track_angle*pi/180);
else
    xe=0;
end

surge=amax.*exp(-((xc - xe - bx)./cx).^2).*exp(-((t + bt)./ct).^2);

surge=surge*1.00;
