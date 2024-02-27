function hm=cosmos_download_cyclone_track_forecasts(hm)

% Also download jtwc data to generate spw files
dr=[hm.meteofolder 'cyclone_track_forecasts' filesep 'jtwc' filesep];

alltracks=autodownloadjmv3(dr);

% Loop though tracks that were downloaded
for itrack=1:length(alltracks)
    tc=alltracks(itrack).tc;
    storm=[tc.basin num2str(tc.number) num2str(tc.year-2000)];
    dr2=[dr tc.basin filesep num2str(tc.year) filesep storm filesep];
    flist=dir([dr2 tc.basin '*']);
    % Now merge different advisories
    for iad=1:length(flist)
        tc=readjmv30([dr2 flist(iad).name]);        
        if iad==1
            tcm=tc;
        else
            it1=find(tcm.time<tc.first_forecast_time,1,'last');
            it2=find(tc.time>=tc.first_forecast_time,1,'first');
            tcm.time=[tcm.time(1:it1) tc.time(it2:end)];
            tcm.lon=[tcm.lon(1:it1) tc.lon(it2:end)];
            tcm.lat=[tcm.lat(1:it1) tc.lat(it2:end)];
            tcm.vmax=[tcm.vmax(1:it1,1:4);tc.vmax(it2:end,1:4)]; 
            tcm.r34=[tcm.r34(1:it1,1:4);tc.r34(it2:end,1:4)]; 
            tcm.r50=[tcm.r50(1:it1,1:4);tc.r50(it2:end,1:4)]; 
            tcm.r64=[tcm.r64(1:it1,1:4);tc.r64(it2:end,1:4)]; 
            tcm.r100=[tcm.r100(1:it1,1:4);tc.r100(it2:end,1:4)]; 
            tcm.advisorynumber=tc.advisorynumber;
        end
    end
    it=find(tcm.vmax>=30,1,'first');
    tcm.time=tcm.time(it:end);
    tcm.lon=tcm.lon(it:end);
    tcm.lat=tcm.lat(it:end);
    tcm.vmax=tcm.vmax(it:end,1:4);
    tcm.r34=tcm.r34(it:end,1:4);
    tcm.r50=tcm.r50(it:end,1:4);
    tcm.r64=tcm.r64(it:end,1:4);
    tcm.r100=tcm.r100(it:end,1:4);

    
    
    % Now create new cyclone structure
    
    tc=tcm;
    
    cyclone.method=2;
    cyclone.quadrantOption='perquadrant';
    cyclone.nrRadialBins=300;
    cyclone.nrDirectionalBins=36;
    cyclone.radius=300;
    cyclone.windconversionfactor=0.9;
    cyclone.initDir=0;
    cyclone.initSpeed=0;
    
    cyclone.nrTrackPoints=length(tc.time);
    
    nt=length(tc.time);
    
    % Set dummy values
    cyclone.trackT=zeros([nt 1]);
    cyclone.trackX=zeros([nt 1]);
    cyclone.trackY=zeros([nt 1]);
    cyclone.trackVMax=zeros([nt 4])-999;
    cyclone.trackPDrop=zeros([nt 4])-999;
    cyclone.trackRMax=zeros([nt 4])-999;
    cyclone.trackR100=zeros([nt 4])-999;
    cyclone.trackR65=zeros([nt 4])-999;
    cyclone.trackR50=zeros([nt 4])-999;
    cyclone.trackR35=zeros([nt 4])-999;
    cyclone.trackA=zeros([nt 4])-999;
    cyclone.trackB=zeros([nt 4])-999;
    
    k=0;
    for it=1:nt
        
        %        if (tc(it).r34(1))>=0
        
        k=k+1;
        
        cyclone.trackT(k)=tc.time(it);
        cyclone.trackX(k)=tc.lon(it);
        cyclone.trackY(k)=tc.lat(it);
        if isfield(tc,'vmax')
            cyclone.trackVMax(k,1:4)=tc.vmax(it,:);
        end
