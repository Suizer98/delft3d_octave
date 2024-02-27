function cosmos_makeMapKMZs(hm,m)
% Makes map plots and KMZs

model=hm.models(m);

fdr=model.cycledirfigures;
% appendeddirmaps=model.appendeddirmaps;
cycledirmaps=model.cycledirmaps;

t=0;

posfile=['.' filesep 'pos1.dat'];

if exist(posfile,'file')
    delete(posfile);
end

name='';
    
nmaps=length(model.mapPlots);

for im=1:nmaps
    
    try
        
        if model.mapPlots(im).plot
            
            if exist(posfile,'file')
                delete(posfile);
            end
            
            % Dataset
            
            ndat=model.mapPlots(im).nrDatasets;
            
            name=model.mapPlots(im).name;
            
            s=[];
            
            nt=0;
            
            for id=1:ndat
                
                plotRoutine=model.mapPlots(im).datasets(id).plotRoutine;
                barlabel=model.mapPlots(im).datasets(id).barLabel;
                clmap=model.mapPlots(im).datasets(id).colorMap;
                
                par{id}=model.mapPlots(im).datasets(id).name;
                
                switch lower(par{id})
                    case{'landboundary'}
                        if exist([model.dir 'data' filesep model.name '.ldb'],'file')
                            [xldb,yldb]=landboundary('read',[dr 'data' filesep model.name '.ldb']);
                        else
                            xldb=[0;0.01;0.01];
                            yldb=[0;0;0.01];
                        end
                        s(id).data.X=xldb;
                        s(id).data.Y=yldb;
                    case{'argusmerged'}
                        s=1;
                    otherwise
                        fname=[cycledirmaps par{id} '.mat'];
