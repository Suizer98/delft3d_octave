function cosmos_adjustInputDelft3DFLOW(hm,m)

hm.models(m).exedirflow=hm.exedirflow;

model=hm.models(m);

tmpdir=hm.tempDir;

%% MDF File
mdffile=[tmpdir model.runid '.mdf'];
cosmos_writeMDF(hm,m,mdffile);

%% Check if ini file needs to be made (used in 3d simulations)
if isempty(model.flowRstFile) && model.makeIniFile
    datafolder=[hm.oceanmodelsfolder model.oceanModel filesep];
    dataname=model.oceanModel;
    wlbndfile=[model.name '.wl.bnd'];
    wlbcafile=[model.name '.wl.bca'];
    curbndfile=[model.name '.current.bnd'];
    curbcafile=[model.name '.current.bca'];
    wlconst=model.zLevel+model.wlboundarycorrection;
    cs.name=model.coordinateSystem;
    cs.type=model.coordinateSystemType;
    writeNestXML([tmpdir 'nest.xml'],tmpdir,model.runid,datafolder,dataname,wlbndfile,wlbcafile,curbndfile,curbcafile,wlconst,cs,'file','file');
    disp('Making ini file ...');
    makeBctBccIni('ini','nestxml',[tmpdir 'nest.xml'],'inpdir',tmpdir,'runid',model.runid,'workdir',tmpdir,'cs',cs);
    delete([tmpdir 'nest.xml']);
end

%% Dummy.wnd
writeDummyWnd(tmpdir);

if model.includeTemperature && model.includeHeatExchange
    %% Dummy.tmp
    writeDummyTem(tmpdir);
end

%% Meteo
if ~isempty(model.meteowind)
    
    try
        
        cs.name=hm.models(m).coordinateSystem;
        cs.type=hm.models(m).coordinateSystemType;
        
        if ~strcmpi(cs.type,'geographic')
            dx=model.dXMeteo;
            dy=model.dYMeteo;
        else
            dx=[];
            dy=[];
        end
        
        reftime=model.refTime;
        
        % Wind
        try
            meteodir=[hm.meteofolder model.meteowind filesep];
            par={'u','v'};
            write_meteo_file(meteodir,model.meteowind,par,tmpdir,'meteo',model.xLim,model.yLim, ...
                model.tFlowStart,model.tStop,'cs',cs,'reftime',reftime,'dx',dx,'dy',dy);
            %             writeD3DMeteoFile4(meteodir,model.meteowind,tmpdir,'meteo',model.xLim,model.yLim, ...
            %                 coordsys,coordsystype,model.refTime,model.tFlowStart,model.tStop, ...
            %                 'parameter',par,'dx',dx,'dy',dy,'exedirflow',model.exedirflow);
        catch
            meteodir=[hm.meteofolder model.backupmeteowind filesep];
            par={'u','v'};
            write_meteo_file(meteodir,model.backupmeteowind,par,tmpdir,'meteo',model.xLim,model.yLim, ...
                model.tFlowStart,model.tStop,'cs',cs,'reftime',reftime,'dx',dx,'dy',dy);
            %             writeD3DMeteoFile4(meteodir,model.backupmeteowind,tmpdir,'meteo',model.xLim,model.yLim, ...
            %                 coordsys,coordsystype,model.refTime,model.tFlowStart,model.tStop, ...
            %                 'parameter',par,'dx',dx,'dy',dy,'exedirflow',model.exedirflow);
        end
        
        % Pressure
        if model.includeAirPressure
            try
                meteodir=[hm.meteofolder model.meteopressure filesep];
                par={'p'};
                write_meteo_file(meteodir,model.meteopressure,par,tmpdir,'meteo',model.xLim,model.yLim, ...
                    model.tFlowStart,model.tStop,'cs',cs,'reftime',reftime,'dx',dx,'dy',dy);
                %                 writeD3DMeteoFile4(meteodir,model.meteopressure,tmpdir,'meteo',model.xLim,model.yLim, ...
                %                     coordsys,coordsystype,model.refTime,model.tFlowStart,model.tStop, ...
                %                     'parameter',par,'dx',dx,'dy',dy,'exedirflow',model.exedirflow);
            catch
                meteodir=[hm.meteofolder model.backupmeteopressure filesep];
                par={'p'};
                write_meteo_file(meteodir,model.backupmeteopressure,par,tmpdir,'meteo',model.xLim,model.yLim, ...
                    model.tFlowStart,model.tStop,'cs',cs,'reftime',reftime,'dx',dx,'dy',dy);
                %                 writeD3DMeteoFile4(meteodir,model.backupmeteopressure,tmpdir,'meteo',model.xLim,model.yLim, ...
                %                     coordsys,coordsystype,model.refTime,model.tFlowStart,model.tStop, ...
                %                     'parameter',par,'dx',dx,'dy',dy,'exedirflow',model.exedirflow);
            end
        end
        
        % Spiderweb
        if ~isempty(model.meteospw)
            copyfile([hm.meteofolder 'spiderwebs' filesep model.meteospw],tmpdir);
        end
        
        % Heat
        if model.includeTemperature && model.includeHeatExchange
            try
                meteodir=[hm.meteofolder model.meteoheat filesep];
                par={'airtemp','relhum','cloudcover'};
                write_meteo_file(meteodir,model.meteoheat,par,tmpdir,'meteo',model.xLim,model.yLim, ...
                    model.tFlowStart,model.tStop,'cs',cs,'reftime',reftime,'dx',dx,'dy',dy);
                %                 writeD3DMeteoFile4(meteodir,model.meteoheat,tmpdir,'meteo',model.xLim,model.yLim, ...
                %                     coordsys,coordsystype,model.refTime,model.tFlowStart,model.tStop, ...
                %                     'parameter',par,'dx',dx,'dy',dy,'exedirflow',model.exedirflow);
            catch
                meteodir=[hm.meteofolder model.backupmeteoheat filesep];
                par={'airtemp','relhum','cloudcover'};
                write_meteo_file(meteodir,model.backupmeteoheat,par,tmpdir,'meteo',model.xLim,model.yLim, ...
                    model.tFlowStart,model.tStop,'cs',cs,'reftime',reftime,'dx',dx,'dy',dy);
                %                 writeD3DMeteoFile4(meteodir,model.backupmeteoheat,tmpdir,'meteo',model.xLim,model.yLim, ...
                %                     coordsys,coordsystype,model.refTime,model.tFlowStart,model.tStop, ...
                %                     'parameter',par,'dx',dx,'dy',dy,'exedirflow',model.exedirflow);
            end
        end
    end
