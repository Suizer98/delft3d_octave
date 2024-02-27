%function STATS(k).location = GoFStats(D3DTimePoints, D3DValues, ...
%   NetCDFTime, NetCDFValues, varargin)

function STATS = GoFStats_test(D3DTimePoints, D3DValues, ...
    NetCDFTime, NetCDFValues);
%GOFSTATS(k).location computes 'Goodness of Fit' scores and plots target diagram
%
% computes 'Goodness of Fit' scores and plots target diagram as explained in
% <a href="http://dx.doi.org/10.1016/j.jmarsys.2008.05.014">Jason K. Jolliff et al., 2009.</a> Summary diagrams for coupled hydrodynamic-
% ecosystem model skill assessment, Journal of Marine Systems 76 (2009) 64-82 .
%
% The statistics are computed for modeled timeseries MODEL assuming that
% the reference is provided by the in-situ measurements OBS.
%
% STATS(k).location = GoFStats(model_times, model_values, obs_times, obs_values, <keyword,value>);
%
% If option subset is deactivated, computes statistics on the whole model
% timeseries (default is option subset activated).
%
% Example:
% STATS(k).location = GoFStats(model_times, model_values, obs_times, obs_values);
%
%  Timeseries data definition:
%   * <a href="https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions">https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions</a> (full definition)
%   * <a href="http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984788">http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984788</a> (simple)
%
%See also: GOFTIMESERIES, http://dx.doi.org/10.1016/j.jmarsys.2008.05.014
% adapted by Valesca Harezlak to have loop over several locations or
% stations

% $Id: GoFStats_v2.m 7255 2012-09-20 12:30:02Z blaas $
% $Date: 2012-09-20 20:30:02 +0800 (Thu, 20 Sep 2012) $
% $Author: blaas $
% $Revision: 7255 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/modelvalidation/deprecated/GoFStats_v2.m $
% $Keywords: $

datadir = 'xxxx'; %directory of model data
cd(datadir)
fileinfo=dir([datadir,'*.txt']);

