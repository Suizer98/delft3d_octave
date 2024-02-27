function structOut = delwaq_target(File1,File2,SubstanceName,Type,Tinter)
%DELWAQ_TARGET Read Delwaq files and write a Difference file.
%
%   STRUCTOUT = DELWAQ_TARGET(FILE1,FILE2,FILE2SAVE,SUBSTANCENAME,SUBSTANCENAME,TYPE)
%   Reads FILE1 and FILE2, find the matchig fields:
%   substances/segments/stations in both files and write the statistics to
%   plot a target diagram
%
%   STRUCTOUT = DELWAQ_TARGET(...,SUBSTANCESNAME,...) specifies substances to
%   be used. SUBSTANCESNAME = 0 for all substances.      
%
%   STRUCTOUT = DELWAQ_TARGET(...,TYPE) specifies alternate methods.  
%   The default is 'none'.  Available methods are:
%  
%       'none'    - Difference: File1-File2
%       'log'     - stat of natural logarithm: log(File1)-log(File2)
%       'log10'   - Difference of base 10 logarithm: log10(File1)-log10(File2)
%       'log_a'   - stat of natural logarithm: log(File1)-log(File2)
%       'log10_a' - Difference of base 10 logarithm: log10(File1)-log10(File2)
%       'fwf'  - For Salinity: Fresh water fraccion

% 
%   See also: DELWAQ, DELWAQ_CONC, DELWAQ_RES, DELWAQ_TIME, DELWAQ_STAT, 
%             DELWAQ_INTERSECT

%   Copyright 2011 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   2011-Jul-12 Created by Gaytan-Aguilar
%   email: sandra.gaytan@deltares.com
%--------------------------------------------------------------------------

if nargin<4
    Type = 'none';
end
if nargin<5
    Tinter = 0;
end
if nargin<3
   error('The name of the substance is not provided');
elseif nargin>=3 && iscell(SubstanceName) && length(SubstanceName)>1
   SubstanceName = SubstanceName{1};
   warning('Too many substances, only the first substance will be used') %#ok<*WNTAG>
end
SegmentsNames = 0;

S = delwaq_intersect(File1,File2);

% Matching SubsName and SegmentsNames
S = delwaq_match(S,SubstanceName,SegmentsNames);


if isempty(S.Subs)
   disp('There is any match in the substance name');
   return 
end

if isempty(S.Segm)
   disp('There is any match in the substance name');
   return 
end


% Opening Files
struct1 = delwaq('open',File1);
struct2 = delwaq('open',File2);
k = 0;

switch S.extId
    case 'map'
    disp('Not yet implemented for map files')

   case 'his'
       
    for iseg = 1:S.nSegm
        disp(['delwaq_target progress: ' num2str(iseg) '/' num2str(S.nSegm)])

        [time1, data1] = delwaq('read',struct1,S.iSubs{1}(1),S.iSegm{1}(iseg),0);
        [time2, data2] = delwaq('read',struct2,S.iSubs{2}(1),S.iSegm{2}(iseg),0);
        inot1 = isnan(data1);
        time1(inot1) = [];
        data1(inot1) = [];
           
        inot2 = isnan(data2);
        time2(inot2) = [];
        data2(inot2) = [];
            
        if Tinter~=0
           [it1 it2]  = time_near(time1,time2,Tinter);
           time1 = time1(it1);
           time2 = time1;
           data1 = data1(it1);
           data2 = data2(it2);
        end
            
        % Target diagram information
        if length(time1)>2
           k = k+1;
           structOut(k).subsName = S.Subs{1};
           structOut(k).obs_name = S.Segm{iseg};            
           TS = target_stat(time1, data1, time2, data2, Type); %#ok<*AGROW>
           tnames = fieldnames(TS);
           for j = 1:length(tnames)
               structOut(k).(tnames{j}) = TS.(tnames{j});
           end
        end 
    end
    
end

if ~exist('structOut','var')
   structOut = [];
end

function S = target_stat(modelTime, modelValues, obsTime, obsValues, Type)
%GoFStats computes 'Goodness of Fit' scores and plots target diagram 
%as explained in Jolliff et al., 2009 [Summary diagrams for coupled
%hydrodynamic-ecosystem model skill assessment, Jason K. Jolliff et al., 
%Journal of Marine Systems 76 (2009) 64-82].
%The statistics are computed for modeled timeseries MODEL assuming that 
%the reference is provided by the in-situ measurements OBS.
%
% S = GoFStats(model_times, model_values, obs_times, obs_values, varargin);
%
% If option subset is deactivated, computes statistics on the whole model 
% timeseries (default is option subset activated).
%
% Example:
% S = GoFStats(model_times, model_values, obs_times, obs_values);
%
%  Timeseries data definition:
%   * <a href="https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions">https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions</a> (full definition)
%   * <a href="http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984788">http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984788</a> (simple)
%
%See also: GOFTIMESERIES

% $Id: delwaq_target.m 7027 2012-07-25 09:29:52Z gaytan_sa $
% $Date: 2012-07-25 17:29:52 +0800 (Wed, 25 Jul 2012) $
% $Author: gaytan_sa $
% $Revision: 7027 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/waq/delwaq_target.m $
% $Keywords: $

% inot = isnan(modelValues);
% modelValues(inot) = [];
% inot = isnan(obsValues);
% obsValues(inot) = [];

