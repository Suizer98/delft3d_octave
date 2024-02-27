function [x,y,ll]=gridsnapper(xg,yg,xp,yp,dx,x0,y0,rot,kcs)
ll=[];
np=length(xp);
dy=dx;
nmax=size(xg,1);
mmax=size(xg,2);

kcg=zeros(size(xg));
for ii=1:size(xg,1)-1
    for jj=1:size(xg,2)-1
        if kcs(ii)>0
            kcg(ii,jj)=1;
            kcg(ii+1,jj)=1;
            kcg(ii,jj+1)=1;
            kcg(ii+1,jj+1)=1;
        end
    end
end


% dx=[];

% if ~isempty(varargin)
%     dx=varargin{1};
% end

% if isempty(dx)
%     [dmin,dmax]=findMinMaxGridSize(xg,yg);
%     dx=dmin/4;
% end

cosrot=cos(-rot*pi/180);
sinrot=sin(-rot*pi/180);

% Rotate everything to new local system
xg=xg-x0;
yg=yg-y0;
xg1 = xg*cosrot - yg*sinrot;
yg1 = xg*sinrot + yg*cosrot;
xp=xp-x0;
yp=yp-y0;
xp1=xp*cosrot - yp*sinrot;
yp1=xp*sinrot + yp*cosrot;
xg=xg1;
yg=yg1;
xp=xp1;
yp=yp1;

xga=xg(kcg>0);
yga=yg(kcg>0);

figure(123);
plot(xg,yg,'k');hold on
plot(xg',yg','k');hold on
axis equal;
plot(xp,yp,'ro-');
plot(xga,yga,'b.');

% % First find indices of nearest grid point at start of poyline
% dst=sqrt((xg-xp(1)).^2 + (yg-yp(1)).^2);
% [imin,jmin]=find(dst==min(min(dst)));
% imin=imin(1);
% jmin=jmin(1);
% 
% ncor(1)=imin;
% mcor(1)=jmin;
% nlast=ncor(1);
% mlast=mcor(1);

nlast=0;
mlast=0;
% hsum=zp(1);
nuv=0;
% x=xg(ncor(ilast),mcor(ilast));
% y=yg(ncor(ilast),mcor(ilast));
x=[];
y=[];

for ix=1:mmax-1
    for iy=1:nmax-1
        % U point
        if kcg(iy,ix)>0 && kcg(iy+1,ix)>0
            for ip=1:np-1
                
                
                x1=xp(ip);
                y1=yp(ip);
                x2=xp(ip+1);
                y2=yp(ip+1);
                x0a=xg(iy,ix);
                y0a=yg(iy,ix);
                x0b=xg(iy+1,ix);
                y0b=yg(iy+1,ix);
                d=prj(x0a,y0a,x0b,y0b,x1,y1,x2,y2,0.5*sqrt(2)*dx);
                if ~isnan(d)
                    okay=1;
                    x=[x xg(iy,ix) xg(iy+1,ix) NaN];
                    y=[y yg(iy,ix) yg(iy+1,ix) NaN];
                else
                    okay=0;
                end
                %                ll(iuv)=ll(iuv)+d;
                
                
            end
        end
    end
