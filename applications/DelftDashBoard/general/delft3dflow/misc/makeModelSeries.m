function makeModelSeries(modelprefix,xp,yp,overlap,dx,dy,distoff,dt,inclobs,bathymetry,bathy,cs,dr,iplot,solver,Lfric,Hfric)

diston=distoff;

xg1a=xp(1,:);
yg1a=yp(1,:);
xg2a=xp(2,:);
yg2a=yp(2,:);

for ib=1:length(bathy)
    bathynames{ib}=bathy(ib).name;
    zmn(ib)=bathy(ib).zmin;
    zmx(ib)=bathy(ib).zmax;
    verticaloffsets(ib)=bathy(ib).offset;
end

gridlength=sqrt((xg2a-xg1a).^2+(yg2a-yg1a).^2);

% Determine grid orientation
alph=atan2(yg2a-yg1a,xg2a-xg1a);

% Grid start and end points WITH overlap
xg1=xg1a-overlap*(xg2a-xg1a)./gridlength;
yg1=yg1a-overlap*(yg2a-yg1a)./gridlength;
xg2=xg2a+overlap*(xg2a-xg1a)./gridlength;
yg2=yg2a+overlap*(yg2a-yg1a)./gridlength;
    
% Origin
xx1=xg1+distoff*cos(alph+1.5*pi);
yy1=yg1+distoff*sin(alph+1.5*pi);
xx2=xg2+distoff*cos(alph+1.5*pi);
yy2=yg2+distoff*sin(alph+1.5*pi);
xx3=xg2+diston*cos(alph+0.5*pi);
yy3=yg2+diston*sin(alph+0.5*pi);
xx4=xg1+diston*cos(alph+0.5*pi);
yy4=yg1+diston*sin(alph+0.5*pi);

% ibathy is index of last (coarsest) bathymetry dataset
ibathy=strmatch(bathy(end).name,bathymetry.datasets,'exact');

% Make the grids
ngrids=length(xg1a);

for ig=1:ngrids
    
    modelname=[modelprefix '_' num2str(ig,'%0.4i')];
    
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
    nx=ceil((gridlength(ig)+2*overlap)/dx)-1;
    ny=ceil((diston+distoff)/dy);
    
    % Convert coordinates of polygon to coordinates of bathymetry dataset 
    [xpol1,ypol1]=convertCoordinates(xpol,ypol, ...
        'CS2.name',bathymetry.dataset(ibathy).horizontalCoordinateSystem.name,'CS2.type',bathymetry.dataset(ibathy).horizontalCoordinateSystem.type, ...
        'CS1.name',cs.name,'CS1.type',cs.type);
    xlb=[min(xpol1) max(xpol1)];
    ylb=[min(ypol1) max(ypol1)];
    
    % Get coarse bathymetry (for making initial grid)
    [xx,yy,zz,ok]=ddb_getBathymetry(bathymetry,xlb,ylb,'bathymetry',bathynames{end},'maxcellsize',dx);
    
    % interpolate to model coordinate system
    %    if ~strcmpi(dataCoord.name,coord.name) || ~strcmpi(dataCoord.type,coord.type)
    dmin=min(dx,dy);
    [xg,yg]=meshgrid(min(xpol):dmin:max(xpol),min(ypol):dmin:max(ypol));
    [xgb,ygb]=convertCoordinates(xg,yg,'CS2.name',bathymetry.dataset(ibathy).horizontalCoordinateSystem.name,'CS2.type',bathymetry.dataset(ibathy).horizontalCoordinateSystem.type, ...
        'CS1.name',cs.name,'CS1.type',cs.type);
    zz=interp2(xx,yy,zz,xgb,ygb);
    %    else
    %        xg=xx;
    %        yg=yy;
    %    end
    %pcolor(xg,yg,zz);
    
    % Make rectangular grid
    zmax=200;
    
    [x,y,z]=MakeRectangularGrid(xpol(1),ypol(1),nx,ny,dx,dy,alph(ig),zmax,xg,yg,zz);

    % Extract enclosure    
    enc=ddb_enclosure('extract',x,y);
    
     % Write grid file
    if strcmpi(cs.type,'geographic')
        coord='Spherical';
    else
        coord='Cartesian';
    end
    
    ddb_wlgrid('write','FileName',[dr filesep modelname filesep 'input' filesep modelname '.grd'],'X',x,'Y',y,'Enclosure',enc,'CoordinateSystem',coord);

    %% Bathymetry

    % Interpolate bathymetry onto grid
    [xz,yz]=getXZYZ(x,y);
    z=ddb_interpolateBathymetry(bathymetry,xz,yz,'datasets',bathynames, ...
        'zmin',zmn,'zmax',zmx,'verticaloffsets',verticaloffsets,'verticaloffset',0,'coordinatesystem',cs);
    
    
    % Apply internal diffusion (for missing depth points)
    
    % Missing points are at least 2 m deep    
    isn=isnan(z);              % Missing indices in depth matrix
    
    mask=zeros(size(z))+1;
    mask(isnan(xz))=0;         % Missing indices in grid matrix 
    
    z=internaldiffusion(z,'mask',mask);    
    isn2=logical(isn.*mask);   % Only update points that did not have a depth, but were in an active grid

    z(isn2)=min(z(isn2),-2);
    
    % Make depth of non-active grid points NaN
    z(isnan(x))=NaN;
    ddb_wldep('write',[dr filesep modelname filesep 'input' filesep modelname '.dep'],z);
    
    % Creates RGH file, based on land/water grid cell
    rgh=z;
    rgh(rgh>=0)  =Lfric;        
    rgh(rgh<0)   =Hfric;
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
    
    % MDF?
    xmean=nanmean(nanmean(x));
    ymean=nanmean(nanmean(y));
    [xmean,ymean]=convertCoordinates(xmean,ymean,'CS2.name','WGS 84','CS2.type','geographic', ...
        'CS1.name',cs.name,'CS1.type',cs.type);
    writeMDF([dr filesep modelname filesep 'input' filesep],modelname,size(x,1)+1,size(x,2)+1,ymean,dt,inclobs,solver,Lfric,Hfric);  
    
    % XML
    xml=[];
    xml.name=modelname;
    xml.csname=cs.name;
    xml.cstype=cs.type;
    xml.flownested='';
    xmlfile=[dr filesep modelname filesep modelname '.xml'];
    struct2xml(xmlfile,xml);
    
