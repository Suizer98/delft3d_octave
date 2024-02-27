function UCIT_cdots_amy(x,y,z,zmin,zmax,c,p)
% CDOTS plot color-coded scattered data points
%               elevations color coded with a colormap
%
%  usage:  cdots(x,y,z,zmin,zmax,c)
%
%                 x,y,z:  the elevation data
%                 zmin: minimum elevation to color
%                 zmax: maximum elevation to color
%                 c:  color map
%                 p:  (optional) parent of plot (ie: axes handle)
%
%  example:  cdots(x,y,z,-15,1,jet(128))
%
% written mostly by R. Signell, 5/95
% changed by afarris@usgs.gov 2005Aug12 so that z values less than zmin are
% colored the first color and z values larger than zmax are colored the
% last color
% afarris@usgs.gov 2007july26 added ability to pass in axes handle

if nargin < 7
    p = gca;
end

%% take out the higher parts
x = x(z<=5);
y = y(z<=5);
z = z(z<=5);

%% get number of colors in colormap
[m,n]=size(c);

%% get step size
zinc=(zmax-zmin)/m;

%% do first color first (all z values less than or eqaul to zmin)
i=1;
ind = find(z<=zmin);
line(x(ind),y(ind),'linestyle','none','marker','.','color',c(i,:),'parent',p);

%% now step thru all other colors (except last one)
for i=2:m-1;
    z1=zmin+zinc*(i-1);
    z2=zmin+zinc*i;
    ind=find(z>=z1& z<z2);
    line(x(ind),y(ind),'linestyle','none','marker','.','color',c(i,:),'parent',p);
end

%% now do last color (all z values greater than or eqaul to zmax)
i=m;
ind = find(z>=zmax);
line(x(ind),y(ind),'linestyle','none','marker','.','color',c(i,:),'parent',p);
