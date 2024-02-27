addpath('..\..\..\src\matlab\');

%% Physical parameters
Qtot  = 15;%50;
B     = 11; %30 in bends
H     = 2; %2.5
U     = Qtot/B/H;
optds = 2*1.8037;

%% Savitsky-Golay filter settings
degree = 5;
halfwin = 7;
intnum = 2;

getcurv2   %get initial channel centre-line and curvature etc.

figure(1);
hold on;
plot(xC,yC,'.',xC0,yC0,'r-')

%% Extend and shorten procedure 
dsC0max = max(diff(sC0));
dsC0min = min(diff(sC0));
%ddsC0 = sC0(3:end)-sC0(1:end-2);
%[dds,k]=min(ddsC0);
while (dsC0max>optds || dsC0min<optds/3)
    dsC0 = diff(sC0);
    for k = length(dsC0):-1:1;
        if (dsC0(k)>optds)
            disp(['add node: ',num2str(k)]);
            xC0=[xC0(1:k),xm0(k),xC0(k+1:end)];
            yC0=[yC0(1:k),ym0(k),yC0(k+1:end)];
            sC0=[sC0(1:k),0.5*(sC0(k)+sC0(k+1)),sC0(k+1:end)];
            %plot(xC0(k+1),yC0(k+1),'g.');
        end
    end
    %shorten proc
    ddsC0 = sC0(3:end)-sC0(1:end-2);
    [dsC0min,k] = min(diff(sC0));
    %pause
    while dsC0min<optds/3
        %        plot(xC0(k+1),yC0(k+1),'r.');
        if k == 1;
            kr = 2;
        elseif k == length(sC0)-1;
            kr = length(sC0)-1;
        else
            if ddsC0(k-1)>ddsC0(k)
                kr = k;
            else
                kr = k+1;
            end
        end
        disp(['remove node: ',num2str(kr-1)]);
        xC0=[xC0(1:kr-1),xC0(kr+1:end)];
        yC0=[yC0(1:kr-1),yC0(kr+1:end)];
        sC0=[sC0(1:kr-1),sC0(kr+1:end)];
        %pause
        ddsC0 = sC0(3:end)-sC0(1:end-2);
        [dsC0min,k] = min(diff(sC0));
    end
    [xC0,xC1,xC2,xm0] = sgolayirreg(sC0,xC0,degree,halfwin);
    [yC0,yC1,yC2,ym0] = sgolayirreg(sC0,yC0,degree,halfwin);
    sC0=[0,cumsum(sqrt(diff(xC0).^2+diff(yC0).^2))];
    dsC0max = max(diff(sC0));
    dsC0min = min(diff(sC0));
end

plot(xC0,yC0,'r-')

%pause
%%
%pause(1)
%min()
figure(2);
zt = (xC1.^2 + yC1.^2);
iR0 = sign(yC1.*xC2 - xC1.*yC2).*sqrt(zt.*(xC2.^2 + yC2.^2)-((xC1.*xC2+yC1.*yC2).^2))./(zt.^(3/2));
angC0 = angle((yC1-i*xC1));
plot(sC0,iR0)

%plot(sC0,xC0)
o = ones(size(sC0));
%%



[ul]  = meander_model(sC0,iR0,3*0*o,Qtot/B*o,H*o,B*o,0.008,-H*o,0*o,0.01,0,0);
[unl] = meander_model(sC0,iR0,3*0*o,Qtot/B*o,H*o,B*o,0.008,-H*o,0*o,0.01,1,0);
for k = 1:10
    [unl] = meander_model(unl.s,iR0,unl.AR,unl.q,unl.h,unl.W,unl.Cf3,-H*o,unl.asR,0.01,1,0);
end
figure(2)
plot(ul.s,B*ul.iR)%,sC,snL.*iRL,sC,snR.*iRR);
hold on;
plot(ul.s,B*ul.asR,'g-')
plot(unl.s,B*unl.asR,'r-')
legend('B/R','B\alpha_{s}/R (linear)','B\alpha_{s}/R (non-linear)','Location','SouthWest')
xlabel('distance along channel (m)');
ylabel('-');
%%
%(Eu*unl.asR*U+Eh*unl.AR*H);