end

%
function writeMDF(dr,modelname,mmax,nmax,anglat,dt,inclobs,solver,Lfric,Hfric)

fid=fopen([dr filesep 'runflow.bat'],'wt');
fprintf(fid,'%s\n','@ echo off');
fprintf(fid,'%s\n','set argfile=config_flow2d3d.ini');
fprintf(fid,'%s\n','set exedir=C:\Delft3D\w32\flow\bin\');
fprintf(fid,'%s\n','set PATH=%exedir%;%PATH%');
fprintf(fid,'%s\n','%exedir%\deltares_hydro.exe %argfile%');
fclose(fid);

fid=fopen([dr filesep 'config_flow2d3d.ini'],'wt');
fprintf(fid,'%s\n','[FileInformation]');
fprintf(fid,'%s\n','   FileCreatedBy    = Maarten');
fprintf(fid,'%s\n','   FileCreationDate = 02-Feb-2013 01:34:57');
fprintf(fid,'%s\n','   FileVersion      = 00.01');
fprintf(fid,'%s\n','[Component]');
fprintf(fid,'%s\n','   Name                = flow2d3d');
fprintf(fid,'%s\n',['   MDFfile             = ' modelname]);
fclose(fid);

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
fprintf(fid,'%s\n','Itdate= #2013-01-01#');
fprintf(fid,'%s\n','Tunit = #M#');
fprintf(fid,'%s\n','Tstart= 0.0000000e+000');
fprintf(fid,'%s\n','Tstop = RDURKEY');
%fprintf(fid,'%s\n',['Tstop = ' num2str(rdur) ' ']);
fprintf(fid,'%s\n',['Dt    = ' num2str(dt)]);
fprintf(fid,'%s\n','Tzone = 0');
fprintf(fid,'%s\n','Sub1  = #    #');
fprintf(fid,'%s\n','Sub2  = #   #');
fprintf(fid,'%s\n','Wnsvwp= #N#');
fprintf(fid,'%s\n','Wndint= #Y#');
% fprintf(fid,'%s\n','Zeta0 = 0.0000000e+000');
% fprintf(fid,'%s\n','U0    = [.]');
% fprintf(fid,'%s\n','V0    = [.]');
fprintf(fid,'%s\n',['Filic = #' modelname '.ini#']);
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
fprintf(fid,'%s\n','Wstres= 6.3000000e-004  0.0000000e+000  7.2300000e-003  3.0000000e+001');
fprintf(fid,'%s\n','Rhoa  = 1.0000000e+000');
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
fprintf(fid,'%s\n','Vicouv= 1.0000000e+003');
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
fprintf(fid,'%s\n','Prhis = 0.0000000e+000  0.0000000e+000  0.0000000e+000');
fprintf(fid,'%s\n','Flmap = 0.0000000e+000  1.0000000e+001  RDURKEY');
if inclobs
    fprintf(fid,'%s\n','Flhis = 0.0000000e+000  1.0000000e+001  RDURKEY');
else
    fprintf(fid,'%s\n','Flhis = 0.0000000e+000  0.0000000e+000  0.0000000e+000');
end
fprintf(fid,'%s\n','Flpp  = 0.0000000e+000  0.0000000e+000  1.2000000e+002');
fprintf(fid,'%s\n','Flrst = 0.0000000e+000');
fprintf(fid,'%s\n',['Filfou= #' modelname '.fou#']);
fprintf(fid,'%s\n','Fmtfou= #FR#');

fclose(fid);

fid=fopen([dr filesep modelname '.fou'],'wt');
fprintf(fid,'%s\n',['wl         0.00      RDURKEY     1     1.00000     0.00000  max']);
fclose(fid);
