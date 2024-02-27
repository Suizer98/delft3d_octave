clear all;close all;fclose all;clear functions
%% Input section
ns=200;               % Number of grid cells
d=25;                 % Height of active profile
dt=.1;              % Time step (yr)
nt=400;               % Number of time steps
interval=20;           % Output interval
%% Read outline for graphics
xyg=load('ijmuiden.txt')
xyg(xyg==-999)=NaN;
xg=xyg(:,1);
yg=xyg(:,2);
%% Read initial coastline
%xyi=load('InitialCoastline.txt');
xyi=load('xy1967.txt')
xi=xyi(:,1);
yi=xyi(:,2);
%% Read reference coastline
xy=load('Baseline.txt');
xref=xy(:,1);
yref=xy(:,2);
%% Read present coastline
%xyp=load('PresentCoastline.txt');
xyp=load('xy2007.txt');
xp=xyp(:,1);
yp=xyp(:,2);
%% Compute distance along reference coastline
dist(1)=0;
for i=2:length(xref);
    dist(i)=dist(i-1)+sqrt((xref(i)-xref(i-1))^2+(yref(i)-yref(i-1))^2);
end
%% Create computational grid
ds=(dist(end)-dist(1))/(ns-1);  % Alongshore stepsize
s=0:ds:dist(end);               % Alongshore distance
xr=spline(dist,xref,s);            % x of coastline grid points
yr=spline(dist,yref,s);            % y of coastline grid points
%% Compute locations of initial coastline
[si,ni]=locate(s,xr,yr,xi,yi);
n=interp1(si,ni,s,'linear','extrap');    % Cross-shore coastline change
for i=2:ns-1
    ds2(i)=sqrt((xr(i+1)-xr(i-1))^2+(yr(i+1)-yr(i-1))^2);
    dy=n(i)*(xr(i+1)-xr(i-1))/ds2(i);
    dx=-n(i)*(yr(i+1)-yr(i-1))/ds2(i);
    x(i)=xr(i)+dx;
    y(i)=yr(i)+dy;
    if i==2
        x(1)=xr(1)+dx;
        y(1)=yr(1)+dy;
    end
    if i==ns-1
        x(ns)=xr(ns)+dx;
        y(ns)=yr(ns)+dy;
    end
end
nS=.5*(n(1:ns-1)+n(2:ns));      % n of transport points
sS=.5*(s(1:ns-1)+s(2:ns));      % s of transport points
xS=.5*(x(1:ns-1)+x(2:ns));      % x of transport points
yS=.5*(y(1:ns-1)+y(2:ns));      % y of transport points
%% Plot initial coastline
figure(1)
plot(xr,yr,'.-k',xi,yi,'.',x,y,'r.-');hold on;
axis equal
%% Load groin locations
try
    xyend=load('end of groins');
    xytip=load('tip of groins');
    xgroin(:,1)=xyend(:,1);
    ygroin(:,1)=xyend(:,2);
    xgroin(:,2)=xytip(:,1);
    ygroin(:,2)=xytip(:,2);
    length_groin=squeeze(sqrt((xgroin(:,2)-xgroin(:,1)).^2 ...
        +(ygroin(:,2)-ygroin(:,1)).^2));
    plot(xgroin',ygroin');hold on
    %% Compute cross-shore cumulative transport ditribution
    %% to account for groin effect
    [dist_cross,ScumRel]=analyse_transports();
    groins=1
catch
    groins=0
end
%% S-phi curves
load S_phi.mat;
ww=load('WaveWindows.txt');
[sww,nww]=locate(s,x,y,ww(:,1),ww(:,2));
angle1=interp1(sww,ww(:,3),sS,'linear','extrap');
angle2=interp1(sww,ww(:,4),sS,'linear','extrap');
%% Compute local S-phi curves
for i=1:ns-1
    for iphi=1:length(phic)
        Sploc(i,iphi)=integrate(angle1(i),angle2(i),wavedir,Splus(iphi,:));
        Smloc(i,iphi)=integrate(angle1(i),angle2(i),wavedir,Smin(iphi,:));
    end