end

%% Discharges
if ~isempty(model.discharge)
    % src file
    discharges=model.discharge;
    saveSrcFile([hm.tempDir model.name '.src'],discharges);
    % dis file
    for j=1:length(discharges)
        discharges(j).timeSeriesT=[model.tFlowStart model.tStop];
        discharges(j).timeSeriesQ=[model.discharge(j).q model.discharge(j).q];
        discharges(j).salinity.timeSeries=[model.discharge(j).salinity.constant model.discharge(j).salinity.constant];
        discharges(j).temperature.timeSeries=[model.discharge(j).temperature.constant model.discharge(j).temperature.constant];
        for itr=1:length(model.tracer)
            discharges(j).tracer(itr).name=model.tracer(itr).name;
            discharges(j).tracer(itr).timeSeries=[model.discharge(j).tracer(itr).constant model.discharge(j).tracer(itr).constant];
        end
    end
    saveDisFile([hm.tempDir model.name '.dis'],model.refTime,discharges) 
end

%% Observation Points
fname=[tmpdir model.name '.obs'];

fid=fopen(fname,'wt');

for istat=1:model.nrStations
    st=model.stations(istat).name;
    len=length(deblank(st));
    namestr=[st repmat(' ',1,22-len)];
    len=length(num2str(model.stations(istat).m));
    mstr=[repmat(' ',1,5-len) num2str(model.stations(istat).m)];
    len=length(num2str(model.stations(istat).n));
    nstr=[repmat(' ',1,7-len) num2str(model.stations(istat).n)];
    str=[namestr mstr nstr];
    fprintf(fid,'%s\n',str);
end

