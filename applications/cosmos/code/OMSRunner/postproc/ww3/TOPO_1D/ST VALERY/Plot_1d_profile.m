w=readtable('deneme.csv'); %% there is two columns as M and Z in it
x=w.M
x=transpose(x)
z=w.Z
z=transpose(z)
%% 2) Mean water level
zs0  = 0.77; % mean water level [m]

%% 3) Grid and Bathymetry profile 
dxmin = 0.1;% minimum grid size (near shore line)
Hm0 = 0.14;  % significant wave height (m)
Tp  = 2.5; 

%%
% Use xb_grid_xgrid tool to get optimized cross-shore grid
[xx,zz] = xb_grid_xgrid(x,z,'dxmin',dxmin,'Tm',Tp/1.2,'wl',zs0);

% Plot profile
plot(xx,zz,'k');hold on
plot([-28 0],[zs0 zs0],'b')

% Figure labels
xlabel('x [m]')
ylabel('z [m]')
ylim([-30 20])
xlim([-500 2700])

% Title
title('1D Model Setup')