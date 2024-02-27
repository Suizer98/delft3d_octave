function outputfile = EHY_simdirRunIdAndModelType2outputfile(sim_dir,runid,modelType)
% get outputfile from the sim_dir,runid and modelType
switch modelType

    case {'dfm','d3dfm','dflow','dflowfm','mdu'}
        %% Delft3D-Flexible Mesh
        mdu = dflowfm_io_mdu('read',[sim_dir filesep runid '.mdu']);
        outputDir  = EHY_getOutputDirFM([sim_dir filesep runid '.mdu']);
        hisncfiles = dir([outputDir filesep '*his*.nc']);
        outputfile = [outputDir filesep hisncfiles(1).name];
        
    case {'d3d','d3d4','delft3d4','mdf'}
        %% Delft3D 4
        outputfile = [sim_dir filesep 'trih-' runid '.dat'];

    case {'waqua','simona','siminp'}
        %% SIMONA (WAQUA/TRIWAQ)
        outputfile = [sim_dir filesep 'SDS-' runid];
        
    case {'sobek3'}
        %% SOBEK3
        sobekFile = dir([sim_dir filesep runid '.dsproj_data\Water level (op)*.nc*']);
        outputfile = [sim_dir filesep runid '.dsproj_data' filesep sobekFile.name];
        
    case {'sobek3_new'}
        %% SOBEK3 new
        outputfile = [sim_dir filesep 'dflow1d\output\observations.nc'];
        
    case{'implic'}
        %% IMPLIC
        outputfile = sim_dir;
    case{'waqua_scaloost'}
        outputfile = [sim_dir filesep '**stationName**_' runid];
end