nx = 2;
ny = 2;

figure;

s = [];

s(1) = subplot(ny,nx,1);
t = ncread('slamfat.nc','threshold');
pcolor(t'); shading flat; colorbar;
clim([0 10]);
title('threshold velocity');

s(2) = subplot(ny,nx,2);
m = ncread('slamfat.nc','moisture');
pcolor(m'); shading flat; colorbar;
clim([0 .4])
title('moisture content');

s(3) = subplot(ny,nx,3);
r = ncread('slamfat.nc','cummulative_rainfall');
r(r>1e10) = nan;
bar(diff(r(:,1))); box on;
ylim([0 .1]);
title('rainfall');

s(4) = subplot(ny,nx,4);
e = ncread('slamfat.nc','cummulative_evaporation');
e(e>1e10) = nan;
bar(diff(e(:,1))); box on;
ylim([0 .001]);
title('evaporation');

linkaxes(s,'x');

pos = get(s(1),'Position');
for i = 2:length(s)
    pos_i = get(s(i),'Position');
    pos_i(3:4) = pos(3:4);
    set(s(i),'Position',pos_i);
end
