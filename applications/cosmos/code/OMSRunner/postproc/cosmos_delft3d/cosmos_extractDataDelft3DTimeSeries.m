function cosmos_extractDataDelft3DTimeSeries(hm,m)

model=hm.models(m);
dr=model.dir;
outdir=[dr 'lastrun' filesep 'output' filesep];
archdir = model.archiveDir;

%% Time Series
fid=qpfopen([outdir 'trih-' model.runid '.dat']);
[fieldnames,dims,nval] = qpread(fid,1);

for i=1:model.nrStations

    stName=model.stations(i).name;
    stLongName=model.stations(i).longName;
    tstart=max(model.tWaveOkay,model.tFlowOkay);

    for k=1:model.stations(i).nrParameters

        data=[];

        par=model.stations(i).parameters(k).name;
        parLongName=getParameterInfo(hm,par,'longname');

        try
            s.Time=[];
            s.Val=[];
            fname=[archdir 'appended' filesep 'timeseries' filesep par '.' stName '.mat'];
            if exist(fname,'file')
                s=load(fname);
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
                s.Name=stLongName;
                s.Parameter=parLongName;
            end

            fil=getParameterInfo(hm,par,'model',model.type,'datatype','timeseries','file');
            filpar=getParameterInfo(hm,par,'model',model.type,'datatype','timeseries','name');

            if ~isempty(fil) && ~isempty(filpar)

                switch lower(fil)
                    case{'trih'}
                        if ~exist([outdir 'trih-' model.runid '.dat'],'file')
                            %                             killAll;
                        else
                            ii=strmatch(filpar,fieldnames,'exact');
                            if ~isempty(ii)
                                if ~isempty(model.stations(i).parameters(k).layer)
                                    data=qpread(fid,filpar,'data',0,i,model.stations(i).parameters(k).layer);
                                else
                                    data=qpread(fid,filpar,'data',0,i);
                                end
                            end
                        end
                    case{'trim'}
                        if ~exist([outdir 'trim-' model.runid '.dat'],'file')
                            %                             killAll;
                        else
                            mm=model.stations(i).m;
                            nn=model.stations(i).N;
                            fid=qpfopen([outdir 'trim-' model.runid '.dat']);
                            data=qpread(fid,filpar,'data',0,mm,nn);
                            if isfield(data,'XComp')
                                % Vector data, needs to be converted to
                                % magnitude
                                filcomp=getParameterInfo(hm,par,'model',model.type,'datatype','timeseries','component');
                                switch lower(filcomp)
                                    case{'magnitude'}
                                        data.Val=sqrt(data.XComp.^2 + data.YComp.^2);
                                    case{'angle (degrees)'}
                                        %                                ang=180*(atan2(data.YComp,data.XComp)-pi)/pi;
                                        ang=180*(atan2(data.YComp,data.XComp))/pi;
                                        ang=mod(ang,360);
                                        data.Val=ang;
                                end
                            end
                        end
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
            end

            if ~isempty(data)

                n2=find(data.Time>=tstart);
                n2=n2(1)+1;
                s2.Time=data.Time(n2:end);
                s2.Val=data.Val(n2:end);

                s.Time=[s.Time;s2.Time];
                s.Val=[s.Val;s2.Val];
                save(fname,'-struct','s','Name','Parameter','Time','Val');

                s3.Name=stLongName;
                s3.Parameter=parLongName;
                s3.Time=data.Time;
                s3.Val=data.Val;

                fname=[archdir hm.cycStr filesep 'timeseries' filesep par '.' stName '.mat'];

                save(fname,'-struct','s3','Name','Parameter','Time','Val');

            end

        catch
            WriteErrorLogFile(hm,['Something went wrong extracting time series data - ' hm.models(m).name]);
        end
    end
end
