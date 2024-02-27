function Fld=land_decay_factor(t,vt,phi,vmax)
% t    = time w.r.t. landfall (days)
% vt   = forward speed (km/h)
% phi  = track angle (degrees)
% vmax = Vmax (km/h)

Rs=110;
vmax=vmax/0.88; % Convert to 1-minute sustained winds
Tl=Rs/(vt*cos((phi)*pi/180));
th=t*24;
F1=(th+Tl).^2/(4*Tl);
F2=th;
F=zeros(size(th));
F(th>=-Tl & th<=Tl)=F1(th>=-Tl & th<=Tl);
F(th>Tl)=F2(th>Tl);
alfa=0.095;
vb=26.7*1.852; % km/h
%Fld=(vb + (vmax - vb)*exp(-alfa.*F))/vmax;
Fld=(vb + (vmax - vb)*exp(-alfa.*F))/(vmax);
