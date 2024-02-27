function cosmos_preProcess(hm,m)

tmpdir=hm.tempDir;
jobdir=hm.jobDir;

inpdir=[hm.models(m).datafolder 'input' filesep];
mdl=hm.models(m).name;

%% Make model folder in scenarion directory
makedir([hm.scenarioDir 'models' filesep hm.models(m).continent filesep mdl]);
makedir([hm.scenarioDir 'models' filesep hm.models(m).continent filesep mdl filesep 'archive']);
makedir([hm.scenarioDir 'models' filesep hm.models(m).continent filesep mdl filesep 'restart']);

%% Clear temp directory
lst=dir(tmpdir);
for i=1:length(lst)
    if isdir([tmpdir lst(i).name])
        switch lst(i).name
            case{'.','..'}
            otherwise
                [success,message,messageid]=rmdir([tmpdir lst(i).name],'s');
        end
    end
end
try
    delete([tmpdir '*']);
end

%% Copy input to temp folder 
[success,message,messageid] = copyfile([inpdir '*'],tmpdir,'f');

%% Startpre-processing
switch lower(hm.models(m).type)
    case{'delft3dflow','delft3dflowwave'}
        cosmos_preProcessDelft3D(hm,m)
    case{'ww3'}
        cosmos_preProcessWW3(hm,m)
    case{'xbeach'}
        cosmos_preProcessXBeach(hm,m)
    case{'xbeachcluster'}
        cosmos_preProcessXBeachCluster(hm,m);
end

%% Move to job directory

disp(['Moving input to job directory - ' mdl]);

makedir(jobdir);
makedir(jobdir,mdl);

[success,message,messageid]=movefile([tmpdir '*'],[jobdir mdl],'f');

[success,message,messageid]=rmdir([tmpdir '*']);
