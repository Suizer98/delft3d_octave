function hurrywave_binary_output_to_mat(matfile,inpfile,tref,version)

[folder,name,ext] = fileparts(inpfile);
if ~isempty(folder)
    folder=[folder filesep];
end

inp=sfincs_initialize_input;
inp=sfincs_read_input(inpfile,inp);

[xg,yg]=meshgrid(0:inp.dx:(inp.mmax)*inp.dx,0:inp.dy:(inp.nmax)*inp.dy);
%tstart=datenum(inp.tstart,'yyyymmdd HHMMSS');
tstart=inp.tstart;
rot=inp.rotation*pi/180;
x=inp.x0+cos(rot)*xg-sin(rot)*yg;
y=inp.y0+sin(rot)*xg+cos(rot)*yg;

% Read index file
fid=fopen([folder inp.indexfile],'r');
np=fread(fid,1,'integer*4');
indices=fread(fid,np,'integer*4');
fclose(fid);

% Read depth file
fid=fopen([folder inp.depfile],'r');
zbv=fread(fid,np,'real*4');
fclose(fid);

    zb=zeros(inp.nmax,inp.mmax);
    zbb(zb==0)=NaN;
    zb(indices)=zbv;

% Read data file
it=0;
fid=fopen([folder 'hm0.dat'],'r');
while 1
    idummy=fread(fid,1,'integer*4');
    if isempty(idummy)
        break
    end
    it=it+1;
    zsv=fread(fid,np,'real*4');
    idummy=fread(fid,1,'integer*4');
    zsv(zbv>0)=NaN;
    zs0=zeros(inp.nmax,inp.mmax);
    zs0(zs0==0)=NaN;
    zs0(indices)=zsv;
%    zs0(zs0-zb<0.1)=NaN;
%    zs0(zb>0)=NaN; 
    val(it,:,:)=zs0;
    t(it)=(it-1)*inp.dtmapout;
end
fclose(fid);

it=0;
fid=fopen([folder 'tp.dat'],'r');
while 1
    idummy=fread(fid,1,'integer*4');
    if isempty(idummy)
        break
    end
    it=it+1;
%    zsv=fread(fid,np,'real*4');
    zsv=fread(fid,np,'real*4');
    zsv(zbv>0)=NaN;
    idummy=fread(fid,1,'integer*4');
    zs0=zeros(inp.nmax,inp.mmax);
    zs0(zs0==0)=NaN;
    zs0(indices)=zsv;
%    zs0(zs0-zb<0.1)=NaN;
%    zs0(zb>0)=NaN; 
    valtp(it,:,:)=zs0;
    t(it)=(it-1)*inp.dtmapout;
end
fclose(fid);

it=0;
fid=fopen([folder 'wavdir.dat'],'r');
while 1
    idummy=fread(fid,1,'integer*4');
    if isempty(idummy)
        break
    end
    it=it+1;
%    zsv=fread(fid,np,'real*4');
    zsv=fread(fid,np,'real*4');
    zsv(zbv>0)=NaN;
    idummy=fread(fid,1,'integer*4');
    zs0=zeros(inp.nmax,inp.mmax);
    zs0(zs0==0)=NaN;
    zs0(indices)=zsv;
%    zs0(zs0-zb<0.1)=NaN;
%    zs0(zb>0)=NaN; 
    valwd(it,:,:)=zs0;
    t(it)=(it-1)*inp.dtmapout;
end
fclose(fid);

it=0;
fid=fopen([folder 'dirspr.dat'],'r');
while 1
    idummy=fread(fid,1,'integer*4');
    if isempty(idummy)
        break
    end
    it=it+1;
%    zsv=fread(fid,np,'real*4');
    zsv=fread(fid,np,'real*4');
    zsv(zbv>0)=NaN;
    idummy=fread(fid,1,'integer*4');
    zs0=zeros(inp.nmax,inp.mmax);
    zs0(zs0==0)=NaN;
    zs0(indices)=zsv;
