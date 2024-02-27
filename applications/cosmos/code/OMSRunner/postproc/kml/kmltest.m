clear variables;close all;
nt=10;

%s=load('hs.mat');
s=load('hs.mat');

it0=100;
it1=length(s.time);
it1=110;

x=s.X;
y=s.Y;
z=s.Val(it0:it1,:,:);
t=s.time(it0:it1);

z(z<0.001)=NaN;

contourfKML('hs',x,y,z,'time',t,'levels',[0:1:12],'colormap',jet(64),'screenoverlay','colorbar.png');
