function [numpar] = getnumpar();
% GETNUMPAR
numpar.gq = 0.5773502691896257645; % Quadrature point 
numpar.ds = 0.1;                 % Optimal distance between neighbouring points

numpar.sweCFL = 0.04;              % CFL number
numpar.sweacc = 1e-5;              % accuracy cutoff for SWE calculation

numpar.asRCFL = 0.2; 
numpar.asRacc = 1e-10;              % accuracy cutoff for alpha_s/R calculation
numpar.maxK   = 2000;              % maximum iterations of \alpha_s calculation

%numpar.modtyp = 1;                % 0 = linear model by Johannesson & Parker (1989)
                                   % 1 = non-linear model by Blanckaert & De Vriend (2009)

numpar.routyp = 1;                 % 0 = straight channel friction factor
                                   % 1 = calculated from grain roughness
                                   
numpar.smoothrad = 1;              % 0 = adaptation by Johannesson & Parker (1989)
                                   % 1 = diffusion of geometric radius.
                                   % 2 = relaxation equation with

numpar.streamcurv = 0;             % 0 = none;
                                   % 1 = according to (BdV 2009, eq (41)).

numpar.bedtype = 3;                % 0 = flat bed   (A=0)
                                   % 1 = river bed  (A=3)
                                   % 2 = A/R from input 
                                   % 3 = A/R from calculation
                                   
numpar.rn = 0.99;                  % relaxation factor bewteen two alpha_s/R iterations


numpar.amplitude = 1;              % 0 = small amplitude perturbation
                                   % 1 = large amplitude perturbation
                                   
numpar.strongcurvature = 1;        % 0 = mild curvature
                                   % 1 = strong curvature
                                   
numpar.calfac = 1;

