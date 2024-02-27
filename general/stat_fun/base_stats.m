function xStats = base_stats(x,prc,bin,type)
% BASE_STATS determines basic statistics of a sample: 
% mean. variance, standard deviation, percentiles, max, min
% mean of squares, roof of mean of squares, number of samples
% histogram bins
%
%   Syntax:
%   xStats = BASE_STATS(x,prc,bin,type) 
%
%   Input:
%   x   = data values (can be a matrix)
%   prc = percentile values (can be a vector)
%   bin = binning interval over which stats computed
%   type = transformation type (default no transformation)
% 	'log', 'log10', 'exp', 'exp10'        
%    
%
%   Output:
%  	xStats.mean 
%  	xStats.var  
%  	xStats.std  
%  	xStats.mse  
%  	xStats.rmse 
%  	xStats.nbin 
%
%   Example
%    ...
%   See also percentile, wmean, .
%
% Copyright notice
%   --------------------------------------------------------------------
%   Copyright 2011 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   2011-Sep-25 Created by Gaytan-Aguilar
%   email: sandra.gaytan@deltares.com
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
%
% This tool is part of OpenEarthTools.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.
%
%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 14 Apri l2012
% Created with Matlab version: 7.11.0.584 (R2010b)
%
% $Id: base_stats.m 5980 2012-04-16 14:46:06Z blaas $
% $Date: 2012-04-16 22:46:06 +0800 (Mon, 16 Apr 2012) $
% $Author: blaas $
% $Revision: 5980 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/stat_fun/base_stats.m $
% $Keywords: $


if nargin < 2
    prc = [5 50 95];
end
if nargin < 3
    bin = 20;
end

if nargin < 4
    type = 'none';
end

switch type
    case 'log'        
        x(x<=0) = nan;
        x = log(x);
    case 'log10'        
        x(x<=0) = nan;
        x = log10(x);
    case 'exp'        
        x = exp(x);
    case 'exp10'        
        x = 10.^x;
end

x = x(:);
n = length(x);
inan = isnan(x);
x(inan) = [];

xStats.n = n;
xStats.nan = sum(inan);
xStats.min = min(x);
if isempty(xStats.min)
   xStats.min = nan;
end
xStats.max = max(x);
if isempty(xStats.max)
   xStats.max = nan;
end

P = perctile(x,prc);
for ip  = 1:length(prc)
    xStats.(['prc' (num2str(prc(ip),'%02.0f'))]) = P(ip);
end
xStats.mean  = mean(x);
xStats.var   = var(x);
xStats.std   = std(x);
xStats.mse  = mean(x.^2);
xStats.rmse = sqrt(xStats.mse);
[xStats.nbin xStats.bin] = hist(x,bin);

%--------------------------------------------------------------------------
% Percentile
%--------------------------------------------------------------------------
function P = perctile(x,prc)

P = nan(length(prc),1);
x = x(:);
x(isnan(x)) = [];
x = sort(x);
n = length(x);
if n==1
   P(:) = x;
elseif n>=2
   P = interp1((1:n)/n,x,(prc/100),'nearest','extrap');    
end
