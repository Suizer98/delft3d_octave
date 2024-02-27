function surge=compute_tangential_surge(xc,t,vmax,rmax,r35,foreward_speed,phi,phi_spiral,shelf_width,a,manning,latitude,iopt,varargin)

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
    a1=compute_tangential_surge_a1(a,vmax,shelf_width,foreward_speed,phi);
    a2=compute_tangential_surge_a2(a,vmax,shelf_width,foreward_speed,phi,manning);
    c1=compute_tangential_surge_c1(a,rmax,r35,shelf_width,phi);
    c2=compute_tangential_surge_c2(a,rmax,vmax,shelf_width,phi,foreward_speed);
    % d1=compute_tangential_surge_d1(a,foreward_speed);
    d2=compute_tangential_surge_d2(shelf_width,foreward_speed,a);
    e1=compute_tangential_surge_e1(foreward_speed,shelf_width);
    e2=compute_tangential_surge_e2(foreward_speed,phi);
    f1=compute_tangential_surge_f1(a,vmax,shelf_width,foreward_speed,phi);
    f2=compute_tangential_surge_f2(a,vmax,shelf_width,foreward_speed,phi);
    xshift=compute_tangential_surge_xshift(phi,vmax);
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

% a1=-compute_tangential_surge_a1(a,vmax,shelf_width,foreward_speed,phi);
% a2=compute_tangential_surge_a2(a,vmax,shelf_width,foreward_speed,phi);
% c1=compute_tangential_surge_c1(a,rmax,r35,shelf_width);
% c2=compute_tangential_surge_c2(a,rmax,vmax,shelf_width,phi,foreward_speed);
% d1=compute_tangential_surge_d1(a,foreward_speed);
% d2=compute_tangential_surge_d2(shelf_width,foreward_speed);
% e1=compute_tangential_surge_e1(foreward_speed,shelf_width);
% e2=compute_tangential_surge_e2(foreward_speed,phi);


if iopt==1
    xe=-t.*foreward_speed.*sin(phi*pi/180);
    xacc=xc-xe-xshift;
else
    xacc=xc-xshift;
end

fx=sqrt(exp(1)./c1).*a1.*-sign(xacc).*sqrt(abs(xacc)).*exp(-abs(xacc)./(2*c1));
% fx(xacc<0)=fx(xacc<0)*f1;
ft=(exp(1)./e1).*-(t-d2).*exp(-(abs(t-d2)./e1));
ft(t>d2)=0;
st_1=fx.*ft;

fx=sqrt(exp(1)./c2).*a2.* sign(xacc).*sqrt(abs(xacc)).*exp(-abs(xacc)./(2*c2));
% fx(fx>0)=fx(fx>0)*0.8;
% fx(fx<0)=fx(fx<0)*1.2;
% fx(xacc<0)=fx(xacc<0)*f2;
%ft=exp(-((t-d2)./(e2.*(1+0.005*abs(xacc)))).^2);
ft=(exp(1)./e2).*(t-d2).*exp(-(abs(t-d2)./e2));
ft(t<d2)=0;
st_2=fx.*ft;

surge=st_1+st_2;



% f1=2.331/sqrt(c1);
% f2=2.331/sqrt(c2);
%
% xe=-t*foreward_speed*sin(phi*pi/180)+xshift;
%
% st_1=-f1*a1.*sign(xc-xe).*(abs(xc-xe)).^0.5.*exp(-(abs(xc-xe)/(2*c1)).^1).*exp(-((t-d1)./(e1.*((abs(xc-xe)+50)/200))).^2);
% st_2=f2*a2.*sign(xc-xe).*(abs(xc-xe)).^0.5.*exp(-(abs(xc-xe)/(2*c2)).^1).*exp(-((t-d2)./(e2.*((abs(xc-xe)+50)/200))).^2);
%
% surge=st_1+st_2;
