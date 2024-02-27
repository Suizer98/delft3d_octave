function subgrd1=sfincs_make_subgrid_file(dr,subgridfile,bathy,manning_input,cs,nbin,refi,refj,uopt,maxdzdv,varargin)
% Makes SFINCS subgrid file in the folder dr
%
% E.g.:
%
% dr='d:\sfincstest\run01\';         % output folder
% subgridfile='sfincs.sbg';          % name of subgrid file
% bathy(1).name='ncei_new_river_nc'; % first bathy dataset
% bathy(2).name='usgs_ned_coastal';  % second bathy dataset
% bathy(3).name='ngdc_crm';          % third bathy dataset
% cs.name='WGS 84 / UTM zone 18N';   % cs name of model
% cs.type='projected';               % cs type of model
% nbin=5;                            % Number of bins in subgrid table
% refi=20;                           % Subgrid refinement factor w.r.t. SFINCS grid in n direction
% refj=20;                           % Subgrid refinement factor w.r.t. SFINCS grid in m direction
%
% sfincs_make_subgrid_file(dr,subgridfile,bathy,cs,nbin,refi,refj)
%%

% Variable input
polygons=[];
quiet   = false;
nrmax   = 2000;
rgh_missing = 0.04;

%% Read input arguments
for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'polygons'}
                polygons=varargin{ii+1};
            case{'quiet'}
                quiet=varargin{ii+1};
            case{'rgh_missing'}
                rgh_missing=varargin{ii+1};
        end
    end
end

% Handle coordinate systems
if ~isempty(cs)
    
    % Global load bathymetry from Dashboard
    global bathymetry
    if isempty(bathymetry)
        error('Bathymetry database has not yet been initialized! Please run initialize_bathymetry_database.m first.')
    end
    
    % Define subgrid file

    if ~isempty(subgridfile)
        subgridfile=[dr filesep subgridfile];
    end

    
    % Loop over bathy
    for ib=1:length(bathy)
        model.bathymetry(ib).name=bathy(ib).name;
        ii=strmatch(lower(bathy(ib).name),lower(bathymetry.datasets),'exact');
        model.bathymetry(ib).csname=bathymetry.dataset(ii).horizontalCoordinateSystem.name;
        model.bathymetry(ib).cstype=bathymetry.dataset(ii).horizontalCoordinateSystem.type;
    end
    
    % Loop over roughness datasets (if data comes from ddb tiles)
    if isstruct(manning_input)
        if ~isfield(manning_input,'x')
            for ib=1:length(manning_input)
                ii=strmatch(lower(manning_input(ib).name),lower(bathymetry.datasets),'exact');
                manning_input(ib).csname=bathymetry.dataset(ii).horizontalCoordinateSystem.name;
                manning_input(ib).cstype=bathymetry.dataset(ii).horizontalCoordinateSystem.type;
            end
        end
    end
    
    model.cs.name=cs.name;
    model.cs.type=cs.type;
end

% Read sfincs inputs
inp=sfincs_read_input([dr 'sfincs.inp'],[]);
mmax=inp.mmax;
nmax=inp.nmax;
dx=inp.dx;
dy=inp.dy;
x0=inp.x0;
y0=inp.y0;
rotation=inp.rotation;
cosrot=cos(rotation*pi/180);
sinrot=sin(rotation*pi/180);
ilev=1;

indexfile   = [dr inp.indexfile];
bindepfile  = [dr inp.depfile];
binmskfile  = [dr inp.mskfile];
[~,msk]     = sfincs_read_binary_inputs(mmax,nmax,indexfile,bindepfile,binmskfile);

di=dy/2^(ilev-1);  % cell size
dj=dx/2^(ilev-1);  % cell size
dif=di/refi;       % size of subgrid pixel
djf=dj/refj;       % size of subgrid pixel
imax=nmax+1;       % add extra cell to compute u and v in the last row/column
jmax=mmax+1;       % add extra cell to compute u and v in the last row/column

nib=floor(nrmax/(di/dif)); % nr of regular cells in a block
njb=floor(nrmax/(dj/djf)); % nr of regular cells in a block

