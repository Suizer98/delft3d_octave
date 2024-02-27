function[Dw,Qb]=Baldock2(gamma,k,h,H,T,opt);
% Compute dissipation according to Baldock
alpha=1;rho=1000;g=9.81;
Hmax=0.88/k*tanh(gamma*k*h/0.88);
Qb=exp(-(Hmax/H)^2);
    if opt==1
    Dw=0.25*alpha*rho*g/T*Qb*(Hmax^2+H^2);
else
    Dw=0.25*alpha*rho*g/T*Qb*(Hmax^3+H^3)/gamma/h;
end
end