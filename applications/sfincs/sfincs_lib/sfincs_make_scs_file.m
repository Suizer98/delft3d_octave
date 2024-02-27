function sfincs_make_scs_file(dr,scsfile,cn_input,cs,refi,refj,varargin)
% Makes SFINCS scs file in the folder dr
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

soiltype='B';

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch varargin{ii}
            case{'soiltype'}
                soiltype=varargin{ii+1};
        end
    end
end


scsfile=[dr filesep scsfile];

% Read sfincs inputs
inp=sfincs_read_input([dr 'sfincs.inp'],[]);

mmax=inp.mmax;
nmax=inp.nmax;
dx=inp.dx;
dy=inp.dy;
x0=inp.x0;
y0=inp.y0;
rotation=inp.rotation;

indexfile=[dr inp.indexfile];
bindepfile=[dr inp.depfile];
binmskfile=[dr inp.mskfile];
[z,msk]=sfincs_read_binary_inputs(mmax,nmax,indexfile,bindepfile,binmskfile);

di=dy;       % cell size
dj=dx;       % cell size
dif=dy/refi; % size of subgrid pixel
djf=dx/refj; % size of subgrid pixel
imax=nmax; % add extra cell to compute u and v in the last row/column
jmax=mmax; % 

cosrot=cos(rotation*pi/180);
sinrot=sin(rotation*pi/180);

nrmax=2000;

nib=floor(nrmax/(di/dif)); % nr of regular cells in a block
njb=floor(nrmax/(dj/djf)); % nr of regular cells in a block

ni=ceil(imax/nib); % nr of blocks
nj=ceil(jmax/njb); % nr of blocks

% Initialize temporary arrays

s=zeros(nmax,mmax);

ib=0;
for ii=1:ni
    for jj=1:nj
        
        %% Loop through blocks
        
        ib=ib+1;
        
        disp(['Processing block ' num2str(ib) ' of ' num2str(ni*nj)]);
        
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
        xx1=xx0 + njb1*dj - djf;
        yy1=yy0 + nib1*di - dif;
        xx=xx0:djf:xx1;
        yy=yy0:djf:yy1;
        xx=xx+0.5*djf;
        yy=yy+0.5*dif;
        [xx,yy]=meshgrid(xx,yy);
        xg0 = x0 + cosrot*xx - sinrot*yy;
        yg0 = y0 + sinrot*xx + cosrot*yy;
        clear xx yy
        
        if ischar(cn_input)
            
            sn=get_nlcd_values(cn_input,xg0,yg0,cs,'cn','soiltype',soiltype);
            cn=sn.cn;
            clear sn
                            
        else
            
            xx=cn_input.x;
            yy=cn_input.y;
            zz=cn_input.z;
            cn=interp2(xx,yy,zz,xg0,yg0);
            cn(isnan(cn))=100;
            
        end
        
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
                cn1=cn(i1:refi:i2,j1:refj:j2);
                d(:,:,np)=cn1;
            end
        end
        
        d=1000./d - 10.0; % convert to S value
        
        d=nanmean(d,3);   % compute average subgrid S 
        
        s(ic1:ic2,jc1:jc2)=d;
                
    end
end

iincl=0;  % include only msk=1 and msk=2
% iincl=-1; % include all points

fid=fopen(scsfile,'w');
val=s(msk>iincl);
fwrite(fid,val,'real*4');
fclose(fid);
