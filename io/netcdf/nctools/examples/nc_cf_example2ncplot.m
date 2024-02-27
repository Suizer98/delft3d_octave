%% read data
D.lat  = nc_varget('nc_cf_example2nc.nc','lat');
D.lon  = nc_varget('nc_cf_example2nc.nc','lon');
D.time = nc_varget('nc_cf_example2nc.nc','time');
D.T    = nc_varget('nc_cf_example2nc.nc','T');

%% plot data
for it=1:length(D.time)
surf(D.lon',D.lat',permute(D.T(it,:,:),[2 3 1]));
hold on
end
colorbar
alpha 0.5

%% read meta-data
M.lat  = nc_attget('nc_cf_example2nc.nc','lat' ,'long_name');
M.lon  = nc_attget('nc_cf_example2nc.nc','lon' ,'long_name');
M.time = nc_attget('nc_cf_example2nc.nc','time','long_name');
M.T    = nc_attget('nc_cf_example2nc.nc','T'   ,'long_name');

%% plot meta-data
xlabel(M.lon)
ylabel(M.lat)
zlabel(M.T)
