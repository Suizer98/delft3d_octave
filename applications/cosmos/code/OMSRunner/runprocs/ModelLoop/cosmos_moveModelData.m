function cosmos_moveModelData(hm,m)
% Creates required archive folders
% Moves data from run folder to archive folders

model=hm.models(m);

% Create archive folders
archivedir=[hm.archiveDir filesep model.continent filesep model.name filesep 'archive' filesep];

hm.models(m).cycledirinput=[archivedir 'input' filesep hm.cycStr filesep];
hm.models(m).cyclediroutput=[archivedir 'output' filesep hm.cycStr filesep];
hm.models(m).cycledirfigures=[archivedir 'figures' filesep hm.cycStr filesep];

dr=model.dir;

switch lower(model.type)
    case{'delft3dflow','delft3dflowwave','ww3','xbeach'}
        
        % Delete existing folders        
        delete([hm.models(m).cycledirinput '*']);
        delete([hm.models(m).cyclediroutput '*']);
        delete([hm.models(m).cycledirfigures '*']);
        [status,message,messageid]=rmdir(hm.models(m).cycledirinput,'s');
        [status,message,messageid]=rmdir(hm.models(m).cyclediroutput,'s');
        [status,message,messageid]=rmdir(hm.models(m).cycledirfigures,'s');        
        
        % Create restart folder        
        makedir(dr,'restart');
end

makedir(hm.models(m).cycledirinput);
makedir(hm.models(m).cyclediroutput);
makedir(hm.models(m).cycledirfigures);

switch lower(model.type)
    case{'delft3dflow','delft3dflowwave'}
        makedir(dr,'restart','hot');
        makedir(dr,'restart','tri-rst');
        cosmos_moveDataDelft3D(hm,m);
    case{'ww3'}
        cosmos_moveDataWW3(hm,m);
    case{'xbeach'}
        cosmos_moveDataXBeach(hm,m);
    case{'xbeachcluster'}
        cosmos_moveDataXBeachCluster(hm,m);
end

[status,message,messageid]=rmdir([hm.jobDir model.name], 's');