end
%% Start time loop
for it=1:nt;
    %% Compute coast angles (direction of shore normal, nautical
    %% convention)
    for i=1:ns-1
        phi(i)=(2*pi-atan2(y(i+1)-y(i),x(i+1)-x(i)))*180/pi;
        if phi(i)>360
            phi(i)=phi(i)-360;
        end
    end
    %% Compute transport from sum of Splus(phi) and Smin(phi)
    for i=1:ns-1
        Sp(i)=interp1(phic,Sploc(i,:),phi(i));
        Sm(i)=interp1(phic,Smloc(i,:),phi(i));
    end
    if groins
        %% Apply influence factors due to groins
        %Locate gridpoints at groin locations
        [sgroin,ngroin_end]=locate(s,x,y,xgroin(:,1),ygroin(:,1))
        ngroin_tip=ngroin_end+length_groin';
        ngroin_coast=interp1(s,n,sgroin);
        igroin=round(sgroin/ds)+1;
        dist_active=-500;
        dist_end=ngroin_coast-ngroin_end;
        dist_tip=ngroin_coast-ngroin_tip;
        for ig=1:length(sgroin)
            reducfac(ig)=interp1(dist_cross,ScumRel,dist_tip(ig)) ...
                -interp1(dist_cross,ScumRel,dist_active) ...
                +1-interp1(dist_cross,ScumRel,dist_end(ig));
            Sp(igroin(ig))=Sp(igroin(ig))*reducfac(ig);
            Sm(igroin(ig)-1)=Sm(igroin(ig)-1)*reducfac(ig);
        end
    end
    S=Sp+Sm;
    %% Stop if bad things happen
    if sum(isnan(S))>0
        break
    end
    %% Update coastline
    for i=2:ns-1;
        dn=-dt/d*(S(i)-S(i-1))/ds;
        n(i)=n(i)+dn;
        dy=n(i)*(xr(i+1)-xr(i-1))/ds2(i);
        dx=-n(i)*(yr(i+1)-yr(i-1))/ds2(i);
        x(i)=xr(i)+dx;
        y(i)=yr(i)+dy;
        if i==2
            %% First boundary condition: constant transport gradient
            x(1)=xr(1)+dx;
            y(1)=yr(1)+dy;
            n(1)=n(1)+dn;
        end
        if i==ns-1
            %% Second boundary condition: constant transport gradient
            x(ns)=xr(ns)+dx;
            y(ns)=yr(ns)+dy;
            n(ns)=n(ns)+dn;
        end
    end
    %% Update yS and nS
    yS=.5*(y(1:ns-1)+y(2:ns));
    nS=.5*(n(1:ns-1)+n(2:ns));
    %% Plot results
    if mod(it,interval)==0
        figure(2)
        set(gcf,'color','w')
        subplot(211);hold on
        plot(s/1000,n);
        ylabel('coastline position (m)')
        subplot(212);hold on
        plot(sS/1000,S,sS/1000,Sp,sS/1000,Sm);
        xlabel('longshore distance (km)')
        ylabel('sediment transport (m^3/yr)')
%         figure(2)
%         subplot(131);hold on
%         plot(xref,yref,xp,yp,'.',x,y);set(gca,'ylim',[min(y),max(y)]);axis equal
%         xlabel('x (m)');ylabel('y (m)');
%         subplot(132);hold on
%         plot(-n,y);set(gca,'ylim',[min(y),max(y)]);
%         ylabel('coastline change (m)')
%         subplot(133);hold on
%         plot(S,yS,Sp,yS,Sm,yS);set(gca,'ylim',[min(y),max(y)]);
%         ylabel('Transport (m^3/yr)')
        figure(3)
        set(gcf,'color','w')
        plot(xref/1000,yref/1000,xi/1000,yi/1000,'.r',xp/1000,yp/1000,'.b',x/1000,y/1000);
        set(gca,'ylim',[490 505]);axis equal
        legend('reference line','1967 coastline','2007 coastline','computed coastline') 
        hold on
        plot(xg/1000,yg/1000,'k','linewidth',2)
        xlabel('X (km)')
        ylabel('Y (km)')
    end
end
        figure(2);
        subplot(211);hold on
        plot(s/1000,n,'linewidth',2);
        subplot(212);hold on
        plot(sS/1000,S,sS/1000,Sp,sS/1000,Sm,'linewidth',2');
        legend('Total transport','N transport','S transport');
        print('-dpng','ijmuiden.png')
        print('-depsc2','ijmuiden.eps')
        