ni=ceil(imax/nib); % nr of blocks
nj=ceil(jmax/njb); % nr of blocks

% Initialize temporary arrays
subgrd.z_zmin=zeros(imax,jmax);
subgrd.z_zmax=zeros(imax,jmax);
subgrd.z_volmax=zeros(imax,jmax);
subgrd.z_depth=zeros(imax,jmax,nbin);
subgrd.z_hrep=zeros(imax,jmax,nbin);
subgrd.z_navg=zeros(imax,jmax,nbin);
subgrd.z_dhdz=zeros(imax,jmax);

% Display
if quiet ~= 1
    disp(['Grid size of flux grid is dx= ',num2str(dx),' and dy= ',num2str(dy)])
    disp(['Grid size of subgrid pixels is dx= ',num2str(djf),' and dy= ',num2str(dif)])
end

%% Loop through blocks
ib=0;
for ii=1:ni
    for jj=1:nj
        
        % Count
        ib=ib+1;
        if quiet ~= 1; disp(['Processing block ' num2str(ib) ' of ' num2str(ni*nj)]); end
        
        % cell indices
        ic1=(ii-1)*nib+1;
        jc1=(jj-1)*njb+1;
        ic2=(ii  )*nib;
        jc2=(jj  )*njb;
        
        ic2=min(ic2,imax);
        jc2=min(jc2,jmax);
        
        % Actual number of grid cells in this block (after cutting off irrelevant edges)
        nib1=ic2-ic1+1;
        njb1=jc2-jc1+1;
        
        % Make subgrid
        xx0=(jj-1)*njb*dj;
        yy0=(ii-1)*nib*di;
        xx1=xx0 + (njb1+1)*dj - djf;
        yy1=yy0 + (nib1+1)*di - dif;
        xx=xx0:djf:xx1;
        yy=yy0:djf:yy1;
        xx=xx+0.5*djf;
        yy=yy+0.5*dif;
        [xx,yy]=meshgrid(xx,yy);
        xg0 = x0 + cosrot*xx - sinrot*yy;
        yg0 = y0 + sinrot*xx + cosrot*yy;

        if isempty(cs)
            cellareas=repmat(dx*dy,nib1,njb1);
        else
            if strcmpi(cs.type,'projected')
                cellareas=repmat(dx*dy,nib1,njb1);
            else
                xxc = (x0 + (jc1-1)*dx + 0.5*dx):dx: (x0 + jc2*dx - 0.5*dx);
                yyc = (y0 + (ic1-1)*dy + 0.5*dy):dy: (y0 + ic2*dx - 0.5*dy);
                [xc,yc] = meshgrid(xxc,yyc);
                cellareas = (dy*111111.1)*(dx*111111.1)*cos(yc*pi/180);
            end
        end
        clear xx yy
        
        % Initialize depth of subgrid at NaN
        zg          = zeros(size(xg0));
        zg(zg==0)   = NaN;
        if ~isempty(cs)
            
            % Loop through bathymetry datasets
            for ibat=1:length(model.bathymetry)
                
                % Convert model grid to bathymetry cs
                [xg,yg]=convertCoordinates(xg0,yg0,'persistent','CS1.name',model.cs.name,'CS1.type',model.cs.type,'CS2.name',model.bathymetry(ibat).csname,'CS2.type',model.bathymetry(ibat).cstype);
                
                xmin=nanmin(nanmin(xg));
                xmax=nanmax(nanmax(xg));
                ymin=nanmin(nanmin(yg));
                ymax=nanmax(nanmax(yg));
                ddx=0.05*(xmax-xmin);
                ddy=0.05*(ymax-ymin);
                bboxx=[xmin-ddx xmax+ddx];
                bboxy=[ymin-ddy ymax+ddy];
                
                % Now get the bathy data for this block
                if ~isempty(find(isnan(zg), 1))
                    [xx,yy,zz,ok]=ddb_getBathymetry(bathymetry,bboxx,bboxy,'bathymetry',model.bathymetry(ibat).name,'maxcellsize',min(dif,djf),'quiet');
                    zz(zz<bathy(ibat).zmin)=NaN;
                    zz(zz>bathy(ibat).zmax)=NaN;
                    if ~isempty(find(~isnan(zz), 1))
                        zg1=interp2(xx,yy,zz,xg,yg);
                        zg(isnan(zg))=zg1(isnan(zg));
                    end
                end
            end
            
            % Adjust bathymetry based on polygon data
            if ~isempty(polygons)
                for ipol=1:length(polygons)
                    if strcmpi(polygons(ipol).type,'bathymetry')

                        [xpol,ypol]=landboundary('read',polygons(ipol).filename);
                        
                        xmin=nanmin(nanmin(xg0));
                        xmax=nanmax(nanmax(xg0));
                        ymin=nanmin(nanmin(yg0));
                        ymax=nanmax(nanmax(yg0));
                        
                        xminp=nanmin(xpol);
                        xmaxp=nanmax(xpol);
                        yminp=nanmin(ypol);
                        ymaxp=nanmax(ypol);
                        
                        if xminp<xmax && xmaxp>xmin && yminp<ymax && ymaxp>ymin 
                            inpol=inpolygon(xg0,yg0,xpol,ypol);
                            switch lower(polygons(ipol).operator)
                                case{'min'}
                                    zg(inpol)=min(zg(inpol),polygons(ipol).value);
                                case{'max'}
                                    zg(inpol)=max(zg(inpol),polygons(ipol).value);
                                case{'add'}
                                    zg(inpol)=zg(inpol)+polygons(ipol).value;
                                case{'eq'}
                                    zg(inpol)=min(zg(inpol),polygons(ipol).value);
                            end
                        end
                    end
                end
            end
            
        else
            
            % Simply load bathy structure
            xx=bathy.x;
            yy=bathy.y;
            zz=bathy.z;
            zg=interp2(xx,yy,zz,xg0,yg0);
            
        end

