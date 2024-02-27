function [rmax,dr35] = wind_radii_nederhoff(vmax,lat,region, probability)
% Function calculates RMW and R35 including RMSE needed for probablistic
% forecasting of tropical cyclones
% v1.0  Nederhoff   Jan-17
% v1.1  Nederhoff   Feb-17
% v1.2  Nederhoff   Jun-17
% v1.3  Nederhoff   Aug-18
% v1.4  Nederhoff   Mar-19
% v1.5  Nederhoff   Sep-20
% URL: https://nhess.copernicus.org/articles/19/2359/2019/

%% Input
% vmax in m/s, 10 meter height and 1-minute averaged
% lat in degrees
% region, see below
% probablity if 1 script will generate 1000 realisations

%% Idea: lognormal distributions for RMW and delta R35 based on curve fitting of the coefficients determing their shape
% A-value is used for the standard deviation.
% B-value is used for the median

%% Area definitions                     METHOD 1 (-360 TO 0)                    METHOD 2 (-180 TO +180)
% region 0: North Indian Ocean          (x<-260) & (y > 0);
% region 1: South West Indian Ocean     (x<-270) & (y < 0)
% region 2: South East Indian Ocean	    (x>-270) & (x<-225) & (y < 0);
% region 3: South Pacific Ocean'        (x>-225) & (AL < 0) & (y < 0);
% region 4: North West Pacific Ocean    (x>-260) & (x<-180) & (y > 0);
% region 5: North East Pacific Ocean    (x>-180) & (AL < 0) & (y > 0);
% region 6: Atlantic Ocean              (x>-140) & (AL> 0) & (y>0)
% region 7: all data points

%% Area definitions                     METHOD 2 (-180 TO +180)
% region 0: North Indian Ocean          (x > 0) & (x<+100) & (y > 0);
% region 1: South West Indian Ocean     (x > 0) & (x<+90)  & (y < 0)
% region 2: South East Indian Ocean	    (x>+90) & (x+135) & (y < 0);
% region 3: South Pacific Ocean'        ( (x>+135) | (x < 0) ) & (y < 0);
% region 4: North West Pacific Ocean    (x<+100) & (x>0) & (y > 0);
% region 5: North East Pacific Ocean    (AL < 0) & (x<0) &  & (y > 0);
% region 6: Atlantic Ocean              (AL > 0)
% region 7: all data points

%% Radius of maximum winds (RMW or Rmax)
% 1. Coefficients for A
coefficients_a = [0.30698254
    0.338409237
    0.34279145
    0.36354649
    0.358572938
    0.310729085
    0.395431764
    0.370190027];

% 2. Coefficients for B
coefficients_b = [132.4119062	14.56403797	-0.002597033	20.38080365
    229.2458441	9.538650691	0.003988105	28.44573672
    85.25766551	30.69208726	0.00243248	5.781165406
    127.8333007	11.84747574	0.015936312	25.46820005
    153.7332947	11.47888854	0.007471193	28.94897887
    261.5288742	7.011517854	0.026191256	29.20227871
    19.08992428	24.08855731	0.10624034	23.18020146
    44.82417433	23.37171288	0.030469057	22.42820361];

% 3. Get the best guess for a and b given wind speed and latitude
a_value = ones(1,length(vmax))*coefficients_a(region+1);
b_value = coefficients_b(region+1, 1) *  exp(-vmax/coefficients_b(region+1, 2)).* (1 + coefficients_b(region+1, 3)*abs(lat)) + coefficients_b(region+1, 4);

% 4. Compute 1000 delta R35 values
for ii = 1:length(a_value)
    rmax.mode(ii)               = exp(log(b_value(ii)) - a_value(ii).^2);
    if probability == 1
        numbers                     = sort(exp(randn(100000,1).*a_value(ii)+log(b_value(ii))));  % lognormal distribution
        rmax.mean(ii)               = mean(numbers);
        rmax.mean(ii)               = exp(log(b_value(ii)) + (a_value(ii).^2)/2);
        rmax.median(ii)             = median(numbers);
        rmax.median(ii)             = b_value(ii);
        rmax.lowest(ii)             = numbers(0.05*length(numbers));
        rmax.highest(ii)            = numbers(0.95*length(numbers));
        rmax.numbers                = sort(numbers);
    end
end

%% Delta radius of 35 knots (R35)
% 1. Coefficients for A
coefficients_a = [0.121563729	-0.052184289	0.032953813
    0.131188105	-0.044389473	0.002253258
    0.122286754	-0.045355772	0.013286154
    0.120490659	-0.035029431	-0.005249445
    0.156059522	-0.041685377	0.004952978
    -0.251333213	-0.009072243	-0.00506365
    0.131903526	-0.042096876	0.012443195
    0.190044585	-0.044602083	0.006117124];

% 2. Coefficients for B
coefficients_b = [30.92867473	0.530681714	-0.012001645
    30.21210133	0.414897465	0.021689596
    26.58686237	0.425916004	0.028547278
    23.88007085	0.43109144	0.038119083
    33.26829485	0.42859578	0.017209431
    18.11013691	0.486399912	0.02955688
    16.9973011	0.453713419	0.054643743
    29.61141102	0.4132484	0.024418947];

% 3. Get the best guess for a and b given wind speed and latitude
a_value = coefficients_a(region+1, 1) +  exp(vmax * coefficients_a(region+1, 2)) .* (1 + coefficients_a(region+1, 3)* abs(lat));
b_value = coefficients_b(region+1, 1) .*  (vmax-18).^coefficients_b(region+1, 2) .* (1 + coefficients_b(region+1, 3)* abs(lat));

% 4. Compute 1000 delta R35 values
for ii = 1:length(a_value)
    if vmax > 20
        dr35.mode(ii)               = exp(log(b_value(ii)) - a_value(ii).^2);
        if probability == 1
            numbers                      = sort(exp(randn(100000,1).*a_value(ii)+log(b_value(ii))));  % lognormal distribution
            dr35.mean(ii)                = exp(log(b_value(ii)) + (a_value(ii).^2)/2);
            dr35.median(ii)              = b_value(ii);
            dr35.lowest(ii)              = numbers(0.05*length(numbers));
            dr35.highest(ii)             = numbers(0.95*length(numbers));
            dr35.numbers                 = sort(numbers);
        end
    else
        dr35.mode(ii)               = NaN;
    end
end
end

