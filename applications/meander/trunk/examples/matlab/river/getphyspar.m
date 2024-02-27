function [physpar] = getphyspar();
% GETPHYSPAR
% Do not use NaN or Inf ...
physpar.b      = 5;               % Non-linearity of sediment transport
physpar.g      = 9.81;            % Gravity constant 
physpar.karman = 0.4;             % von Karman constant
physpar.H0     = 0.6282;%1.0087;%1.1867;%.1722;%1.1867;%1.00871;%1.1722;%1.1731;            % Average water depth 
physpar.W      = 29.85;%17;          % Channel width 
physpar.Q0     = 50/physpar.W;%0.9*physpar.H0;%1981/200;      % Unit discharge (Fr = 0.1);
physpar.iS     = 0;%0.0002;             % Valley slope      
physpar.Eu     = 0;%0.116e-5;        % Erosion rate based on velocity excess
physpar.Eh     = 0.0;             % Erosion rate based on water level excess
physpar.Cf0    = 0.008;%06;%25;%9.81/30/30;%0.0044;%0.8*(0.02/0.28)^2;%0.001;            % Friction factor %-physpar.iS*physpar.g*physpar.H0^3/physpar.Q0^2; % Equilibrium friction factor
physpar.ks     = 0.0004*3;           % Nikuradse roughness height
physpar.Sn     = 1;               % Transverse slope
physpar.chi    = 1.5;             % ??
physpar.L      = 12500;%7*3.2138;        % Valley length


physpar.D50 = physpar.ks/3;%ks/3; %ks = 3.D90;
physpar.nukin  = 1e-6;
physpar.specden= 2.65; 
physpar.relden= 1.65; 
Dst    = physpar.D50*((physpar.specden-1)*physpar.g/physpar.nukin^2)^(1/3);
physpar.thetcr = 0.055;
physpar.thetcr(Dst<=150) = 0.013*Dst^(0.29);
physpar.thetcr(Dst<=20)  = 0.04*Dst^(-0.10);
physpar.thetcr(Dst<=10)  = 0.14*Dst^(-0.64);
physpar.thetcr(Dst<=4)   = 0.24*Dst^(-1);

%physpar.Ashld = 0.1;
%physpar.Ashld = 0.6;
%physpar.Bshld = 0.5;
physpar.thet  = physpar.Cf0.*(physpar.Q0./physpar.H0).^2./physpar.g./physpar.relden./physpar.D50;