function [S,Slong]=soulsby_van_rijn(x,h,T,k,H,u,v,ks,hmin,D50,D90)
%
% Compute sand transport according to Soulsby - van Rijn
% ------------------------------------------------------
g=9.81;delta=1.65;nu=1.e-6;kappa=0.39;Acal=1;
z0=ks/30;
Dstar=(g*delta/nu^2)^(1/3)*D50;
for i=1:length(x)
    if h(i)>hmin
        Urms(i)=1/sqrt(2)*pi*H(i)/T./sinh(k(i).*h(i));
        if D50<=0.5e-3
            Ucr(i)=0.19*D50^0.1*log10(4*h(i)/D90);
        else
            Ucr=8.5*D50^0.6*log10(4*h/D90);
        end
        Cf(i)=(kappa/(log(h(i)/z0)-1))^2;
        umod(i)=sqrt(u(i)^2+v(i)^2+0.018/Cf(i)*Urms(i)^2);
        if umod(i)>Ucr(i)
            ksi(i)=(umod(i)-Ucr(i))^2.4;
        else
            ksi(i)=0;
        end
        Asb(i)=0.005*h(i)*(D50/h(i)/delta/g/D50)^1.2;
        Ass(i)=0.012*D50*Dstar^(-0.6)/(delta*g*D50)^1.2;
        Sbx(i)=Acal*Asb(i)*u(i)*ksi(i);
        Sby(i)=Acal*Asb(i)*v(i)*ksi(i);
        Ssx(i)=Acal*Ass(i)*u(i)*ksi(i);
        Ssy(i)=Acal*Ass(i)*v(i)*ksi(i);
        Stotx(i)=Sbx(i)+Ssx(i);
        Stoty(i)=Sby(i)+Ssy(i);
    else
        Urms(i)=0;
        Ucr(i)=0;
        Cd(i)=0;
        ksi(i)=0;
        Asb(i)=0;
        Ass(i)=0;
        Sbx(i)=0;
        Sby(i)=0;
        Ssx(i)=0;
        Ssy(i)=0;
        Stotx(i)=0;
        Stoty(i)=0;
    end
end
S=Stoty*3600*24*365;
Slong=.5*sum((S(1:end-1)+S(2:end)).*(x(2:end)-x(1:end-1)));