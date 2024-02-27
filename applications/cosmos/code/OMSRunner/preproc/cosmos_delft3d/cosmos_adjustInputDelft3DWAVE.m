function cosmos_adjustInputDelft3DWAVE(hm,m)

model=hm.models(m);

tmpdir=hm.tempDir;

%% MDW File
mdwfile=[tmpdir model.runid '.mdw'];
cosmos_writeMDW(hm,m,mdwfile);

%% DIOConfig file 
writeDIOConfig(tmpdir);

%% Nesting
k=0;
n=length(model.nestedWaveModels);
for i=1:n

    % A model is nested in this Delft3D-WAVE model
    mm=model.nestedWaveModels(i);
    k=k+1;
    
    locfile=[hm.models(mm).datafolder 'nesting' filesep model.name '.loc'];

    % Find boundary points nested grid
    switch lower(hm.models(mm).type)
        case{'xbeachcluster'}
            d=[];
            for ip=1:hm.models(mm).nrProfiles
                d(ip,1)=hm.models(mm).profile(ip).originX;
                d(ip,2)=hm.models(mm).profile(ip).originY;
            end
            save(locfile,'d','-ascii');
        case{'xbeach'}
            d=[];
            mdl=hm.models(mm);            
            ygrdname=[mdl.datafolder 'input' filesep 'y.grd'];
            ygrd = load(ygrdname, '-ascii');            
            % crop grid
            ygrd = ygrd(:,1);
            lngth=ygrd(end);            
            d(1,1)=mdl.xOri+cos(pi*(mdl.alpha+90)/180)*0.5*lngth;
            d(1,2)=mdl.yOri+sin(pi*(mdl.alpha+90)/180)*0.5*lngth;
            save(locfile,'d','-ascii');
        otherwise
            if ~exist(locfile,'file')
                grdname=[hm.models(mm).datafolder 'input' filesep hm.models(mm).name '_swn.grd'];
                [x,y,enc]=wlgrid('read',grdname);
                nstep=10;
                [xb,yb]=getGridOuterCoordinates(x,y,nstep);
                d=[xb yb];
                save(locfile,'d','-ascii');
            end
    end

    locs=load(locfile);
    if ~strcmpi(hm.models(mm).coordinateSystem,model.coordinateSystem) || ~strcmpi(hm.models(mm).coordinateSystemType,model.coordinateSystemType)
        % Convert coordinates
        xx=locs(:,1);
        yy=locs(:,2);
        [xx,yy]=convertCoordinates(xx,yy,'persistent','CS1.name',hm.models(mm).coordinateSystem,'CS1.type',hm.models(mm).coordinateSystemType,'CS2.name',model.coordinateSystem,'CS2.type',model.coordinateSystemType);
        locs(:,1)=xx;
        locs(:,2)=yy;
    end
    save([tmpdir hm.models(mm).runid '.loc'],'locs','-ascii');
    

end
