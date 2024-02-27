function tsunami_make_model_series(models,polylinefile,modelsdir,iplot,varargin)

global bathymetry

modeltype='tsunami';

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'modeltype'}
                modeltype=varargin{ii+1};
        end
    end
end
    
% Polyline file to be used
[xp,yp]=landboundary('read',polylinefile);

% Create spline through polyline
[xs,ys]=spline2d(xp,yp);

if iplot
    % Plot spline
    plot(xs,ys);
    hold on;
    axis equal
    drawnow;
end

% Loop through model levels
for im=1:length(models)
    
    if im==1
        
        % Highest resolution model
        
        % Determine start and end points of each grid based on polyline
        
        % Determine length of spline
        pd=pathdistance(xs,ys);
        splinelength=pd(end);
        
        % Determine number of grids along spline
        ngrids=ceil(splinelength/models(im).gridlength);
        
        % Determine exact grid length
        gridlength=splinelength/ngrids;
        
        % Compute grid start and end points (xg and yg) of grids along coastline WITHOUT overlap
        % These coordinates are sent to makeModels
        gridpoints=0:gridlength:splinelength;
        gridsx=interp1(pd,xs,gridpoints);
        gridsy=interp1(pd,ys,gridpoints);
        xg(1,:)=gridsx(1:end-1);
        xg(2,:)=gridsx(2:end);
        yg(1,:)=gridsy(1:end-1);
        yg(2,:)=gridsy(2:end);
        
    else

        % Determine start and end points of each grid based on higher resolution grids        
        xg0=xg;
        yg0=yg;        
        xg=[];
        yg=[];
        irefine=models(im).nrnestedmodels; % Number of high-res models nested in this level
        ng=ceil(size(xg0,2)/irefine);
        for ig=1:ng
            % Start point of coarser grid
            ig1=(ig-1)*irefine+1;
            ig2=ig1+irefine-1;
            ig2=min(ig2,size(xg0,2));
            xg(1,ig)=xg0(1,ig1);
            xg(2,ig)=xg0(2,ig2);
            yg(1,ig)=yg0(1,ig1);
            yg(2,ig)=yg0(2,ig2);

            % Adjust flownested input in finer models

            % Determine index of coarse model
            mindex1=ig;
            if isfield(models(im),'indexstart')
                if ~isempty(models(im).indexstart)
                    mindex1=ig+models(im).indexstart-1;
                end
            end            
            
            for ii=ig1:ig2
                % Determine index of fine model
                mindex2=ii;
                if isfield(models(im-1),'indexstart')
                    if ~isempty(models(im-1).indexstart)
                        mindex2=ii+models(im-1).indexstart-1;
                    end
                end
                mm=[models(im-1).prefix '_' num2str(mindex2,'%0.4i')];
                xmlfile=[modelsdir filesep mm filesep mm '.xml'];
                xml=xml2struct(xmlfile,'structuretype','supershort');
                xml.flownested=[models(im).prefix '_' num2str(mindex1,'%0.4i')];
                struct2xml(xmlfile,xml,'structuretype','supershort');
            end
        end
        
    end
    
    % And now make the models
    
    makeModels(models(im),xg,yg,bathymetry,modelsdir,modeltype,iplot);

end

%%
function makeModels(model,xp,yp,bathymetry,dr,modeltype,iplot)

model.diston=model.distoff;

xg1a=xp(1,:);
yg1a=yp(1,:);
xg2a=xp(2,:);
yg2a=yp(2,:);

gridlength=sqrt((xg2a-xg1a).^2+(yg2a-yg1a).^2);

% Determine grid orientation
alph=atan2(yg2a-yg1a,xg2a-xg1a);

% Grid start and end points WITH overlap
xg1=xg1a-model.overlap*(xg2a-xg1a)./gridlength;
yg1=yg1a-model.overlap*(yg2a-yg1a)./gridlength;
xg2=xg2a+model.overlap*(xg2a-xg1a)./gridlength;
yg2=yg2a+model.overlap*(yg2a-yg1a)./gridlength;
    
