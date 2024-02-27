function z0land=delft3d_create_z0land_file(fname,xg,yg,xx,yy,zz,z0luni,opt)

% Compute coordinates of cell centres
[xz,yz]=getXZYZ(xg,yg);
xz=xz(2:end,2:end);
yz=yz(2:end,2:end);

dirs=-pi:pi/6:5*pi/6;
dstv=0:1000:30000;
% weights
sigm=12000;
w=(1/sqrt(2*pi*sigm))*exp(-dstv.^2/(2*sigm^2));
sumw=sum(w);

[dstv,dirs]=meshgrid(dstv,dirs);
xrad=dstv.*cos(dirs);
yrad=dstv.*sin(dirs);

switch opt
    case{'geo','geographic','latlon'}
        lat=abs(nanmean(nanmean(yg))*pi/180);
        geofac=111111;
        xrad=xrad/(geofac*cos(lat));
        yrad=yrad/geofac;
end

% Allocate
xp=zeros(size(xz,1),size(xz,2),size(xrad,1),size(xrad,2));
yp=xp;

% Store in large matrix
for ii=1:size(xz,1)
    for jj=1:size(xz,2)
        xp(ii,jj,:,:)=xz(ii,jj)+xrad;
        yp(ii,jj,:,:)=yz(ii,jj)+yrad;
    end
end

% Interpolate land data
zp=interp2(xx,yy,zz,xp,yp);
zp(isnan(zp))=-100;
zland=-0.5;
iland=find(zp>zland);
isea=find(zp<=zland);
zp(iland)=z0luni;
zp(isea)=0;

z0land=zeros(size(xz,1)+2,size(xz,2)+2,12)-999;

for ii=1:size(xz,1)
    for jj=1:size(xz,2)
        for k=1:12
            z0l=squeeze(zp(ii,jj,k,:));            
            z0land(ii+1,jj+1,k)=sum(z0l.*w')/sumw;
        end
    end
end

% Write to file
if exist(fname,'file')
    try
        delete(fname);
    catch
        error('Could not delete existing file!');
    end
end

for k=1:12
    v=squeeze(z0land(:,:,k));
    ddb_wldep('append',fname,v,'negate','n','bndopt','n');
end