% Nesting Points
n=0;
obspm=[];
obspn=[];
for i=1:hm.nrModels
    if hm.models(i).flowNested
        if strcmpi(hm.models(i).flowNestModel,model.name)

            switch lower(hm.models(i).type)
                case{'xbeachcluster'}
                    np=hm.models(i).nrProfiles;
                otherwise
                    np=1;
            end
            
            for ip=1:np
                switch lower(hm.models(i).type)
                    case{'xbeachcluster'}
                        id=hm.models(i).profile(ip).name;
                        nstdir=[hm.models(i).datafolder 'nesting' filesep id filesep];
                        
                        if ~exist(nstdir,'dir')
                            makedir([hm.models(i).datafolder 'nesting'],id);
                        end
                        
                    otherwise
                        nstdir=[hm.models(i).datafolder 'nesting' filesep];
                end
                
                nstobs=[nstdir model.name '.obs'];
                
                if ~exist(nstobs,'file')

                    % Nest pre-processing (NESTHD1)
                    switch lower(hm.models(i).type)
                        case{'xbeachcluster'}
                            
                            mdl=hm.models(i).profile(ip);
                            mdl.alpha=pi*mdl.alpha/180;

                            fi2=fopen([hm.tempDir 'temp.bnd'],'wt');
                            fprintf(fi2,'%s\n','sea                  Z T     1     2     1     3  0.0000000e+000');
                            fclose(fi2);

                            % grd file
                            xg(1,1)=mdl.originX;
                            xg(1,2)=mdl.originX-sin(mdl.alpha)*0.5*mdl.dY;
                            xg(1,3)=mdl.originX-sin(mdl.alpha)*mdl.dY;

                            xg(2,1)=xg(1,1)+cos(mdl.alpha)*mdl.dY;
                            xg(2,2)=xg(1,2)+cos(mdl.alpha)*mdl.dY;
                            xg(2,3)=xg(1,3)+cos(mdl.alpha)*mdl.dY;

                            yg(1,1)=mdl.originY;
                            yg(1,2)=mdl.originY+cos(mdl.alpha)*0.5*mdl.dY;
                            yg(1,3)=mdl.originY+cos(mdl.alpha)*mdl.dY;

                            yg(2,1)=yg(1,1)+sin(mdl.alpha)*mdl.dY;
                            yg(2,2)=yg(1,2)+sin(mdl.alpha)*mdl.dY;
                            yg(2,3)=yg(1,3)+sin(mdl.alpha)*mdl.dY;
                            
                            enc=enclosure('extract',xg,yg);

                        case{'xbeach'}
                            
                            mdl=hm.models(i);
                            
                            % read grid
                            xgrdname=[mdl.dir 'input' filesep 'x.grd'];
                            ygrdname=[mdl.dir 'input' filesep 'y.grd'];
                            xgrd = load(xgrdname, '-ascii');
                            ygrd = load(ygrdname, '-ascii');
                            
                            % crop grid
                            xgrd = xgrd(:,1:2)';
                            ygrd = ygrd(:,1:2)';
                            
                            % rotate grid
                            alpha = mdl.alpha/pi*180;
                            R = [cos(alpha) -sin(alpha); sin(alpha) cos(alpha)];
                            xg = mdl.xOri+R(1,1)*xgrd+R(1,2)*ygrd;
                            yg = mdl.yOri+R(2,1)*xgrd+R(2,2)*ygrd;
                            
                            % write bnd file
                            fi2=fopen([hm.tempDir 'temp.bnd'],'wt');
                            fprintf(fi2,'%s\n',['sea                  Z T     1     2     1     ' num2str(size(xgrd,2)) ' 0.0000000e+000']);
                            fclose(fi2);
                            
                            enc=enclosure('extract',xg,yg);
                            
                        case{'delft3dflow','delft3dflowwave'}
                            grdname=[hm.models(i).datafolder 'input' filesep hm.models(i).name '.grd'];
                            [xg,yg,enc]=wlgrid('read',grdname);
                            [status,message,messageid]=copyfile([hm.models(i).datafolder 'input' filesep hm.models(i).name '.bnd'],[hm.tempDir 'temp.bnd'],'f');
                    end
                            
                    if ~strcmpi(hm.models(i).coordinateSystem,model.coordinateSystem) || ~strcmpi(hm.models(i).coordinateSystemType,model.coordinateSystemType)
                        % Convert coordinates
                        [xg,yg]=convertCoordinates(xg,yg,'persistent','CS1.name',hm.models(i).coordinateSystem,'CS1.type',hm.models(i).coordinateSystemType,'CS2.name',hm.models(m).coordinateSystem,'CS2.type',hm.models(m).coordinateSystemType);
                    end

                    wlgrid('write',[hm.tempDir 'temp.grd'],xg,yg,enc);

                    fi2=fopen([hm.tempDir 'nesthd1.inp'],'wt');
                    fprintf(fi2,'%s\n',[hm.tempDir model.name '.grd']);
                    fprintf(fi2,'%s\n',[hm.tempDir model.name '.enc']);
                    fprintf(fi2,'%s\n',[hm.tempDir 'temp.grd']);
                    fprintf(fi2,'%s\n',[hm.tempDir 'temp.enc']);
                    fprintf(fi2,'%s\n',[hm.tempDir 'temp.bnd']);
                    fprintf(fi2,'%s\n',[hm.tempDir hm.models(i).name '.nst']);
                    fprintf(fi2,'%s\n',[hm.tempDir 'temp.obs']);
                    fclose(fi2);

                    system([hm.exeDir 'nesthd1.exe < ' hm.tempDir 'nesthd1.inp']);
                    
                    if ~isdir(nstdir)
                        mkdir(nstdir);
                    end

                    [status,message,messageid]=movefile([hm.tempDir hm.models(i).name '.nst'],nstdir,'f');
                    [status,message,messageid]=movefile([hm.tempDir 'temp.obs'],[nstdir model.name '.obs'],'f');
                    [status,message,messageid]=movefile([hm.tempDir 'temp.bnd'],[nstdir hm.models(i).name '.bnd'],'f');

                    delete([hm.tempDir 'nesthd1.inp']);
                    delete([hm.tempDir 'temp.grd']);
                    delete([hm.tempDir 'temp.enc']);
                    if exist([hm.tempDir 'temp.bnd'],'file')
                        delete([hm.tempDir 'temp.bnd'])
                    end

                end
                
                ObsPoints=ReadObsFile(nstobs);
                nrobs=length(ObsPoints);
                for j=1:nrobs
                    % Check for duplicates
                    mobs=ObsPoints(j).m;
                    nobs=ObsPoints(j).n;

                    ii=find(obspm==mobs & obspn==nobs, 1);

                    if isempty(ii)
                        n=n+1;
                        obspm(n)=mobs;
                        obspn(n)=nobs;
                        name=deblank(ObsPoints(j).name);
                        len=length(deblank(name));
                        namestr=[name repmat(' ',1,22-len)];
                        len=length(num2str(mobs));
                        mstr=[repmat(' ',1,5-len) num2str(mobs)];
                        len=length(num2str(nobs));
                        nstr=[repmat(' ',1,7-len) num2str(nobs)];
                        str=[namestr mstr nstr];
                        fprintf(fid,'%s\n',str);
                    end
                end
            end
        end
    end
