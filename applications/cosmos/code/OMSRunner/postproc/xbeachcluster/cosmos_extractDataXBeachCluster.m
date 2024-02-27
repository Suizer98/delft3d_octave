function cosmos_extractDataXBeachCluster(hm,m)

model=hm.models(m);

cycledirnetcdf=model.cycledirnetcdf;
outdir=model.cyclediroutput;

for ip=1:model.nrProfiles
    
    disp('Extracting data profile ')
    
    profile=model.profile(ip).name;

    disp(['Extracting data ' model.name ' - profile ' profile]);

    inputdir=[model.cycledirinput profile filesep];
    outputdir=[outdir profile filesep];
    archivedir=[cycledirnetcdf profile filesep];
    if ~exist(archivedir,'dir')
        mkdir(archivedir);
    end
    
    % Check if simulation has run
    if exist([outputdir 'dims.dat'],'file')
        
        tref=model.tFlowStart;
        

%         % Wave statistics from input sp2 files
%         [t,Dp,Tp,Hs] = calc_wavestats(inputdir);
%         
% %        dr=[model.archiveDir hm.cycStr filesep 'timeseries' filesep];
%         dr=archivedir;

%         s3.time=t;
%         s3.name=profile;
%         
%         s3.parameter='Significant wave height';
%         s3.Val=Hs;
%         fname=[dr 'hs.' profile '.mat'];
%         save(fname,'-struct','s3','Name','Parameter','Time','Val');
% 
%         s3.parameter='Peak wave period';
%         s3.Val=Tp;
%         fname=[dr 'tp.' profile '.mat'];
%         save(fname,'-struct','s3','Name','Parameter','Time','Val');
% 
%         s3.parameter='Peak wave direction';
%         s3.Val=Dp;
%         fname=[dr 'wavdir.' profile '.mat'];
%         save(fname,'-struct','s3','Name','Parameter','Time','Val');
% 
%         % Tide time series
%         s=load([inputdir 'tide.txt']);
%         s3.parameter='Water level';
%         s3.time=tref+s(:,1)/86400;
%         s3.Val=s(:,2);
%         fname=[dr 'wl.' profile '.mat'];
%         save(fname,'-struct','s3','Name','Parameter','Time','Val');

%         % Convert to netCDF
%         xbprofile2nc(inputdir,outputdir,archivedir,profile,tref);

        % Convert to netCDF
%        xbprofile2nc_all(inputdir,outputdir,archivedir,profile,tref);

%        unzip([inputdir 'sp2.zip'],inputdir);
        system([hm.exeDir 'unzip.exe -q ' inputdir 'sp2.zip -d ' inputdir]);
        xbprofile2nc_stat(inputdir,outputdir,archivedir,profile,tref);
        delete([inputdir '*.sp2']);

    end
    
end
