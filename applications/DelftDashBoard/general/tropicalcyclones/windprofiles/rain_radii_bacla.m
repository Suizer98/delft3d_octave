function [pmax_out,pr] = rain_radii_bacla(meas_vmax, rmax, radius, probability, tp)
% Function to calculate pmax (maximum rainfall intensity)
% and the radial distribution of the rain (pr)
% Input meas_vmax in m/s and 10 minute averaged or the pressure deficit in
% hPa
% Input rmax and radius in km
% Probability is 0, means you will get the most probably pmax and pr
% Probability is 1, means you will get a 1,000 random realisations
% Probability is 2, means you will get the pmax and pr based on user defined percentile
% tp.data = 1 : GPM/TRMM data trained model
% tp.data = 2 : Stage IV blend data trained model
% tp.split = 1: no split
% tp.split = 2 : simple split
% tp.split = 3: xn forced to get pmax, bsfit
% tp.split = 4: xn forced to get pmax fit, bs based on area under graph
% tp.type = 1 : vmax based model
% tp.type = 2 : pdef based model
% tp.loc = 1 : ocean fit (classic Holland)
% tp.loc = 2 : land fit (constant pmax till rmax as in IPET, after rmax classic holland fit)
% tp.perc = 50: requested specific percentile

if ~isfield(tp,'perc') && probability == 2
   tp.perc = 50; %if not provided
end


%% 0. Coefficients of copula's (needed for pmax)
n  = 1000;            % number of samples

if tp.data == 1 %GPM/TRMM data trained model
    pmax.sigma =  0.8736;
    pmax.mu= 1.6635;
    if tp.type == 1 %vmax based model
        frank_theta =  6.7551;
        vmax.labda = 147.8526;
        vmax.mu = 30.1971;
        vmax.type = tp.type; 
        pmax_samples  = copula3(meas_vmax, frank_theta, n, vmax, pmax, tp);
    elseif tp.type == 2 %pdef based model
        frank_theta =  4.1927;
        pdef.beta =     14.8101;
        pdef.gamma = 1.0405;
        pdef.type = tp.type;
        pmax_samples  = copula3(meas_vmax, frank_theta, n, pdef, pmax, tp);
    end
    
elseif tp.data == 2 %Stage IV blend data trained model
    pmax.sigma =  0.8672;
    pmax.mu=  1.6754;
    if tp.type == 1 %vmax based model
        frank_theta =   6.7452;
        vmax.labda = 146.6439;
        vmax.mu = 30.1223;
        vmax.type = tp.type;
        pmax_samples  = copula3(meas_vmax, frank_theta, n, vmax, pmax, tp);
    elseif tp.type == 2 %pdef based model
        gaussian_theta =    0.6368;
        pdef.beta =      14.8182;
        pdef.gamma = 1.0385;
        pdef.type = tp.type;
        pmax_samples  = copula3(meas_vmax, gaussian_theta, n, pdef, pmax, tp);
    end

end


% assess samples
values      = sort(pmax_samples);
median50    = values(round(length(values) * 0.50));
perc   = values(round(length(values) * tp.perc / 100));

if probability == 1
    pmax_out = pmax_samples;
    disp('NOTE: using the BaCla rainfall model with random = 1 might be relatively slow to generate all fits')    
elseif probability == 2
    pmax_out = perc;
else
    pmax_out = median50;          
end

%% 2. Fit on distribution 
% Fit with radius according to Holland, 2010
inp.pmax    = pmax_out;
[id1, id2] = size(radius);
if id1 == 1
    inp.radius  = radius';
else
    inp.radius  = radius;
end
inp.rmax    = rmax;

pr = fitsample(tp, inp, pmax_out);

end

%% Subfunction Frank and Gaussian Copula

function pmax_samples = copula3(vmax_input, theta, n, vmax, pmax, tp)
% vmax_input    = maximum sustained wind speed in [m/s]
% theta   = the copula parameter value
% n             = number of samples
% vmax          = the list of marginal distribution parameters for vmax or
% pdef
% pmax          = the list of marginal distribution parameters for pmax



