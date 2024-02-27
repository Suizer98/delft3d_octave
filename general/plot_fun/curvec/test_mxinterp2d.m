clear variables;close all;

x1=0:100;
y1=0:50;
[x1,y1]=meshgrid(x1,y1);
z1=x1;

x2=100*rand(200,1);
y2=50*rand(200,1);

z2=mxinterp2d(x1,y1,z1,x2,y2);

pcolor(x1,y1,z1);shading flat;
hold on
sc=scatter(x2,y2,20,z2,'filled');
set(sc,'MarkerEdgeColor','k');
colorbar;