end
fclose(fid);


%% BeachWizard

try
    if ~isempty(model.beachWizard)
        
        %         bwtimes=cosmos_findBWTimes(model.beachWizard);
        %         it=find(bwtimes<=hm.cycle,1,'last');
        %         url=['http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/beachwizard/output/' model.beachWizard '/' ...
        %             model.beachWizard '.' datestr(bwtimes(it),'yyyymmdd.HHMMSS') '.nc'];
        
        % Try reading from p drive for now
        dr='p:\argus\argusdata\beachWizard\jvspeijk\zboutput\';
        dr='p:\argus\argusdata\cbathy\jvspeijk\';
        flist=dir([dr '*.nc']);
        for ii=1:length(flist)
%            tstr=flist(ii).name(end-17:end-3);
            tstr=[flist(ii).name(10:18) flist(ii).name(22:27)];
            bwtimes(ii)=datenum(tstr,'yyyymmdd.HHMMSS');
        end
        it=find(bwtimes<=hm.cycle,1,'last');
        url=[dr flist(it).name];
        
        x=nc_varget(url,'x');
        y=nc_varget(url,'y');
%        z=nc_varget(url,'z');
        z=-nc_varget(url,'z');
        grd=wlgrid('read',[tmpdir model.name '.grd']);
        mmax=size(grd.X,1)+1;
        nmax=size(grd.X,2)+1;
        dep=wldep('read',[tmpdir model.name '.dep'],[mmax nmax]);
        zbw0=griddata(x,y,z,grd.X,grd.Y);
        zbw=zeros(size(dep));
        zbw(zbw==0)=NaN;
        zbw(1:end-1,1:end-1)=-zbw0; % Positive down!
        dep(~isnan(zbw))=zbw(~isnan(zbw));
        wldep('write',[tmpdir model.name '.dep'],dep);
    end
catch
    WriteErrorLogFile(hm,'Something went wrong while getting bathymetry from BeachWizard - see oms.err');
end
