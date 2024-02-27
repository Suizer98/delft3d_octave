function [xp,yp]=MakeCurvedArrow(xs,ys,arthck,hdthck,arlength,nrhead);
%MakeCurvedArrow turn particle track into plottable nice arrow polygon
%
%  [xp,yp]=MakeCurvedArrow(xs,ys,arthck,hdthck,arlength,nrhead);
%
% Example: 
%   t = 0:10
%   x = cos(2*pi*t/40)
%   y = sin(2*pi*t/40)
%   close;
%   [xp,yp]=MakeCurvedArrow(x ,y ,.05   ,.1    ,.2     ,1     );plot(xp,yp,'.-','DisplayName','particle arrow');
%   hold on;
%   plot(x,y,'r.-','DisplayName','particle track')
%   legend show
%
%See also: mxcurvec


relwdt=1;

ip=0;

nt=length(xs);

pd=pathdistance(xs,ys);
pd=pd(end:-1:1);
nhead=length(pd(pd<arlength));
nhead=max(nhead,2);

if nrhead==1
    
    % single arrow

    for ii=1:nt-nhead
        %
        % Next two points along track
        %
        xx1=xs(ii);
        yy1=ys(ii);
        xx2=xs(ii+1);
        yy2=ys(ii+1);
        dx=xx2-xx1;
        dy=yy2-yy1;
        ang=atan2(dy,dx);
        %
        % Compute points at arthck*ds at either side
        %
        xar(2*ii-1) = xx1+sin(ang)*arthck*relwdt;
        yar(2*ii-1) = yy1-cos(ang)*arthck*relwdt;
        xar(2*ii)   = xx1-sin(ang)*arthck*relwdt;
        yar(2*ii)   = yy1+cos(ang)*arthck*relwdt;
    end
    ii=nt-nhead+1;
    %
    %        points of arrow head
    %
    xar(2*ii-1) = xx1+sin(ang)*hdthck*relwdt;
    yar(2*ii-1) = yy1-cos(ang)*hdthck*relwdt;
    xar(2*ii)   = xx1-sin(ang)*hdthck*relwdt;
    yar(2*ii)   = yy1+cos(ang)*hdthck*relwdt;
    ii=ii+1;
    %
    %        Point of arrow
    %
    xar(2*ii-1) = xs(nt);
    yar(2*ii-1) = ys(nt);
    %
    %        Now fill xp:yp
    %
    narpt=ii;
    %
    %        Right-hand side
    %
    for ii=1:narpt
        ip=ip+1;
        xp(ip)=xar(2*ii-1);
        yp(ip)=yar(2*ii-1);
    end
    %
    %        Left-hand side
    %
    for ii=narpt-1:-1:1
        ip=ip+1;
        xp(ip)=xar(2*ii);
        yp(ip)=yar(2*ii);
    end
    %
    %        lose polygon and add novalue-point
    %
    ip=ip+1;
    xp(ip)=xar(1);
    yp(ip)=yar(1);

else
    
    % double arrow
    
    % First point of arrow
    %
    xar(1) = xs(1);
    yar(1) = ys(1);
    xar(2) = xs(1);
    yar(2) = ys(1);
    %
    % points of arrow head
    %
    xx1=xs(1);
    yy1=ys(1);
    xx2=xs(nhead+1);
    yy2=ys(nhead+1);
    dx=xx2-xx1;
    dy=yy2-yy1;
    ang=atan2(dy,dx);
    %
    xar(3)   = xx2+sin(ang)*hdthck*relwdt;
    yar(3)   = yy2-cos(ang)*hdthck*relwdt;
    xar(4)   = xx2-sin(ang)*hdthck*relwdt;
    yar(4)   = yy2+cos(ang)*hdthck*relwdt;
    %
    kk=2;
    for ii=nhead+1:nt-nhead
        kk=kk+1;
        %
        % Next two points along tra%k
        %
        xx1=xs(ii);
        yy1=ys(ii);
        xx2=xs(ii+1);
        yy2=ys(ii+1);
        dx=xx2-xx1;
        dy=yy2-yy1;
        ang=atan2(dy,dx);
        %
        % Compute points at arth%k*ds at either side
        %
        xar(2*kk-1) = xx1+sin(ang)*arthck*relwdt;
        yar(2*kk-1) = yy1-cos(ang)*arthck*relwdt;
        xar(2*kk)   = xx1-sin(ang)*arthck*relwdt;
        yar(2*kk)   = yy1+cos(ang)*arthck*relwdt;
    end
    ii=nt-nhead+1;
    %
    %        points of arrow head
    %
    xx1=xs(nt-nhead);
    yy1=ys(nt-nhead);
    xx2=xs(nt);
    yy2=ys(nt);
    dx=xx2-xx1;
    dy=yy2-yy1;
    ang=atan2(dy,dx);
    kk=kk+1;
    %
    xar(2*kk-1) = xx1+sin(ang)*hdthck*relwdt;
    yar(2*kk-1) = yy1-cos(ang)*hdthck*relwdt;
    xar(2*kk)   = xx1-sin(ang)*hdthck*relwdt;
    yar(2*kk)   = yy1+cos(ang)*hdthck*relwdt;
    %
    %        Point of arrow
    %
    kk=kk+1;
    xar(2*kk-1) = xs(nt);
    yar(2*kk-1) = ys(nt);
    xar(2*kk) = xs(nt);
    yar(2*kk) = ys(nt);
    %
    %        Now fill xp:yp
    %
    narpt=kk;
    %
    %        Right-hand side
    %
    ip=0;
    for ii=1:narpt
        ip=ip+1;
        xp(ip)=xar(2*ii-1);
        yp(ip)=yar(2*ii-1);
    end
    %
    %        Left-hand side
    %
    for ii=narpt:-1:1
        ip=ip+1;
        xp(ip)=xar(2*ii);
        yp(ip)=yar(2*ii);
    end
    
end
