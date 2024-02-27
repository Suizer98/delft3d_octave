%% create stochast

stochast = struct();

% water level
stochast(1).Name   = 'MWL';
stochast(1).Distr  = @exp_inv;
stochast(1).Params = {4 1};

% wave height
stochast(2).Name   = 'H';
stochast(2).Distr  = @norm_inv;
stochast(2).Params = {1 2};

% wave period
stochast(3).Name   = 'T';
stochast(3).Distr  = @norm_inv;
stochast(3).Params = {6 2};

% crest height
stochast(4).Name   = 'h_crest';
stochast(4).Distr  = @deterministic;
stochast(4).Params = {7};

% slope
stochast(5).Name   = 'tanalpha';
stochast(5).Distr  = @deterministic;
stochast(5).Params = {1/3};

% critical water level for geotechnical stability
stochast(6).Name   = 'h_critical';
stochast(6).Distr  = @norm_inv;
stochast(6).Params = {2 .1};


%% create z-function

zFunction1   = @x2z_HuntsFormula1;
zFunction2   = @x2z_WaveOvertopping1;

%% run FORM computation

F1 = FORM( ...
    'x2zFunction',  zFunction1, ...
    'stochast',     stochast);

plotFORMresult(F1);

F2 = FORM( ...
    'x2zFunction',  zFunction2, ...
    'stochast',     stochast);

plotFORMresult(F2);

%% run Monte Carlo computation

M1 = MC( ...
    'x2zFunction',  zFunction1, ...
    'NrSamples',    1e4,       ...
    'stochast',     stochast);

%plotMCResult(M1);

M2 = MC( ...
    'x2zFunction',  zFunction2, ...
    'NrSamples',    1e4,       ...
    'stochast',     stochast);

%plotMCResult(M2);

%% results:

beta1=F1.Output.Beta
beta1=M1.Output.Beta
alphas1=F1.Output.alpha

beta2=F2.Output.Beta
beta2=M2.Output.Beta
alphas2=F2.Output.alpha

%% combined

alphasIn=[alphas1; alphas2];
betasIn=[beta1; beta2];
rhos=ones(size(alphasIn,2),1)';

[alphasAND, betasAND, alphasOR, betasOR] = CombinedProbability(alphasIn,...
      betasIn, rhos, 'FORM') ;
  
[alphasAND, betasAND, alphasOR, betasOR] = CombinedProbability(alphasIn,...
      betasIn, rhos, 'Numerical') ;
  
[alphasAND, betasAND, alphasOR, betasOR] = CombinedProbability(alphasIn,...
      betasIn, rhos) ;