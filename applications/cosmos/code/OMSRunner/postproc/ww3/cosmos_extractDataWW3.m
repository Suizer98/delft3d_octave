function cosmos_extractDataWW3(hm,m)

model=hm.models(m);

appendeddirtimeseries=model.appendeddirtimeseries;
appendeddirmaps=model.appendeddirmaps;
cycledirmaps=model.cycledirmaps;
cycledirtimeseries=model.cycledirtimeseries;
cycledirsp2=model.cycledirsp2;
outdir=model.cyclediroutput;

%% Maps

curdir=pwd;

[status,message,messageid]=copyfile([outdir 'ww3.ctl'],curdir,'f');
[status,message,messageid]=copyfile([outdir 'ww3.grads'],curdir,'f');

ExtractGrads(hm,m);

par='windvel';
ii=strmatch(model.meteowind,hm.meteoNames,'exact');
dt=hm.meteo(ii).timeStep;
data = extractMeteoData(hm.meteofolder,model,dt,par);
times = data.Time;
s=[];
s.Parameter=par;
s.X=data.X;
s.Y=data.Y;

ifirst=find(times==hm.cycle);

if ~isempty(ifirst)
    s.Time=times(ifirst:end);
else
    s.Time=times;
end

fout=[cycledirmaps par '.mat'];

if ndims(data.XComp)==3
    s.U=data.XComp(ifirst:end,:,:);
    s.V=data.YComp(ifirst:end,:,:);
else
    s.U=data.XComp;
    s.V=data.YComp;
end

save(fout,'-struct','s','Parameter','Time','X','Y','U','V');

delete('ww3.ctl');
delete('ww3.grads');

%% Time Series

if model.nrStations>0

    archdir=cycledirsp2;

    % 2D spectra
    k=0;
    % Find stations for which 2D spectra must be stored. 
    for istat=1:model.nrStations
        for j=1:model.stations(istat).nrDatasets
            if strcmpi(model.stations(istat).datasets(j).parameter,'sp2')
                k=k+1;
                isp2(k)=istat;
                fnames{k}=[archdir 'sp2.' model.stations(istat).datasets(j).sp2id '.mat'];
            end
        end
    end    
    if k>0
        cosmos_extractWW3spectra([outdir 'ww3.' model.name '.spc'],isp2,fnames);
    end
    
    % Wave statistics
    
    [t,hs,tp,wavdir]=ReadTab33(hm,m,[outdir 'tab33.ww3']);
    
    tstart=model.tWaveOkay;
    
    for istat=1:model.nrStations

        st=model.stations(istat).name;

%        for i=1:model.stations(istat).nrDatasets
                        
            % Hs
            fname=[appendeddirtimeseries 'hs.' st '.mat'];
            
            s.Time=[];
            s.Val=[];
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
            end
            
            s2.Val=hs(:,istat);
            s2.Time=t;
            
            n2=find(s2.Time>=tstart);
            n2=n2(1)+1;
            
            s2.Time=s2.Time(n2:end);
            s2.Val=s2.Val(n2:end);
            
            s.Time=[s.Time;s2.Time];
            s.Val=[s.Val;s2.Val];
            
            s.Parameter='hs';
            fname=[appendeddirtimeseries 'hs.' st '.mat'];
            save(fname,'-struct','s','Parameter','Time','Val');
            
            s3.Parameter='hs';
            s3.Val=hs(:,istat);
            s3.Time=t;
            fname=[cycledirtimeseries filesep 'hs.' st '.mat'];
            save(fname,'-struct','s3','Parameter','Time','Val');
            
            % Tp
            fname=[appendeddirtimeseries 'tp.' st '.mat'];
            
            s.Time=[];
            s.Val=[];
            if exist(fname,'file')
                s=load(fname);
                n1=find(s.Time<model.tOutputStart);
                if ~isempty(n1)
                    n1=n1(end);
                    s.Time=s.Time(1:n1);
                    s.Val=s.Val(1:n1);
                else
                    s.Time=[];
                    s.Val=[];
                end
            end
            
            s2.Val=tp(:,istat);
            s2.Time=t;
            
            n2=find(s2.Time>=model.tOutputStart);
            n2=n2(1)+1;
            
            s2.Time=s2.Time(n2:end);
            s2.Val=s2.Val(n2:end);
            
            s.Time=[s.Time;s2.Time];
            s.Val=[s.Val;s2.Val];
            
            s.Parameter='tp';
            fname=[appendeddirtimeseries 'tp.' st '.mat'];
            save(fname,'-struct','s','Parameter','Time','Val');
            
            s3.Parameter='tp';
            s3.Val=tp(:,istat);
            s3.Time=t;
            fname=[cycledirtimeseries filesep 'tp.' st '.mat'];
            save(fname,'-struct','s3','Parameter','Time','Val');

            
             % Wavdir
            fname=[appendeddirtimeseries 'wavdir.' st '.mat'];
            
            s.Time=[];
            s.Val=[];
            if exist(fname,'file')
                s=load(fname);
                n1=find(s.Time<model.tOutputStart);
                if ~isempty(n1)
                    n1=n1(end);
                    s.Time=s.Time(1:n1);
                    s.Val=s.Val(1:n1);
                else
                    s.Time=[];
                    s.Val=[];
                end
            end
            
            s2.Val=wavdir(:,istat);
            s2.Time=t;
            
            n2=find(s2.Time>=model.tOutputStart);
            n2=n2(1)+1;
            
            s2.Time=s2.Time(n2:end);
            s2.Val=s2.Val(n2:end);
            
            s.Time=[s.Time;s2.Time];
            s.Val=[s.Val;s2.Val];
            
            s.Parameter='wavdir';
            fname=[appendeddirtimeseries 'wavdir.' st '.mat'];
            save(fname,'-struct','s','Parameter','Time','Val');
            
            s3.Parameter='wavdir';
            s3.Val=wavdir(:,istat);
            s3.Time=t;
            fname=[cycledirtimeseries filesep 'wavdir.' st '.mat'];
            save(fname,'-struct','s3','Parameter','Time','Val');           
            
            
%        end
    end
end


