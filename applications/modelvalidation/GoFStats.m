function STATS = GoFStats(ModelTimePoints, ModelValues, ...
    ObsTime, ObsValues, varargin)
%GoFStats computes 'Goodness of Fit' scores and plots target diagram 
%as explained in Jolliff et al., 2009 [Summary diagrams for coupled
%hydrodynamic-ecosystem model skill assessment, Jason K. Jolliff et al., 
%Journal of Marine Systems 76 (2009) 64-82].
%The statistics are computed for modeled timeseries MODEL assuming that 
%the reference is provided by the in-situ measurements OBS.
%
% STATS = GoFStats(model_times, model_values, obs_times, obs_values, varargin);
%
% varargin:
% 'station' with a cellstring of station names
% 'subset' 0 or 1  (default = 1)
% 'geomean' 0 or 1 (default = 0)
% 'mode' 0, 1, 2 (default = 0)

% If 'subset' is active (=1), compute statistics on the matching samples of both timeseries only; 
% If 'subset'is deactivated, compute statistics on original combined w. interpolated series (default: 'subset' is active).
%
% If 'geomean' =1 , geometric means are used to compute biases (for skewed distributions). 
% NB!remove negative values in the timeseries if relevant i.e. newData.model(newData.model<0)=NaN;
%
% If option 'mode'=1, the mode is estimated using log transformation
% If option 'mode'=2, the mode is estimated using histogram w. 100 bins
% Default 'mode'is inactive (0)

% Example:
% STATS = GoFStats(model_times, model_values, obs_times, obs_values);
%
%  Timeseries data definition:
%   * <a href="https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions">https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions</a> (full definition)
%   * <a href="http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984788">http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984788</a> (simple)
%
%See also: GOFTIMESERIES; GOFPLOT

% $Id: GoFStats.m 7422 2012-10-10 07:46:08Z harezlak $
% $Date: 2012-10-10 15:46:08 +0800 (Wed, 10 Oct 2012) $
% $Author: harezlak $
% $Revision: 7422 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/modelvalidation/GoFStats.m $
% $Keywords: $

%
OPT.geomean= 0;
OPT.mode= 0;
OPT.station = '';
OPT.subset = 1;
OPT = setproperty(OPT, varargin{:});

%% combine timeseries:
%   - missing observations are replaced by NaNs 
%     !NB! NANs affect interp1: so best do interp1 on sets without NaNs 
%   - negative model values are replaced by NaNs
%   - missing model values are interpolated (linearly) in time to obs. times

tmpTime = cat(2, squeeze(ModelTimePoints), squeeze(ObsTime));
[STATS.datenum, idx] = sort(tmpTime);

newData.model = interp1(squeeze(ModelTimePoints), ...
    squeeze(ModelValues), squeeze(ObsTime));       
newData.obs = NaN + zeros(size(squeeze(ModelTimePoints)));
tmpData.model = cat(2, squeeze(ModelValues), squeeze(newData.model));
tmpData.obs = cat(2, squeeze(newData.obs), squeeze(ObsValues));
combined_all.ModelTimePoints = tmpTime(idx);
combined_all.ObsTime = tmpTime(idx);
combined_all.ModelValues = tmpData.model(idx);
combined_all.ObsValues = tmpData.obs(idx);

%% Option: keep only samples that have an matchup between model and observations
% and compute the statistics on this subset
 if (OPT.subset)
    msk = find(~isnan(combined_all.ObsValues.*combined_all.ModelValues));
    combined.ObsValues = combined_all.ObsValues(msk);
    combined.ObsTime = combined_all.ObsTime(msk);
    combined.ModelTimePoints = combined_all.ModelTimePoints(msk);
    combined.ModelValues = combined_all.ModelValues(msk);
 else
 % compute statistics on all samples of both sets: i.e. for the model the original AND interpolated ones
    combined.ModelTimePoints = combined_all.ModelTimePoints;
    combined.ObsTime = combined_all.ObsTime;
    combined.ModelValues = combined_all.ModelValues;
    combined.ObsValues = combined_all.ObsValues;
end

STATS.model_combval = combined.ModelValues;
STATS.model_combtim = combined.ModelTimePoints;
STATS.obs_combval = combined.ObsValues;
STATS.obs_combtim = combined.ObsTime;