end
%
%             
% % Loop through polylines
% for ip=1:np-1
%     
%     
%     dst=sqrt((xp(ip+1)-xp(ip))^2 + (yp(ip+1)-yp(ip))^2);
%     n=ceil(dst/(0.25*dx));
%     dstx=(xp(ip+1)-xp(ip))/n;
%     dsty=(yp(ip+1)-yp(ip))/n;
%     
%     for ii=1:n+1
%         
%         xxx=xp(ip)+(ii-1)*dstx;
%         yyy=yp(ip)+(ii-1)*dsty;
%         
%         % Compute indices of nearest grid corner
%         ix = round(xxx/dx) + 1;
%         iy = round(yyy/dy) + 1;
%         
%         if ix<1 || iy<1 || ix>mmax || iy>nmax
%             % Point outside grid
%             mlast=0;
%             nlast=0;
%             continue
%         end
%         
%         % Check if this is an active grid point
%         if kcg(iy,ix)<1
%             mlast=0;
%             nlast=0;
%             continue
%         end
%         
%         % Active corner point found
%         if mlast==0 && nlast==0
%             % Completely new point found
%             mlast = ix;
%             nlast = iy;
%         else
%             if ix~=mlast || iy~=nlast
%                 if ix~=mlast && iy~=nlast
%                     % Oops, we went diagonally
%                     if ix>mlast && iy>nlast
%                         % right-up
%                         iy1=1;
%                         ix1=0;
%                         iy2=0;
%                         ix2=1;
%                     elseif ix<mlast && iy<nlast
%                         % left-up
%                         iy1=0;
%                         ix1=-1;
%                         iy2=1;
%                         ix2=0;
%                     elseif ix<mlast && iy<nlast
%                         % left-down
%                         iy1=0;
%                         ix1=-1;
%                         iy2=-1;
%                         ix2=0;
%                     elseif ix>mlast && iy<nlast
%                         % right down
%                         iy1=-1;
%                         ix1=0;
%                         iy2=0;
%                         ix2=1;
%                     else
%                         disp('this is not possible');
%                     end
%                     x0=xg(nlast,mlast);
%                     y0=yg(nlast,mlast);
%                     x1=xg(nlast+iy1,mlast+ix1);
%                     y1=yg(nlast+iy1,mlast+ix1);
%                     x2=xg(nlast+iy2,mlast+ix2);
%                     y2=yg(nlast+iy2,mlast+ix2);
%                     dst1=sqrt((x1-x0)^2+(y1-y0)^2);
%                     dst2=sqrt((x2-x0)^2+(y2-y0)^2);
%                     if dst1<dst2
%                         if kcg(nlast+iy1,mlast+ix1)>0
%                             nuv=nuv+1;
%                             mm(nuv,1)=mlast;
%                             nn(nuv,1)=nlast;
%                             mm(nuv,2)=mlast+ix1;
%                             nn(nuv,2)=nlast+iy1;
%                             nuv=nuv+1;
%                             mm(nuv,1)=mlast+ix1;
%                             nn(nuv,1)=nlast+iy1;
%                             mm(nuv,2)=ix;
%                             nn(nuv,2)=iy;
%                             mlast=ix;
%                             nlast=iy;
%                         else
%                             mlast=0;
%                             nlast=0;
%                         end
%                     else
%                         if kcg(nlast+iy2,mlast+ix2)>0
%                             nuv=nuv+1;
%                             mm(nuv,1)=mlast;
%                             nn(nuv,1)=nlast;
%                             mm(nuv,2)=mlast+ix2;
%                             nn(nuv,2)=nlast+iy2;
%                             nuv=nuv+1;
%                             mm(nuv,1)=mlast+ix2;
%                             nn(nuv,1)=nlast+iy2;
%                             mm(nuv,2)=ix;
%                             nn(nuv,2)=iy;
%                             mlast=ix;
%                             nlast=iy;
%                         else
%                             mlast=0;
%                             nlast=0;
%                         end
%                     end
%                 else
%                     nuv=nuv+1;
%                     mm(nuv,1)=mlast;
%                     nn(nuv,1)=nlast;
%                     mm(nuv,2)=ix;
%                     nn(nuv,2)=iy;
%                     mlast=ix;
%                     nlast=iy;
%                 end
%             else
%                 % Same coordinates as previous point
%             end
%         end
%     end
% end
% 
% disp(nuv);
% x=[];
% y=[];
% for iuv=1:nuv
%     x=[x xg(nn(iuv,1),mm(iuv,1)) xg(nn(iuv,2),mm(iuv,2)) NaN];
%     y=[y yg(nn(iuv,1),mm(iuv,1)) yg(nn(iuv,2),mm(iuv,2)) NaN];
% end
% 
% % plot(x,y,'g')
% % 
% % x0=9;
% % y0=2;
% % 
% % x1=0;
% % y1=0;
% % 
% % x2=10;
% % y2=0;
% 
% ll=zeros(1,nuv);
% 
% for iuv=1:nuv
%     for ip=1:np-1
%         x1=xp(ip);
%         y1=yp(ip);
%         x2=xp(ip+1);
%         y2=yp(ip+1);
%         x0a=xg(nn(iuv,1),mm(iuv,1));
%         y0a=yg(nn(iuv,1),mm(iuv,1));
%         x0b=xg(nn(iuv,2),mm(iuv,2));
%         y0b=yg(nn(iuv,2),mm(iuv,2));
%         d=prj(x0a,y0a,x0b,y0b,x1,y1,x2,y2);
%         ll(iuv)=ll(iuv)+d;
%     end
% end
% 

% %distance between p1 and p2
% % l2 is length polyline segment
% 
% l2 = np.sum((p1-p2)**2)
% 
% %The line extending the segment is parameterized as p1 + t (p2 - p1).
% %The projection falls where t = [(p3-p1) . (p2-p1)] / |p2-p1|^2
% 
% #if you need the point to project on line extention connecting p1 and p2
% t = np.sum((p3 - p1) * (p2 - p1)) / l2
% 
% #if you need to ignore if p3 does not project onto line segment
% if t > 1 or t < 0:
%   print('p3 does not project onto p1-p2 line segment')
% 
% #if you need the point to project on line segment between p1 and p2 or closest point of the line segment
% t = max(0, min(1, np.sum((p3 - p1) * (p2 - p1)) / l2))
% 
% projection = p1 + t * (p2 - p1)
