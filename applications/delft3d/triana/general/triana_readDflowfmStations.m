function s = triana_readDflowfmStations(s);
    
s.model.data.statsAll = char2cell(ncread(s.model.file,'station_name')');

info = nc_getvarinfo(s.model.file,'station_x_coordinate');

if length(info.Size) == 1
    s.model.data.XAll = ncread(s.model.file,'station_x_coordinate');
    s.model.data.YAll = ncread(s.model.file,'station_y_coordinate');
else
    s.model.data.XAll = nc_varget(s.model.file,'station_x_coordinate',[0 0],[1 info.Size(2)])';
    s.model.data.YAll = nc_varget(s.model.file,'station_y_coordinate',[0 0],[1 info.Size(2)])';
end


