function Pc = wpr_knaff_and_zehr_2007(Vsrm1,lat,S,Pe) 
% Knaff and Zehr (2007) wind pressure relationship
% S=V500/V500C;
% Pe give in Pa
% Vsrm1 = one-minute mean maximum winds in knots adjusted for storm motion
Pc = 23.286 - 0.483*Vsrm1 - (Vsrm1/24.254)^2 - 12.587*S - 0.483*abs(lat) + Pe/100;
Pc = Pc*100;

