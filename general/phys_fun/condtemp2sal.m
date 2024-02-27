function [Salinity] = condtemp2sal(conductivity,temperature,pressure)

% Calculation of salinity from measured conductivity, and optionally 
% temperature and pressure using unesco formula 
% (see http://www.jodc.go.jp/info/ioc_doc/UNESCO_tech/046148eb.pdf)
%
% conductivity = []; %measured conductivity in mS/cm
% temperature  = temperature in deg Celcius
% optional:
% pressure     = pressure above one standard atmosphere in bar (default = 0 bar)

if nargin==0
    varargout = {OPT};
    return
end
    
sz = size(conductivity);

if nargin==2
    OPT.p    = 0;
    disp('Pressure set to 0, equal to one standard atmosphere')
elseif nargin==3
    if sum((size(pressure)==sz)==0)>0
        pressure=reshape(pressure,sz(1),sz(2));
    end
    OPT.p    = pressure;
end

if sum((size(temperature)==sz)==0)>0
    temperature=reshape(temperature,sz(1),sz(2));
end

R = (conductivity)./42.914;

e1 = 2.07*10^-4;
e2 = -6.37*10^-8;
e3 = 3.989*10^-12;
d1 = 3.426*10^-2;
d2 = 4.464*10^-4;
d3 = 4.215*10^-1;
d4 = -3.107*10^-3;
c0 = 0.6766097;
c1 = 2.00564*10^-2;
c2 = 1.104259*10^-4;
c3 = -6.9698*10^-7;
c4 = 1.0031*10^-9;
k = 0.0162; 
b0 = 0.0005;
b1 = -0.0056;
b2 = -0.0066;
b3 = -0.0375;
b4 = 0.0636;
b5 = -0.0144;
Sb = b0+b1+b2+b3+b4+b5; %should be zero
a0 = 0.008;
a1 = -0.1692;
a2 = 25.3851;
a3 = 14.0941;
a4 = -7.0261;
a5 = 2.7081;
Sa = a0+a1+a2+a3+a4+a5; %should be 35

Rp = 1+(OPT.p.*(e1+e2.*OPT.p+e3.*OPT.p.^2))./(1+d1.*temperature+d2.*temperature.^2+(d3+d4.*temperature).*R);
rt = c0 + c1.*temperature + c2.*temperature.^2 + c3.*temperature.^3 + c4.*temperature.^4;
Rt = R./(Rp.*rt);
dS = ((temperature-15)./(1+k.*(temperature-15))) .* (b0 + b1.*Rt.^0.5 + b2.*Rt + b3.*Rt.^1.5 + b4.*Rt.^2 + b5.*Rt.^2.5);
Salinity = a0 + a1.*Rt.^0.5 + a2.*Rt + a3.*Rt.^1.5 + a4.*Rt.^2 + a5.*Rt.^2.5 + dS;
