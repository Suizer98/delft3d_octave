%% Frequencies of Exceedance
%
% This tutorial shows the possibilities of the stat_freqexc_* function in
% the statistic toolbox. These functions determine the frequency of
% exceedance from a given time series. As an example, the output from a
% SOBEK model is used as time series and a frequency of exceedance line
% useful for the Hydra models is determined.

%% Read SOBEK data
%
% First read a timeseries from a SOBEK model:

his = sobek_his_read('CALCPNT.HIS');

%% Filter SOBEK data
%
% As an example, we are only interested in winter periods. Mask all other
% values in the time series before starting the analysis:

[t x] = stat_freqexc_mask(his.time, squeeze(his.data(:,1,1)), {'mm' [1 2 3 10 11 12]});

% shift time axis to fit hydrological year (starts at October 1st)
t = t+92;

%% Determine maxima
%
% Count maxima in time series that exceed different thresholds, thus
% creating a description of the frequency of exceedance line. Consider
% maxima that differ less than 25 days as a single maximum:

res = stat_freqexc_get(t, x, 'horizon', 25);

% Now, plot the result:

stat_freqexc_plot(res);

%% Filter maxima
%
% Now we have collected for many thresholds all the maxima. For an extreme
% value analysis we only need a single threshold and the maxima for each
% year. We can select this data from the just obtained result:

res = stat_freqexc_filter(res, 'mask', 'yyyy');

% Again, plot the result with the very same function:

stat_freqexc_plot(res);

%% Fit maxima
%
% The empirical data only contains low frequency values. In order to obtain
% a full description of the frequency of exceedance, we need to extrapolate
% these values to low frequencies. We use several probability distributions
% to do so and use the averaged result:

res = stat_freqexc_fit(res);

% And again, plot the result:

stat_freqexc_plot(res);

%% Combine empirical and fitted data
%
% Now we have an empiricial, high frequency and a fitted, low frequency
% description of the frequency of exceedance. We would like to combine both
% to a single description for specified frequencies:

res = stat_freqexc_combine(res, 'f', 1./[.3 .5 1 5 1e2 1e3 1e4 1e5]);

% It is time to plot the final result:

stat_freqexc_plot(res);

%% Plot on logarithmic scale
%
% As you might see, the low frequency data is not very well presented in
% the plots above. In order to obtain a better view on the result, plot it
% on logarithmic scale:

stat_freqexc_logplot(res);

%% Plot duration of peaks
%
% Plot the average duration of a peak given the threshold of exceedance:

stat_freqexc_plotduration(res);

%% Write Hydra input
%
% Write the combined frequency of exceedance line now to a text file that
% can be used with the Hydra models, like Hydra-Zoet:

stat_freqexc_writehydra(res);