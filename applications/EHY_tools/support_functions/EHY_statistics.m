function [Statistics,Z_int] = EHY_statistics(varargin)
%% [Statistics,Z_int] = EHY_statistics(varargin)
%
% function Statistics = EHY_statistics(Z_sim, Z_obs)
% Simulated vs. observed values. No interpolation of x- or time (see below) is performed
%
% 1D: function Statistics = EHY_statistics(X_sim, Z_sim, X_obs, Z_obs)
% uses interp1
%
% 2D: function Statistics = EHY_statistics(X_sim, Y_sim, Z_sim, X_obs, Y_obs, Z_obs)
% uses scatteredInterpolant as it can handle 'scattered' XYZ-data. XY is
% not always plain/'meshgridded'
%
% Interpolation method: linear
% Extrapolation method: None  (i.e. returns a NaN)

%% Initiate and check
Statistics.std_obs      = NaN;
Statistics.std_obs_norm = NaN;
Statistics.std_sim      = NaN;
Statistics.std_sim_norm = NaN;
Statistics.bias         = NaN;
Statistics.bias_norm    = NaN;
Statistics.meanerror    = NaN; % = bias
Statistics.std          = NaN;
Statistics.std_norm     = NaN;
Statistics.RMSE         = NaN;
Statistics.RMSE_norm    = NaN;
Statistics.rmserror     = NaN; % = RMSE
Statistics.maxerror     = NaN;
Statistics.minerror     = NaN;
Statistics.obsrange     = NaN;
Statistics.simrange     = NaN;
Statistics.simrangeint  = NaN;
Statistics.rms_obs      = NaN;
Statistics.corrcoef     = NaN; % correlation coefficient
Statistics.n            = NaN; % number of points

Z_int = [];

if any(cellfun(@isempty,varargin))
    return % statistics can not be determined
end

%% Interpolate
if nargin == 2 % Statistics = EHY_statistics(X_sim, Z_sim, X_obs, Z_obs)
    
    Z_sim = varargin{1};
    Z_int = Z_sim;
    Z_obs = varargin{2};

elseif nargin == 4 % Statistics = EHY_statistics(X_sim, Z_sim, X_obs, Z_obs)
    
    X_sim = varargin{1};
    Z_sim = varargin{2};
    X_obs = varargin{3};
    Z_obs = varargin{4};
    
    nonan = ~(isnan(X_sim) | isnan(Z_sim));
    if sum(nonan) < 2
        return % statistics can not be determined
    else
        Z_int = interp1(X_sim(nonan), Z_sim(nonan), X_obs);
    end
    
elseif nargin == 6 % Statistics = EHY_statistics(X_sim, Y_sim, Z_sim, X_obs, Y_obs, Z_obs)
    
    X_sim = varargin{1};
    Y_sim = varargin{2};
    Z_sim = varargin{3};
    X_obs = varargin{4};
    Y_obs = varargin{5};
    Z_obs = varargin{6};
    
    % Make sure dimensions of X_sim and Y_sim are the same as Z_sim
    % First reshape in case of row/column vectors. Then, apply repmat if needed
    %
    % This is needed when e.g. X_sim = Zcen [times x layers], Y_sim = time [times,1] 
    % and Z_sim = salinity [times x layers]
    
    if size(X_sim,1) == 1 && size(X_sim,2) == size(Z_sim,1)
        X_sim = X_sim';
    elseif size(Y_sim,1) == 1 && size(Y_sim,2) == size(Z_sim,1)
        Y_sim = Y_sim';
    end
    
    if size(X_sim,1) ~= size(Z_sim,1) && size(X_sim,1) == 1 % X_sim, 1st dim
        X_sim = repmat(X_sim,size(Z_sim,1),1);
    elseif size(X_sim,2) ~= size(Z_sim,2) && size(X_sim,2) == 1 % X_sim, 2nd dim
        X_sim = repmat(X_sim,1,size(Z_sim,2));
    elseif size(Y_sim,1) ~= size(Z_sim,1) && size(Y_sim,1) == 1 % Y_sim, 1st dim
        Y_sim = repmat(Y_sim,size(Z_sim,1),1);
    elseif size(Y_sim,2) ~= size(Z_sim,2) && size(Y_sim,2) == 1 % Y_sim, 2nd dim
        Y_sim = repmat(Y_sim,1,size(Z_sim,2));
    end
    
    nonan = ~(isnan(X_sim) | isnan(Y_sim));
    if sum(sum(nonan)) < 2
        return % statistics can not be determined
    end
    XYZ = unique([X_sim(nonan) Y_sim(nonan) Z_sim(nonan)],'rows');
    F = scatteredInterpolant(XYZ(:,1), XYZ(:,2), XYZ(:,3),'linear','none');
    Z_int = F(X_obs,Y_obs);
    
else
    disp('Number of input arguments in function EHY_statistics is incorrect')
    return % statistics can not be determined
end

%% Determine statistics
nonan = ~isnan(Z_int) & ~isnan(Z_obs);
err   = Z_int(nonan) - Z_obs(nonan); % err = 'error'

if sum(size(err)>1)>1
    error('2D error array.. please debug as I''m not sure if statistics below are OK for 2D')
end

if numel(err) > 1   
    Statistics.std_obs      = std(Z_obs(nonan),1);  % Note the difference with std(error) [= std(error,0)]
    Statistics.std_obs_norm = 1;
    Statistics.std_sim      = std(Z_int(nonan),1);  % Note the difference with std(error) [= std(error,0)]
    Statistics.std_sim_norm = Statistics.std_sim/Statistics.std_obs;
    Statistics.bias         = mean(err);
    Statistics.bias_norm    = Statistics.bias/Statistics.std_obs;
    Statistics.meanerror    = mean(err);
    Statistics.std          = std(err,1);  % AKA crmsd; Note the difference with std(error) [= std(error,0)]
    Statistics.std_norm     = Statistics.std/Statistics.std_obs;
    Statistics.RMSE         = norm(err)/sqrt(length(err));
    Statistics.RMSE_norm    = Statistics.RMSE/Statistics.std_obs;
    Statistics.rmserror     = Statistics.RMSE;
    Statistics.maxerror     = max(err);
    Statistics.minerror     = min(err);
    Statistics.obsrange     = max(Z_obs) - min(Z_obs);
    Statistics.simrange     = max(max(Z_sim)) - min(min(Z_sim));
    Statistics.simrangeint  = max(Z_int) - min(Z_int);
    Statistics.rms_obs      = Statistics.rmserror / Statistics.obsrange;
    r                       = corrcoef(Z_int(nonan),Z_obs(nonan));
    Statistics.corrcoef     = r(1,2);
    Statistics.n            = length(err);
end