%                        fname=[appendeddirmaps par{id} '.mat'];
                        if exist(fname,'file')
                            s(id).data=load(fname);
                        else
                            disp(['File ' fname ' not found! - ' model.name]);
                            break;
                        end
                        switch lower(model.mapPlots(im).datasets(id).component)
                            case{'2dscalar','2dvector','magnitude','vector'}
                                if strcmpi(model.mapPlots(im).datasets(id).component,'vector')
                                    for jj=1:size(s(id).data.U,1)
                                        mag(jj,:,:)=sqrt((squeeze(s(id).data.U(jj,:,:))).^2+(squeeze(s(id).data.V(jj,:,:))).^2);
                                    end
                                else
                                    mag=s(id).data.Val;
                                end
                                minc=min(min(min(mag)));
                                maxc=max(max(max(mag)));
                                clear mag;
                                minc=min(minc,floor(minc));
                                maxc=max(maxc,ceil(maxc));
                                if isempty(model.mapPlots(im).datasets(id).cLim)
                                    clim(1)=minc;
                                    clim(3)=maxc;
                                    [tck,cdec]=cosmos_getTicksAndDecimals(clim(1),clim(3),10);
                                    clim(2)=tck;
                                else
                                    clim=model.mapPlots(im).datasets(id).cLim;
                                    cdec=3;
                                end
                                if ~isempty(model.mapPlots(im).datasets.colorBarDecimals)
                                    cdec=model.mapPlots(im).datasets.colorBarDecimals;
                                end
                                if ~isempty(model.mapPlots(im).datasets(id).cMinCutOff)
                                    clim(1)=max(clim(1),model.mapPlots(im).datasets(id).cMinCutOff);
                                end
                                if ~isempty(model.mapPlots(im).datasets(id).cMaxCutOff)
                                    clim(3)=max(clim(3),model.mapPlots(im).datasets(id).cMaxCutOff);
                                end
                                
                        end
                        nt=length(s(id).data.Time);

                        if ~strcmpi(model.coordinateSystemType,'geographic')
                            if isvector(s(id).data.X)
                                [xxx,yyy]=meshgrid(s(id).data.X,s(id).data.Y);
                            else
                                xxx=s(id).data.X;
                                yyy=s(id).data.Y;
                            end
                            [s(id).data.X,s(id).data.Y]=convertCoordinates(xxx,yyy,'persistent','CS1.name',model.coordinateSystem,'CS1.type',model.coordinateSystemType,'CS2.name','WGS 84','CS2.type','geographic');
                        end
                
                end
                
                
            end
            
            if isempty(s)
                % File not found
                break
            end
            
            if nt>1
                AvailableTimes=s(1).data.Time;
                dt=86400*(AvailableTimes(2)-AvailableTimes(1));
                n3=round(model.mapPlots(im).timeStep/dt);
                n3=max(n3,1);
                it1=find(AvailableTimes>=hm.catchupCycle-0.001,1,'first');
            else
                dt=1;
                n3=1;
                it1=1;
            end
            
            switch lower(plotRoutine)
                
                case{'coloredvectors'}
                    % Quiver KML
                    clrbarname=[fdr name '.colorbar.png'];
                    cosmos_makeColorBar(clrbarname,'contours',clim(1):clim(2):clim(3),'colormap',clmap,'label',barlabel,'decimals',cdec);
                    xx=s(1).data.X;
                    yy=s(1).data.Y;
                    tim=s(id).data.Time(it1:n3:end);
                    uu=s(1).data.U(it1:n3:end,:,:);
                    vv=s(1).data.V(it1:n3:end,:,:);
                    thin=model.mapPlots(im).datasets.thinning;
                    thinX=model.mapPlots(im).datasets.thinningX;
                    thinY=model.mapPlots(im).datasets.thinningY;
                    if thin>thinX
                        thinX=thin;
                    end
                    if thin>thinY
                        thinY=thin;
                    end
                    
                    quiverKML([name '.' model.name],xx,yy,uu,vv,'time',tim,'kmz',1,'colormap',jet(64),'levels',clim(1):clim(2):clim(3), ...
                        'directory',fdr,'screenoverlay',[name '.colorbar.png'],'thinningx',thinX, ...
                        'thinningy',thinY,'scalefactor',model.mapPlots(im).datasets.scaleFactor);
                    if exist([fdr name '.colorbar.png'],'file')
                        delete([fdr name '.colorbar.png']);
                    end
                    
                case{'vectorxml'}
                    % Quiver KML
                    clrbarname=[fdr name '.colorbar.png'];
                    cosmos_makeColorBar(clrbarname,'contours',clim(1):clim(2):clim(3),'colormap',clmap,'label',barlabel,'decimals',cdec);
                    xx=s(1).data.X;
                    yy=s(1).data.Y;
                    tim=s(id).data.Time(it1:n3:end);
                    uu=s(1).data.U(it1:n3:end,:,:);
                    vv=s(1).data.V(it1:n3:end,:,:);
                    thin=model.mapPlots(im).datasets.thinning;
                    thinX=model.mapPlots(im).datasets.thinningX;
                    thinY=model.mapPlots(im).datasets.thinningY;
                    if thin>thinX
                        thinX=thin;
                    end
                    if thin>thinY
                        thinY=thin;
                    end
                    if ~isempty(model.mapPlots(im).datasets(1).polygon)
                        polxy=load([model.datafolder 'data' filesep model.mapPlots(im).datasets(1).polygon]);
                        if ~strcmpi(model.coordinateSystemType,'geographic')
                            xp=squeeze(polxy(:,1));
                            yp=squeeze(polxy(:,2));
                            [xp,yp]=convertCoordinates(xp,yp,'persistent','CS1.name',model.coordinateSystem,'CS1.type',model.coordinateSystemType, ...
                                'CS2.name','WGS 84','CS2.type','geographic');
                            polxy(:,1)=xp;
                            polxy(:,2)=yp;
                        end
                    else
                        polxy=[];
                    end
                    
                    vectorXML([name '.' model.name '.xml'],xx,yy,uu,vv,'time',tim,'levels',clim(1):clim(2):clim(3), ...
                        'directory',fdr,'screenoverlay',[name '.colorbar.png'],'thinningx',thinX, ...
                        'thinningy',thinY,'polygon',polxy,'scalefactor',model.mapPlots(im).datasets.scaleFactor, ...
                        'screenoverlay',[name '.colorbar.png'],'colormap',jet(64),'levels',clim(1):clim(2):clim(3));
                    
                case{'coloredcurvyarrows','coloredcurvylines'}
                    % Curvec KML
                    clrbarname=[fdr name '.colorbar.png'];
                    cosmos_makeColorBar(clrbarname,'contours',clim(1):clim(2):clim(3),'colormap',clmap,'label',barlabel,'decimals',cdec);
                    xx=s(1).data.X;
                    yy=s(1).data.Y;
                    if size(s(1).data.X,1)==1 || size(s(1).data.X,2)==1
                        [xx,yy]=meshgrid(xx,yy);
                    end
                    tim=s(id).data.Time(it1:n3:end);
                    uu=s(1).data.U(it1:n3:end,:,:);
                    vv=s(1).data.V(it1:n3:end,:,:);
                    if ~isempty(model.mapPlots(im).datasets(1).polygon)
                        polxy=load([model.dir 'data' filesep model.mapPlots(im).datasets(1).polygon]);
                        if ~strcmpi(model.coordinateSystemType,'geographic')
                            xp=squeeze(polxy(:,1));
                            yp=squeeze(polxy(:,2));
                            [xp,yp]=convertCoordinates(xp,yp,'persistent','CS1.name',model.coordinateSystem,'CS1.type',model.coordinateSystemType,'CS2.name','WGS 84','CS2.type','geographic');
                            polxy(:,1)=xp;
                            polxy(:,2)=yp;
                        end
                    else
                        polxy=[];
                    end
                    
                    if strcmpi(plotRoutine,'coloredcurvyarrows')
                        ilines=0;
                        nrvert=8;
                    else
                        ilines=1;
                        nrvert=3;
                    end
                    
                    curvecKML2([name '.' model.name],xx,yy,uu,vv,'time',tim,'kmz',1,'colormap',jet(64),'levels',clim(1):clim(2):clim(3), ...
                        'directory',fdr,'screenoverlay',[name '.colorbar.png'],'timestep',model.mapPlots(im).timeStep, ...
                        'dx',model.mapPlots(im).datasets.spacing,'relativespeed',0.5,'length',model.mapPlots(im).datasets.arrowLength,'lines',ilines,'polygon',polxy,'nrvertices',nrvert, ...
                        'nhead',2);
                    if exist([fdr name '.colorbar.png'],'file')
                        delete([fdr name '.colorbar.png']);
                    end
                    
                case{'patches'}
                    % Patches
                    if ~isempty(s)
                        
                        if ~isempty(model.mapPlots(im).timeStep)
                            n2=round(dt/(model.mapPlots(im).timeStep));
                        else
                            n2=1;
                        end
                        it2=0;
                        t2=[];
                        
                        clrbarname=[fdr name '.colorbar.png'];
                        cosmos_makeColorBar(clrbarname,'contours',clim(1):clim(2):clim(3),'colormap',clmap,'label',barlabel,'decimals',cdec);
                        
                        for it=it1:n3:nt
                            
                            if it<nt
                                ninterm=max(1,n2);
                            else
                                ninterm=1;
                            end
                            
                            for ii=1:ninterm
                                
                                nd=0;
                                
                                for id=1:ndat
                                    
                                    nd=nd+1;
                                    
                                    if ndims(s(id).data.Val)==2
                                        data.Val=s(id).data.Val(:,:);
                                    else
                                        data.Val=s(id).data.Val(it,:,:);
                                        t=s(id).data.Time(it);
                                        if n2>1
                                            if it<nt
                                                f1=(n2+1-ii)/n2;
                                                f2=1-f1;
                                                data2.Val=s(id).data.Val(it+1,:,:);
                                                data.Val=f1*data.Val+f2*data2.Val;
                                            end
                                            t=t+(ii-1)*model.mapPlots(im).timeStep/86400;
                                        end
                                    end
                                    data.x=s(id).data.X;
                                    data.y=s(id).data.Y;
                                    x=data.x;
                                    y=data.y;
                                    if size(x,1)==1
                                        [x,y]=meshgrid(x,y);
                                    end
                                    
                                    dmp.x=x;
                                    dmp.y=y;
                                    dmp.z=squeeze(data.Val);
                                    dmp.zz=squeeze(data.Val);
                                    if ~isempty(model.mapPlots(im).datasets(id).cMinCutOff)
                                        dmp.z(dmp.z<model.mapPlots(im).datasets(id).cMinCutOff)=NaN;
                                    end
                                    if ~isempty(model.mapPlots(im).datasets(id).cMaxCutOff)
                                        dmp.z(dmp.z>model.mapPlots(im).datasets(id).cMaxCutOff)=NaN;
                                    end
                                    
                                end
                                
                                it2=it2+1;
                                t2(it2)=t;
                                
                                % Figure Properties
                                figname=[fdr name '.' datestr(t,'yyyymmdd.HHMMSS') '.png'];
                                
                                xlim=model.xLimPlot;
                                ylim=model.yLimPlot;
                                
                                if ~strcmpi(model.coordinateSystemType,'geographic')
                                    [xlim(1),ylim(1)]=convertCoordinates(xlim(1),ylim(1),'persistent','CS1.name',model.coordinateSystem,'CS1.type',model.coordinateSystemType,'CS2.name','WGS 84','CS2.type','geographic');
                                    [xlim(2),ylim(2)]=convertCoordinates(xlim(2),ylim(2),'persistent','CS1.name',model.coordinateSystem,'CS1.type',model.coordinateSystemType,'CS2.name','WGS 84','CS2.type','geographic');
                                end
                                
                                % Make figure
                                cosmos_mapPlot(figname,dmp,'xlim',xlim,'ylim',ylim,'clim',[clim(1) clim(3)]);
                                
                            end
                            
                        end
                        
                        flist=[];
                        
                        for it=1:length(t2)
                            flist{it}=[name '.' datestr(t2(it),'yyyymmdd.HHMMSS') '.png'];
                        end
                        
                        if ~isempty(flist)
                            writeMapKMZ('filename',[name '.' model.name],'dir',fdr,'filelist',flist,'colorbar',[name '.colorbar.png'],'xlim',xlim,'ylim',ylim,'deletefiles',1);
                        end
                        
                    end
                    
                case{'argusmerged'}
                    
                    try
                        station=model.mapPlots(im).datasets(id).argusstation;
                        t=floor(hm.cycle)-1+0.5;
%                        figdr=[cycledir 'figures' filesep];
                        xori=model.mapPlots(im).datasets(id).argusxorigin;
                        yori=model.mapPlots(im).datasets(id).argusyorigin;
                        wdt=model.mapPlots(im).datasets(id).arguswidth;
                        hgt=model.mapPlots(im).datasets(id).argusheight;
                        rot=model.mapPlots(im).datasets(id).argusrotation;
                        csname=model.coordinateSystem;
                        cstype=model.coordinateSystemType;
                        kmzfile=['argusmerged.' model.name];
                        argus2kmz(kmzfile,station,t,fdr,xori,yori,wdt,hgt,rot,csname,cstype);
                    end
                    
            end
            
            if exist(posfile,'file')
                delete(posfile);
            end
        end
        
    catch
        
        WriteErrorLogFile(hm,['Something went wrong with generating map figures of ' name ' - ' model.name]);
        
    end
    
end


if exist(posfile,'file')
    delete(posfile);
end
