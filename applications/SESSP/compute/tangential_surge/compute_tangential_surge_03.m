function surge=compute_tangential_surge_03(xc,t,vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat,iopt,varargin)

if ~isempty(varargin)
    beta=varargin{1};
    %     redfac=beta.redfac;
    %     redext=beta.redext;
    %     cshift=beta.eyevec1;
    %     ashift=beta.eyevec2;
    %     lrfac=beta.offshorefac;
    a1=beta.a1;
    a2=beta.a2;
    c1=beta.c1;
    c2=beta.c2;
    d1=beta.d1;
    d2=beta.d2;
    e1=beta.e1;
    e2=beta.e2;
    f1=beta.f1;
    f2=beta.f2;
    xshift=beta.xshift;
else
    a1=compute_tangential_surge_a1_03(vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat);
    c1=compute_tangential_surge_c1_03(vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat);
    e1=compute_tangential_surge_e1_03(vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat);
    a2=compute_tangential_surge_a2_03(vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat);
    c2=compute_tangential_surge_c2_03(vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat);
    e2=compute_tangential_surge_e2_03(vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat);
    d2=compute_tangential_surge_d2_03(vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat);
    xshift=compute_tangential_surge_xshift_03(vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat);
end

% x in km
% t in hours

nt=length(t);
nx=length(xc);

t=t*24;
if iopt==1
    xc=repmat(xc,[nt 1]);
    t=repmat(t,[1 nx]);
end

if iopt==1
    xe=-t.*vt.*sin(phi*pi/180);
    xacc=xc-xe-xshift;
else
    xacc=xc-xshift;
end

fx=sqrt(exp(1)./c1).*a1.*-sign(xacc).*sqrt(abs(xacc)).*exp(-abs(xacc)./(2*c1));
ft=(exp(1)./e1).*-(t-d2).*exp(-(abs(t-d2)./e1));
ft(t>d2)=0;
st_1=fx.*ft;

fx=sqrt(exp(1)./c2).*a2.* sign(xacc).*sqrt(abs(xacc)).*exp(-abs(xacc)./(2*c2));
ft=(exp(1)./e2).*(t-d2).*exp(-(abs(t-d2)./e2));
ft(t<d2)=0;
st_2=fx.*ft;

surge=st_1+st_2;