%         % Check if we find NaNs
%         zg(isnan(zg))=0;
%         if ~isempty(find(isnan(zg)))
%             error(['NaNs found in bathymetry!!! Block ii = ' num2str(ii) ', jj = ' num2str(jj)]);
%         end

        %% Now get manning values
        % Ini values
        manning=zeros(size(xg0));
        manning(manning==0)=NaN;
        
        % If manning is a character string, determine it from the NLCD database
        % If manning is a structure, x, y and z 
        % If manning is a numeric, values are determined based on deep, shallow and level
        if ischar(manning_input)
            sn              = get_nlcd_values(manning_input,xg0,yg0,model.cs,'manning');
            manning         = sn.manning;
            clear sn
        elseif isstruct(manning_input)
            
            if isfield(manning_input,'x')
                % Manning from regular grid
                % x and y must be in the same coordinate system as the model !!!
                manning         = interp2(manning_input.x,manning_input.y,manning_input.val,xg0,yg0);
            else
                % Manning from ddb tiles
                % Loop through manning datasets
                for ibat=1:length(manning_input)
                    
                    % Convert model grid to bathymetry cs
                    [xg,yg]=convertCoordinates(xg0,yg0,'persistent','CS1.name',model.cs.name,'CS1.type',model.cs.type,'CS2.name',manning_input(ibat).csname,'CS2.type',manning_input(ibat).cstype);
                    
                    xmin=nanmin(nanmin(xg));
                    xmax=nanmax(nanmax(xg));
                    ymin=nanmin(nanmin(yg));
                    ymax=nanmax(nanmax(yg));
                    ddx=0.05*(xmax-xmin);
                    ddy=0.05*(ymax-ymin);
                    bboxx=[xmin-ddx xmax+ddx];
                    bboxy=[ymin-ddy ymax+ddy];
                    
                    % Now get the bathy data for this block
                    if ~isempty(find(isnan(manning), 1))
                        [xx,yy,zz,ok]=ddb_getBathymetry(bathymetry,bboxx,bboxy,'bathymetry',manning_input(ibat).name,'maxcellsize',min(dif,djf),'quiet');
                        zz(zz<manning_input(ibat).zmin)=NaN;
                        zz(zz>manning_input(ibat).zmax)=NaN;
                        if ~isempty(find(~isnan(zz), 1))
                            zg1=interp2(xx,yy,zz,xg,yg);
                            manning(isnan(manning))=zg1(isnan(manning));
                        end
                    end
                end
            end
            
        else
            manning_deep    = manning_input(1);
            manning_shallow = manning_input(2);
            manning_level   = manning_input(3);
            manning         = zeros(size(zg));
            manning(zg<manning_level)=manning_deep;
            manning(zg>=manning_level)=manning_shallow;
        end
        clear zg1 xx yy zz manning1 manning2
        
        % Adjust manning based on polygon data
        if ~isempty(polygons)
            for ipol=1:length(polygons)
                if strcmpi(polygons(ipol).type,'manning')

                    [xpol,ypol]=landboundary('read',polygons(ipol).filename);

                    xmin=nanmin(nanmin(xg0));
                    xmax=nanmax(nanmax(xg0));
                    ymin=nanmin(nanmin(yg0));
                    ymax=nanmax(nanmax(yg0));

                    xminp=nanmin(xpol);
                    xmaxp=nanmax(xpol);
                    yminp=nanmin(ypol);
                    ymaxp=nanmax(ypol);

                    if xminp<xmax && xmaxp>xmin && yminp<ymax && ymaxp>ymin 
                        inpol=inpolygon(xg0,yg0,xpol,ypol);
                        switch lower(polygons(ipol).operator)
                            case{'min'}
                                manning(inpol)=min(manning(inpol),polygons(ipol).value);
                            case{'max'}
                                manning(inpol)=max(manning(inpol),polygons(ipol).value);
                            case{'add'}
                                manning(inpol)=manning(inpol)+polygons(ipol).value;
                            case{'eq'}
                                manning(inpol)=min(manning(inpol),polygons(ipol).value);
                        end
                    end
                end
            end
        end
        
        % Check: no NaNs
        if ~isempty(find(isnan(zg), 1)) || ~isempty(find(isnan(manning), 1))
            isn=find(isnan(zg));
            if ~isempty(isn)
                if length(isn)<0.1*size(xg,1)*size(xg,2)
                    % just a limited number of points
                    disp('Small number of NaNs found in topography data. Trying internal diffusion ...');
                    zg=internaldiffusion(zg);
                else
                    error(['Stop processing: NaN values found in topography -> Block ii = ' num2str(ii) ', jj = ' num2str(jj)]);
                end
            end
            isn=find(isnan(manning));
            if ~isempty(isn)
                if length(isn)<0.1*size(manning,1)*size(manning,2)
                    % just a limited number of points
                    disp('Small number of NaNs found in roughness data. Trying internal diffusion ...');
                    manning=internaldiffusion(manning);
                else
                    disp(['Warning: missing manning values set to ' num2str(rgh_missing) '!']);
                    manning(isnan(manning))=rgh_missing;
