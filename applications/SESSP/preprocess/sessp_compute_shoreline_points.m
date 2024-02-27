function [xl,yl,xx,phic1,w2,a2,iid2]=sessp_compute_shoreline_points(plifile,depthfile,outputfile,varargin)

xon=1000;
xon=0;
xoff=300000;
nsmooth1=3;
nsmooth2=100;
nsmooth3=5;
adepth=10;
max_iid=30000;
min_a=0.01;
max_a=0.30;
shelffile=[];

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'xon'}
                xon=varargin{ii+1};
            case{'xoff'}
                xoff=varargin{ii+1};
            case{'max_iid'}
                max_iid=varargin{ii+1};
            case{'min_a'}
                min_a=varargin{ii+1};
            case{'max_a'}
                max_a=varargin{ii+1};
            case{'adepth'}
                adepth=varargin{ii+1}; % depth to determine Dean slope a
            case{'nsmooth1'}
                nsmooth1=varargin{ii+1};
            case{'nsmooth2'}
                nsmooth2=varargin{ii+1};
            case{'nsmooth3'}
                nsmooth3=varargin{ii+1};
            case{'shelffile'}
                shelffile=varargin{ii+1};
        end
    end
end

[xl,yl]=landboundary('read',plifile);
np=length(xl);

if ~isempty(shelffile)
    [xshelf,yshelf]=landboundary('read',shelffile);
else
    xshelf=[];
    yshelf=[];
end

% xlc=xl;
% ylc=yl;
%[xlc,ylc]=landboundary('read','gulf_wgs84_200km_5km.pli');

% xl=xl(50:200);
% yl=yl(50:200);
% % xlc=xlc(50:200);
% % ylc=ylc(50:200);

[phic1,phic2,xland,yland,xsea,ysea]=sessp_compute_shore_normals(xl,yl,xon,xoff,nsmooth1,nsmooth2,xshelf,yshelf);

figure(100)
clf
plot(xl,yl);axis equal
hold on
plot(xland,yland,'k--');axis equal
plot(xsea,ysea,'k--');axis equal
crsx=[xland;xsea];
crsy=[yland;ysea];
plot(crsx,crsy,'k');axis equal
plot(xshelf,yshelf,'b');
xs=[xland;xsea];
ys=[yland;ysea];

% cs1.name='WGS 84';
% cs1.type='geographic';
% 
% % Determine UTM zone
% utmz = fix( ( mean(xl) / 6 ) + 31);
% utmz = mod(utmz,60);
% if mean(yl)>0
%     cs2.name=['WGS 84 / UTM zone ' num2str(utmz) 'N'];
% else
%     cs2.name=['WGS 84 / UTM zone ' num2str(utmz) 'S'];
% end
% cs2.type='projected';
% 
% % Convert ldb file to local projected coordinate system
% [xlu,ylu]=convertCoordinates(xl,yl,'persistent','CS1.name',cs1.name,'CS1.type',cs1.type,'CS2.name',cs2.name,'CS2.type',cs2.type);
% % [xlcu,ylcu]=convertCoordinates(xlc,ylc,'persistent','CS1.name',cs1.name,'CS1.type',cs1.type,'CS2.name',cs2.name,'CS2.type',cs2.type);
% 
% figure(100)
% 
% plot(xland,yland);hold on;
% plot(xsea,ysea,'r');hold on;
% 
% pd=pathdistance(xlu,ylu);
% 
% figure(1)
% 
% plot(xl,yl);hold on;
% plot(xs,ys);hold on;

% Interpolate values in depth file to profiles
[xx,zc]=sessp_compute_profile_depths(xs,ys,200,depthfile);

iid=zeros(1,np);
w=zeros(1,np);
a=zeros(1,np);

% Determine iid, a and shelf width
for ip=1:length(xl)

    zz=zc(:,ip)';

    iid(ip)=compute_iid(xx,zz,-200,0);
    
    iid(ip)=min(iid(ip),max_iid);
    
    iw=find(zz<-100,1,'first');
    if isempty(iw)
        iw=length(xx);
    end
    
    w(ip)=xx(iw);
    
    aval=adepth;
    ia=find(zz<-aval,1,'first');
    if isempty(ia)
        ia=find(zz==min(zz),1,'first');
        aval=-zz(ia);
    end
    a(ip)=aval/(xx(ia).^.667);

    a(ip)=min(a(ip),max_a);
    a(ip)=max(a(ip),min_a);

end

xx=pathdistance(xl,yl,'geographic')/1000;


% Now smooth a, w and iid
a2=a;
w2=w;
iid2=iid;
for it=1:nsmooth3
    aa=0.25*a2(1:end-2)+0.50*a2(2:end-1)+0.25*a2(3:end);
    a2(2:end-1)=aa;
    ww=0.25*w2(1:end-2)+0.50*w2(2:end-1)+0.25*w2(3:end);
    w2(2:end-1)=ww;
    iii=0.25*iid2(1:end-2)+0.50*iid2(2:end-1)+0.25*iid2(3:end);
    iid2(2:end-1)=iii;
end
if nsmooth3>0
    a2(1)=a2(2);
    a2(end)=a2(end-1);
    w2(1)=w2(2);
    w2(end)=w2(end-1);
    iid2(1)=iid2(2);
    iid2(end)=iid2(end-1);
end

figure(111)
plot(xx,iid,'k--');title('iid');
hold on
plot(xx,iid2,'r');title('iid');
set(gca,'xlim',[1000 1700]);

figure(112)
plot(xx,w,'k--');title('w');
hold on
plot(xx,w2,'r');title('w');
set(gca,'xlim',[1000 1700]);

figure(113)
plot(xx,a,'k--');title('a');
hold on
plot(xx,a2,'r');title('a');
set(gca,'xlim',[1000 1700]);
set(gca,'xlim',[1000 1700]);

figure(115)
plot(xx,phic1*180/pi,'k--');title('phi');
hold on
plot(xx,phic2*180/pi,'r');title('phi');
set(gca,'xlim',[1000 1700]);

fid=fopen(outputfile,'wt');
for ip=1:length(xl)
    fprintf(fid,'%12.7f %12.7f %14.7e %14.7e %14.7e %14.7e\n',xl(ip),yl(ip),phic1(ip)+0.5*pi,w2(ip),a2(ip),iid2(ip));
end
fclose(fid);
