P1 = [];P2 = [];P3 = [];Pexact = [];K0 = [];

nryears       = 50;                                     % dirty way to get the time length (tend - t0)
r             = 15.3;                                      % logistic growth rate benthic community (polychaetes: r = 4, bivalves r = 2).
epsval        = 1;                                      % epsilon determines recovery time of CC. Beach e = 2, shoreface e = 1, mega e = 0.5.
s             = 1.;                                     % sigma, where sigma = s = 1 
ii            = 1;                                      % nr. of coastline sections (i.e. grid cells) along the Holland coast
Ks            = 0.03;                                    % default carrying capacity (CC) of the system
P0            = 0.03;                                    % in initial population (used as reference only)
dt            = 1;
tsub          = 0;

% set initial values
K0(ii,1)      = Ks;                                     % set initial carrying capacity (CC0)
Pexact(ii,1)  = P0;
P1(ii,1)      = P0;                                     % set initial population (P0)
P2(ii,1)      = P0;
P3(ii,1)      = P0;
time          = [0:dt:nryears];
IDsub         = find(abs(time-tsub)==min(abs(time-tsub)));
        
for tt = 1:length(time)-1           % timeframe of simulation
    K0red = 0.;
    P0red = 0.;

    % check if there is a nourishment (or construction)
    % which reduces the population and carrying capacity
    if  tt==IDsub
        P0red = 50;                % reduction in pop. size after nourishment is 1%
        K0red = 50;                % reduction in CC after nourishment (e.g. mega: back to 5%, beach/shoreface back to 50%)
        P1(ii,tt)     = P1(ii,tt)*(100-P0red)/100;
        K0(ii,tt)     = K0(ii,tt)*(100-K0red)/100;
        tsub          = time(tt);
        ttsub         = tt;
        P2(ii,tt)     = P1(ii,tt);
        P3(ii,tt)     = P1(ii,tt);
        Pexact(ii,tt) = P1(ii,tt);
    end

    % Equation 17 in Shepard & Stojkov, 2007: 
    K = Ks/(1+((Ks/K0(ii,ttsub))^s-1)*exp(-s*epsval*(time(tt+1)-tsub))).^(1/s);% compute carrying capacity in next timestep

    % Equation 18 of Shepard & Stojkov, 2007:
    %    a = alpha in Eq. 18
    %    b = beta in Eq. 18

    % exact solution
    a          = r/(r-epsval)*((Ks/K0(ii,1)).^s-1);
    b          = (Ks/Pexact(ii,1)).^s-1;                                     % different from Eq. 18 which is probably wrong. Ks instead of K0 !!
    Pexact(ii,tt+1) = Ks./(1+a*exp(-epsval*s*(time(tt+1)-tsub))+(b-a)*exp(-r*s*(time(tt+1)-tsub))).^(1/s);% time variable pop. size

    % exact solution (discrete)
    a          = r/(r-epsval)*((Ks/K0(ii,tt))^s-1);
    b          = (Ks/P1(ii,tt))^s-1;                                % different from Eq. 18 which is probably wrong. Ks instead of K0 !!
    P1(ii,tt+1) = Ks/(1+a*exp(-epsval*s*dt)+(b-a)*exp(-r*s*dt))^(1/s);   % time variable pop. size

    % approximation 1
    P2(ii,tt+1) = (K*P2(ii,tt)*exp(r*(time(tt+1)-tsub))) ...
                 ./ (K+P2(ii,tt)*(exp(r*(time(tt+1)-tsub))-1));             % compute population in next time step
    % approximation 2
    P3(ii,tt+1) = P3(ii,tt)+r*P3(ii,tt)*(1-P3(ii,tt)/mean([K,K0(ii,tt)]))*dt;

    % time variable pop. size
    K0(ii,tt+1) = K;
end

% PRINT OUTPUT
Tindex = length(time);Tindex=20;
fprintf('    TIME      Pexact    Pexact2    P,approx1  P,approx2 \n');
fprintf('%9.2f  %9.3f  %9.3f  %9.3f  %9.3f\n',[time(1:Tindex)',Pexact(1:Tindex)',P1(1:Tindex)',P2(1:Tindex)',P3(1:Tindex)']');