function [v,Dh]=longshore_current_t(x,Fy,h,H,T,D,k,ks,rho,hmin)
kappa=0.39;fac=0.5;dt=2;eps=1.e-5;
Uw=pi*H./T./sinh(k.*h);
Aw=Uw.*T/2/pi;
z0=ks/30;
fw=1.39*(Aw/z0).^(-0.52);
tauw=.5*fw*rho.*Uw.^2;
Cf=(kappa./(log(h/z0)-1)).^2;
% Longshore velocity
Dh=fac*(D/rho).^(1/3).*h;
vn=zeros(size(x));v=ones(size(x));
n=length(x);
while max(abs(vn-v))>eps;
    v=vn;
    tauc=rho*Cf.*v.^2;
    taum=tauc.*(1+1.2*(tauw./(tauc+tauw)).^3.2);
    tauby=taum;
    vn(1)=v(1)+dt*( ...
        +(Fy(1)-tauby(1))/rho/h(1) );
    for i=2:n-1;
        dx=(x(i+1)-x(i-1))/2;
        vn(i)=v(i)+dt*( ...
            ((Dh(i)+Dh(i+1))*(v(i+1)-v(i))-(Dh(i-1)+Dh(i))*(v(i)-v(i-1)))/2/dx^2 ...
            +(Fy(i)-tauby(i))/rho/h(i) );
    end
    vn(n)=v(n)+dt*( ...
        +(Fy(n)-tauby(n))/rho/h(n) );
    vn(h<hmin)=0;
end