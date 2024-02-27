function surge=compute_inflow_surge(xc,t,vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat,iopt,varargin)

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
    amax=compute_inflow_surge_amax_02(vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat);
    bt=compute_inflow_surge_bt_02(vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat);
    ct=compute_inflow_surge_ct_02(vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat);
    bx=compute_inflow_surge_bx_02(vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat);
    cx=compute_inflow_surge_cx_02(vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat);
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
    xe=-t.*vt.*sin(phi*pi/180);
else
    xe=0;
end

surge=amax.*exp(-((xc - xe - bx)./cx).^2).*exp(-((t + bt)./ct).^2);

surge=surge*1.00;