% Origin
xx1=xg1+model.distoff*cos(alph+1.5*pi);
yy1=yg1+model.distoff*sin(alph+1.5*pi);
xx2=xg2+model.distoff*cos(alph+1.5*pi);
yy2=yg2+model.distoff*sin(alph+1.5*pi);
xx3=xg2+model.diston*cos(alph+0.5*pi);
yy3=yg2+model.diston*sin(alph+0.5*pi);
xx4=xg1+model.diston*cos(alph+0.5*pi);
yy4=yg1+model.diston*sin(alph+0.5*pi);

% Snap coordinates of cell centre of grid origin to mesh with grid spacing of dx
% First round coordinates of cell centre of origin
xz1=xx1+0.5*model.dx*cos(alph)-0.5*model.dy*sin(alph);
yz1=yy1+0.5*model.dx*sin(alph)+0.5*model.dy*cos(alph);
xz1round=roundnearest(xz1,model.dx);
yz1round=roundnearest(yz1,model.dx);
% Now determine difference between snapped origin and original origin
ddxx=xz1round-xz1;
ddyy=yz1round-yz1;
% Now correct four corners of the grid
xx1=xx1+ddxx;
yy1=yy1+ddyy;
xx2=xx2+ddxx;
yy2=yy2+ddyy;
xx3=xx3+ddxx;
yy3=yy3+ddyy;
xx4=xx4+ddxx;
yy4=yy4+ddyy;

% ibathy is index of last (coarsest) bathymetry dataset (assuming here this is GEBCO)
ibathy=strmatch(model.bathymetry(end).name,bathymetry.datasets,'exact');

% Make the grids
ngrids=length(xg1a);