%                    error(['stop processing: NaN in Manning values -> Block ii = ' num2str(ii) ', jj = ' num2str(jj)]);
                end
            end
        end
        % Done interpolating bed levels and Manning's n onto high-res block
        
        %% Now compute subgrid properties
        % Volumes
        np=0;
        d=zeros(nib1,njb1,refi*refj); % First create 3D matrix (nmax,mmax,refi*refj)
        d(d==0)=NaN;
        for iref=1:refi
            for jref=1:refj
                np=np+1;
                i1=iref;
                i2=i1+(nib1-1)*refi;
                j1=jref;
                j2=j1+(njb1-1)*refj;
                zg1=zg(i1:refi:i2,j1:refj:j2);
                d(:,:,np)=zg1;
            end
        end
        
        % Determine values for subgrid
        [zmin,zmax,volmax,ddd]=mx_subgrid_volumes_v05(d,cellareas,nbin,dx,dy,maxdzdv);
        
        % Re-map Z points
        subgrd.z_zmin(ic1:ic2,jc1:jc2)=zmin;
        subgrd.z_zmax(ic1:ic2,jc1:jc2)=zmax;
        subgrd.z_volmax(ic1:ic2,jc1:jc2)=volmax;
        subgrd.z_depth(ic1:ic2,jc1:jc2,:)=ddd;
         
        % Now the U points
        np=0;
        d=zeros(nib1,njb1,refi*refj); % First create 3D matrix (nmax,mmax,refi*refj)
        d(d==0)=NaN;
        manning1=d;
        for jref=1:refj
            for iref=1:refi
                np=np+1;
                i1=iref;
                i2=i1+(nib1-1)*refi;
                j1=jref + refj/2;
                j2=j1+(njb1-1)*refj + refj/2;
                zg1=zg(i1:refi:i2,j1:refj:j2);
                d(:,:,np)=zg1;
                manning1(:,:,np)=manning(i1:refi:i2,j1:refj:j2);
            end
        end
        [ddd_u,dhdz_u,navg_u,zmin_u,zmax_u]=mx_subgrid_depth_v05(d,manning1,nbin);
        
        % Re-map U points
        subgrd.u_zmin(ic1:ic2,jc1:jc2)=zmin_u;
        subgrd.u_zmax(ic1:ic2,jc1:jc2)=zmax_u;
        subgrd.u_dhdz(ic1:ic2,jc1:jc2)=dhdz_u;
        subgrd.u_hrep(ic1:ic2,jc1:jc2,:)=ddd_u;
        subgrd.u_navg(ic1:ic2,jc1:jc2,:)=navg_u;
        
        
        % And the V points (note that the order in d and manning1 is different here!!!)
        np=0;
        d=zeros(nib1,njb1,refi*refj); % First create 3D matrix (nmax,mmax,refi*refj)
        d(d==0)=NaN;
        manning1=d;
        for iref=1:refi
            for jref=1:refj
                np=np+1;
                i1=iref + refi/2;
                i2=i1+(nib1-1)*refi + refi/2;
                j1=jref;
                j2=j1+(njb1-1)*refj;
                zg1=zg(i1:refi:i2,j1:refj:j2);
                d(:,:,np)=zg1;
                manning1(:,:,np)=manning(i1:refi:i2,j1:refj:j2);
            end
        end
        [ddd_v,dhdz_v,navg_v,zmin_v,zmax_v]=mx_subgrid_depth_v05(d,manning1,nbin);
        
        % Re-map V points
        subgrd.v_zmin(ic1:ic2,jc1:jc2)=zmin_v;
        subgrd.v_zmax(ic1:ic2,jc1:jc2)=zmax_v;
        subgrd.v_dhdz(ic1:ic2,jc1:jc2)=dhdz_v;
        subgrd.v_hrep(ic1:ic2,jc1:jc2,:)=ddd_v;
        subgrd.v_navg(ic1:ic2,jc1:jc2,:)=navg_v;
                
    end
