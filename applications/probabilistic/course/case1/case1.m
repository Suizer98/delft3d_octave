close all;

%% create stochast

stochast = struct();

% resistance
stochast(1).Name   = 'R';
stochast(1).Distr  = @norm_inv;
stochast(1).Params = {9 2};

% sollicitation
stochast(2).Name   = 'S';
stochast(2).Distr  = @norm_inv;
stochast(2).Params = {6 4};

%% run FORM computation

F = FORM( ...
    'x2zFunction',  @x2z, ...
    'stochast',     stochast);

plotFORMresult(F);

%% run Monte Carlo computation

M = MC( ...
    'x2zFunction',  @x2z,      ...
    'NrSamples',    1e4,       ...
    'stochast',     stochast);

plotMCResult(M);

%% plot histograms

figure;

s = [];
xlim = [-10 15];
x = linspace(xlim(1), xlim(2), round(diff(xlim)*1.5));

% plot R
s(1) = subplot(3,1,1);
hist(M.Output.x(:,1), x);
title(M.Input(1).Name);

% plot S
s(2) = subplot(3,1,2);
hist(M.Output.x(:,2), x);
title(M.Input(2).Name);

% plot Z (= R - S)
s(3) = subplot(3,1,3);
hist(M.Output.z, x);
title('Z');

% align x-axes
linkaxes(s, 'x')
set(s,'XLim',xlim);