for ig=1:ngrids

    mindex=ig;
    if isfield(model,'indexstart')
        if ~isempty(model.indexstart)
            mindex=ig+model.indexstart-1;
        end
    end
    
    modelname=[model.prefix '_' num2str(mindex,'%0.4i')];
    
    disp(modelname);
    
    if ~isdir([dr filesep modelname])
        mkdir([dr filesep modelname]);
    end
    if ~isdir([dr filesep modelname filesep 'input'])
        mkdir([dr filesep modelname filesep 'input']);
    end
    
    %% Make grid

    % Polygon around grid
    xpol=[xx1(ig) xx2(ig) xx3(ig) xx4(ig) xx1(ig)];
    ypol=[yy1(ig) yy2(ig) yy3(ig) yy4(ig) yy1(ig)];
    
    if iplot
        plot(xpol,ypol,'r');
        drawnow;        
    end
    
    % nmax and mmax    
    nx=ceil((gridlength(ig)+2*model.overlap)/model.dx)-1;
    ny=ceil((model.diston+model.distoff)/model.dy);
    
    % Convert coordinates of polygon to coordinates of bathymetry dataset 
    [xpol1,ypol1]=convertCoordinates(xpol,ypol, ...
        'CS2.name',bathymetry.dataset(ibathy).horizontalCoordinateSystem.name,'CS2.type',bathymetry.dataset(ibathy).horizontalCoordinateSystem.type, ...
        'CS1.name',model.cs.name,'CS1.type',model.cs.type);
    xlb=[min(xpol1) max(xpol1)];
    ylb=[min(ypol1) max(ypol1)];
    
    % Get coarse bathymetry (for making initial grid)
    [xx,yy,zz,ok]=ddb_getBathymetry(bathymetry,xlb,ylb,'bathymetry',model.bathymetry(end).name,'maxcellsize',model.dx);
    
    % interpolate to model coordinate system
    dmin=min(model.dx,model.dy);
    [xg,yg]=meshgrid(min(xpol):dmin:max(xpol),min(ypol):dmin:max(ypol));
    [xgb,ygb]=convertCoordinates(xg,yg,'CS2.name',bathymetry.dataset(ibathy).horizontalCoordinateSystem.name,'CS2.type',bathymetry.dataset(ibathy).horizontalCoordinateSystem.type, ...
        'CS1.name',model.cs.name,'CS1.type',model.cs.type);
    zz=interp2(xx,yy,zz,xgb,ygb);
    
    % Make rectangular grid
    zmax=200;
    
    [x,y,z]=MakeRectangularGrid(xpol(1),ypol(1),nx,ny,model.dx,model.dy,alph(ig),zmax,xg,yg,zz);

    % Extract enclosure    
    enc=ddb_enclosure('extract',x,y);
    
     % Write grid file
    if strcmpi(model.cs.type,'geographic')
        coord='Spherical';
    else
        coord='Cartesian';
    end
    
    ddb_wlgrid('write','FileName',[dr filesep modelname filesep 'input' filesep modelname '.grd'],'X',x,'Y',y,'Enclosure',enc,'CoordinateSystem',coord);

    %% Bathymetry - interpolate bathymetry onto grid

    % Get coordinates of cell centres
    [xz,yz]=getXZYZ(x,y);
    zz=zeros(size(xz));
    zz(zz==0)=NaN;

    % Procedure is as follows:
    % 1) Create depth matrix on land (zland), copy it to z, but set all values to -2
    % 2) Create depth matrix on sea (zsea), copy it to z, except land points found in step 1
    % 3) Apply internal diffusion to fill in gaps between land and sea
    % 4) Copy zland values to z    

    % The reason for this order is that the internal diffusion procedure
    % may create too many land points, in particular in the case of steep
    % coasts (e.g. cliffs etc.)

    % First interpolate land, and set depth to -2, basically creating land mask    

    zland=ddb_interpolateBathymetry2(bathymetry,model.topography,xz,yz,zz,0,1,'structured',0,model.cs);
    z=zland;
    z(~isnan(z))=-2;

    % Then sea and apply internal diffusion

    zsea=ddb_interpolateBathymetry2(bathymetry,model.bathymetry,xz,yz,zz,0,1,'structured',0,model.cs);
    z(~isnan(zsea) & isnan(zland))=zsea(~isnan(zsea) & isnan(zland));

    % Now apply internal diffusion

    isn=isnan(z);              % Missing indices in depth matrix    
    mask=zeros(size(z))+1;
    mask(isnan(xz))=0;         % Missing indices in grid matrix     
    z=internaldiffusion(z,'mask',mask); 
    isn2=logical(isn.*mask);   % Only update points that did not have a depth, but were in an active grid
    z(isn2)=min(z(isn2),-2);

    % Then land again, but now use actual values

    z(~isnan(zland))=zland(~isnan(zland));
    
    % Make depth of non-active grid points NaN
    z(isnan(x))=NaN;
    z(isnan(xz))=NaN;
    ddb_wldep('write',[dr filesep modelname filesep 'input' filesep modelname '.dep'],z);
    
    % Creates RGH file, based on land/water grid cell
    rgh=z;
    rgh(rgh>=0)  =model.lfric;        
    rgh(rgh<0)   =model.hfric;
    rgh(isnan(rgh))=0.024;    
    ddb_wldep('write',[dr filesep modelname filesep 'input' filesep modelname '.rgh'],-rgh);
    ddb_wldep('append',[dr filesep modelname filesep 'input' filesep modelname '.rgh'],-rgh);
    
    %% Boundaries

    openBoundaries=[];
    depth=z;
    zmax=0;
    d=10;
    
    openBoundaries=findBoundarySectionsOnStructuredGrid(openBoundaries,depth,zmax,d,'namingoption',2,'dpsopt','dp');
    for ib=1:length(openBoundaries)
        openBoundaries=delft3dflow_setDefaultBoundaryType(openBoundaries,ib);
        openBoundaries(ib).type='R';
        openBoundaries(ib).forcing='T';
    end    
    ddb_saveBndFile(openBoundaries,[dr filesep modelname filesep 'input' filesep modelname '.bnd']);
    
    %% MDF file
    xmean=nanmean(nanmean(x));
    ymean=nanmean(nanmean(y));
    [xmean,ymean]=convertCoordinates(xmean,ymean,'CS2.name','WGS 84','CS2.type','geographic', ...
        'CS1.name',model.cs.name,'CS1.type',model.cs.type);
    writeMDF([dr filesep modelname filesep 'input' filesep],modelname,modeltype,size(x,1)+1,size(x,2)+1,ymean,model.dt,model.inclobs,model.solver,model.vicouv);  
    
    %% XML
    xml=[];
    xml.name=modelname;
    xml.csname=model.cs.name;
    xml.cstype=model.cs.type;
    if ~isempty(model.nestedin)
        xml.flownested=model.nestedin;
    else
        xml.flownested='';
    end
    xml.xbox=xpol;
    xml.ybox=ypol;
    xmlfile=[dr filesep modelname filesep modelname '.xml'];
    struct2xml(xmlfile,xml,'structuretype','supershort');
    
