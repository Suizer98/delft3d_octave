function cosmos_extractDataDelft3DTimeSeries3(hm,m)

model=hm.models(m);

appendeddir=model.appendeddirtimeseries;
cycledir=model.cycledirtimeseries;
outdir=model.cyclediroutput;

%% Time Series
trihfile=[outdir 'trih-' model.runid '.dat'];

if exist(trihfile,'file')
    
    fid=qpfopen(trihfile);
    
    [fieldnames,dims,nval] = qpread(fid,1);
    
    tstart=max(model.tWaveOkay,model.tFlowOkay);
    
    for istat=1:model.nrStations
        
        stName=model.stations(istat).name;
        
        for i=1:model.stations(istat).nrDatasets
            
            data=[];
            
            try
                
                par=model.stations(istat).datasets(i).parameter;
                
                switch par
                    case{'sp2'}
                    otherwise
                        parLongName=getParameterInfo(hm,par,'longname');
                        
                        s.Time=[];
                        s.Val=[];
                        fname=[appendeddir par '.' stName '.mat'];
                        if exist(fname,'file')
                            s=load(fname);
                            
                            % This shouldn't have to happen
                            ntt=length(s.Time);
                            ntv=length(s.Val);
                            nt=min(ntt,ntv);
                            s.Time=s.Time(1:nt);
                            s.Val=s.Val(1:nt);
                            
                            n1=find(s.Time<tstart);
                            if ~isempty(n1)
                                n1=n1(end);
                                s.Time=s.Time(1:n1);
                                s.Val=s.Val(1:n1);
                            else
                                s.Time=[];
                                s.Val=[];
                            end
                        else
                            s.Parameter=parLongName;
                        end
                        
                        fil=getParameterInfo(hm,par,'model',model.type,'datatype','timeseries','file');
                        filpar=getParameterInfo(hm,par,'model',model.type,'datatype','timeseries','name');
                        
                        if ~isempty(fil) && ~isempty(filpar)
                            
                            switch lower(fil)
                                case{'trih'}
                                    ii=strmatch(filpar,fieldnames,'exact');
                                    if ~isempty(ii)
                                        if ~isempty(model.stations(istat).datasets(i).layer)
                                            data=qpread(fid,filpar,'data',0,istat,model.stations(istat).datasets(i).layer);
                                        else
                                            data=qpread(fid,filpar,'data',0,istat);
                                        end
                                    end
                                case{'trim'}
                                    mm=model.stations(i).m;
                                    nn=model.stations(i).n;
                                    fid=qpfopen([outdir 'trim-' model.runid '.dat']);
                                    data=qpread(fid,filpar,'data',0,mm,nn);
                                case{'sp2mat'}
                                    if ~exist([archdir hm.cycStr filesep 'sp2' filesep 'sp2.' stName '.mat'],'file')
                                        
                                    else
                                        d=load([archdir hm.cycStr filesep 'sp2' filesep 'sp2.' stName '.mat']);
                                        for t=1:length(d.SP2Data.time)
                                            data.Time(t)=d.SP2Data.time(t).spec.times;
                                            if strcmpi(par,'hswell')
                                                data.Val(t)=d.SP2Data.time(t).Separation.Swell.Hs;
                                            end
                                            if strcmpi(par,'tswell')
                                                data.Val(t)=d.SP2Data.time(t).Separation.Swell.Tp;
                                            end
                                        end
                                        
                                    end
                            end
                            
                            if isfield(data,'XComp')
                                % Vector data, needs to be converted to
                                % magnitude
                                filcomp=getParameterInfo(hm,par,'model',model.type,'datatype','timeseries','component');
                                switch filcomp
                                    case{'directionto'}
                                        data.Val=mod(180*atan2(data.YComp,data.XComp)/pi,360);
                                    case{'directionfrom'}
                                        data.Val=mod(180*atan2(data.YComp,data.XComp)/pi+180,360);
                                    case{'magnitude'}
                                        data.Val=sqrt(data.XComp.^2+data.YComp.^2);
                                end
                            end
                            
                        end
                        
                        if ~isempty(data)
                            
                            % Appended data
                            
                            n2=find(data.Time>=tstart);
                            n2=n2(1)+1;
                            s2.Time=data.Time(n2:end);
                            s.Time=[s.Time;s2.Time];
                            
                            s2.Val=data.Val(n2:end);
                            s.Val=[s.Val;s2.Val];
                            save(fname,'-struct','s','Parameter','Time','Val');
                            
                            % Just data from last run
                            s3.Parameter=parLongName;
                            s3.Time=data.Time;
                            s3.Val=data.Val;
                            
                            fname=[cycledir par '.' stName '.mat'];
                            save(fname,'-struct','s3','Parameter','Time','Val');
                            
                        end
                end
            catch
                WriteErrorLogFile(hm,['Something went wrong extracting time series data - ' hm.models(m).name]);
            end
        end
    end
end