%    zs0(zs0-zb<0.1)=NaN;
%    zs0(zb>0)=NaN; 
    valds(it,:,:)=zs0;
    t(it)=(it-1)*inp.dtmapout;
end
fclose(fid);


valout=zeros(size(val,1),inp.nmax+1,inp.mmax+1);
zbout=zeros(inp.nmax+1,inp.mmax+1);
valout(valout==0)=NaN;
zbout(zbout==0)=NaN;

n=0;

valout(:,1:end-1,1:end-1)=val;
n=n+1;
s.parameters(n).parameter.name='Hm0';

s.parameters(n).parameter.time=tstart+t/86400;
s.parameters(n).parameter.x=x;
s.parameters(n).parameter.y=y;
s.parameters(n).parameter.val=valout;
s.parameters(n).parameter.size=[size(valout,1) 0 size(x,1) size(x,2) 0];
s.parameters(n).parameter.quantity='scalar';

valout(:,1:end-1,1:end-1)=valtp;
n=n+1;
s.parameters(n).parameter.name='Tp';

s.parameters(n).parameter.time=tstart+t/86400;
s.parameters(n).parameter.x=x;
s.parameters(n).parameter.y=y;
s.parameters(n).parameter.val=valout;
s.parameters(n).parameter.size=[size(valout,1) 0 size(x,1) size(x,2) 0];
s.parameters(n).parameter.quantity='scalar';

valout(:,1:end-1,1:end-1)=valwd;
n=n+1;
s.parameters(n).parameter.name='wave direction';

s.parameters(n).parameter.time=tstart+t/86400;
s.parameters(n).parameter.x=x;
s.parameters(n).parameter.y=y;
s.parameters(n).parameter.val=valout;
s.parameters(n).parameter.size=[size(valout,1) 0 size(x,1) size(x,2) 0];
s.parameters(n).parameter.quantity='scalar';

u=valout;
v=valout;
dr=pi*(270-valwd)/180;
uu=val.*cos(dr);
vv=val.*sin(dr);
u(:,1:end-1,1:end-1)=uu;
v(:,1:end-1,1:end-1)=vv;

n=n+1;
s.parameters(n).parameter.name='wave vector';

s.parameters(n).parameter.time=tstart+t/86400;
s.parameters(n).parameter.x=x;
s.parameters(n).parameter.y=y;
s.parameters(n).parameter.u=u;
s.parameters(n).parameter.v=v;
s.parameters(n).parameter.size=[size(valout,1) 0 size(x,1) size(x,2) 0];
s.parameters(n).parameter.quantity='vector';

valout(:,1:end-1,1:end-1)=valds;
n=n+1;
s.parameters(n).parameter.name='directional spreading';
s.parameters(n).parameter.time=tstart+t/86400;
s.parameters(n).parameter.x=x;
s.parameters(n).parameter.y=y;
s.parameters(n).parameter.val=valout;
s.parameters(n).parameter.size=[size(valout,1) 0 size(x,1) size(x,2) 0];
s.parameters(n).parameter.quantity='scalar';

zbout(1:end-1,1:end-1)=zb;
n=n+1;
s.parameters(n).parameter.name='water depth';
s.parameters(n).parameter.x=x;
s.parameters(n).parameter.y=y;
s.parameters(n).parameter.val=zbout;
s.parameters(n).parameter.size=[0 0 size(x,1) size(x,2) 0];
s.parameters(n).parameter.quantity='scalar';

% zbout(1:end-1,1:end-1)=zb;
% n=n+1;
% s.parameters(n).parameter.name='bed level';
% s.parameters(n).parameter.x=x;
% s.parameters(n).parameter.y=y;
% s.parameters(n).parameter.val=zbout;
% s.parameters(n).parameter.size=[0 0 size(x,1) size(x,2) 0];
% s.parameters(n).parameter.quantity='scalar';

if version == 7.3
	save(matfile,'-struct','s','-v7.3'); %For variables larger than 2GB use MAT-file version 7.3 or later. 
else
	save(matfile,'-struct','s');
end
