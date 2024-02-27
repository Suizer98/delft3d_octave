%% SCRIPT FOR LOGISTIC POPULATION GROWTH
% Shepard, J.J. & L. Stojkov, 2007. The logistic population model with slowly varying
% carrying capacity. ANZIAM J. 47 (EMAC2005), pp. C492-C506.
% 
% logistic growth function for recovery of benthic community affected by time variable function for
% CC that denotes the 'habitat quality' that needs to recover.
% 
% Parameters:
%   r = growth rate
%   P0 = starting population size
%   e = rate of variation in time (small, positive parameter to determine slow time variation)
%   K = carrying capacity, time-dependent so: K(et)
%   K0 = initial value for K(et)
%   Ks = limiting value for K(et) as t --> infinity
function ecorules
% input: isoort of supplicie
% input: time
% coastline position (x,y,z)
% output: Ps
%for isoort=1:2

global S

if ~exist('sens','var')
sens=1;
end

%load PRNdata

x0         = S.PP(sens).GEmapping.x0;
y0         = S.PP(sens).GEmapping.y0;
zminz0     = S.PP(sens).GEmapping.zminz0;                                           % change of coastline since t0
nryears    = size(S.PP(sens).GEmapping.zminz0,1);                                   % dirty way to get the time length (tend - t0)
nrsections = size(S.PP(sens).GEmapping.zminz0,2);                                   % dirty way to get the nr. of coastline sections (i.e. grid cells) along the Holland coast
isoort     = 3;

% ShoreWidth = 10000.0;                                                      % initial shoreface width, i.e. 10km.
% ShoreWidthFact = zeros();
% ShoreWidthFact = (ShoreWidth-(zminz0>0))/ShoreWidth;                       % if zminz0 >0, then the shoreface width decrease, then K and P of the species will descrease in a portion.



%S.PP(sens).GEmapping.supp(2:12,10:12) = 0;                                          % temperarily overruling the mapping nourishment.
%S.PP(sens).GEmapping.supp(14:nryears,10:12) = 0;                                    % temperarily overruling the mapping nourishment.
% S.GEmapping.supp(2:nryears,10:12) = 0;                                   % temperarily overruling the mapping nourishment.

%% INPUT VARIABLES from a file....
ECO=read_eco_input([S.settings.basedir 'Matlab/postprocessing/indicators/eco/eco_input.txt']);
% t = [0:0.1:21];
% P(time, nrsections)
% K(time, nrsections)
%% 
for k = 1: length(ECO)-2                                                     % nr. of species.
%Ks=1200;
%P0=200;

Ks(k) = ECO(k).k_s;
P0(k) = ECO(k).p0;
r     = ECO(k).r; 
for i = 1: nrsections                                                      % nr. of coastline sections (i.e. grid cells) along the Holland coast
    %    r = 0.1;                                                          % logistic growth rate benthic community (polychaetes: r = 4, bivalves r = 2).
    %     Ks = 100.;
        K0(1,i)=Ks(k);
        P(1,i)=P0(k);
        tsub=  0;
        for t = 1:nryears
            K0red = 0.;
            P0red = 0.;
            % check if there is a nourishment or anaything else 
            % that reduces the population :
            if (S.PP(sens).GEmapping.supp(t,i)==1)
                isoort=1; 
                P0red = ECO(k).k_beach_nourishment;                        % reduction in pop. size after nourishment is 1%
                K0red = ECO(k).k_beach_nourishment;                        % reduction in CC after nourishment. mega: back to 1%, beach/shoreface back to 50%              
                P(t,i) = P(t,i)*(100-P0red)/100;
                K0(t,i) = K0(t,i)*(100-K0red)/100;
                tsub = t-1;
            end
            if (S.PP(sens).GEmapping.rev(t,i) ==1)
                isoort=2; 
                P0red = ECO(k).k_revetment;                                % reduction in pop. size after nourishment is 1%
                K0red = ECO(k).k_revetment;                                % reduction CC after nourishment. mega: back to 1%, beach/shoreface back to 50%   
                P(t,i) = P(t,i)*(100-P0red)/100;
                K0(t,i) = K0(t,i)*(100-K0red)/100;
                tsub = t-1;
           end

            % reduce population
            e = 0.5;                                                       % epsilon determines recovery time of CC. Beach e = 2, shoreface e = 1, mega e = 0.5.
            s = 1.;                                                        % sigma, where sigma = s = 1 

            % reduce the populations due to the shoreface width change.
            % P(t,i) = ShoreWidthFact(t,i)*P(t,i);
            % K0(t,i) = ShoreWidthFact(t,i)*K0(t,i);

            % Equation 17 in Shepard & Stojkov, 2007: 
            K = Ks/(1+((Ks/K0(1+tsub,i))^s-1)*exp(-s*e*(t-tsub))).^(1/s);

            % Equation 18 of Shepard & Stojkov, 2007:
            %    a = alpha in Eq. 18
            %    b = beta in Eq. 18
            %a = r/(r-e)*((Ks/K0(t,i)).^s-1);
            %b = (K0(t,i)/P0).^s-1;                                        % different from Eq. 18 which is probably wrong. Ks instead of K0 !!
            %P(t+1,i) = Ks./(1+a*exp(-e*s*t)+(b-a)*exp(-r*s*t)).^(1/s);    % time variable pop. size
            P(t+1,i) = (K*P(t,i)*exp(r*(t-tsub)))./(K+P(t,i)*(exp(r*(t-tsub))-1));  

            % time variable pop. size
            K0(t+1,i) = K;
            %plot(t,P(i)); grid on; hold on;
        end
    end
%     P = P(k);
end

S.PP(sens).eco.P = P;
%Ps = the standard, fixed (not time-varying) logistic function for pop. size
%Ps = (Ks*P0*exp(r*t))./(Ks+P0*(exp(r*t)-1));

%% Write to kml
HKtool_eco_to_kml

% %% PLOT THE POPULATION IN TIME
%  figure;
%  plot(1:21,P(1:21,11),'-or');hold on;
%  plot(1:21,K0(1:21,11),'-+g');grid on;

