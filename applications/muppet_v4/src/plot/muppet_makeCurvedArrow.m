function [xp,yp]=muppet_makeCurvedArrow(xs,ys,varargin)

if length(xs)<2
    xp=xs;
    yp=ys;
    return
end

arthck=2;
hdthck=4;
hdlength=8;
nrhead=1;
% iexport=0;

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'headwidth'}
                hdthck=varargin{ii+1};
            case{'arrowwidth'}
                arthck=varargin{ii+1};
            case{'headlength'}
                hdlength=varargin{ii+1};
            case{'nrarrowheads'}
                nrhead=varargin{ii+1};
%             case{'cm2pix'}
%                 cm2pix=varargin{ii+1};
        end
    end
end

% Determine scale of figure
xl=get(gca,'xlim');
papersize=get(gcf,'PaperSize');
figpos=get(gcf,'Position');
cm2pix=getappdata(gcf,'cm2pix');
if isempty(cm2pix)
    cm2pix=figpos(3)/papersize(1);
end
axpos=get(gca,'position')/cm2pix;
scl=(xl(2)-xl(1))/(0.01*axpos(3));
arthck=0.001*arthck*scl;
hdthck=0.001*hdthck*scl;
hdlength=0.001*hdlength*scl;

[xs,ys]=spline2d(xs',ys');

relwdt=1;

ip=0;

nt=length(xs);

pd=pathdistance(xs,ys);
pd=pd(end:-1:1);
nhead=length(pd(pd<hdlength));
nhead=max(nhead,2);
nhead=min(nhead,nt-1);

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
        % Compute points at arth%k*ds at either side
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
