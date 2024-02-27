function [x,y]=gridsnapper(xg,yg,xp,yp,varargin)

np=length(xp);

nmax=size(xg,1);
mmax=size(xg,2);

dx=[];

if ~isempty(varargin)
    dx=varargin{1};
end

if isempty(dx)
    [dmin,dmax]=findMinMaxGridSize(xg,yg);
    dx=dmin/10;
end

% First find indices of nearest grid point at start of poyline
dst=sqrt((xg-xp(1)).^2 + (yg-yp(1)).^2);
[imin,jmin]=find(dst==min(min(dst)));
imin=imin(1);
jmin=jmin(1);

ncor(1)=imin;
mcor(1)=jmin;
nlast=ncor(1);
mlast=mcor(1);
% hsum=zp(1);
ilast=1;

x=xg(ncor(ilast),mcor(ilast));
y=yg(ncor(ilast),mcor(ilast));
            
for ip=1:np-1
    
    dst=sqrt((xp(ip+1)-xp(ip))^2 + (yp(ip+1)-yp(ip))^2);
    n=ceil(dst/(0.25*dx));
    dstx=(xp(ip+1)-xp(ip))/n;
    dsty=(yp(ip+1)-yp(ip))/n;
    
    for ii=1:n+1
        
        xxx=xp(ip)+(ii-1)*dstx;
        yyy=yp(ip)+(ii-1)*dsty;   
        
        % Four surrounding points
        j=0;
        mnew=[];
        nnew=[];
        xs=[];
        ys=[];

        j=j+1;
        mnew(j)=mlast;
        nnew(j)=nlast;
        xs(j)=xg(nnew(j),mnew(j));
        ys(j)=yg(nnew(j),mnew(j));
        
        if mlast<mmax
            j=j+1;
            mnew(j)=mlast+1;
            nnew(j)=nlast;
            xs(j)=xg(nnew(j),mnew(j));
            ys(j)=yg(nnew(j),mnew(j));
        end

        if nlast<nmax
            j=j+1;
            mnew(j)=mlast;
            nnew(j)=nlast+1;
            xs(j)=xg(nnew(j),mnew(j));
            ys(j)=yg(nnew(j),mnew(j));
        end
        
        if mlast>1
            j=j+1;
            mnew(j)=mlast-1;
            nnew(j)=nlast;
            xs(j)=xg(nnew(j),mnew(j));
            ys(j)=yg(nnew(j),mnew(j));
        end

        if nlast>1
            j=j+1;
            mnew(j)=mlast;
            nnew(j)=nlast-1;
            xs(j)=xg(nnew(j),mnew(j));
            ys(j)=yg(nnew(j),mnew(j));
        end
        
        dst=sqrt((xs-xxx).^2 + (ys-yyy).^2);
        inear=find(dst==min(dst));
        
        if isempty(inear)
            disp('warning')
        else
        inear=inear(1);
            
        end
        
        if nnew(inear)~=nlast | mnew(inear)~=mlast
            
            % New point found !!!
            
%             xpl=[xg(ncor(ilast),mcor(ilast)) xg(nnew(inear),mnew(inear))];
%             ypl=[yg(ncor(ilast),mcor(ilast)) yg(nnew(inear),mnew(inear))];
            
            x=[x xg(nnew(inear),mnew(inear))];
            y=[y yg(nnew(inear),mnew(inear))];
%             p=plot(xpl,ypl,'b');
%             set(p,'linewidth',2);
            
%             hsum=0;

            ilast=ilast+1;
            ncor(ilast)=nnew(inear);
            mcor(ilast)=mnew(inear);

            nlast=ncor(ilast);
            mlast=mcor(ilast);
        end
    end
end

