function sfincs_write_indices_for_dem(inpfile,outfile,demx,demy,cs_dem,cs_sfincs)
%
% E.g.
%
% dr='d:\PhD\sfincs_tests\subgrid\charleston\run01\';
% topofile='charleston_ncei_14m.mat';
% 
% matfile=[dr 'sfincs.mat'];
% 
% s2=load(topofile);
% 
% demx=s2.parameters(1).parameter.x(1,:);  % must be an 1xn vector
% demy=s2.parameters(1).parameter.y(:,1)'; % must be an 1xn vector
% demz=s2.parameters(1).parameter.val;
% 
% clear s2
% 
% inpfile='sfincs.inp';
% outfile='charleston_ncei_14m_indices.dat';
% cs_dem.name='WGS 84';
% cs_dem.type='geographic';
% cs_sfincs.name='WGS 84 / UTM zone 18N';
% cs_sfincs.type='projected';
% 
% sfincs_write_indices_for_dem(inpfile,outfile,demx,demy,cs_dem,cs_sfincs);

inp=sfincs_initialize_input;
inp=sfincs_read_input(inpfile,inp);

% % sfincs grid
% [xg0,yg0]=meshgrid(0:inp.dx:(inp.mmax)*inp.dx,0:inp.dy:(inp.nmax)*inp.dy);
% rot=inp.rotation*pi/180;
% xg=inp.x0+cos(rot)*xg0-sin(rot)*yg0;
% yg=inp.y0+sin(rot)*xg0+cos(rot)*yg0;
% clear xg0 yg0
% 
% % Convert sfincs grid to dem coordinate system
% [xg,yg]=convertCoordinates(xg,yg,'persistent','CS1.name',cs_sfincs.name,'CS1.type',cs_sfincs.type,'CS2.name',cs_dem.name,'CS2.type',cs_dem.type);        

% size of dem
ntopo=size(demy,2); 
mtopo=size(demx,2);

% Get indices. Do this in blocks as the mex file can't handle large arrays
blocksize = 50;
nn1=ceil(ntopo/blocksize);
mm1=ceil(mtopo/blocksize);
indices=zeros(ntopo,mtopo);
for in=1:nn1
    disp(['Processing DEM row ' num2str(in) ' of ' num2str(nn1) ' ...']);
    for im=1:mm1
        i1=(in-1)*blocksize+1;
        j1=(im-1)*blocksize+1;
        i2=i1+blocksize-1;
        j2=j1+blocksize-1;
        i2=min(i2,ntopo);
        j2=min(j2,mtopo);
%        ind=mx_find_grid_indices(demx(j1:j2),demy(i1:i2),xg,yg);
        ind=find_grid_indices(demx(j1:j2),demy(i1:i2),inp.x0,inp.y0,inp.dx,inp.dy,inp.mmax,inp.nmax,inp.rotation,cs_sfincs,cs_dem);
%        ind=double(ind);
        indices(i1:i2,j1:j2)=ind;
    end
end

% Now write output file
%indices=reshape(indices,[1 ntopo*mtopo]);

fid=fopen(outfile,'w');
fwrite(fid,ntopo,'integer*4');
fwrite(fid,mtopo,'integer*4');
fwrite(fid,indices,'integer*4');
fclose(fid);

function ind=find_grid_indices(demx,demy,x0,y0,dx,dy,mmax,nmax,rotation,cs_sfincs,cs_dem)

[xx,yy]=meshgrid(demx,demy);
[xx,yy]=convertCoordinates(xx,yy,'persistent','CS1.name',cs_dem.name,'CS1.type',cs_dem.type,'CS2.name',cs_sfincs.name,'CS2.type',cs_sfincs.type);        

cosrot=cos(rotation*pi/180);
sinrot=sin(rotation*pi/180);

% Rotate dem around sfincs origin
xr =   cosrot*(xx - x0) + sinrot*(yy - y0);
yr = - sinrot*(xx - x0) + cosrot*(yy - y0);

m = floor(xr/dx) + 1;
n = floor(yr/dy) + 1;

ind = (m-1)*nmax + n;
ind(m<1)=0;
ind(n<1)=0;
ind(m>mmax)=0;
ind(n>nmax)=0;

