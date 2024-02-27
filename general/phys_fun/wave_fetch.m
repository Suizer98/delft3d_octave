function [Hs, Tm] = wave_fetch(F, u10)
% Simple empircal formulation for determing Hs and Tm based on fetch and umag
% v1.0 	Nederhoff	July-16

%% Constants based on Breugem and Holthuijsen (2007)
% https://ascelibrary.org/doi/pdf/10.1061/%28ASCE%290733-950X%282007%29133%3A3%28173%29

% Wave height
Hinf    = 0.24;
k1      = 4.14*10^-4;
m1      = 0.79;
p       = 0.572;

% Wave period
Tinf    = 7.69;
k2      = 2.77*10^-7;
m2      = 1.45;
q       = 0.187;

%% Idealised fetch
Fbar = 9.81 * F / (u10.^2);

%% Bar values - independent from u10
Hbar = Hinf * (tanh(k1*Fbar^m1))^p;
Tbar = Tinf * (tanh(k2*Fbar^m2))^q;

%%  Real values  - dependent from u10
Hs  = Hbar * u10.^2 / 9.81;
Tm 	= Tbar * u10 / 9.81;

end