end

%
function writeMDF(dr,modelname,modeltype,mmax,nmax,anglat,dt,inclobs,solver,vicouv)

fid=fopen([dr filesep modelname '.mdf'],'wt');

fprintf(fid,'%s\n','Ident = #Delft3D-FLOW  .03.02 3.39.26#');
fprintf(fid,'%s\n','Runtxt= #                              #');
fprintf(fid,'%s\n',['Filcco= #' modelname '.grd#']);
fprintf(fid,'%s\n','Fmtcco= #FR#');
fprintf(fid,'%s\n',['Anglat= ' num2str(anglat)]);
fprintf(fid,'%s\n','Grdang= 0.0000000e+000');
fprintf(fid,'%s\n',['Filgrd= #' modelname '.enc#']);
fprintf(fid,'%s\n','Fmtgrd= #FR#');
fprintf(fid,'%s\n',['MNKmax= ' num2str(mmax) '  ' num2str(nmax) '   1']);
fprintf(fid,'%s\n','Thick = 1.0000000e+002');
fprintf(fid,'%s\n',['Fildep= #' modelname '.dep#']);
fprintf(fid,'%s\n','Fmtdep= #FR#');
switch lower(modeltype)
    case{'cyclone','tropicalcyclone'}
        fprintf(fid,'%s\n','Itdate= #ITDATEKEY#');
        fprintf(fid,'%s\n','Tunit = #M#');
        fprintf(fid,'%s\n','Tstart= TSTARTKEY');
        fprintf(fid,'%s\n','Tstop = TSTOPKEY');
    otherwise
        fprintf(fid,'%s\n','Itdate= #2013-01-01#');
        fprintf(fid,'%s\n','Tunit = #M#');
        fprintf(fid,'%s\n','Tstart= 0.0000000e+000');
        fprintf(fid,'%s\n','Tstop = RDURKEY');
end
%fprintf(fid,'%s\n',['Tstop = ' num2str(rdur) ' ']);
fprintf(fid,'%s\n',['Dt    = ' num2str(dt)]);
fprintf(fid,'%s\n','Tzone = 0');
switch lower(modeltype)
    case{'cyclone','tropicalcyclone'}
        fprintf(fid,'%s\n','Sub1  = #  W #');
    otherwise
        fprintf(fid,'%s\n','Sub1  = #    #');
end
fprintf(fid,'%s\n','Sub2  = #   #');
fprintf(fid,'%s\n','Wnsvwp= #N#');
fprintf(fid,'%s\n','Wndint= #Y#');
% fprintf(fid,'%s\n','Zeta0 = 0.0000000e+000');
% fprintf(fid,'%s\n','U0    = [.]');
% fprintf(fid,'%s\n','V0    = [.]');
switch lower(modeltype)
    case{'tsunami'}
        fprintf(fid,'%s\n',['Filic = #' modelname '.ini#']);
