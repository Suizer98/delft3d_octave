function [grd,dps]=getgridinfo(varargin)

grdfile=[];
depfile=[];

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'gridfile'}
                grdfile=varargin{ii+1};
            case{'depfile'}
                depfile=varargin{ii+1};
            case{'gridx'}
                xg0=varargin{ii+1};
            case{'gridy'}
                yg0=varargin{ii+1};
            case{'depth'}
                dps=varargin{ii+1};
        end
    end
end

if ~isempty(grdfile)
    [xg0,yg0,enc]=ddb_wlgrid('read',grdfile);
    xg0=xg0';
    yg0=yg0';
end


nx=size(xg0,2)+1;
ny=size(xg0,1)+1;
xg=zeros(ny,nx);
xg(xg==0)=NaN;
yg=xg;
xg(1:end-1,1:end-1)=xg0;
yg(1:end-1,1:end-1)=yg0;
np=nx*ny;

grd.xg=xg;
grd.yg=yg;
grd.nx=nx;
grd.ny=ny;

[xz,yz]=getXZYZ(xg,yg);
% gvu=zeros(size(xg));
% gvu(gvu==0)=NaN;
% guv=gvu;
% guu=gvu;
% gvv=gvu;

% dx=xz(2:end-1,3:end-1)-xz(2:end-1,2:end-2);
% dy=yz(2:end-1,3:end-1)-yz(2:end-1,2:end-2);
% dst=sqrt(dx.^2+dy.^2);
% gvu(2:end-1,2:end-2)=dst;

% dx=xz(3:end-1,2:end-1)-xz(2:end-2,2:end-1);
% dy=yz(3:end-1,2:end-1)-yz(2:end-2,2:end-1);
% dst=sqrt(dx.^2+dy.^2);
% guv(2:end-2,2:end-1)=dst;

if ~isempty(depfile)
    dps=ddb_wldep('read',depfile,[nx ny]);
    dps=dps';
    dps(dps==-999)=NaN;
    dps=dps*-1;
else
    dps00=dps;
    dps=zeros(size(dps,1)+1,size(dps,2)+1);
    dps(dps==0)=NaN;
    dps(1:end-1,1:end-1)=dps00;
end

dps=getDepthZ(dps,'MEAN');


grd.dx=zeros(size(dps))+xg(2,1)-xg(1,1);
grd.dy=zeros(size(dps))+yg(1,2)-yg(1,1);


% dps=zeros(size(xg))-10;
% dps(dps<-998)=NaN;
% dps=dps*-1;
% dps=dps';

% dps(~isnan(dps))=-10;


% kfu, kfv and kcs
% kcu=zeros(size(xg));
% kcv=kcu;
% kcs=kcu;
% kcs(isnan(dps))=0;
% kcs(dps>0.1)=1;

% notnan=~isnan(dps(:,1:end-1)) | ~isnan(dps(:,2:end));
% kcu(:,1:end-1)=notnan;
% notnan=~isnan(dps(1:end-1,:)) | ~isnan(dps(2:end,:));
% kcv(1:end-1,:)=notnan;
% 
% % Grid distances
% dx=zeros(size(xg))+100;
% dy=dx;
% volum1=dx;
% 

% grd.dx=zeros(size(xg));
% grd.dy=zeros(size(xg));
% 
% grd.dx(2:end-1,1:end-1)=xg(2:end-1,1:end-1)-xg(1:end-2,1:end-1);
% grd.dy(2:end-1,1:end-1)=yg(2:end-1,1:end-1)-yg(1:end-2,1:end-1);
% grd.a=grd.dx.*grd.dy;
%grd.a=zeros(size(xg))+10000;
% Indices


dx=xg0(1,2)-xg0(1,1);
dy=yg0(2,1)-yg0(1,1);

grd.dx=zeros(size(dps))+dx;
grd.dy=zeros(size(dps))+dy;
grd.a=zeros(size(dps))+dx*dy;

nm=1:np;
grd.nm=1:np;
m=ceil(nm/ny);
n=nm-(m-1)*ny;

mm3=max(-3,1-m);
mm2=max(-2,1-m);
mm1=max(-1,1-m);
mp3=min(2,nx-m);
mp2=min(2,nx-m);
mp1=min(1,nx-m);

nm3=max(-3,1-n);
nm2=max(-2,1-n);
nm1=max(-1,1-n);
np3=min(3,ny-n);
np2=min(2,ny-n);
np1=min(1,ny-n);

grd.nmddd=nm+mm3*ny;
grd.nmdd=nm+mm2*ny;
grd.nmd=nm+mm1*ny;
grd.nmu=nm+mp1*ny;
grd.nmuu=nm+mp2*ny;
grd.nmuuu=nm+mp3*ny;

grd.ndddm=nm+nm3;
grd.nddm=nm+nm2;
grd.ndm=nm+nm1;
grd.num=nm+np1;
grd.nuum=nm+np2;
grd.nuuum=nm+np3;

% a=zeros(size(h))+10000;
% dx=zeros(size(h))+100;
% dy=zeros(size(h))+100;