switch Type
    case 'log'        
        modelValues(modelValues<=0) = nan;
        obsValues(obsValues<=0) = nan;
        modelValues = log(modelValues);
        obsValues   = log(obsValues);
    case 'log10'        
        modelValues(modelValues<=0) = nan;
        obsValues(obsValues<=0) = nan;
        modelValues = log10(modelValues);
        obsValues   = log10(obsValues);
    case 'loga'        
        modelValues(modelValues<=0) = nan;
        obsValues(obsValues<=0) = nan;
        modelValues = log(modelValues+1);
        obsValues   = log(obsValues+1);
    case 'log10a'        
        modelValues(modelValues<=0) = nan;
        obsValues(obsValues<=0) = nan;
        modelValues = log10(modelValues+1);
        obsValues   = log10(obsValues+1);
    case 'log10b'        
        modelValues(modelValues<=0) = nan;
        obsValues(obsValues<=0) = nan;
        modelValues = log10(modelValues);
        obsValues   = log10(obsValues);
    case 'fwf'        
        modelValues(modelValues<=0) = nan;
        obsValues(obsValues<=0) = nan;
        S0 = 36;
        modelValues = log10((S0-modelValues)./S0);
        obsValues = log10((S0-obsValues)./S0);
end
OPT.station = '';
OPT.subset = 1;

%% combine timeseries:
%   - missing observations are replaced by NaNs
%   - missing model values are interpolated in time
tmpTime = cat(1, squeeze(modelTime), squeeze(obsTime));
[S.datenum, idx] = sort(tmpTime);
newData.model = interp1(squeeze(modelTime), ...
    squeeze(modelValues), squeeze(obsTime));
newData.obs = NaN + zeros(size(squeeze(modelTime)));
tmpData.model = cat(1, squeeze(modelValues), squeeze(newData.model));
tmpData.obs = cat(1, squeeze(newData.obs), squeeze(obsValues));
combined_all.modelTime = tmpTime(idx);
combined_all.obsTime = tmpTime(idx);
combined_all.modelValues = tmpData.model(idx);
combined_all.obsValues = tmpData.obs(idx);

%% Keep only (model) points that have an equivalent in the observations
%% and compute the statistics on this subset
if (OPT.subset)
    msk = find(~isnan(combined_all.obsValues));
    combined.modelTime = combined_all.modelTime(msk);
    combined.obsTime = combined_all.obsTime(msk);
    combined.modelValues = combined_all.modelValues(msk);
    combined.obsValues = combined_all.obsValues(msk);
else
    combined.modelTime = combined_all.modelTime;
    combined.obsTime = combined_all.obsTime;
    combined.modelValues = combined_all.modelValues;
    combined.obsValues = combined_all.obsValues;
end

S.model_comb = combined.modelValues;
S.obs_comb = combined.obsValues;
S.model_datenum = combined.modelTime;
S.obs_datenum = combined.obsTime;

%% compute means and stddev of normal distributions
S.model_mean = nanmean(combined.modelValues);
S.obs_mean = nanmean(combined.obsValues);
S.model_stddev = nanstd(combined.modelValues);
S.obs_stddev = nanstd(combined.obsValues);
%% compute residus of normal distributions
S.model_res = combined.modelValues - S.model_mean;
S.obs_res = combined.obsValues - S.obs_mean;
%% compute various statistics
% number of records
S.n = length(combined.modelValues); 
% correlation coefficient
S.R = nanmean(S.model_res.*S.obs_res)/ ...
    (S.model_stddev.*S.obs_stddev);
% normalized standard deviation
S.normalized_stddev = S.model_stddev/S.obs_stddev; 
% total RMS difference
%S.RMSD = sqrt(nanmean((combined.modelValues - combined.obsValues).^2));
S.RMSD = sqrt(nanmean((S.model_comb-S.obs_comb).^2));
% bias
S.bias = S.model_mean - S.obs_mean;
% unbiased RMS difference
%S.unbiased_RMSD = sqrt(S.RMSD^2 - S.bias^2);
if strcmpi(Type,'log10b')
   S.unbiased_RMSD = sqrt(nanmean(((10.^S.model_res)-(10.^S.obs_res)).^2));
else
   S.unbiased_RMSD = sqrt(nanmean((S.model_res-S.obs_res).^2));
end
% normalized bias
S.normalized_bias = (S.model_mean - S.obs_mean)/ ...
    S.obs_stddev;
% normalized unbiased RMS difference
%S.normalized_unbiased_RMSD = sqrt(1. + ...
%    S.normalized_stddev^2 - 2.*S.normalized_stddev*S.R);
S.normalized_unbiased_RMSD = S.unbiased_RMSD/S.normalized_stddev;
% model efficiency
S.model_efficiency = 1.0 - ...
    nansum((combined.modelValues-combined.obsValues).^2)/ ...
    nansum(S.model_res.^2);
% skill score
S.skill_score = 1.0 - ((1.0+S.R)/2.)* ...
    exp(-(S.normalized_stddev-1)^2/0.18);

S.CF = nanmean(abs(combined.modelValues - combined.obsValues))./ ...
    S.model_stddev;

%% Compute coordinates for the target diagrams
% S.model.GoF = [S.RMScp]*sign([S.model.stddev] - ...
%     [S.obs.stddev])./[S.obs.stddev];
S.xTarget = sign(S.model_stddev-S.obs_stddev)*...
    S.normalized_unbiased_RMSD;
S.yTarget = S.normalized_bias;

% S = rmfield(S, {'datenum' 'model_comb' 'obs_comb' 'model_res' 'obs_res'});

