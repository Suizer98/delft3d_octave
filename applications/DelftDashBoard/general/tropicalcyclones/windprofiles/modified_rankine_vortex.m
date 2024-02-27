function vr=modified_rankine_vortex(r,theta,vmax,rmax,x,a,theta0)

theta0=theta0*pi/180;

vr=zeros(size(r));

vro = (vmax-a)*(rmax./r).^x + a*cos(theta-theta0);
vri = (vmax-a)*(r./rmax).^1 + a*cos(theta-theta0);

vr(r>=rmax)=vro(r>=rmax);
vr(r< rmax)=vri(r< rmax);

vr=max(vr,0);

% pr=zeros(size(vr));
