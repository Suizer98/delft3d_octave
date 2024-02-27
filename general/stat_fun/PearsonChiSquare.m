function Chi2 = PearsonChiSquare(xc, zc, xm, zm, x0, z0, varargin)
%PEARSONCHISQUARE  One line description goes here.
%
%   Compute chi^2 according to:
%	\chi^2 = \sum_{i=1}^n \frac{(O_i - E_i)^2}{E_i}
%   where O_i = |zm-z0|
%         E_i = |zc-z0|
%   Please note that the corresponding x-values are needed to synchronise
%   all z-values to the same x-grid.
%
%   Syntax:
%   Chi2 = PearsonChiSquare(xc, zc, xm, zm, x0, z0, varargin)
%
%   Input:
%   xc  = calculated x grid
%   zc  = calculated z values
%   xm  = measured x grid
%   zm  = measured z values
%   x0  = initial x grid
%   z0  = initial z values
%   varargin  = leave empty for a weighted score based on the combined
%   xgrid, otherwise either the number of grid cells <nx> or a PropertyName
%   PropertyValue pair 'equidistant', <nx>. 
%
%   Output:
%   Chi2     =
%
%   Example
%   PearsonChiSquare
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Kees den Heijer
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

% This tool is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 04 Nov 2009
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: PearsonChiSquare.m 2492 2010-04-27 06:38:22Z heijer $
% $Date: 2010-04-27 14:38:22 +0800 (Tue, 27 Apr 2010) $
% $Author: heijer $
% $Revision: 2492 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/stat_fun/PearsonChiSquare.m $
% $Keywords: $

%%
OPT = struct(...
    'equidistant', false ... % either false or # gridcells
	);

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

%% calculate Chi-Square
if OPT.equidistant
    % weight is equaly devided over all points.
    weight = ones(size(x_new));
else
    % weight is defined as half of diff left and half of diff right of each
    % point; first and last point are considered to have only one side.
    weight = diff([x_new(1) diff(x_new)/2 + x_new(1:end-1) x_new(end)]);
end
    
Obs = abs(zm_new - z0_new); % absolute values of difference between model final profile and initial profile
Exp = abs(zc_new - z0_new); % absolute values of difference between computed final profile and initial profile
id = Exp ~= 0 | Obs ~= 0;
total = sum(weight(id));
Chi2 = sum(((Obs(id) - Exp(id)).^2 ./ Exp(id)) .* weight(id)) / total; % weighted chi square value