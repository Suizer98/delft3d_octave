%% create stochast

stochast = struct();

% water level
stochast(1).Name   = 'MWL';
stochast(1).Distr  = @deterministic;
stochast(1).Params = {0};

% wave height
stochast(2).Name   = 'H';
stochast(2).Distr  = @norm_inv;
stochast(2).Params = {3 2};

% wave period
stochast(3).Name   = 'T';
stochast(3).Distr  = @norm_inv;
stochast(3).Params = {6 2};

% crest height
stochast(4).Name   = 'h_crest';
stochast(4).Distr  = @deterministic;
stochast(4).Params = {10};

% slope
stochast(5).Name   = 'tanalpha';
stochast(5).Distr  = @deterministic;
stochast(5).Params = {1/4};

%% create importance sampling structure

is = struct();

is(1).Name         = 'H';
is(1).Method       = @prob_is_uniform;
is(1).Params       = {0 6};

is(2).Name         = 'T';
is(2).Method       = @prob_is_uniform;
is(2).Params       = {0 8};

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
    'NrSamples',    3e4,       ...
    'stochast',     stochast);

plotMCResult(M);

%% run Directional Sampling computation

D = DS( ...
    'x2zFunction',  zFunction, ...
    'ARS',          false, ...
    'z20Function',  @find_zero_poly2, ...
    'z20Variables', {'animate' true 'verbose' true}, ...
    'stochast',     stochast, ...
    'animate',      true);

%% run Monte Carlo computation with IS

M = MC( ...
    'x2zFunction',  zFunction, ...
    'NrSamples',    3e4,       ...
    'IS',           is,        ...
    'stochast',     stochast);

plotMCResult(M);
