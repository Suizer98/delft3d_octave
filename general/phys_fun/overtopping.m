function [q, surf] = overtopping(Hs,Tm,h,alfa,R)
% Calculate overtopping
% Based on the EUROTOP Manual (2007), the wave overtopping rate for smooth and rough impermeable slopes can be described by

% Coefficients
A1      = 0.067;
A2      = 4.3;
A3      = 0.2;
A4      = 2.3;
A5      = 0.2;
A6      = 1.11;

% Standard coefficients
ys      = 1.2;
yr      = 1;
yberm   = 1;
ybeta   = 1;

% Calculate surf
k       = disper( (2*pi/Tm), h, 9.81);
L       = 2*pi / k;
surf    = tand(alfa) / ((Hs / L));

% Overtopping
q1       = ys * surf * (A1 / tand(alfa).^0.5) * (9.81*Hs.^3) * exp( (-A2*R / (surf * yberm * yr * ybeta * Hs) ) );
q2       = ys * A3 * (9.81*Hs.^3).^0.5  * exp( (-A4*R / (yberm * yr * ybeta * Hs) ) );
q3       = ys * A5 * (9.81*Hs.^3).^0.5  * exp( (-A6*R / (yberm * yr * ybeta * (0.33 + 0.022 * surf * Hs)) ) );

% Select correct one based on surf
if surf < 1.8
    q = q1;
elseif surf > 7 
    q = q3;
else
    q = q2;
end

end

