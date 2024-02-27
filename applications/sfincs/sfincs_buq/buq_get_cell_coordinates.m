function [xz,yz]=buq_get_cell_coordinates(buq,ib)

cosrot=cos(buq.rotation*180/pi);
sinrot=sin(buq.rotation*180/pi);

xz=nan(16,16);
yz=nan(16,16);

iref=buq.level(ib);
dx1=buq.dx*0.5^iref;
dy1=buq.dy*0.5^iref;
dxc=dx1/15;
dyc=dy1/15;

x=(buq.m(ib)-1)*dx1+0.5*dxc : dxc : (buq.m(ib))*dx1-0.5*dxc;
y=(buq.n(ib)-1)*dy1+0.5*dyc : dyc : (buq.n(ib))*dy1-0.5*dyc;
[x,y]=meshgrid(x,y);

xz(2:end,2:end)=buq.x0 + cosrot*x - sinrot*y;
yz(2:end,2:end)=buq.x0 + sinrot*x + cosrot*y;
