function [xg,yg,xz,yz]=sfincs_make_grid(x0,y0,dx,dy,mmax,nmax,rot)

cosrot=cos(rot*pi/180);
sinrot=sin(rot*pi/180);

[xg0,yg0]=meshgrid(0:dx:mmax*dx,0:dy:nmax*dy);
xg = x0 + xg0*cosrot - yg0*sinrot;
yg = y0 + xg0*sinrot + yg0*cosrot;

[xg0,yg0]=meshgrid(0.5*dx:dx:mmax*dx-0.5*dx,0.5*dy:dy:nmax*dy-0.5*dy);
xz = x0 + xg0*cosrot - yg0*sinrot;
yz = y0 + xg0*sinrot + yg0*cosrot;
