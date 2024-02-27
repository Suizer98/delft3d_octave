function cosmos_determineHazardsXBeachCluster(hm,m)

model=hm.models(m);
archivedir=[hm.archiveDir filesep model.continent filesep model.name filesep 'archive' filesep];
cycledir=[archivedir hm.cycStr filesep];

np=hm.models(m).nrProfiles;

for ip=1:np
    
    profile=model.profile(ip).name;
    
    inputdir=[inpdir profile filesep];
    archivedir=[cycledir 'netcdf' filesep profile filesep];
    xmldir=[cycledir filesep 'hazards' filesep profile filesep];
    
    % Check if simulation has run
    if exist([archivedir profile '.nc'],'file')
        
        if ~exist(xmldir,'dir')
            mkdir(xmldir);
        end
        
        tref=model.tFlowStart;

        % Compute run-up etc.
        profile_calcs(inputdir,archivedir,xmldir,profile,tref);
        
    end
    
end
