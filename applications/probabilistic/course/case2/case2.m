%% create stochast

stochast = struct();

% water level
stochast(1).Name   = 'MWL';
stochast(1).Distr  = @exp_inv;
stochast(1).Params = {.5 1};

% wave height
stochast(2).Name   = 'H';
stochast(2).Distr  = @norm_inv;
stochast(2).Params = {3 1};

% wave period
stochast(3).Name   = 'T';
stochast(3).Distr  = @norm_inv;
stochast(3).Params = {6 2};

% crest height
stochast(4).Name   = 'h_crest';
stochast(4).Distr  = @deterministic;
stochast(4).Params = {5};

% slope
stochast(5).Name   = 'tanalpha';
stochast(5).Distr  = @deterministic;
stochast(5).Params = {1/3};

%% create z-function

zFunction   = @x2z_HuntsFormula;

%% run FORM computation

F = FORM( ...
    'x2zFunction',  zFunction, ...
    'stochast',     stochast);

plotFORMresult(F);

%% run Monte Carlo computation

M = MC( ...
    'x2zFunction',  zFunction, ...
    'NrSamples',    1e4,       ...
    'stochast',     stochast);

plotMCResult(M);