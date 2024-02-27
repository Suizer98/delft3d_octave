function cosmos_extractDataDelft3DMaps(hm,m)

model=hm.models(m);

%appendeddir=model.appendeddirmaps;
cycledirmaps=model.cycledirmaps;
outdir=model.cyclediroutput;

np=model.nrMapDatasets;

for ip=1:np
    
    try
        
        par=model.mapDatasets(ip).name;
        fout=[cycledirmaps par '.mat'];
        
        data=[];
        
        switch lower(par)
            case{'peak_water_level'}
                
                % Read peak water levels from fourier file
                fif=tekal('open',[outdir 'fourier.' model.runid],'loaddata');
                maxwl=squeeze(fif.Field.Data(:,:,7));
                fim=qpfopen([outdir 'trim-' model.runid '.dat']);
                dps=qpread(fim,1,'bed level in water level points','griddata',1,0,0);
                maxwl(isnan(dps.Val))=NaN;
                maxwl(dps.Val>0)=NaN;
                data.X=dps.X;
                data.Y=dps.Y;
                data.Val=maxwl;
                times=dps.Time(1);
                typ='2dscalar';
                
            otherwise
                
                fil=getParameterInfo(hm,par,'model',model.type,'datatype','map','file');
                filpar=getParameterInfo(hm,par,'model',model.type,'datatype','map','name');
                typ=getParameterInfo(hm,par,'type');
                
                switch lower(typ)
                    case{'magnitude','angle'}
                        typ='2dscalar';
                    case{'vector'}
                        typ='2dvector';
                end
                
                layer=model.mapDatasets(ip).layer;
                
                switch fil
                    case{'wavm','trim'}
                        if ~exist([outdir fil '-' model.runid '.dat'],'file')
                            disp(['trim file ' model.name ' does not exist!']);
                            %                    killAll;
                        else
                            fid = qpfopen([outdir fil '-' model.runid '.dat']);
                            times = qpread(fid,1,filpar,'times');
                            data.Val=zeros();
                            % Read first time step to get dimensions and grid
                            if ~isempty(layer)
                                data0 = qpread(fid,1,filpar,'griddata',1,0,0,layer);
                            else
                                data0 = qpread(fid,1,filpar,'griddata',1,0,0);
                            end
                            data.X=squeeze(data0.X);
                            data.Y=squeeze(data0.Y);
                            data.Val=zeros(length(times),size(data.X,1),size(data.X,2));
                            % Loop through all time steps
                            for it=1:length(times)
                                if ~isempty(layer)
                                    d = qpread(fid,1,filpar,'data',it,0,0,layer);
                                else
                                    if length(times)>1
                                        d = qpread(fid,1,filpar,'data',it,0,0);
                                    else
                                        d = qpread(fid,1,filpar,'data',0,0);
                                    end
                                end
                                if isfield(d,'Val')
                                    data.Val(it,:,:)=d.Val;
                                else
                                    data.XComp(it,:,:)=d.XComp;
                                    data.YComp(it,:,:)=d.YComp;
                                end
                            end
                            switch lower(par)
                                case{'hs','tp'}
                                    data.Val(data.Val==0)=NaN;
                            end
                        end
                    case{'meteo'}
                        switch par
                            case{'windvel'}
                                meteo=model.meteowind;
                        end
                        ii=strmatch(meteo,hm.meteoNames,'exact');
                        dt=hm.meteo(ii).timeStep;
                        data = extractMeteoData(hm.meteofolder,model,dt,par);
                        times = data.Time;
                    case{'oil-map'}
                        %                data=getSurfaceOil(outdir,model.runid,'Ekofisk (floating)');
                        data=getSurfaceOil(outdir,model.runid,'light_crude');
                        times=data.Time;
                end
                
        end
        
        s=[];
        s.Parameter=par;
        s.X=data.X;
        s.Y=data.Y;
        
        ifirst=find(abs(times-hm.cycle)<0.001);
        
        if ~isempty(ifirst)
            s.Time=times(ifirst:end);
        else
            s.Time=times;
            ifirst=1;
        end
        
        switch typ
            case{'2dscalar'}
                if ndims(data.Val)==3
                    s.Val=data.Val(ifirst:end,:,:);
                else
                    s.Val=data.Val;
                end
                save(fout,'-struct','s','Parameter','Time','X','Y','Val');
            case{'2dvector'}
                if ndims(data.XComp)==3
                    s.U=data.XComp(ifirst:end,:,:);
                    s.V=data.YComp(ifirst:end,:,:);
                else
                    s.U=data.XComp;
                    s.V=data.YComp;
                end
                %                s.mag=sqrt(s.U.^2+s.V.^2);
                %                save(fout,'-struct','s','Parameter','Time','X','Y','U','V','Mag');
                save(fout,'-struct','s','Parameter','Time','X','Y','U','V');
        end
        %     for t=t0:(dt/1440):t1;
        %    it=find(times==t);
        %         s.Val=hs.Val();
        %     fout=[archdir 'appended\maps\hs.' datestr(t,'yyyymmdd.HHMMSS') '.mat'];
        %     save(fout,'-struct','s','Parameter','Time','x','y','Val');
        %     end
        
    catch
        WriteErrorLogFile(hm,['Something went wrong extracting map data - ' par ' from ' fil ' in ' hm.models(m).name]);
    end
    
    
end