%%
addpath('D:\wottevanger\My Documents\Codes\Software\meamoARver1\')
for k = 1:10
    %[unl]=meamo(sC,snC.*iRC,3*snC.*iRC,unl.q,unl.h,unl.W,unl.Cf3,-H*o,unl.asR,0.01,1,0);
    [unl]=meander_model_AR(sC0,iR0,unl.AR,unl.q,unl.h,unl.W,unl.Cf3,-H*o,unl.asR,0.01,0,0,0,0,0.8,0.25);
    %[unl]=meamoAR(sC0,iR0,unl.AR,unl.q,unl.h,unl.W,unl.Cf3,-H*o,unl.asR,0.01,1,0,1,1,0.8,0.25);
end


figure(3);
[AX,H1,H2] = plotyy(sC0,U*(1-B/2*unl.asR),sC0,H*(1-B/2*unl.AR))
set(get(AX(1),'Ylabel'),'String','Velocity at right bank (m/s)')
set(get(AX(2),'Ylabel'),'String','Water depth at right bank (m)')
hold on;
%plot([sC(175) sC(175)],[0 2.5],'k-');
xlabel('Distance along channel (m)');

%set(AX(1),'YLim',[0.5 1.1],'YTick',[0.6 0.8 1])
%set(AX(2),'YLim',[1.5 2.5],'YTick',[1.6:0.2:2.4])
%%

figure(4);
% xC = xC(:);
% yC = yC(:);

%plot(xC,yC);,xC+B/2*cos(angC),yC-B/2*sin(angC),xC-B/2*cos(angC),yC+B/2*sin(angC));


dt = 24*60*60;
hold on;
%plot(xC+B/2*cos(angC),yC+B/2*sin(angC),'k-',xC-B/2*cos(angC),yC-B/2*sin(angC),'k-');
U = unl.q(1)/unl.h(1);
%pcolor([xC+B/2*cos(angC),xC-B/2*cos(angC)],[yC+B/2*sin(angC),yC-B/2*sin(angC)],[U*unl.asR*B/2,-U*unl.asR*B/2]);
%hold on; % plot([1250 1400],[222 260]-2,'k-'),plot([1250 1400],[222 260]+2,'k-')
%p = patch([1250 1400;1250 1400],[222-2 260-2;222+2 260+2],0*[222-2 260-2;222+2 260+2],'FaceColor',[1 1 1]);

