function [xx,yy,zz]=sfincs_get_obstacle_height(xp,yp,dx,w,cs,bathysets)

pd=pathdistance(xp,yp);
np=ceil(pd(end)/dx);
pp=0:pd(end)/(np-1):pd(end);
xx=interp1(pd,xp,pp);
yy=interp1(pd,yp,pp);

ncrs=round(w);

crsx=zeros(length(xx),ncrs);
crsy=zeros(length(xx),ncrs);

for ip=1:length(xx)
    if ip==1
        phi=atan2(yy(ip+1)-yy(ip),xx(ip+1)-xx(ip));
    elseif ip==length(xx)
        phi=atan2(yy(ip)-yy(ip-1),xx(ip)-xx(ip-1));
    else
        phi=atan2(yy(ip+1)-yy(ip-1),xx(ip+1)-xx(ip-1));
    end
    px1=xx(ip)+0.5*w*cos(phi+pi/2);
    py1=yy(ip)+0.5*w*sin(phi+pi/2);
    px2=xx(ip)+0.5*w*cos(phi-pi/2);
    py2=yy(ip)+0.5*w*sin(phi-pi/2);
    dpx=(px2-px1)/(ncrs-1);
    dpy=(py2-py1)/(ncrs-1);
    if dpx==0
        crsx(ip,:)=zeros(1,ncrs)+px1;
    else
        crsx(ip,:)=px1:dpx:px2;
    end
    if dpy==0
        crsy(ip,:)=zeros(1,ncrs)+py1;
    else
        crsy(ip,:)=py1:dpy:py2;
    end
end

crsz=zeros(size(crsx));
crsz=interpolate_bathymetry_to_grid(crsx,crsy,crsz,bathysets,cs,'quiet');

zz=max(crsz,[],2);
