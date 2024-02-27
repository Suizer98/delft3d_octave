function cosmos_determineHazardsXBeachCluster(hm,m)

model=hm.models(m);

np=hm.models(m).nrProfiles;

for ip=1:np
    
    profile=model.profile(ip).name;
    
    inputdir=[model.cycledirinput profile filesep];
    archivedir=[model.cycledirnetcdf  profile filesep];
    xmldir=[model.cycledirhazards profile filesep];
    
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
