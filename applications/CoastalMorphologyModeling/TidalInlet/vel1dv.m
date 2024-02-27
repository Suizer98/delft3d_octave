clear all;close all
relfac=1
phi=51;
taper=100;
nuconstant=0
c={'b','r'}
for icor=0:1
    f=2*7.27e-5*sin(phi*pi/180)*(icor);
    tauw=1;
    dir=45;
    tauwx=tauw*cos(dir*pi/180);
    tauwy=tauw*sin(dir*pi/180);
    h=20;H=0;
    L=1000;
    dz=.5;
    dt=.5;
    nt=200000;
    rho=1000;g=9.81
    kappa=0.4;
    z=[-h:dz:0];
    u=zeros(size(z));
    v=zeros(size(z));
    unew=u;
    vnew=v;
    detadx=0;
    t=[0:dt:(nt-1)*dt];
    eta=zeros(nt,1);
    umean=zeros(nt,1);
    nz=length(z);
    if nuconstant==0
        vstar=sqrt(sqrt(tauwx^2+tauwy^2)/rho);
        nut=-kappa*vstar*z.*(h+z)/h;
        nut(ceil(end/2):end)=max(nut(ceil(end/2):end),kappa*vstar*H)
    else
        nut=ones(size(z))*nuconstant;
    end
    figure(1)
    for it=2:nt
        tap=1-exp(-(t(it)/taper)^2);
        %tap=1;
        unew(1)=0;
        vnew(1)=0;
        for i=1:nz-1
            tauzx(i)=.5*rho*(nut(i)+nut(i+1))*(u(i+1)-u(i))/dz;
            tauzy(i)=.5*rho*(nut(i)+nut(i+1))*(v(i+1)-v(i))/dz;
        end
        for i=2:nz-1
            unew(i)=u(i)+dt*((tauzx(i)-tauzx(i-1))/dz/rho-g*detadx+f*v(i));
            % unew(i)=u(i)+dt*((tauzx(i)-tauzx(i-1))/dz/rho+f*v(i));
            vnew(i)=v(i)+dt*((tauzy(i)-tauzy(i-1))/dz/rho-f*u(i));
        end
        unew(nz)=u(nz-1)+dz*tauwx*tap/(.5*(nut(nz-1)+nut(nz))*rho);
        vnew(nz)=v(nz-1)+dz*tauwy*tap/(.5*(nut(nz-1)+nut(nz))*rho);
        umean(it)=mean(unew);
        etanew=eta(it-1)+dt*2*umean(it)*h/L;
        eta(it)=(1-relfac)*eta(it-1)+relfac*etanew;
        detadx=eta(it)/L;
        u=unew;
        v=vnew;
        if mod(it,nt)==0
            subplot(1,2,1)
            plot(u,z,c{icor+1},'linewidth',2');hold on
            legend('without Coriolis','with Coriolis')
            xlabel('u');ylabel('z')
            subplot(1,2,2)
            plot(v,z,c{icor+1},'linewidth',2');hold on
            xlabel('v');ylabel('z')
        end
    end
end
set(gcf,'color','w')
