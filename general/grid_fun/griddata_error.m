%GRIDDATA_ERROR example to show that anisotrope scaling affects results
%
%  E.g. for t-z interpolkation, when dt is small (for instance times in datenum for profiles)
%  interpolation will favor time-nearness over z-nearness, and hence will corrupt
%  profiles. GRIDDATA does not use matrix topology as interp 2 does,
%  but destoys matrix topology and reconnects them using Delaunay triangulation.
%
%See also: griddata, http://www.mathworks.nl/support/solutions/en/data/1-CHR2J8/index.html
%          http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.22.2848

X0 = [ -2   -1    0    1
       -2   -1    0    1]

X1 = [ -2   -1    0    1
       -2   -1    0    1]/10 % 10 times smaller X coordinates results in error

Y = [ -1.3   -1.2   -1.1   -1.0
      -3.0   -3.0   -3.0   -3.0]

V = [-15.9   -3.6   -1.9   -1.6
     -15.9   -3.6   -1.9   -1.6]

Xq0 = X0(1,:)
Xq1 = X1(1,:)

Yq = [-2.4 -2.4 -2.4 -2.4];

Vq0 = griddata(X0,Y,V,Xq0,Yq,'linear')
Vq1 = griddata(X1,Y,V,Xq1,Yq,'linear')

subplot(2,1,1)
h = pcolor(X0,Y,V);
shading interp
set(h,'EdgeColor','k')
hold on
scatter(Xq0,Yq,300,Vq0,'filled')
title('correct')

subplot(2,1,2)
h = pcolor(X1,Y,V);
shading interp
set(h,'EdgeColor','k')
hold on
scatter(Xq1,Yq,300,Vq1,'filled')
title('wrong due to smaller X coordinates')

%%

F = TriScatteredInterp([X0(:) Y(:)], V(:));F([Xq0(:) Yq(:)])
F = TriScatteredInterp([X1(:) Y(:)], V(:));F([Xq1(:) Yq(:)])
