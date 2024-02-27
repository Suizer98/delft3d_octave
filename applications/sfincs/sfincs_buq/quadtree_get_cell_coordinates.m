function [xz,yz]=quadtree_get_cell_coordinates(buq)

cosrot=cos(buq.rotation*pi/180);
sinrot=sin(buq.rotation*pi/180);

iref=buq.level;
dx=buq.dx*0.5.^iref;
dy=buq.dy*0.5.^iref;
xz=buq.x0 + cosrot*((buq.m-0.5).*dx) - sinrot*((buq.n-0.5).*dy);
yz=buq.y0 + sinrot*((buq.m-0.5).*dx) + cosrot*((buq.n-0.5).*dy);

% xg=zeros(5,nb);
% yg=zeros(5,nb);
% 
% for ib=1:nb
%     iref=buq.level(ib);
%     dx1=buq.dx*0.5^iref;
%     dy1=buq.dy*0.5^iref;
%     xg(1,ib)=cosrot*((buq.m(ib)-1)*dx1) - sinrot*((buq.n(ib)-1)*dy1);
%     yg(1,ib)=sinrot*((buq.m(ib)-1)*dx1) + cosrot*((buq.n(ib)-1)*dy1);
%     xg(2,ib)=cosrot*((buq.m(ib)  )*dx1) - sinrot*((buq.n(ib)-1)*dy1);
%     yg(2,ib)=sinrot*((buq.m(ib)  )*dx1) + cosrot*((buq.n(ib)-1)*dy1);
%     xg(3,ib)=cosrot*((buq.m(ib)  )*dx1) - sinrot*((buq.n(ib)  )*dy1);
%     yg(3,ib)=sinrot*((buq.m(ib)  )*dx1) + cosrot*((buq.n(ib)  )*dy1);
%     xg(4,ib)=cosrot*((buq.m(ib)-1)*dx1) - sinrot*((buq.n(ib)  )*dy1);
%     yg(4,ib)=sinrot*((buq.m(ib)-1)*dx1) + cosrot*((buq.n(ib)  )*dy1);
%     xg(5,ib)=xg(1,ib);
%     yg(5,ib)=yg(1,ib);    
% end
% xg=xg+buq.x0;
% yg=yg+buq.y0;


% xg=zeros(1,6*nb);
% yg=zeros(1,6*nb);
% 
% n=0;
% for ib=1:nb
%     iref=buq.level(ib);
%     dx1=buq.dx*0.5^iref;
%     dy1=buq.dy*0.5^iref;
%     n=n+1;
%     xg(n)=cosrot*((buq.m(ib)-1)*dx1) - sinrot*((buq.n(ib)-1)*dy1);
%     yg(n)=sinrot*((buq.m(ib)-1)*dx1) + cosrot*((buq.n(ib)-1)*dy1);
%     n=n+1;
%     xg(n)=cosrot*((buq.m(ib)  )*dx1) - sinrot*((buq.n(ib)-1)*dy1);
%     yg(n)=sinrot*((buq.m(ib)  )*dx1) + cosrot*((buq.n(ib)-1)*dy1);
%     n=n+1;
%     xg(n)=cosrot*((buq.m(ib)  )*dx1) - sinrot*((buq.n(ib)  )*dy1);
%     yg(n)=sinrot*((buq.m(ib)  )*dx1) + cosrot*((buq.n(ib)  )*dy1);
%     n=n+1;
%     xg(n)=cosrot*((buq.m(ib)-1)*dx1) - sinrot*((buq.n(ib)  )*dy1);
%     yg(n)=sinrot*((buq.m(ib)-1)*dx1) + cosrot*((buq.n(ib)  )*dy1);
%     n=n+1;
%     xg(n)=cosrot*((buq.m(ib)-1)*dx1) - sinrot*((buq.n(ib)-1)*dy1);
%     yg(n)=sinrot*((buq.m(ib)-1)*dx1) + cosrot*((buq.n(ib)-1)*dy1);
%     n=n+1;
%     xg(n)=NaN;
%     yg(n)=NaN;    
% end
% xg=xg+buq.x0;
% yg=yg+buq.y0;