end
fprintf(fid,'%s\n',['Filbnd= #' modelname '.bnd#']);
fprintf(fid,'%s\n','Fmtbnd= #FR#');
fprintf(fid,'%s\n',['FilbcT= #' modelname '.bct#']);
fprintf(fid,'%s\n','FmtbcT= #FR#');
fprintf(fid,'%s\n','Ag    = 9.8100000e+000');
fprintf(fid,'%s\n','Rhow  = 1.0000000e+003');
fprintf(fid,'%s\n','Alph0 = [.]');
fprintf(fid,'%s\n','Tempw = 1.5000000e+001');
fprintf(fid,'%s\n','Salw  = 3.1000000e+001');
fprintf(fid,'%s\n','Rouwav= #    #');
fprintf(fid,'%s\n','Wstres= 6.3000000e-004  0.0000000e+000  2.5000000e-003  3.0000000e+001  1.5000000e-003  5.0000000e+001');
fprintf(fid,'%s\n','Rhoa  = 1.1500000e+000');
fprintf(fid,'%s\n','Betac = 5.0000000e-001');
fprintf(fid,'%s\n','Equili= #Y#');
fprintf(fid,'%s\n','Tkemod= #            #');
fprintf(fid,'%s\n','Ktemp = 0');
fprintf(fid,'%s\n','Fclou = 0.0000000e+000');
fprintf(fid,'%s\n','Sarea = 0.0000000e+000');
fprintf(fid,'%s\n','Temint= #Y#');
fprintf(fid,'%s\n','Roumet= #M#');
% fprintf(fid,'%s\n','Ccofu = 2.0000000e-002');
% fprintf(fid,'%s\n','Ccofv = 2.0000000e-002');
fprintf(fid,'%s\n',['Filrgh = #' modelname '.rgh#']);
fprintf(fid,'%s\n','Xlo   = 0.0000000e+000');
fprintf(fid,'%s\n',['Vicouv= ' num2str(vicouv)]);
fprintf(fid,'%s\n','Dicouv= 1.0000000e+000');
fprintf(fid,'%s\n','Htur2d= #N#');
fprintf(fid,'%s\n','Irov  = 0');
fprintf(fid,'%s\n','Iter  = 2');
fprintf(fid,'%s\n','Dryflp= #YES#');
fprintf(fid,'%s\n','Dpsopt= #DP#');
fprintf(fid,'%s\n','Dpuopt= #MIN#');
fprintf(fid,'%s\n','Dryflc= 1.0000000e-001');
fprintf(fid,'%s\n','Dco   = -9.9900000e+002');
fprintf(fid,'%s\n','Tlfsmo= 0.0000000e+000');
fprintf(fid,'%s\n','ThetQH= 0.0000000e+000');
fprintf(fid,'%s\n','Forfuv= #N#');
fprintf(fid,'%s\n','Forfww= #N#');
fprintf(fid,'%s\n','Sigcor= #N#');
fprintf(fid,'%s\n','Trasol= #Cyclic-method#');
fprintf(fid,'%s\n',['Momsol= #' solver '#']);
fprintf(fid,'%s\n','SMhydr= #YYYYY#');
fprintf(fid,'%s\n','SMderv= #YYYYYY#');
fprintf(fid,'%s\n','SMproc= #YYYYYYYYYY#');
fprintf(fid,'%s\n','PMhydr= #YYYYYY#');
fprintf(fid,'%s\n','PMderv= #YYY#');
fprintf(fid,'%s\n','PMproc= #YYYYYYYYYY#');
fprintf(fid,'%s\n','SHhydr= #YYYY#');
fprintf(fid,'%s\n','SHderv= #YYYYY#');
fprintf(fid,'%s\n','SHproc= #YYYYYYYYYY#');
fprintf(fid,'%s\n','SHflux= #YYYY#');
fprintf(fid,'%s\n','PHhydr= #YYYYYY#');
fprintf(fid,'%s\n','PHderv= #YYY#');
fprintf(fid,'%s\n','PHproc= #YYYYYYYYYY#');
fprintf(fid,'%s\n','PHflux= #YYYY#');
fprintf(fid,'%s\n','Online= #N#');
fprintf(fid,'%s\n','Waqmod= #N#');
fprintf(fid,'%s\n','WaveOL= #N#');
if inclobs
    fprintf(fid,'%s\n',['Filsta= #' modelname '.obs#']);
    fprintf(fid,'%s\n','Fmtsta= #FR#');
