function [xacc,tacc,phi_rel,r]=compute_virtual_landfall_coordinates(t,trackt,coast)

% Virtual track

x0=trackt.x;
y0=trackt.y;

for ip=1:length(coast.x)

    phin=coast.phi(ip); % direction of shore normal
    phic=coast.phi(ip)+90; % direction of shoreline
    phic=mod(phic,360);
    phit=trackt.heading;
    
    % Compute virtual landfall point 
    ac=tan(phic*pi/180);
    cc=coast.y(ip)-ac*coast.x(ip);
    bt=tan(phit*pi/180);
    dt=y0-bt*x0;
    xlf=(dt-cc)/(ac-bt);
    ylf=ac*xlf+cc;

    phi=phit-phin;
    if phi<-180
        phi=phi+360;
    end
    
    if phi>=90 || phi<=-90
        % oh no, track and coast cross at wrong point !!!
        if phi>=90
            phit=phin+60;
        else
            phit=phin-60;
        end
        % Try it again
        bt=tan(phit*pi/180);
        dt=y0-bt*x0;
        xlf=(dt-cc)/(ac-bt);
        ylf=ac*xlf+cc;
    end
    
    % Check to see if track angle phi still does not exceed 60
    phi=phit-phin;
    if phi<-180
        phi=phi+360;
    end
    
    if phi>60
        phi=60;
        phit=phin+phi;
        % Try it again
        bt=tan(phit*pi/180);
        dt=y0-bt*x0;
        xlf=(dt-cc)/(ac-bt);
        ylf=ac*xlf+cc;
    elseif phi<-60
        phi=-60;
        phit=phin+phi;
        % Try it again
        bt=tan(phit*pi/180);
        dt=y0-bt*x0;
        xlf=(dt-cc)/(ac-bt);
        ylf=ac*xlf+cc;
    end
    
    if phit<=180 && ylf>y0
        % We are before landfall
        ilf=-1;
    else
        ilf=1;
    end
    
    % distance between eye and new virtual landfall point
    as=sqrt((x0-xlf)^2+(y0-ylf)^2);
    xx1=sqrt((coast.x(ip)-xlf)^2+(coast.y(ip)-ylf)^2);
    if (phin<=180 && coast.x(ip)<xlf) || (phin>=180 && coast.x(ip)>xlf)
        xx1=xx1*-1;
    end
    if phi>0
        xx2=+ilf*as*cos((90-phi)*pi/180); % distance between landfall and eye projected on coastline
    else
        xx2=-ilf*as*cos((90+phi)*pi/180); % distance between landfall and eye projected on coastline
    end
    
    xx=xx2+xx1;
    tt=ilf*(as./trackt.forward_speed)/24;
            
    xacc(ip)=xx;
    phi_rel(ip)=phi;
    tacc(ip)=tt;
    r(ip)=sqrt((coast.x(ip)-x0)^2+(coast.y(ip)-y0)^2);

    
%     if ip==94
%         figure(222)
%         clf
%         plot(coast.x,coast.y);hold on;axis equal;
%         
%         xxx=-1000:2000;
%         yyy=ac*xxx+cc;
%         plot(xxx,yyy,'k--');hold on
%         yyy=bt*xxx+dt;
%         plot(xxx,yyy,'r--');hold on
%         plot(coast.x(ip),coast.y(ip),'kx');
%         plot(xlf,ylf,'bo');
%         plot(x0,y0,'ro');
%         
%         phit0=trackt.heading;
%         bt0=tan(phit0*pi/180);
%         dt0=y0-bt0*x0;
%         yyy=bt0*xxx+dt0;
%         plot(xxx,yyy,'r.');hold on
%         
% 
%         
%         set(gca,'xlim',[0 1000],'ylim',[2600 3600]);
%         axis equal;
%         ok=1;
%     end
end
