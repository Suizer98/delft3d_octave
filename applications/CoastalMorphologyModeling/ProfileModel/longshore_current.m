function [v]=longshore_current(x,Fy,h,H,T,k,ks,rho,hmin)
z0=ks/30;kappa=0.39;
taum=abs(Fy);
Uw=pi*H/T./sinh(k.*h);
Aw=Uw*T/2/pi;
fw=1.39*(Aw./z0).^(-0.52);
tauw=.5*fw.*rho.*Uw.^2;
% Longshore velocity
tauc=zeros(size(x));
for i=1:length(tauw)
    if h(i)>hmin
        tauc(i)=soulsby(taum(i),tauw(i));
    else
        tauc(i)=0;
    end
end
Cf=(kappa./(log(h./z0)-1)).^2;
v=sqrt(abs(tauc)./rho./Cf).*sign(Fy);