end
switch lower(modeltype)
    case{'cyclone','tropicalcyclone'}
        fprintf(fid,'%s\n','Prhis = 0.0000000e+000  0.0000000e+000  0.0000000e+000');
        fprintf(fid,'%s\n','Flmap = TSTARTKEY  DTMAPKEY  TSTOPKEY');
        if inclobs
            fprintf(fid,'%s\n','Flhis = TSTARTKEY  DTHISKEY  TSTOPKEY');
        else
            fprintf(fid,'%s\n','Flhis = 0.0000000e+000  0.0000000e+000  0.0000000e+000');
        end
    otherwise
        fprintf(fid,'%s\n','Prhis = 0.0000000e+000  0.0000000e+000  0.0000000e+000');
        fprintf(fid,'%s\n','Flmap = 0.0000000e+000  RDURKEY  RDURKEY');
        if inclobs
            fprintf(fid,'%s\n','Flhis = 0.0000000e+000  1.0000000e+000  RDURKEY');
        else
            fprintf(fid,'%s\n','Flhis = 0.0000000e+000  0.0000000e+000  0.0000000e+000');
        end
end

fprintf(fid,'%s\n','Flpp  = 0.0000000e+000  0.0000000e+000  0.0000000e+000');
fprintf(fid,'%s\n','Flrst = 0.0000000e+000');
fprintf(fid,'%s\n',['Filfou= #' modelname '.fou#']);
fprintf(fid,'%s\n','Fmtfou= #FR#');
fprintf(fid,'%s\n','FLNcdf= #fou map#');
switch lower(modeltype)
    case{'cyclone','tropicalcyclone'}
        fprintf(fid,'%s\n','Filweb= #SPWKEY#');
end

fclose(fid);

% And the fourier file
fid=fopen([dr filesep modelname '.fou'],'wt');
switch lower(modeltype)
    case{'cyclone','tropicalcyclone'}
        fprintf(fid,'%s\n','wl         TSTARTKEY      RDURKEY     1     1.00000     0.00000      max');
        fprintf(fid,'%s\n','uv         TSTARTKEY      RDURKEY     1     1.00000     0.00000  1   max');
        fprintf(fid,'%s\n','eh         TSTARTKEY      RDURKEY     1     1.00000     0.00000      max');
        fprintf(fid,'%s\n','wl         TSTARTKEY      RDURKEY     1     1.00000     0.00000      max  inidryonly');
        fprintf(fid,'%s\n','uv         TSTARTKEY      RDURKEY     1     1.00000     0.00000  1   max  inidryonly');
        fprintf(fid,'%s\n','eh         TSTARTKEY      RDURKEY     1     1.00000     0.00000      max  inidryonly');
    otherwise
        fprintf(fid,'%s\n','wl         0.00      RDURKEY     1     1.00000     0.00000      max');
        fprintf(fid,'%s\n','uv         0.00      RDURKEY     1     1.00000     0.00000  1   max');
        fprintf(fid,'%s\n','eh         0.00      RDURKEY     1     1.00000     0.00000      max');
        fprintf(fid,'%s\n','wl         0.00      RDURKEY     1     1.00000     0.00000      max  inidryonly');
        fprintf(fid,'%s\n','uv         0.00      RDURKEY     1     1.00000     0.00000  1   max  inidryonly');
        fprintf(fid,'%s\n','eh         0.00      RDURKEY     1     1.00000     0.00000      max  inidryonly');
end
fclose(fid);

%%
function val=roundnearest(a,d)
n=round(a/d);
val=n*d;
