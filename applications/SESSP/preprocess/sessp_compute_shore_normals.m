function [phic1,phic2,xland,yland,xsea,ysea]=sessp_compute_shore_normals(xl,yl,xon,xoff,nsmooth1,nsmooth2,xshelf,yshelf)

% xl and yl are all the points along coast
% xlc and ylc are all the points along coast

% xl and yl must be in geographic coordinates !!!
% Outputs are also in geographic coordinates !!!


cs1.name='WGS 84';
cs1.type='geographic';

% Determine UTM zone
utmz = fix( ( mean(xl) / 6 ) + 31);
utmz = mod(utmz,60);
if mean(yl)>0
    cs2.name=['WGS 84 / UTM zone ' num2str(utmz) 'N'];
else
    cs2.name=['WGS 84 / UTM zone ' num2str(utmz) 'S'];
end
cs2.type='projected';


% cs1.name='WGS 84 / UTM zone 11N';
% cs1.type='projected';
% 
% cs2.name='WGS 84 / UTM zone 11N';
% cs2.type='projected';

% Convert ldb file to local projected coordinate system
[xlu,ylu]=convertCoordinates(xl,yl,'persistent','CS1.name',cs1.name,'CS1.type',cs1.type,'CS2.name',cs2.name,'CS2.type',cs2.type);
pd=pathdistance(xlu);

if ~isempty(xshelf)
[xshelf,yshelf]=convertCoordinates(xshelf,yshelf,'persistent','CS1.name',cs1.name,'CS1.type',cs1.type,'CS2.name',cs2.name,'CS2.type',cs2.type);
end



np=length(xlu);

% Determine angle of coast line (along coast)
phic0=zeros(1,np);
phic00=atan2(ylu(2:end-1)-ylu(1:end-2),xlu(2:end-1)-xlu(1:end-2));
phic0(2:end-1)=phic00;
phic0(1)=phic0(2);
phic0(end)=phic0(end-1);

% Now apply a bit of smoothing to phic0 to get phic1
% Phic1 will be used in SESSP as the coast angle
phix=cos(phic0);
phiy=sin(phic0);
for it=1:nsmooth1
    phix1=0.25*phix(1:end-2)+0.50*phix(2:end-1)+0.25*phix(3:end);
    phix(2:end-1)=phix1;
    phiy1=0.25*phiy(1:end-2)+0.50*phiy(2:end-1)+0.25*phiy(3:end);
    phiy(2:end-1)=phiy1;
end
if nsmooth1>0
    phix(1)=phix(2);
    phiy(1)=phiy(2);
    phix(end)=phix(end-1);
    phiy(end)=phiy(end-1);
end
phic1=atan2(phiy,phix);

% Phic2 will be used here to compute slope, iid etc.

if ~isempty(xshelf)
    
    % phic2 determined based on user defined shore normals
    
    for ii=1:length(xshelf)/3
        i1=(ii*3-2);
        i2=(ii*3-1);
        % find nearest shoreline point
        dst=sqrt((xlu-xshelf(i1)).^2+(ylu-yshelf(i1)).^2);
        imin=find(dst==min(dst),1,'first');
        pdx(ii)=pd(imin);
        phitan(ii)=atan2(yshelf(i2)-yshelf(i1),xshelf(i2)-xshelf(i1))+0.5*pi;
    end
    
    phix=cos(phitan);
    phiy=sin(phitan);
    
    phix0=spline(pdx,phix,pd);
    phiy0=spline(pdx,phiy,pd);
    phic2=atan2(phiy0,phix0);
    
    
    
    
    %     for ii=1:length(xlu)
    %         dst=sqrt((xshelf-xlu(ii)).^2+(yshelf-ylu(ii)).^2);
    %         imin=find(dst==min(dst),1,'first');
    %         xs=xshelf(imin);
    %         ys=yshelf(imin);
    %         phic0(ii)=atan2(ys-ylu(ii),xs-xlu(ii))+0.5*pi;
    %     end
else

