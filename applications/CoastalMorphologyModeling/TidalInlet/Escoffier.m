clear all;close all; fclose all;
obrien=4.69e-4/(0.3048)^(3*0.85)*0.3048^2;
Ac=0:10:50000;
col=['b','r','g'];
for p=1:3
    for isc=1:3
         if p==1
            Lgorge=2000*2^(isc-1);
        else
            Lgorge=4000;
        end
       if p==2
            h=sqrt(Ac/50/2^(isc-1));
        else
            h=sqrt(Ac/50/2);
        end
        A=150e6;
        if p==3
            etamp=.5*2^(isc-1);
        else
            etamp=1;
        end
        Cf=0.004;
        g=9.81;
        T=12.5*3600;
        omega=2*pi/T;
        uampmax=A./Ac*omega*etamp;
        uamp=1.0;
        labda=pi/4*Cf*uamp;
        mu=Ac.*h/A*g./labda/Lgorge;
        phi=omega./mu;
        uamp=A./Ac*omega./sqrt(1+phi.^2)*etamp;
        P=2*etamp*A./sqrt(1+phi.^2);
        f=figure(p)
        set(f,'color','w','resize','off')
        plot(Ac,uamp,col(isc),'linewidth',2);hold on;
        xlabel('A_{c} (m²)');ylabel('v_{max} (m/s)')
        % figure(2)
%         plot(Ac,1./sqrt(1+phi.^2),col(isc),'linewidth',2);hold on
         figure(10+p)
         set(gcf,'color','w')
         loglog(Ac,P,col(isc),'linewidth',2);hold on
        xlabel('A_{c} (m²)');ylabel('P (m³/s)')
    end
    loglog(Ac,2*1.06*Ac/omega,'k');
    figure(p)
    if p==1
        legend('L_{gorge}=2000 m','L_{gorge}=4000 m','L_{gorge}=8000 m')
    elseif p==2
        legend('B/h = 50','B/h = 100','B/h = 200')
    elseif p==3
        legend('tidal amplitude=0.5 m','tidal amplitude=1 m','tidal amplitude=2m')
    end
    plot(Ac,ones(size(Ac))*1.06,'k')
    fname=['escoffier',num2str(p),'.png']
    print('-dpng',fname)
    fname=['escoffier',num2str(p),'.eps']
    print('-depsc2',fname)
    figure(10+p)
    if p==1
        legend('L_{gorge}=2000 m','L_{gorge}=4000 m','L_{gorge}=8000 m','location','northwest')
    elseif p==2
        legend('B/h = 50','B/h=100','B/h=200','location','northwest')
    elseif p==3
        legend('tidal amp.=0.5 m','tidal amp.=1 m','tidal amp.=2m','location','northwest')
    end
    fname=['escoffier',num2str(10+p),'.png']
    print('-dpng',fname)
    fname=['escoffier',num2str(10+p),'.eps']
    print('-depsc2',fname)
end