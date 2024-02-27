function [xx,zc]=sessp_compute_profile_depths(xn,yn,dx,depfile)

% zc starts at shore

% depfile must be in wgs84

x0=mean(mean(xn));
y0=mean(mean(yn));

% xg=reshape(xg,[size(xg,1)*size(xg,2) 1]);
% yg=reshape(yg,[size(yg,1)*size(yg,2) 1]);
% zg=reshape(zg,[size(zg,1)*size(zg,2) 1]);
% F = scatteredInterpolant(xg,yg,zg);

cs1.name='WGS 84';
cs1.type='geographic';

% Determine UTM zone
utmz = fix( ( x0 / 6 ) + 31);
utmz = mod(utmz,60);
if y0>0
    cs2.name=['WGS 84 / UTM zone ' num2str(utmz) 'N'];
else
    cs2.name=['WGS 84 / UTM zone ' num2str(utmz) 'S'];
end
cs2.type='projected';

% Convert shore normal coordinates to utm
[xn,yn]=convertCoordinates(xn,yn,'persistent','CS1.name',cs1.name,'CS1.type',cs1.type,'CS2.name',cs2.name,'CS2.type',cs2.type);

% Compute maximum length of all 
dst=sqrt((xn(2,:)-xn(1,:)).^2+(yn(2,:)-yn(1,:)).^2);
maxdist=max(dst);

np=size(xn,2);           % number of coastline points
ncrs=ceil(maxdist/dx)+1; % number of points per cross-section

xx=0:dx:(ncrs-1)*dx;

% Create grid with cross section points (in UTM)
xc=zeros(ncrs,np);
yc=zeros(ncrs,np);
% zc=zeros(ncrs,np);

xc(xc==0)=NaN;
yc(yc==0)=NaN;
% zc(zc==0)=NaN;

for ip=1:np
    % Total number of points along this cross-section
    n=ceil(dst(ip)/dx)+1;
    dstx=xn(2,ip)-xn(1,ip);
    dsty=yn(2,ip)-yn(1,ip);
    xcc=xn(1,ip):dstx/(n-1):xn(2,ip);
    ycc=yn(1,ip):dsty/(n-1):yn(2,ip);    
    xc(1:n,ip)=xcc';
    yc(1:n,ip)=ycc';
end

% Convert back to WGS 84
[xc,yc]=convertCoordinates(xc,yc,'persistent','CS1.name',cs2.name,'CS1.type',cs2.type,'CS2.name',cs1.name,'CS2.type',cs1.type);

zc=zeros(size(xc));
zc(zc==0)=NaN;

if iscell(depfile)
    for ifil=1:length(depfile)
        
        s=load(depfile{ifil});
        
        xg=s.parameters(1).parameter.x;
        xg=xg(1,:);
        yg=s.parameters(1).parameter.y;
        yg=yg(:,1);
        zg=s.parameters(1).parameter.val;

% figure(789)
% clf
% pcolor(xg,yg,zg);shading flat;axis equal;caxis([-20 20]);colorbar
% 
% 
% hold on
% plot(xc,yc)
        
        % Interpolate depth data to grid
        zinterp=interp2(xg,yg,zg,xc,yc);
        
        zc(isnan(zc))=zinterp(isnan(zc));
        
    end
else
    
    s=load(depfile);
    
    xg=s.parameters(1).parameter.x;
    xg=xg(1,:);
    yg=s.parameters(1).parameter.y;
    yg=yg(:,1);
    zg=s.parameters(1).parameter.val;
    
    % Interpolate depth data to grid
    zc=interp2(xg,yg,zg,xc,yc);
    
end


% % Compute shore normal coordinates for 
% 
% phinor=phinor*pi/180;
% xon=20000;
% xoff=400000;
% x1a=x1-xon*cos(phinor);
% y1a=y1-xon*sin(phinor);
% x1b=x1+xoff*cos(phinor);
% y1b=y1+xoff*sin(phinor);
% len=xon+xoff;
% np=round(len/100);
% dx=(x1b-x1a)/np;
% dy=(y1b-y1a)/np;
% 
% 
% for ii=1:length(x1)
% %     if ii==2
% %         shite=1
% %     end
%     xx=x1a(ii):dx(ii):x1b(ii);
%     yy=y1a(ii):dy(ii):y1b(ii);
% %    xx=fliplr(xx);
% %    yy=fliplr(yy);
% 
%     % Convert points along shore normals to lat-lon 
%     [xx0,yy0]=convertCoordinates(xx,yy,'persistent','CS1.name',cs2.name,'CS1.type',cs2.type,'CS2.name',cs1.name,'CS2.type',cs1.type);
%     zz=interp2(xg,yg,zg,xx0,yy0);
% %     ifirst=find(zz<-2,1,'first');
% %     xx=xx(ifirst:end);
% %     yy=yy(ifirst:end);
% %     zz=zz(ifirst:end);
% % %     ilast=find(zz>0,1,'first');
% % %     if isempty(ilast)
% %         ilast=length(zz);
% % %     end
% %     xx=xx(1:ilast-1);
% %     yy=yy(1:ilast-1);
% %     zz=zz(1:ilast-1);
%     xx=fliplr(xx);
%     yy=fliplr(yy);
%     zz=fliplr(zz);
%     ilast=find(zz>=-2,1,'first')-1;
%     xx=xx(1:ilast);
%     yy=yy(1:ilast);
%     zz=zz(1:ilast);
%     
%     xx=pathdistance(xx,yy);
%     i100=find(zz<-100,1,'last');
%     if isempty(i100)
%         i100=1;
%     end
%     shelfwidth(ii)=xx(end)-xx(i100);
%     iid(ii)=compute_iid(xx,zz,-100);
%     
% end
