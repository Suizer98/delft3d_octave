function [hm,ifin]=cosmos_checkForFinishedSimulations(hm)
% Checks for finished simulations in job directory

%% Daemon

ifin=[];
k=0;

f=dir([hm.jobDir filesep 'finished.*']);
n=length(f);

if n>0
    fname=[hm.jobDir f(1).name];
    mdl=f(1).name(25:end);
    m=findstrinstruct(hm.models,'name',mdl);
    k=k+1;
    ifin(k)=m;
end

%% And now H4
for i=1:hm.nrModels
    switch lower(hm.models(i).type)
        case{'xbeachcluster'}
            if isdir([hm.jobDir hm.models(i).name])
                hm.models(i).status='running';
                nprfperjob=hm.nrProfilesPerJob;
                njobs=ceil(hm.models(i).nrProfiles/nprfperjob);
                allready=1;
                for j=1:njobs
                    fname=[hm.jobDir hm.models(i).name filesep 'finished' num2str(j) '.txt'];
                    if ~exist(fname,'file')
                        allready=0;
                    end
                end
                if allready
                    k=k+1;
                    ifin(k)=i;
%                     hm.models(i).status='simulationfinished';
                end
            end
        otherwise
            if isdir([hm.jobDir hm.models(i).name])
                hm.models(i).status='running';
                if exist([hm.jobDir hm.models(i).name filesep 'finished.txt'],'file')
                    k=k+1;
                    ifin(k)=i;
%                     hm.models(i).status='simulationfinished';
                end
            end
    end
end

% Determine run times (only used to present on website)
for i=1:length(ifin)

    m=ifin(i);
    
    hm.models(m).simStart=0;
    hm.models(m).simStop=0;
    hm.models(m).runDuration=0;
    
    try
        
        switch hm.models(m).type
            case{'xbeachcluster'}
                startt=0;
                stopt=0;
                for j=1:njobs
                    fname=[hm.jobDir hm.models(m).name filesep 'finished' num2str(j) '.txt'];
                    fid=fopen(fname);
                    startstr = fgetl(fid);
                    stopstr = fgetl(fid);
                    fclose(fid);
                    delete(fname);
                    startt=max(datenum(startstr,'yyyymmdd HHMMSS'),startt);
                    stopt =max(datenum(stopstr,'yyyymmdd HHMMSS'),stopt);
                end
                
            otherwise
                fid=fopen(fname);
                startstr = fgetl(fid);
                stopstr = fgetl(fid);
                fclose(fid);
                
                startt=datenum(startstr,'yyyymmdd HHMMSS');
                stopt =datenum(stopstr,'yyyymmdd HHMMSS');
        end
        
        hm.models(m).simStart=startt;
        hm.models(m).simStop=stopt;
        hm.models(m).runDuration=(stopt-startt)*86400;
        
    end
    
end