for k=1:length(fileinfo)
    
    %% read model data
        fid = fopen  (fileinfo(k).name,'r');
        disp('Scanning file, please wait ...')
        nt     = 0;
        
        while true
            tline = fgetl(fid);
            
            if ~ischar(tline), break
            end
            nt = nt + 1;
        end
        
        fseek(fid,0,-1); % rewind file
        
        disp(['found',num2str(nt),' lines.'])
        
        disp('Reading file, please wait ...')
        nrow = 0;
        
        for i=1:nt
            
            if mod(nrow,100)==0
                disp(['read',num2str(nrow),'lines.'])
            end
            
            
            % Read data
            record = fgetl(fid);
            
            nrow = nrow + 1;
            
            %Interpret one line
            [tok{1}, record] = strtok(record);
            [tok{2}, record] = strtok(record);
            
            % write part of string to structure
            MODEL.time(nrow)=str2double(tok{1});
            MODEL.data(nrow) = str2double(tok{2});
            
            tok = {};
            
        end
        
        fclose(fid);
        
        D3DTimePoints= MODEL.time;
        
        D3DValues=MODEL.data;
        
        %% read observation data
        datadir_obs='xxxx'; %directory with observation data
        cd(datadir_obs)
        fileinfo_obs=dir([datadir_obs,'*.txt']);
        
        
        obs_data = fopen  (fileinfo_obs(l).name,'r');
        disp('Scanning file, please wait ...')
        nt     = 0;
        
        while true
             fline= fgetl(obs_data);
            if ~ischar(fline), break
                
            end
            nt = nt + 1;
        end
        
        fseek(test,0,-1); % rewind file
        
        disp(['found',num2str(nt),' lines.'])
        
        disp('Reading file, please wait ...')
        nrow = 0;
        
        for i=1:nt
            
            if mod(nrow,100)==0
                disp(['read',num2str(nrow),'lines.'])
            end
            
            % Read data
            record = fgetl(test);
            
            nrow = nrow + 1;
            
            %Interpret one line
            [tok{1}, record] = strtok(record);
            [tok{2}, record] = strtok(record);
            
            % write part of string to structure
            OBS.time(nrow)=str2num(tok{1});
            OBS.data(nrow) = str2double(tok{2});
            
            tok = {};
            
        end
        
        fclose(fid);
        
        NetCDFTime = OBS.time;
        NetCDFValues= OBS.data);
                
        OPT.subset  = 1;
        STATS(k).location = fileinfo(k).name;
        
        
        %% combine timeseries:
        %   - missing observations are replaced by NaNs
        %   - missing model values are interpolated in time
        tmpTime = cat(2, squeeze(D3DTimePoints), squeeze(NetCDFTime));
        
        [STATS(k).location.datenum, idx] = sort(tmpTime);
        newData.model = interp1(squeeze(D3DTimePoints), ...
            squeeze(D3DValues), squeeze(NetCDFTime));
        
        newData.obs   = NaN + zeros(size(squeeze(D3DTimePoints)));
        tmpData.model = cat(2, squeeze(D3DValues)  , squeeze(newData.model));
        tmpData.obs   = cat(2, squeeze(newData.obs), squeeze(NetCDFValues));
        
        combined_all.D3DTimePoints = tmpTime(idx);
        combined_all.NetCDFTime    = tmpTime(idx);
        combined_all.D3DValues     = tmpData.model(idx);
        combined_all.NetCDFValues  = tmpData.obs(idx);
        
        %% Keep only (model) points that have an equivalent in the observations
        %% and compute the statistics on this subset
        if (OPT.subset)
            msk = find(~isnan(combined_all.NetCDFValues));
            combined.D3DTimePoints = combined_all.D3DTimePoints(msk);
            combined.NetCDFTime    = combined_all.NetCDFTime(msk);
            combined.D3DValues     = combined_all.D3DValues(msk);
            combined.NetCDFValues  = combined_all.NetCDFValues(msk);
        else
            combined.D3DTimePoints = combined_all.D3DTimePoints;
            combined.NetCDFTime    = combined_all.NetCDFTime;
            combined.D3DValues     = combined_all.D3DValues;
            combined.NetCDFValues  = combined_all.NetCDFValues;
        end
        
        STATS(k).location.model_comb = combined.D3DValues;
        STATS(k).location.obs_comb = combined.NetCDFValues;
        
        %% compute means and stddev of normal distributions
        STATS(k).location.model_mean   = nanmean(combined.D3DValues);
        STATS(k).location.obs_mean     = nanmean(combined.NetCDFValues);
        STATS(k).location.model_stddev = nanstd (combined.D3DValues);
        STATS(k).location.obs_stddev   = nanstd (combined.NetCDFValues);
        
        %% compute residus of normal distributions
        STATS(k).location.model_res    = combined.D3DValues - STATS(k).location.model_mean;
        STATS(k).location.obs_res      = combined.NetCDFValues - STATS(k).location.obs_mean;
        
        %% compute various statistics
        % number of records
        STATS(k).location.n = length(combined.D3DValues);
        % correlation coefficient
        STATS(k).location.R = nanmean(STATS(k).location.model_res.*STATS(k).location.obs_res)/ ...
            (STATS(k).location.model_stddev.*STATS(k).location.obs_stddev);
        % normalized standard deviation
        STATS(k).location.normalized_stddev = STATS(k).location.model_stddev/STATS(k).location.obs_stddev;
        % total RMS difference
        STATS(k).location.RMSD = sqrt(nanmean((STATS(k).location.model_comb-STATS(k).location.obs_comb).^2));
        % bias
        STATS(k).location.bias = STATS(k).location.model_mean - STATS(k).location.obs_mean;
        % unbiased RMS difference
        STATS(k).location.unbiased_RMSD = sqrt(nanmean((STATS(k).location.model_res-STATS(k).location.obs_res).^2));
        % normalized bias
        STATS(k).location.normalized_bias = (STATS(k).location.model_mean - STATS(k).location.obs_mean)/ ...
            STATS(k).location.obs_stddev;
        % normalized unbiased RMS difference
        STATS(k).location.normalized_unbiased_RMSD = STATS(k).location.unbiased_RMSD/STATS(k).location.normalized_stddev;
        % model efficiency
        STATS(k).location.model_efficiency = 1.0 - ...
            nansum((combined.D3DValues-combined.NetCDFValues).^2)/ ...
            nansum(STATS(k).location.model_res.^2);
        % skill score
        STATS(k).location.skill_score = 1.0 - ((1.0+STATS(k).location.R)/2.)* ...
            exp(-(STATS(k).location.normalized_stddev-1)^2/0.18);
        
        STATS(k).location.CF = nanmean(abs(combined.D3DValues - combined.NetCDFValues))./ ...
            STATS(k).location.model_stddev;
        
        %% Compute coordinates for the target diagrams
        STATS(k).location.xTarget = sign(STATS(k).location.model_stddev-STATS(k).location.obs_stddev)*...
        STATS(k).location.normalized_unbiased_RMSD;
        STATS(k).location.yTarget = STATS(k).location.normalized_bias;
        
        %STATS(k).location.model_name = model.name;
        STATS(k).location.obs_name = loc(l);
        
    
end

save xxxx.mat