%         if isfield(tc,'p')
%             if (itype == 0)
%                 %  Modified to use a better value for background atm.
%                 %  pressure (RSL, 16 Dec 2011)
%                 %cyclone.trackPDrop(k,1:4)=[101200 101200 101200 101200] - tc.p(it,:);
%                 cyclone.trackPDrop(k,1:4)=[bg_press_Pa bg_press_Pa bg_press_Pa bg_press_Pa] - tc.p(it,:);
%             else
%                 %  JTWC, NHC current warning files: pressure drop is
%                 %  calculated by the parsing script(s).
%                 cyclone.trackPDrop(k,1:4) = tc.p(it,:);
%             end
%         end
        if isfield(tc,'rmax')
            cyclone.trackRMax(k,1:4)=tc.rmax(it,:);
        end
        if isfield(tc,'a')
            cyclone.trackA(k,1:4)=tc.a(it,:);
        end
        if isfield(tc,'b')
            cyclone.trackB(k,1:4)=tc.b(it,:);
        end
        
        if isfield(tc,'r34')
            cyclone.trackR35(k,1)=tc.r34(it,1);
            cyclone.trackR35(k,2)=tc.r34(it,2);
            cyclone.trackR35(k,3)=tc.r34(it,3);
            cyclone.trackR35(k,4)=tc.r34(it,4);
        elseif isfield(tc,'r35')
            %  See ddb_readGenericTrackFile.m
            cyclone.trackR35(k,1)=tc.r35(it,1);
            cyclone.trackR35(k,2)=tc.r35(it,2);
            cyclone.trackR35(k,3)=tc.r35(it,3);
            cyclone.trackR35(k,4)=tc.r35(it,4);
        end
        
        if isfield(tc,'r50')
            cyclone.trackR50(k,1)=tc.r50(it,1);
            cyclone.trackR50(k,2)=tc.r50(it,2);
            cyclone.trackR50(k,3)=tc.r50(it,3);
            cyclone.trackR50(k,4)=tc.r50(it,4);
        end
        
        if isfield(tc,'r64')
            cyclone.trackR65(k,1)=tc.r64(it,1);
            cyclone.trackR65(k,2)=tc.r64(it,2);
            cyclone.trackR65(k,3)=tc.r64(it,3);
            cyclone.trackR65(k,4)=tc.r64(it,4);
        elseif isfield(tc, 'r65')
            %  See ddb_readGenericTrackFile.m
            cyclone.trackR65(k,1)=tc.r65(it,1);
            cyclone.trackR65(k,2)=tc.r65(it,2);
            cyclone.trackR65(k,3)=tc.r65(it,3);
            cyclone.trackR65(k,4)=tc.r65(it,4);
        end
        
        if isfield(tc,'r100')
            cyclone.trackR100(k,1)=tc.r100(it,1);
            cyclone.trackR100(k,2)=tc.r100(it,2);
            cyclone.trackR100(k,3)=tc.r100(it,3);
            cyclone.trackR100(k,4)=tc.r100(it,4);
        end
        
        %     end
    end
    
    filename1=[tc.name '.spw'];
    filename2=[hm.meteofolder 'spiderwebs' filesep tc.name '.' num2str(tc.advisorynumber) '.spw'];
    exedir=[hm.exeDir 'wes' filesep];
    
    cyclone.deleteTemporaryFiles=1;
    create_spw_file(filename1, cyclone, exedir);    
    movefile(filename1,filename2);
    
    for ii=1:hm.nrModels
        if ~isempty(hm.models(ii).meteospw)
            hm.models(ii).meteospw=[tc.name '.' num2str(tc.advisorynumber) '.spw'];
        end
    end

    % Also add kml file
    fname=[hm.meteofolder 'spiderwebs' filesep tc.name '.' num2str(tc.advisorynumber) '.kml'];
    KMLline(tc.lat,tc.lon,'fileName','line.kml','lineWidth',1,'lineColor',[0 1 1]);
    for it=1:2:length(tc.lon)
        label{it}=[datestr(tc.time(it),'dd mmm HH') 'h - ' num2str(tc.vmax(it,1)) 'kts'];
    end
%    KMLtext(tc.lat,tc.lon,label,'fileName','text.kml');
%    KMLmerge_files('sourceFiles',{'line.kml','text.kml'},'fileName',fname);
    movefile('line.kml',fname);
    
%    delete('text.kml');
%    delete('line.kml');
    
    for ii=1:hm.nrModels
        if ~isempty(hm.models(ii).meteospw)
            hm.models(ii).webSite(1).overlayFile=[tc.name '.' num2str(tc.advisorynumber) '.kml'];
            if ~isdir([hm.models(ii).dir 'data'])
                mkdir([hm.models(ii).dir 'data']);
            end
            copyfile(fname,[hm.models(ii).dir 'data']);
        end
    end

end
