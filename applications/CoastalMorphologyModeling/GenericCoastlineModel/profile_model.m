clear all;close all;
%% Input section
clim=load('climate.txt')      % file with p, Hm0, Tp,dir in columns
% ndir sets of nH records
ndir=18;                      % Number of wave directions
nH=20;                        % Number of wave height classes
data.p=clim(:,1);             % Percentage occurrence of wave condition
data.Hm0=clim(:,2);           % Hm0 wave height
data.Tp=clim(:,3);            % Peak wave period
data.dir=clim(:,4);           % Wave direction
plt=1;                        % Plot intermediate results 0/1
gamma=.75;                    % Breaker parameter
beta=.1;                      % Roller slope parameter
hmin=.5;                      % Cut-off water depth
ks=0.006*30;                  % Bed roughness
rho=1025;                     % Water density
D50=200e-6;                   % D50 grain diameter
D90=300e-6;                   % D90 grain diameter
dxmin=2;                      % Minimum grid size
nphi=10;                      % Number of coast directions
phimin=200;                   % Smallest coast angle considered
dphi=20;                      % Step size coast angles

%% Profile definition 
profile=load('profile.txt')
x1=profile(:,1);
zb1=profile(:,2);
% define grid size as function of depth
ddx=[-2 20];dxd=[2 20];
xn=x1(1);
x(1)=xn;
i=1;
while x(i)<0;
    d=-interp1(x1,zb1,x(i));
    dx=interp1(ddx,dxd,d);
    i=i+1;
    x(i)=x(i-1)+dx;
end
zb=interp1(x1,zb1,x);
%% Start loop over coast angles
for iphi=1:nphi;
    phic(iphi)=phimin+(iphi-1)*dphi; % Coast angles from east through south to west
    %% Start loop over wave conditions
    ic=0
    for idir=1:ndir
        pdir=data.p(ic+1:ic+nH);
        Hm0dir=data.Hm0(ic+1:ic+nH);
        Hm0dir=Hm0dir(pdir~=0);
        Tpdir=data.Tp(ic+1:ic+nH);
        Tpdir=Tpdir(pdir~=0);
        pdir=pdir(pdir~=0);
        Hm0rep(idir,iphi)=(sum(pdir.*Hm0dir.^4)...
            /sum(pdir))^0.25;
        Tprep(idir,iphi)=interp1(Hm0dir,Tpdir,Hm0rep(idir,iphi));
        prep(idir,iphi)=sum(pdir);
        for iH=1:nH+1
            if iH<nH+1
                ic=ic+1;
            end
            wavedir(idir)=data.dir(ic);
            if iH>nH
                Hrms0=Hm0rep(idir)/sqrt(2);
                Tp=Tprep(idir);
            else
                Hrms0=data.Hm0(ic)/sqrt(2);
                Tp=data.Tp(ic);
            end
            dir0=phic(iphi)-data.dir(ic);
            if dir0<-180
                dir0=dir0+360;
            end
            if dir0>180
                dir0=dir0-360;
            end
            pp=data.p(ic);
            if abs(dir0)<89 & (data.p(ic)~=0|iH==nH+1);
                dir0=dir0*pi/180;
                eta0=0;
                %% Solve wave, roller energy balance and setup
                [E,Hrms,Er,Qb,Dw,Dr,eta,h,k,C,Cg,dir,Fx,Fy]= ...
                    balance_1d(Hrms0,dir0,eta0,Tp,x,zb,gamma,beta,hmin);
                %% Solve longshore current with stationary solver
                [vs]=longshore_current(x,Fy,h,Hrms,Tp,k,ks,rho,hmin);
                %% Compute longshore transport rate
                u=zeros(size(vs));
                [S,Slong]=soulsby_van_rijn(x,h,Tp,k,Hrms,u,vs,ks,hmin,D50,D90);
                if iH>nH
                    Screp(:,idir,iphi)=S;
                else
                    Sc(:,ic,iphi)=S;
                    Slongc(iH)=Slong;
                    if abs(Slong)>0&plt&~exist(octave_config_info) % plotting extremely slow under GNU plot
                        %% Plot results
                        figure(1);
                        subplot(321);
                        plot(x,zb,x,eta,'linewidth',2);
                        title('Profile');xlabel('x (m)');ylabel('z_b,eta (m)');
                        axis([-800 0 min(zb) max(zb)]);
                        subplot(323);
                        plot(x,Hrms,'linewidth',2);
                        title('Wave height');xlabel('x (m)');ylabel('H_r_m_s (m)');
                        axis([-800 0 1.1*min(Hrms) 1.1*max(Hrms)]);
                        subplot(325);
                        plot(x,dir*180/pi,'linewidth',2);
                        title('Wave direction');xlabel('x (m)');ylabel('Dir (^o)');
                        axis([-800 0 1.1*min(dir*180/pi) 1.1*max(dir*180/pi)]);
                        subplot(322);
                        plot(x,Dw,x,Dr,'linewidth',2);
                        title('Dissipation');xlabel('x (m)');ylabel('D_w,D_r (W/m^2)');
                        axis([-800 0 0 1.1*max(Dw)]);
                        subplot(324);
                        plot(x,vs,'linewidth',2);
                        title('Longshore velocity');xlabel('x (m)');ylabel('v (m/s)');
                        axis([-800 0 1.1*min(vs) 1.1*max(vs)]);
                        subplot(326);
                        plot(x,S,'linewidth',2);
                        title('Longshore transport');xlabel('x (m)');ylabel('S (m^3/m/yr)');
                        axis([-800 0 1.1*min(S) 1.1*max(S)]);
                    else
                        Sc(:,ic,iphi)=zeros(size(x));
                        Slongc(iH)=0;
                    end
                    disp(['Coast angle:',num2str(phic(iphi)), ...
                        ' Condition:',num2str(ic), ...
                        ' Hm0:',num2str(data.Hm0(ic)), ...
                        ' dir:',num2str(data.dir(ic)), ...
                        ' Slong:',num2str(round(Slongc(iH)))]);
                    pH(iH)=data.p(ic)/100;
                    p(ic)=data.p(ic)/100;
                    
                    Snet(iphi,idir)=sum(Slongc.*pH);
                    Splus(iphi,idir)=sum(Slongc(Slongc>0).*pH(Slongc>0));
                    Smin(iphi,idir)=sum(Slongc(Slongc<0).*pH(Slongc<0));
                end % iH>nH+1
            else
                Sc(:,ic,iphi)=zeros(size(x));
                p(ic)=data.p(ic)/100;

            end
        end
    end
end
figure(2);
plot(phic,sum(Smin,2),phic,sum(Splus,2),phic,sum(Snet,2),'linewidth',2);
legend('Smin','Splus','Snet');
xlabel('phic');ylabel('S');
save S_phi.mat phic wavedir Snet Splus Smin
save SC.mat x Sc p Screp Hm0rep Tprep prep