function surge=compute_tangential_surge(xc,t,vmax,rmax,r35,foreward_speed,phi,phi_spiral,shelf_width,a,manning,latitude)

% x in km
% t in hours

smax=compute_total_surge_smax(vmax,r35,shelf_width,phi,a,foreward_speed);
xmax=compute_total_surge_xmax(rmax,phi,iid);
b1=compute_total_surge_b1(rmax,r35,phi,shelf_width);
c1=1.25;

b2=beta(5);
c2=1.25;

st_1=smax.*exp(-(abs(xc-xmax)/(b1)).^c1);
st_2=smax.*exp(-(abs(xc-xmax)/(b2)).^c2);

st_1(xc<xmax)=0;
st_2(xc>=xmax)=0;



surge=st_1+st_2;
nt=length(t);
nx=length(xc);

t=t*24;
xc=repmat(xc,[nt 1]);
t=repmat(t,[1 nx]);

a1=-compute_tangential_surge_a1(a,vmax,shelf_width,foreward_speed,phi);
a2=compute_tangential_surge_a2(a,vmax,shelf_width,foreward_speed,phi);
c1=compute_tangential_surge_c1(a,rmax,r35,shelf_width);
c2=compute_tangential_surge_c2(a,rmax,vmax,shelf_width,phi,foreward_speed);
d1=compute_tangential_surge_d1(a,foreward_speed);
d2=compute_tangential_surge_d2(shelf_width,foreward_speed);
e1=compute_tangential_surge_e1(foreward_speed,shelf_width);
e2=compute_tangential_surge_e2(foreward_speed,phi);

f1=2.331/sqrt(c1);
f2=2.331/sqrt(c2);

xe=-t*foreward_speed*sin(phi*pi/180);

st_1=f1*a1.*sign(xc-xe).*(abs(xc-xe)).^0.5.*exp(-(abs(xc-xe)/(2*c1)).^1).*exp(-((t-d1)./(e1.*((abs(xc-xe)+50)/200))).^2);
st_2=f2*a2.*sign(xc-xe).*(abs(xc-xe)).^0.5.*exp(-(abs(xc-xe)/(2*c2)).^1).*exp(-((t-d2)./(e2.*((abs(xc-xe)+50)/200))).^2);

surge=st_1+st_2;