if vmax.type == 1 %Frank Copula
    %pdIG = makedist('InverseGaussian',vmax.mu,vmax.labda);
    %u(1,1:n) =  cdf(pdIG, vmax_input);
    u(1,1:n) = invgaudist_cdf(vmax_input, vmax);
elseif vmax.type == 2
    %pdIG = makedist('BirnbaumSaunders',vmax.beta,vmax.gamma);
    %u(1,1:n) =  cdf(pdIG, vmax_input);
      u(1,1:n) = birnsdist_cdf(vmax_input, vmax);
end

if vmax.type == 2 &  tp.data == 2 %Gaussian Copula 
    %x1=norminv(u);
    %x2=norminv(rand(1,n));
    x1=invnorm(u);
    x2=invnorm(rand(1,n));

    X = [x1; x2];

    C = [1, theta; theta,1]; %2x2 Correlation matrix

    cholesky = chol(C,'lower'); %lower triangular matrix of C using Cholesky decomposition

    Copsims = cholesky*X;

    
    v = Copsims(2,:);
    %v = normcdf(v);
    v = cdfnorm(v);
else
    y = rand(1,n);

% use the formula for conditional sampling of a frank copula to produce a
% list of n maximum rainfall intensity values within the copula dataspace
    v = -(1./theta).* log( 1 + (y.*(exp(-theta) - 1)) ./ (exp(-theta.*u) - y.*(exp(-theta.*u) - 1)));
end
% convert the acquired samples back to its original dataspace with the
% given marginal distribution parameters for pmax. 
%pmax_samples = icdf('Lognormal', v, pmax.mu, pmax.sigma);
pmax_samples = icdf_logn(v, pmax);
end


%% 

function pr_save = fitsample(tp, inp, pmax_sample)
 for ii = 1:length(pmax_sample)
     %disp(['fit ',num2str(ii) ,' of: ', num2str(length(pmax_sample))])
     inp.pmax    = pmax_sample(ii);
     
     if tp.data == 1 %GPM/TRMM data trained model
         
         if tp.split == 1 % no split
             bs          = 2.204.* pmax_sample(ii).^-0.231; 
             xn          = 0.788.*pmax_sample(ii).^0.216; 
             betaA       = [xn bs];
             
         elseif tp.split == 2 % simple split
             if pmax_sample(ii) > 5
                 bs          = 0.807.*pmax_sample(ii).^0.165; 
                 xn          = 1.842.*pmax_sample(ii).^-0.104; 
                 betaA       = [xn bs];
             else
                 bs          = 2.220.* pmax_sample(ii).^-0.136; 
                 xn          = 0.373.*pmax_sample(ii).^0.750; 
                 betaA       = [xn bs];
             end
             
         elseif tp.split == 3 % xn forced to get pmax, bsfit
             if pmax_sample(ii) >= 2.8
                 xn = log(inp.pmax)/log(inp.pmax/exp(1));
                 bs          = 0.771.* pmax_sample(ii).^0.309;      
                 betaA       = [xn bs];
             else
                 bs          = 0; 
                 t = pmax_sample(ii)/exp(1);
                 xn = log(pmax_sample(ii))/log(t);
                 betaA       = [xn bs];
             end
             
         elseif tp.split ==4 % xn forced to get pmax fit, bs based on area under graph
             if pmax_sample(ii) >= 2.8
                bsi = 2 .* rand(1000,1);
                xn = log(inp.pmax)/log(inp.pmax/exp(1));
                area = 13.208 + (19.101 * log(inp.pmax)) +  (19.101 * (log(inp.pmax)^2));
                Ai = [];
                for i = 1:length(bsi)
                     betaA       = [xn bsi(i)];
                     pr_computed = aafit(betaA,inp);
                     areai = trapz(pr_computed);
                     Ai = [Ai;areai];
                end
                dif = abs(Ai - area);
                [I, D] = min(dif);
                betaA       = [xn bsi(D)];
                else
                    bs          = 0; 
                    t = pmax_sample(ii)/exp(1);
                    xn = log(pmax_sample(ii))/log(t);
                    betaA       = [xn bs];
                end
         end
         
     elseif tp.data == 2 % Stage IV data trained model
         
         if tp.split == 1 % no split
             bs          = 2.275.* pmax_sample(ii).^-0.252; 
             xn          = 0.777.*pmax_sample(ii).^0.228; 
             betaA       = [xn bs];
             
         elseif tp.split == 2 % simple split
             if pmax_sample(ii) > 5
                 bs          = 0.796.*pmax_sample(ii).^0.166; 
                 xn          = 1.873.*pmax_sample(ii).^-0.105; 
                 betaA       = [xn bs];
             else
                 bs          = 2.305.* pmax_sample(ii).^-0.167;
                 xn          = 0.330.*pmax_sample(ii).^0.859; 
                 betaA       = [xn bs];
             end
             
         elseif tp.split == 3 % xn forced to get pmax, bsfit
             if pmax_sample(ii) >= 2.8
                 xn = log(inp.pmax)/log(inp.pmax/exp(1));
                 bs          = 0.802.* pmax_sample(ii).^0.300;     
                 betaA       = [xn bs];
             else
                 bs          = 0;
                 t = pmax_sample(ii)/exp(1);
                 xn = log(pmax_sample(ii))/log(t);
                 betaA       = [xn bs];
             end
             
         elseif tp.split == 4 %xn forced to get pmax fit, bs based on area under graph
             if pmax_sample(ii) >= 2.8
                bsi = 2 .* rand(1000,1);
                xn = log(inp.pmax)/log(inp.pmax/exp(1));
                area = 13.414 + (18.452 * log(inp.pmax)) +  (11.083* (log(inp.pmax)^2));
                Ai = [];
                for i = 1:length(bsi)
                    betaA       = [xn bsi(i)];
                    pr_computed = aafit(betaA,inp);
                    areai = trapz(pr_computed);
                    Ai = [Ai;areai];
                end
                dif = abs(Ai - area);
                [I, D] = min(dif);
                betaA       = [xn bsi(D)];
                else
                    bs          = 0; 
                    t = pmax_sample(ii)/exp(1);
                    xn = log(pmax_sample(ii))/log(t);
                    betaA       = [xn bs];
                end
         end
     end
     
     pr_computed = aafit(betaA,inp);
     
     if tp.loc == 2;
         m = abs(inp.radius - inp.rmax);
         [B, id] = min(m);
         pr_computed(1:id) = max(pr_computed);
     end
     
     pr_save(:,ii) = pr_computed;
     
 end
 