% Now apply a LOT of smoothing to phic0 to get phic2
    
    phix=cos(phic0);
    phiy=sin(phic0);
    for it=1:nsmooth2
        phix1=0.25*phix(1:end-2)+0.50*phix(2:end-1)+0.25*phix(3:end);
        phix(2:end-1)=phix1;
        phiy1=0.25*phiy(1:end-2)+0.50*phiy(2:end-1)+0.25*phiy(3:end);
        phiy(2:end-1)=phiy1;
    end
    if nsmooth2>0
        phix(1)=phix(2);
        phiy(1)=phiy(2);
        phix(end)=phix(end-1);
        phiy(end)=phiy(end-1);
    end
    phic2=atan2(phiy,phix);
    
end

% phic1=phic2;

% [xlcu,ylcu]=convertCoordinates(xlc,ylc,'persistent','CS1.name',cs1.name,'CS1.type',cs1.type,'CS2.name',cs2.name,'CS2.type',cs2.type);



% % Compute path distance along coast line
% pd=pathdistance(xl1,yl1);
% 
% % Create spline along coast
% xspl=0:dx:pd(end);
% yspl=0:dx:pd(end);
% xspl=spline(pd,xl1,xspl);
% yspl=spline(pd,yl1,yspl);
% 
% xspl=xl1;
% yspl=yl1;

% Determine coastline orientation and shore normal
% phicst=atan2(ylcu(2:end)-ylcu(1:end-1),xlcu(2:end)-xlcu(1:end-1));
% phicst(end+1)=phicst(end);


% phinor=phi-pi/2;
%phi=phi*180/pi;

% % Compute path distance along coast line
% pdd=pathdistance(xld1,yld1);
% 
% % Create spline along coast
% xspld=0:dx:pdd(end);
% yspld=0:dx:pdd(end);
% xspld=spline(pdd,xld1,xspld);
% yspld=spline(pdd,yld1,yspld);


% vv=-xon:100:xoff;

for ii=1:np
%     xx=xspl(ii)+cos(phinor(ii))*vv;
%     yy=yspl(ii)+sin(phinor(ii))*vv;
%     xx=fliplr(xx);
%     yy=fliplr(yy);
%     xland(ii)=xx(1);
%     yland(ii)=yy(1);
%     xsea(ii)=xx(end);
%     ysea(ii)=yy(end);
%     x0(ii)=xlu(ii);
%     y0(ii)=ylu(ii);
    
    % Find nearest point along depth contour (is this really the best method?)
%     dstx=xlcu-x0(ii);
%     dsty=ylcu-y0(ii);
%     dst=sqrt(dstx.^2+dsty.^2);
%     idst=find(dst==min(dst));
%     phi(ii)=phicst(idst);
    
    
    xland(ii)=xlu(ii)+ xon*cos(phic2(ii)+0.5*pi);
    yland(ii)=ylu(ii)+ xon*sin(phic2(ii)+0.5*pi);
    xsea(ii) =xlu(ii)+xoff*cos(phic2(ii)-0.5*pi);
    ysea(ii) =ylu(ii)+xoff*sin(phic2(ii)-0.5*pi);
    
%     phinor(ii)=180*atan2(ysea(ii)-yland(ii),xsea(ii)-xland(ii))/pi;

end

% % apply a bit of smoothing to phi
% phix=cos(phi);
% phiy=sin(phi);
% for it=1:3
%     phix1=0.25*phix(1:end-2)+0.50*phix(2:end-1)+0.25*phix(3:end);
%     phix(2:end-1)=phix1;
%     phiy1=0.25*phiy(1:end-2)+0.50*phiy(2:end-1)+0.25*phiy(3:end);
%     phiy(2:end-1)=phiy1;
% end
% phi=atan2(phiy,phix);

% [x0,y0]=convertCoordinates(x0,y0,'persistent','CS1.name',cs2.name,'CS1.type',cs2.type,'CS2.name',cs1.name,'CS2.type',cs1.type);
[xland,yland]=convertCoordinates(xland,yland,'persistent','CS1.name',cs2.name,'CS1.type',cs2.type,'CS2.name',cs1.name,'CS2.type',cs1.type);
[xsea,ysea]=convertCoordinates(xsea,ysea,'persistent','CS1.name',cs2.name,'CS1.type',cs2.type,'CS2.name',cs1.name,'CS2.type',cs1.type);
