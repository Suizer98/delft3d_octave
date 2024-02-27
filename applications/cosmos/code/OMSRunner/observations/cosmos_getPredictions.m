function cosmos_getPredictions(hm)

%% First determine which predictions are needed 

nobs=0;
idbs=[];
iids=[];

                            try

for i=1:hm.nrModels
    % Check if observations are plotted
    for k=1:hm.models(i).nrStations
        for iplt=1:length(hm.models(i).stations(k).plots)
            for ip=1:length(hm.models(i).stations(k).plots(iplt).datasets)
                if strcmpi(hm.models(i).stations(k).plots(iplt).datasets(ip).type,'predicted')
                    prdsrc=hm.models(i).stations(k).plots(iplt).datasets(ip).source;
                    prdid=hm.models(i).stations(k).plots(iplt).datasets(ip).id;
                    % Determine which database observation is in
                    idb=strmatch(lower(prdsrc),hm.tideDatabases,'exact');
                    if ~isempty(idb) && ~isempty(prdid)
                        % Determine which station is needed
                        iid=strmatch(prdid,hm.tideStations{idb}.IDCode,'exact');
                        if ~isempty(iid)
                            % Check if data will already be downloaded
                            if length(iid)>1
                                iid=iid(2);                                
                            end
                            if sum(idbs==idb(1) & iids==iid(1))==0
                                nobs=nobs+1;
                                idbs(nobs)=idb(1);
                                iids(nobs)=iid(1);
                            end
                        end
                    end
                end
            end
        end
    end
end

                            catch
                                sghite=1
                            end

%% Now go get the data

for i=1:nobs

    idb=idbs(i);
    iid=iids(i);
    
    db=hm.tideDatabases{idb};
    idcode=hm.tideStations{idb}.IDCode{iid};
    
    % Make directory
    makedir(hm.scenarioDir,'observations',db,idcode);
    
    disp(['Generating water level prediction for ' idcode ' from ' db ' ...']);
    
    if strcmpi(hm.scenarioType,'forecast')
        t0=floor(hm.cycle-6);
    else
        t0=hm.cycle;
    end
    t1=ceil(hm.cycle+hm.runTime/24);

    try
        
        cmp=hm.tideStations{idb}.ComponentSet(iid);
        comp=[];
        A=[];
        G=[];

        for ii=1:length(cmp.Component)
            comp{ii}=cmp.Component{ii};
            A(ii,1)=cmp.Amplitude(ii);
            G(ii,1)=cmp.Phase(ii);
        end

%         dt=1/6;
%         [val,t]=delftPredict2007(comp,A,G,t0,t1,dt);
%         val=val(1:end-1);
%         t=t(1:end-1);

        dt=10/1440;
        t=t0:dt:t1;
        latitude=45;
        val=makeTidePrediction(t,comp,A,G,latitude); 
        
        fname=[hm.scenarioDir 'observations' filesep db filesep idcode filesep 'wl.' idcode '.mat'];
        data.Name=idcode;
        data.Parameter='water level';
        data.Time=t;
        data.Val=val;
        save(fname,'-struct','data','Name','Parameter','Time','Val');

    catch
        WriteErrorLogFile(hm,['Something went wrong while predicting water level for ' idcode ' from ' db ' - see oms.err']);
    end

end

