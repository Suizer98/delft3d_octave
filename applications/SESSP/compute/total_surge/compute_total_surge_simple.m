function surge=compute_total_surge_simple(xc,vmax,rmax,r35,foreward_speed,phi,phi_spiral,shelf_width,a,iid,latitude,manning)

% x in km

smax=compute_total_surge_smax(vmax,r35,shelf_width,phi,a,foreward_speed,latitude,phi_spiral,rmax,manning);
xmax=compute_total_surge_xmax(rmax,phi,iid,phi_spiral,shelf_width,a,vmax);
b1=compute_total_surge_b1(rmax,r35,phi,shelf_width);
c1=1.50;
b2=compute_total_surge_b2(rmax,r35,phi,shelf_width,vmax,latitude);
c2=1.50;

d1=0.002;
d2=0.002;

st_1=smax.*exp(-(abs(xc-xmax)/b1).^(c1-d1*(abs(xc-xmax))));
st_2=smax.*exp(-(abs(xc-xmax)/b2).^(c2-d2*(abs(xc-xmax))));

st_1(xc<xmax)=0;
st_2(xc>=xmax)=0;

surge=st_1+st_2;