%pcolor([1250 1400;1250 1400],[222-2 260-2;222+2 260+2],'Color',[0 0 0]);
pcolor([xC0+B/2*cos(angC0);xC0-B/2*cos(angC0)],[yC0+B/2*sin(angC0);yC0-B/2*sin(angC0)],H*(1+[-unl.AR*B/2,unl.AR*B/2]'));
shading interp
%colormap bluewhitered
colormap copper
colorbar
axis equal
%ylim([0 700]);
%xlim([500 1400])
box on;
title('water depth(m)')
xlabel('x-coordinate (m)')
ylabel('y-coordinate (m)')
%text(1100,200,'Junnerweg')
%p = patch([1250 1400 1400 1250 1250],[222-2 260-2 260+2 222+2 222-2],[H H H H H],'FaceColor',[0 0 0]);

%%

Eu = 4.*10^(-6); %(-)   %Geul example, Crosato (2008)
Eh = 6.*10^(-6); %(1/s) %Geul example, Crosato (2008)
deltan = 0*dt*(Eu*unl.asR*U+Eh*unl.AR*H);
%plot(xC-B/2*(1+deltan).*cos(angC),yC-B/2*(1+deltan).*sin(angC),'r-',xC+B/2*(1-deltan).*cos(angC),yC+B/2*(1-deltan).*sin(angC),'r-');
%pause

figure(5)
%plot(xC+B/2*cos(angC),yC+B/2*sin(angC),'k-',xC-B/2*cos(angC),yC-B/2*sin(angC),'k-');
U = unl.q(1)/unl.h(1);
pcolor([xC0+B/2*cos(angC0);xC0-B/2*cos(angC0)],[yC0+B/2*sin(angC0);yC0-B/2*sin(angC0)],U+[-U*unl.asR*B/2,U*unl.asR*B/2]');
%hold on; plot([1250 1400],[222 260]-2,'k-'),plot([1250 1400],[222 260]+2,'k-')
%p = patch([1250 1400;1250 1400],[222-2 260-2;222+2 260+2],0*[222-2 260-2;222+2 260+2],'FaceColor',[1 1 1]);

%pcolor([1250 1400;1250 1400],[222-2 260-2;222+2 260+2],'Color',[0 0 0]);
%pcolor([xC+B/2*cos(angC),xC-B/2*cos(angC)],[yC+B/2*sin(angC),yC-B/2*sin(angC)],H*(1+[unl.AR*B/2,-unl.AR*B/2]));
shading interp
%colormap bluewhitered
colormap copper
colorbar
axis equal
% ylim([0 700]);
% xlim([500 1400])
box on;
title('velocity (m/s)')
xlabel('x-coordinate (m)')
ylabel('y-coordinate (m)')
%text(1100,200,'Junnerweg')
deltan = dt*(Eu*unl.asR'*U+0*Eh*unl.AR'*H)*10;
hold on;
plot(xC0+B/2.*cos(angC0)-B/2*(deltan).*cos(angC0),yC0+B/2.*sin(angC0)-B/2*(deltan).*sin(angC0),'r-',...
    xC0-B/2.*cos(angC0)-B/2*(deltan).*cos(angC0),yC0-B/2.*sin(angC0)-B/2*(deltan).*sin(angC0),'r-');

% p = patch([1250 1400 1400 1250 1250],[222-2 260-2 260+2 222+2 222-2],[U U U U U],'FaceColor',[0 0 0]);


%pause
%%  save initial channel position
t = 0;
eval(['unl',sprintf('%03i',t),'=unl;'])
eval(['unl',sprintf('%03i',t),'.xC=xC;'])
eval(['unl',sprintf('%03i',t),'.yC=yC;'])
%%
taubankc = 0*unl.s;
%%
dt      = 86400*365;  %1 of a year 
tend    = 30*86400*365;
ntsteps = round(tend/dt);
jetc = jet(ntsteps);

for t = [1:1:ntsteps]
    B     = 20;
    H     = 2;
    U     = Qtot/B/H;
    o = ones(size(sC0));
    unl.q = Qtot/B*o;%ones(size(unl.q));
    unl.h = H*o;
    unl.W = B*o;
    for k = 1:10
        %[unl]=meamo(sC,snC.*iRC,3*snC.*iRC,unl.q,unl.h,unl.W,unl.Cf3,-H*o,unl.asR,0.01,1,0);
        %[unl]=meamoAR(sC0,iR0,unl.AR,unl.q,unl.h,unl.W,unl.Cf3,-H*o,unl.asR,0.01,0,0,0,0,0.8,0.25);
        [unl]=meander_model_AR(sC0,iR0,unl.AR,unl.q,unl.h,unl.W,unl.Cf3,-H*o,unl.asR,0.01,1,0,1,1,0.8,0.25);
    end
    psibank = 2-exp(-1.58*(B.*abs(iR0)).^0.7791)+(-0.6473+0.25*log(B/H)).*B.*abs(iR0);
    % wH = 0.01;
    % wlambda = 1;
    % wsigma = 0.5;
    % Cd = 1.79*exp(-0.5*wsigma/H);
    rho = 1000;
%     taubankcr = 95;%
%     Cfwall = 1/(2.5*log(1/0.5*30))^2;%0.007;
%     taubankcr = 3;%
%     Cfwall = 1/(2.5*log(1/0.5*30))^2;%0.007;
    taubankcr = 0.15;
    Cfwall = 1/(2.5*log(1/(0.0004*3)*30))^2;%0.007;
    taubank = rho*Cfwall*psibank.*(U+B/2*unl.asR').^2;% + 0.5*rho*Cd*wH/wlambda.*(U+B/2*unl.asR).^2;
    
    Eu = 2*10^(-7)/sqrt(taubankcr);
    %deltan = sign(unl.asR').*Eu.*max(taubank-taubankcr,0)*dt;
    %deltan=unl.deltan*dt;
    %plot(unl.s,deltan)
    
    %Eh = Eu;
    deltan = dt*(Eu*psibank.*unl.asR'*B/2*U);%+Eh*unl.AR'*B/2*H);
    %deltan(yC0<270) = 0;
    deltan(sC0<20) = 0;
    xC0 = xC0-(deltan).*cos(angC0);
    yC0 = yC0-(deltan).*sin(angC0);
    sC0=[0,cumsum(sqrt(diff(xC0).^2+diff(yC0).^2))];
    [xC0,xC1,xC2,xm0] = sgolayirreg(sC0,xC0,degree,halfwin);
    [yC0,yC1,yC2,ym0] = sgolayirreg(sC0,yC0,degree,halfwin);
    
    dsC0max = max(diff(sC0));
    dsC0min = min(diff(sC0));
    %ddsC0 = sC0(3:end)-sC0(1:end-2);
    %[dds,k]=min(ddsC0);
    while (dsC0max>optds || dsC0min<optds/3)
        dsC0 = diff(sC0);
        for k = length(dsC0):-1:1;
            if (dsC0(k)>optds)
                disp(['add node: ',num2str(k)]);
                xC0=[xC0(1:k),xm0(k),xC0(k+1:end)];
                yC0=[yC0(1:k),ym0(k),yC0(k+1:end)];
                sC0=[sC0(1:k),0.5*(sC0(k)+sC0(k+1)),sC0(k+1:end)];
                %plot(xC0(k+1),yC0(k+1),'g.');
                unl.AR =[unl.AR(1:k) ;unl.AR(k) ;unl.AR(k+1:end)];
                unl.Cf3=[unl.Cf3(1:k);unl.Cf3(k);unl.Cf3(k+1:end)];
                unl.asR=[unl.asR(1:k);unl.asR(k);unl.asR(k+1:end)];
            end
        end
        %shorten proc
        ddsC0 = sC0(3:end)-sC0(1:end-2);
        [dsC0min,k] = min(diff(sC0));
        %pause
        while dsC0min<optds/3
            %        plot(xC0(k+1),yC0(k+1),'r.');
            if k == 1;
                kr = 2;
            elseif k == length(sC0)-1;
                kr = length(sC0)-1;
            else
                if ddsC0(k-1)>ddsC0(k)
                    kr = k;
                else
                    kr = k+1;
                end
            end
            disp(['remove node: ',num2str(kr-1)]);
            xC0=[xC0(1:kr-1),xC0(kr+1:end)];
            yC0=[yC0(1:kr-1),yC0(kr+1:end)];
            sC0=[sC0(1:kr-1),sC0(kr+1:end)];
            unl.AR =[unl.AR(1:kr-1) ;unl.AR(kr+1:end)];
            unl.Cf3=[unl.Cf3(1:kr-1);unl.Cf3(kr+1:end)];
            unl.asR=[unl.asR(1:kr-1);unl.asR(kr+1:end)];
            %pause
            ddsC0 = sC0(3:end)-sC0(1:end-2);
            [dsC0min,k] = min(diff(sC0));
        end
        [xC0,xC1,xC2,xm0] = sgolayirreg(sC0,xC0,degree,halfwin);
        [yC0,yC1,yC2,ym0] = sgolayirreg(sC0,yC0,degree,halfwin);
        sC0=[0,cumsum(sqrt(diff(xC0).^2+diff(yC0).^2))];
        dsC0max = max(diff(sC0));
        dsC0min = min(diff(sC0));
    end
    zt = (xC1.^2 + yC1.^2);
    iR0 = sign(yC1.*xC2 - xC1.*yC2).*sqrt(zt.*(xC2.^2 + yC2.^2)-((xC1.*xC2+yC1.*yC2).^2))./(zt.^(3/2));
    angC0 = angle((yC1-i*xC1));
    
    
    %if ((t/10) == floor(t/10))
    clc;
    disp([t,t,t,t]);
    disp([t,t,t,t]);
    disp([t,t,t,t]);
    disp([t,t,t,t]);
    figure(11)
    hold on;
    %   taubankc =taubankc+taubank;
    %   plot(unl.s,sign(unl.asR').*taubank);
    %title(num2str([t,Qtot]))
    %figure(10)
    %hold on;
    plot(xC0,yC0,'Color',jetc(t,:));
    axis equal;
    %plot(sCA0,deltan,'Color',jetc(yeanum_run2(t),:));
    %xC = xC0;
    %yC = yC0;
    %title(num2str(t))
    %pause(0.1)
    %end
    eval(['taubank',sprintf('%03i',t),'=taubank;'])
    eval(['unl',sprintf('%03i',t),'=unl;'])
    eval(['unl',sprintf('%03i',t),'.xC=xC0;'])
    eval(['unl',sprintf('%03i',t),'.yC=yC0;'])
end

box on;
axis equal
title('Evolution after 30 years');
%ylim([0 700]);
%xlim([500 1400])
%legend('initial','after 10 years','after 20 years','after 30 years','Location','SouthWest')
