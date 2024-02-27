function [BSS alpha beta gamma epsilon] = BrierSkillScore(xc, zc, xm, zm, x0, z0, varargin)
%BRIERSKILLSCORE  Brier Skill Score of cross-shore profile
%
%   Derive Brier Skill Score (Sutherland et al, 2004).
%
%   Syntax:
%   BSS = BrierSkillScore(xc, zc, xm, zm, x0, z0, nx)
%
%   Input:
%   xc  = calculated x grid
%   zc  = calculated z values
%   xm  = measured x grid
%   zm  = measured z values
%   x0  = initial x grid
%   z0  = initial z values
%   varargin  = PropertyName-PropertyValue pairs
%       'equidistant' : - false for a weighted score based on the combined
%                           xgrid
%                       - <nx> for the number of equidistant gridcells
%       'lower_threshold' : - [] empty for no threshold
%                           - <lower_threshold> any value to ceil all lower
%                             values to
%       'verbose' : - true for displaying messages
%                   - false for suppressing messages
%       'numerator' : - [] empty for no prescribed numerator in BSS
%                          equation
%                     - <numerator> value is used as the numerator in
%                       BSS equation (required if BSS is used as skill
%                       parameter according to Ruessink&Kuriyama (2008) in
%                       which the numerator is used as the expected
%                       difference depending on delta T
%                       PLEASE NOTE THAT IF M&E DECOMPOSITION IS USED
%                       NUMERATOR IS IGNORED!
%
%   Output:
%   BSS     = Brier Skill Score
%   alpha   = measure of phase error; when the sand is moved to the wrong
%             position. Perfect modeling of the phase gives alpha=1
%   beta    = measure of amplitude error; when the wrong volume of sand is
%             moved. Perfect modeling of phase and amplitude gives beta=0
%   gamma   = measure of the map mean error; when the predicted average bed
%             level is different from the measured. Perfect modeling of the 
%             mean gives gamma=0
%   epsilon = measure of the map mean error; when the predicted average bed
%             level is different from the measured. Perfect modeling of the
%             mean gives epsilon=0
%
%   Example
%   BrierSkillScore
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Pieter van Geer / C.(Kees) den Heijer
%
%       Kees.denHeijer@Deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 30 Jun 2009
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id: BrierSkillScore.m 7757 2012-11-30 12:03:20Z walstra $
% $Date: 2012-11-30 20:03:20 +0800 (Fri, 30 Nov 2012) $
% $Author: walstra $
% $Revision: 7757 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/general/BrierSkillScore.m $
% $Keywords: $

%%
OPT = struct(...
    'equidistant', false,... % either false or # gridcells
    'lower_threshold', [],...
    'verbose', true,...
    'numerator',[]);

if ~isempty(varargin) && ischar(varargin{1})
    OPT = setproperty(OPT, varargin{:});
elseif ~isempty(varargin)
    % backward compatible (varargin{1} = nx)
    OPT = setproperty(OPT, 'equidistant', varargin{1});
end

%% clear all nan values in input (to avoid problems with interpolation)
x0(isnan(z0)) = [];
z0(isnan(z0)) = [];
xc(isnan(zc)) = [];
zc(isnan(zc)) = [];
xm(isnan(zm)) = [];
zm(isnan(zm)) = [];

%% determine new grid covered by all profiles
if OPT.equidistant
    newxlow = max([min(x0) min(xc) min(xm)]);
    newxhigh = min([max(x0) max(xc) max(xm)]);
    xextends = newxhigh - newxlow;
    
    nx = OPT.equidistant;
    x_new = newxlow:xextends/nx:newxhigh;
else
    x_new = unique([x0' xc' xm']);
end

%% interpolate profiles onto new grid
[x0,id1] = unique(x0);
[xc,id2] = unique(xc);
[xm,id3] = unique(xm);
z0 = z0(id1);
zc = zc(id2);
zm = zm(id3);

z0_new = interp1(x0, z0, x_new);
zc_new = interp1(xc, zc, x_new);
zm_new = interp1(xm, zm, x_new);

% reduce vectors if any nans are left
id = ~(isnan(z0_new) | isnan(zc_new) | isnan(zm_new));
[x_new z0_new zc_new zm_new] = deal(x_new(id), z0_new(id), zc_new(id), zm_new(id));

%% derive weight
if OPT.equidistant
    % weight is equaly devided over all points.
    weight = ones(size(x_new));
else
    % weight is defined as half of diff left and half of diff right of each
    % point; first and last point are considered to have only one side.
    weight = diff([x_new(1) diff(x_new)/2 + x_new(1:end-1) x_new(end)]);
    weight = weight / sum(weight);
end

if nargout < 2
    %% calculate BSS only
    mse_p = sum( (zm_new - zc_new).^2 .* weight );
    if isempty(OPT.numerator)
        mse_0 = sum( (zm_new - z0_new).^2 .* weight );
    else
        mse_0 = OPT.numerator;
    end
    BSS = 1. - (mse_p/mse_0);
    
else
    %% Murphy Epstein (1989) decomposition
    % A.H. Murphy and E.S. Epstein, 1989. Skill scores and correlation
    % coefficients in model verification. Monthly Weather Review,  117  (1989), pp. 572–581.
    % also described in J. Sutherland , A.H. Peet, R.L. Soulsby, 2004 (DOI: 10.1016/j.coastaleng.2004.07.015)
    % BSS = (alpha - beta - gamma + epsilon)/(1 + epsilon)
    
    if ~isempty(OPT.numerator)
        warning('Specified numerator is NOT used!')
    end
    
    % correlation including weight
    r = corr_weighted([(zc_new-z0_new);(zm_new-z0_new)]', weight);
    
    % standard deviation including weight
    % use sqrt(var) instead of std, because var has the possibility to
    % introduce a weight
    std_zc = sqrt(var(zc_new-z0_new, weight));
    std_zm = sqrt(var(zm_new-z0_new, weight));
    
    % mean including weight
    mean_zc = wmean(zc_new-z0_new, weight);
    mean_zm = wmean(zm_new-z0_new, weight);
    
    % decomposition terms
    alpha = r(2)^2;
    beta  = (r(2)-(std_zc/std_zm))^2;
    gamma = ((mean_zc - mean_zm)/std_zm)^2;
    epsilon = (mean_zm/std_zm)^2;
    
    % BSS
    BSS = (alpha - beta - gamma + epsilon)/(1+epsilon);
end

%% apply lower threshold
below_threshold = BSS < OPT.lower_threshold;
if any(below_threshold)
    if OPT.verbose
        disp(['Replaced Brier Skill Score <' num2str(OPT.lower_threshold) ' with a skill score of ' num2str(OPT.lower_threshold)]);
    end
    BSS(below_threshold) = OPT.lower_threshold;
end