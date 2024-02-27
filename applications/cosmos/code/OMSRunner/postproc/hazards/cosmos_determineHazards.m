function hm=cosmos_determineHazards(hm,m)

model=hm.models(m);
archivedir=[hm.archiveDir filesep model.continent filesep model.name filesep 'archive' filesep];
hazarchdir=[archivedir 'hazards' filesep hm.cycStr filesep];

% Create hazard xml folder and remove all existing xml files
makedir(hazarchdir);
delete([hazarchdir '*.xml']);

for j=1:hm.models(m).nrHazards
    switch lower(hm.models(m).hazards(j).type)
        case{'ripcurrents'}
            disp('Rip currents ...');
            hm=cosmos_determineRipCurrents(hm,m,j);
    end
end
