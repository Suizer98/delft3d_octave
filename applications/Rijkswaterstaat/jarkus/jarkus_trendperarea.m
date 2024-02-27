function TREND = jarkus_trendperarea(dZM,S,J,period)
% jarkus_plottrend determine trends in volume changes for a specified area
%
%   Input:
%     dZM      = mean chane in bed level, from jarkus_volumeperarea
%     S        = surface of area, from jarkus_surface
%     J        = years from which the data is used
%     period   = boundaries of the period
%
%   Output:
%     TRENDS   = vector containing: 
%              1: steepness of trendline (A in Ax+B) (positive:
%              sedimentation/increase in bed level)
%              2: offset of trendline (B in Ax+B)
%              3: standar error
%              4: correlation coefficient
%              5: p-value, indication for significance of trend, see doc
%                 of corrcoeff
%   Example: 
%     J      = [1965 1970 1975 1980 1985:2008];
%     period = [1965 1990];
%     TREND = jarkus_trendperarea(dZM,S,J,period);
%

% !! NB: trends are only realistic for area's with uniform
% morphological behavior, if both substantial erosion and
% substantial sedimentation occurs in the defined area the method
% is not reliable !! NB
%
%  see jarkus_volumeperarea and jarkus_surface for S and dZM

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Tommer Vermaas
%
%       tommer.vermaas@gmail.com
%
%       Rotterdamseweg 185
%       2629HD Delft
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
%%
j1 = find(J==period(1));
j2 = find(J==period(2));
i  = find(~isnan(dZM(j1:j2)))+j1-1;

if length(i)>3 %calculate trends only for more than 3 points
    p = polyfit(J(i),dZM(i)*S,1);
    f = polyval(p,J(i));
    
    %calculate standard error and correlation coefficient
    SE    = sqrt( sum((dZM(i)*S-f).^2) /length(i)) / sqrt(length(i));
    [R,P] = corrcoef(J(i),dZM(i)); 

    TREND=[p(1:2) SE R(1,2) P(1,2)];
else
    TREND=repmat(NaN,1,5);
end