%% compute means and stddev of normal distributions
if OPT.geomean
    STATS.model_mean = 10^nanmean(log10(combined.ModelValues)); %geometric mean; can also use 'geomean'
    STATS.model_mean = real(STATS.model_mean);
    STATS.obs_mean = 10^nanmean(log10(combined.ObsValues)); 
    STATS.obs_mean = real(STATS.obs_mean);

% elseif OPT.mode==1
%     STATS.model_mean = mode(combined.ModelValues); 
%     STATS.obs_mean   = mode(combined.ObsValues); 
elseif OPT.mode==1
    STATS.model_mean = 10^nanmean(nanmean(log10(combined.ModelValues))- nanvar(log10(combined.ModelValues))); 
    STATS.obs_mean = 10^nanmean(nanmean(log10(combined.ObsValues))- nanvar(log10(combined.ObsValues))); 
elseif OPT.mode==2
    [nbin bin] = hist(combined.ModelValues,100);
    STATS.model_mean = nanmean(bin(find(nbin==max(nbin)))); 
    [nbin bin] = hist(combined.ObsValues,100);
    STATS.obs_mean = nanmean(bin(find(nbin==max(nbin)))); 
else   
    STATS.model_mean = nanmean(combined.ModelValues);
    STATS.obs_mean = nanmean(combined.ObsValues);
end

STATS.model_stddev = nanstd(combined.ModelValues);
STATS.obs_stddev = nanstd(combined.ObsValues);
%% compute residuals w.r.t. selected mean
STATS.model_res = combined.ModelValues - STATS.model_mean;
STATS.obs_res = combined.ObsValues - STATS.obs_mean;
%% compute various statistics & cost functions

% number of records
STATS.n = length(combined.ModelValues); 

% correlation coefficient
STATS.R = nanmean(STATS.model_res.*STATS.obs_res)/ ...
    (STATS.model_stddev.*STATS.obs_stddev);

% normalized standard deviation
STATS.normalized_stddev = STATS.model_stddev/STATS.obs_stddev; 

% total RMS difference
STATS.RMSD = sqrt(nanmean((STATS.model_combval-STATS.obs_combval).^2));

% bias
STATS.bias = STATS.model_mean - STATS.obs_mean;

% unbiased RMS difference
STATS.unbiased_RMSD = sqrt(STATS.RMSD^2 - STATS.bias^2);
% STATS.unbiased_RMSD =sqrt(nanmean((STATS.model_res-STATS.obs_res).^2)) 
% Both are equivalent for arith.mean, but first version is less skewed/more robust for geomean & mode;

% normalized bias
STATS.normalized_bias = STATS.bias/STATS.obs_stddev;

% normalized unbiased RMS difference
%STATS.normalized_unbiased_RMSD = sqrt(1. + ...
%    STATS.normalized_stddev^2 - 2.*STATS.normalized_stddev*STATS.R);
STATS.normalized_unbiased_RMSD = STATS.unbiased_RMSD/STATS.obs_stddev;

% (normalized) unbiased absolute difference
STATS.unbiased_ABSD = nanmean(abs(STATS.model_res-STATS.obs_res));
STATS.normalized_unbiased_ABSD = STATS.unbiased_ABSD/STATS.obs_stddev;

% Nash Sutcliffe model efficiency
STATS.model_efficiency = 1.0 - ...
    nansum((combined.ModelValues-combined.ObsValues).^2)/ ...
    nansum(STATS.model_res.^2);

% Taylor skill score
STATS.skill_score = 1.0 - ((1.0+STATS.R)/2.)* ...
    exp(-(STATS.normalized_stddev-1)^2/0.18);

%OSPAR cost function (normalized mean abs error)
STATS.CF = nanmean(abs(combined.ModelValues - combined.ObsValues))./ ...
    STATS.model_stddev;

%% Compute coordinates for the target diagrams
% STATS.model.GoF = [STATS.RMScp]*sign([STATS.model.stddev] - ...
%     [STATS.obs.stddev])./[STATS.obs.stddev];
STATS.xTarget = sign(STATS.model_stddev-STATS.obs_stddev)*...
    STATS.normalized_unbiased_RMSD;
STATS.yTarget = STATS.normalized_bias;
%%STATS.model_name = model.name;
STATS.obs_name = OPT.station;

return;
end