end

%%

function pr=aafit(beta,inp)

% Coefficients
a   = beta(1);  % similar to the Holland x parameters
b   = beta(2);  % similar to the Holland B parameter

% Rainfall in which we assume maximum rainfall
% occurs at the location of the maximum winds speed. Correct?
pr = ((inp.pmax*(inp.rmax./inp.radius).^b)./(exp((inp.rmax./inp.radius).^b))).^a;
end

%%
function phicdf = cdfnorm(vmax_input) % cdf for standard normal

phicdf = 0.5 * (1 + erf((vmax_input)/(sqrt(2))));
end

%%
function ino =  invnorm(y) %  inverse cdf for standard normal

ino = (erfinv((2*y) -1 ) * (sqrt(2))) ;
end

%%
function v_sample = invgaudist_cdf(vmax_input, vmax) % cdf of inverse gaussian
x1 = (sqrt(vmax.labda/vmax_input)*((vmax_input/vmax.mu)-1));
x2 = (-sqrt(vmax.labda/vmax_input)*((vmax_input/vmax.mu)+1));
v_sample = 0.5 * (1 + erf((x1)/(sqrt(2)))) + (exp((2*vmax.labda)/vmax.mu) * 0.5 * (1 + erf((x2)/(sqrt(2)))) );
end

%%
function pdef_sample = birnsdist_cdf(pdef_input, pdef) % cdf of BirnbaumSaunders

x1 = ((1/pdef.gamma)*(sqrt(pdef_input/pdef.beta) - sqrt(pdef.beta/pdef_input)));

pdef_sample = 0.5 * (1 + erf((x1)/(sqrt(2))));
end

%%

function pmax_sample = icdf_logn(v, pmax) % inverse cdf of lognormal

pmax_sample = exp((((sqrt(2)*pmax.sigma))*erfinv(2*(v-0.5)))+pmax.mu);

end