end

% Done for this level
subgrd1.z_zmin   = subgrd.z_zmin(1:nmax,1:mmax,:);
subgrd1.z_zmax   = subgrd.z_zmax(1:nmax,1:mmax,:);
subgrd1.z_volmax = subgrd.z_volmax(1:nmax,1:mmax,:);
subgrd1.z_depth  = subgrd.z_depth(1:nmax,1:mmax,:);

subgrd1.u_zmin   = subgrd.u_zmin(1:nmax,1:mmax);
subgrd1.u_zmax   = subgrd.u_zmax(1:nmax,1:mmax);
subgrd1.u_dhdz   = subgrd.u_dhdz(1:nmax,1:mmax);
subgrd1.u_hrep   = subgrd.u_hrep(1:nmax,1:mmax,:);
subgrd1.u_navg   = subgrd.u_navg(1:nmax,1:mmax,:);
subgrd1.v_zmin   = subgrd.v_zmin(1:nmax,1:mmax);
subgrd1.v_zmax   = subgrd.v_zmax(1:nmax,1:mmax);
subgrd1.v_dhdz   = subgrd.v_dhdz(1:nmax,1:mmax);
subgrd1.v_hrep   = subgrd.v_hrep(1:nmax,1:mmax,:);
subgrd1.v_navg   = subgrd.v_navg(1:nmax,1:mmax,:);

% Write file
if ~isempty(subgridfile)
    sfincs_write_binary_subgrid_tables(subgrd1,msk,nbin,subgridfile,uopt);
end
