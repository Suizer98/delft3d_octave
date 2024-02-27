function writeNCtimeseries(ncfile,s)
   
% create netcdf file
nc_create_empty(ncfile,nc_clobber_mode);

% set global attributes
attr=fieldnames(s.global);
for i=1:length(attr)
    nc_attput(ncfile,nc_global,attr{i},s.global.(attr{i}));
end

% First add time
for i=1:length(s.datasets)
    switch lower(s.datasets(i).name)
        case{'time'}
            nc_add_dimension(ncfile,'time',length(s.datasets(i).data));
            v2=rmfield(s.datasets(i),'data');            
            nc_addvar(ncfile,v2);
            nc_varput(ncfile,'time',round((s.datasets(i).data-datenum('1970-01-01 00:00:00')))*86400);
    end
end

for i=1:length(s.datasets)
    name=s.datasets(i).name;
    switch lower(name)
        case{'time'}
        otherwise
            v2=rmfield(s.datasets(i),'data');            
            nc_addvar(ncfile,v2);
            nc_varput(ncfile,name,s.datasets(i).data);
    end
end
