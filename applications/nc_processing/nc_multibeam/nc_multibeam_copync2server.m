function OPT = nc_multibeam_copync2server(OPT)
%NC_MULTIBEAM_COPYNC2SERVER
%
%See also: nc_multibeam, snctools

%% generate a catalog: alsways for server, even when copy2server is false
if ~isfield(OPT,'datestr')
    OPT.datestr        = 'yyyy-mm-ddTHH:MM:SS'; % default for high-freq timeseries
end

if OPT.copy2server
    if exist(fullfile(OPT.basepath_local,OPT.netcdf_path,'catalog.nc'),'file')
        delete(fullfile(OPT.basepath_local,OPT.netcdf_path,'catalog.nc'))
    end
    nc_cf_opendap2catalog('urlPathFcn',@(s) path2os(strrep (s,OPT.basepath_local,OPT.basepath_opendap),'h'),...
        'base',fullfile(OPT.basepath_local,OPT.netcdf_path),...
        'save',true,...
        'datestr',OPT.datestr,...
        'varname',{'x','y','time'});
else
    if OPT.make
        if exist(fullfile(OPT.basepath_local,OPT.netcdf_path,'catalog.nc'),'file')
            delete(fullfile(OPT.basepath_local,OPT.netcdf_path,'catalog.nc'))
        end
        nc_cf_opendap2catalog(...
            'base',fullfile(OPT.basepath_local,OPT.netcdf_path),...
            'save',true,...
            'varname',{'x','y','time'});
        multiWaitbar('Raw data to NetCDF',1,'label','Generating NC files')
    end
end

%% Copy files to server

if OPT.copy2server
    multiWaitbar('copy nc',1,'color',[0.5 0 0],'label','initializing file copying...');
    if strcmpi(OPT.basepath_network,OPT.basepath_local)
        disp('copying skipped because OPT.basepath_network is equal to OPT.basepath_local')
    else
        % delete current nc files
        try
        rmdir (fullfile(OPT.basepath_network,OPT.netcdf_path),'s');
        end
        mkpath(fullfile(OPT.basepath_network,OPT.netcdf_path));
%         delete(fullfile(OPT.basepath_network,OPT.netcdf_path, '*.nc'));
        
        % determine total scope of work
        fns  = dir(fullfile(OPT.basepath_local,OPT.netcdf_path, '*.nc'));
        
        OPT.WBbytesToDo = 0;
        OPT.WBbytesDone = 0;
        for ii = 1:size(fns,1)
            OPT.WBbytesToDo = OPT.WBbytesToDo+fns(ii).bytes;
        end
        
        for ii = 1:length(fns)
            multiWaitbar('copy nc',OPT.WBbytesDone/OPT.WBbytesToDo,'label',sprintf('copying %s...',fns(ii).name));
            copyfile(...
                fullfile(OPT.basepath_local  ,OPT.netcdf_path,fns(ii).name),...
                fullfile(OPT.basepath_network,OPT.netcdf_path,fns(ii).name),'f');
            OPT.WBbytesDone = OPT.WBbytesDone + fns(ii).bytes;
        end
    end
    multiWaitbar('copy nc',1,'label','Copying of NC files');
end
