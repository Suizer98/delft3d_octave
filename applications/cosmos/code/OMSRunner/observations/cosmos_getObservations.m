function cosmos_getObservations(hm)

%% First determine which observations are needed 


nobs=0;
idbs=[];
iids=[];
ipars=[];

for i=1:hm.nrModels
    % Check if observations are plotted
    for k=1:hm.models(i).nrStations
        for iplt=1:length(hm.models(i).stations(k).plots)
            for ip=1:length(hm.models(i).stations(k).plots(iplt).datasets)
                if strcmpi(hm.models(i).stations(k).plots(iplt).datasets(ip).type,'observed')
                    par=hm.models(i).stations(k).plots(iplt).datasets(ip).parameter;
                    obssrc=hm.models(i).stations(k).plots(iplt).datasets(ip).source;
                    obsid=hm.models(i).stations(k).plots(iplt).datasets(ip).id;
                    % Determine which database observation is in
                    idb=strmatch(lower(obssrc),hm.observationDatabases,'exact');
                    if ~isempty(idb)
                        % Determine which station is needed
                        iid=strmatch(obsid,hm.observationStations{idb}.IDCode,'exact');
                        if ~isempty(iid)
                            % Determine which parameter is needed
                            par2=getParameterInfo(hm,lower(par),'source',obssrc,'dbname');
                            ipar=strmatch(lower(par2),lower(hm.observationStations{idb}.Parameters(iid).Name),'exact');
                            if ~isempty(ipar)
                                % Check if this data is available
                                if hm.observationStations{idb}.Parameters(iid).Status(ipar)>0
                                    % Check if data will already be downloaded
                                    if sum(idbs==idb & iids==iid & ipars==ipar)==0
                                        nobs=nobs+1;
                                        idbs(nobs)=idb;
                                        iids(nobs)=iid;
                                        ipars(nobs)=ipar;
                                        % Parameter name used by OpenDAP
                                        opendappar{nobs}=getParameterInfo(hm,lower(par),'source',obssrc,'name');
                                        plotpar{nobs}=lower(par);
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

%% Now go get the data

for i=1:nobs

    idb=idbs(i);
    iid=iids(i);
    ipar=ipars(i);
    
    db=hm.observationDatabases{idb};
    idcode=hm.observationStations{idb}.IDCode{iid};
    par=hm.observationStations{idb}.Parameters(iid).Name{ipar};
    
    disp(['Downloading observations of ' par ' for ' idcode ' from ' db ' ...']);
    
    url=hm.observationStations{idb}.URL;
    
    if strcmpi(hm.scenarioType,'forecast')
        t0=floor(hm.cycle-8);
    else
        t0=hm.cycle;
    end

    t1=ceil(hm.cycle+hm.runTime/24);

    try
 
        par2=opendappar{i};
        
        switch db
            case{'ndbc'}
                [t,val]=getTimeSeriesFromNDBC(url,t0,t1,idcode,par2);
            case{'co-ops'}
%                [t,val]=getTimeSeriesFromCoops(url,t0,t1,idcode,par2);
                [t,val]=getWLFromCoops(idcode,t0,t1);
            case{'matroos'}
                [t,val]=getTimeSeriesFromMatroos(url,t0,t1,hm.observationStations{idb}.Name{iid},par2);
        end

        if ~isempty(t)
            % Make directory
            makedir(hm.scenarioDir,'observations',db,idcode);
            fname=[hm.scenarioDir 'observations' filesep db filesep idcode filesep plotpar{i} '.' idcode '.mat'];
            data.Name=idcode;
            data.Parameter=par;
            data.Time=t;
            data.Val=val;
            save(fname,'-struct','data','Name','Parameter','Time','Val');
        end

    catch
        disp(['Something went wrong while downloading ' par ' for ' idcode ' from ' db]);
    end

end
