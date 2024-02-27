function hm=cosmos_readConfigFile

hm.eMailOnError.send=0;

fname=['..' filesep '..' filesep 'cosmos.ini'];
[pathstr,name,ext] = fileparts(pwd);
hm.scenario=name;

% if ~exist(fname,'file')
% 
%     %% Make cosmos.ini
%     rundir = uigetdir(pwd, 'Select Run Directory');
%     hm.runDir=[rundir filesep];
%     
% %     [filename,pathname,filterindex] = uigetfile([hm.runDir 'scenarios\*.xml'],'Select scenario');
% %     hm.scenario = filename(1:end-4);
% 
%     datadir = uigetdir(pwd, 'Select Data Directory');
%     hm.dataDir=[datadir filesep];
% 
%     jobdir = uigetdir(pwd, 'Select Job Directory');
%     hm.jobDir=[jobdir filesep];
%     
%     webdir = uigetdir(pwd, 'Select Website Directory');
%     hm.webDir=[webdir filesep];
% 
%     hm.nrProfilesPerJob=50;
%     hm.eMailOnError.send=0;
%     hm.eMailOnError.adress='Maarten.vanOrmondt@deltares.nl';
%     hm.h4.userName='ormondt';
%     hm.h4.password='0rm0ndt';
%     hm.h4.path=strrep(['/' hm.jobDir],'\','/');
%     hm.h4.path=strrep(hm.h4.path,':','');
% 
%     fid=fopen(fname,'wt');
%     fprintf(fid,'%s\n',['RunDirectory     ' hm.runDir]);
%     fprintf(fid,'%s\n',['DataDirectory    ' hm.dataDir]);
%     fprintf(fid,'%s\n',['JobDirectory     ' hm.jobDir]);
%     fprintf(fid,'%s\n',['WebDirectory     ' hm.webDir]);
%     fprintf(fid,'%s\n',['H4Directory      ' hm.h4.path]);
%     fprintf(fid,'%s\n',['H4UserName       ' hm.h4.userName]);
%     fprintf(fid,'%s\n',['H4Password       ' hm.h4.password]);
% %    fprintf(fid,'%s\n',['Scenario         ' hm.scenario]);
%     fprintf(fid,'%s\n',['eMailOnError     0']);
%     fprintf(fid,'%s\n',['eMailAdress      ' hm.eMailOnError.adress]);
%     fprintf(fid,'%s\n',['nrProfilesPerJob ' num2str(hm.nrProfilesPerJob)]);
%     fclose(fid);
% 
% end

txt=ReadTextFile(fname);

% Default values
n=length(txt);
hm.nrProfilesPerJob=50;
hm.clusterNode=[];
hm.exedirflow='/u/ormondt/d3d_versions/delftflow_trunk2/bin/';
hm.meteoVersion='1.03';
hm.delay=8; % Delay in hours
% hm.runEnv='h4';
hm.d3d_home='c:\delft3d';
hm.ww3_home='c:\wavewatch3';
hm.xbeach_home='c:\xbeach';
hm.mpi_home='';
hm.scp.hostname='';
hm.scp.username='';
hm.scp.password='';
hm.scp.hostkey='';

for i=1:n
    switch lower(txt{i}),
        case {'rundirectory'}
            hm.runDir=txt{i+1};
        case {'datadirectory'}
            hm.dataDir=txt{i+1};
        case {'jobdirectory'}
            hm.jobDir=txt{i+1};
        case {'webdirectory'}
            hm.webDir=txt{i+1};
        case {'archivedirectory'}
            hm.archiveDir=txt{i+1};
%         case {'scenario'}
%             hm.scenario=txt{i+1};
        case {'emailonerror'}
            hm.eMailOnError.send=str2double(txt{i+1});
        case {'emailadress'}
            hm.eMailOnError.adress=txt{i+1};
        case {'h4username'}
            hm.h4.userName=txt{i+1};
        case {'h4password'}
            hm.h4.password=txt{i+1};
        case {'h4directory'}
            hm.h4.path=txt{i+1};
        case {'nrprofilesperjob'}
            hm.nrProfilesPerJob=str2double(txt{i+1});
        case {'clusternode'}
            hm.clusterNode=txt{i+1};
        case {'exedirflow'}
            hm.exedirflow=txt{i+1};
        case {'meteoversion'}
            hm.meteoversion=txt{i+1};
        case {'delay'}
            hm.delay=str2double(txt{i+1});
%         case {'runenvironment'}
%             hm.runEnv=txt{i+1};
        case {'d3d_home'}
            hm.d3d_home=txt{i+1};
        case {'ww3_home'}
            hm.ww3_home=txt{i+1};
        case {'xbeach_home'}
            hm.xbeach_home=txt{i+1};
        case {'mpi_home'}
            hm.mpi_home=txt{i+1};
        case {'scphostname'}
            hm.scp.hostname=txt{i+1};
        case {'scpusername'}
            hm.scp.username=txt{i+1};
        case {'scppassword'}
            hm.scp.password=txt{i+1};
        case {'scphostkey'}
            hm.scp.hostkey=txt{i+1};
    end
end

hm.meteofolder=[hm.runDir 'externalforcing' filesep 'meteo' filesep];
hm.oceanmodelsfolder=[hm.runDir 'externalforcing' filesep 'oceanmodels' filesep];
hm.scenarioDir=[hm.runDir 'scenarios' filesep hm.scenario filesep];
hm.jobDir=[hm.jobDir hm.scenario filesep];
hm.h4.path=[hm.h4.path hm.scenario '/'];
hm.modelDir=[hm.scenarioDir 'models' filesep];
hm.archiveDir=hm.modelDir;
hm.tempDir=[hm.scenarioDir 'temp' filesep];
hm.exeDir=[hm.dataDir 'exe' filesep];
makedir(hm.tempDir);

hm.scp.open=['open ' hm.scp.username ':' hm.scp.password '@' hm.scp.hostname ' -timeout=15 -hostkey="' hm.scp.hostkey '"'];
