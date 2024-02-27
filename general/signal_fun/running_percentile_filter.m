function result = running_percentile_filter(data,window_left,window_right,percentiles)
%RUNNING_PERCENTILE_FILTER  Moving percentile of 1D data.
%
%   Note difference with runing_median_filter: windo specifies one sided
%   window. running_percentile_filter(data,10,10,50) is (almost) equivalent 
%   to running_median_filter(data,21). There is a difference in the way the
%   boundary is handled.
%
%   Syntax:
%   result = running_percentile_filter(data, window, percentiles)
%
%   data         = vector if input data
%   window_left  = integer number of samples on the left side to include in
%                  the percentile 
%   window_right = integer number of samples on the left side to include in
%                  the percentile 
%   percentiles  = numbers between 0 and 100
%
%   Output:
%   result       = value per percentile
%
%   Example
%     x = (1:120)';
%     data = sin(x)/2 + sin(x/3)+sin(x/4)+3*sin(x/10);
%     percentiles = 0:20:100;
% 
%     subplot(3,1,1)
%     result = running_percentile_filter(data,20,0,percentiles);
%     plot(x,data,'r.-',x,result,'b')
%     title('Left filter, 20 samples')
% 
%     subplot(3,1,2)
%     result = running_percentile_filter(data,20,20,percentiles);
%     plot(x,data,'r.-',x,result,'b')
%     title('Symmetrical window, 20 samples left and 20 samples right')
% 
%     subplot(3,1,3)
%     result = running_percentile_filter(data,0,20,percentiles);
%     plot(x,data,'r.-',x,result,'b')
%     title('Right filter, 20 samples')
%
%   See also: running_median_filter, percentile

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Van Oord
%       Thijs Damsma
%
%       Thijs.Damsma@VanOord.com
%
%       Schaardijk 211
%       3063 NH
%       Rotterdam
%       Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 16 Apr 2014
% Created with Matlab version: 8.3.0.532 (R2014a)

% $Id: running_percentile_filter.m 10558 2014-04-17 07:01:01Z tda.x $
% $Date: 2014-04-17 15:01:01 +0800 (Thu, 17 Apr 2014) $
% $Author: tda.x $
% $Revision: 10558 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/signal_fun/running_percentile_filter.m $
% $Keywords: $

%%
narginchk(4,4)
validateattributes(data        ,{'double'},{'column','nonnan','finite'});
validateattributes(window_left ,{'double'},{'scalar','integer','nonnan','finite'});
validateattributes(window_right,{'double'},{'scalar','integer','nonnan','finite'});
validateattributes(percentiles ,{'double'},{'row','nonnan','finite','>=',0,'<=',100});

%% initialize
result = nan(length(data(:)),length(percentiles(:)));
n = length(data);

ii = 1;
i1 = max(1,ii-window_left);
i2 = min(n,ii+window_right);
[sl_val,sl_ind] = sort(data(i1:i2));
list_length = length(sl_val);
[a,b,ia,ib] = getPercentileFactors(list_length,percentiles);
result(ii,:) = sl_val(ia) .* a + sl_val(ib) .* b;

%% loop through data
for ii = 2:n
    x_ind_to_rem = ii-1-window_left;
    if x_ind_to_rem>=1
        % pos_to_remove = find(id == index_to_remove,1,'first');
        sl_ind_to_rem = 1;
        while sl_ind(sl_ind_to_rem) ~= x_ind_to_rem
            sl_ind_to_rem = sl_ind_to_rem + 1;
        end
    end
    
    x_ind_to_add = ii+window_right;
    if x_ind_to_add<=n
        sl_ind_to_add = 1;
        val_to_add = data(x_ind_to_add);
        while sl_ind_to_add <= list_length && sl_val(sl_ind_to_add) < val_to_add
            sl_ind_to_add = sl_ind_to_add + 1;
        end
    end
    
    if x_ind_to_rem>=1 && x_ind_to_add<=n % add and remove
        if sl_ind_to_add == sl_ind_to_rem
            sl_val = [sl_val(1:sl_ind_to_rem-1);   val_to_add; sl_val(sl_ind_to_rem+1:list_length)];
            sl_ind = [sl_ind(1:sl_ind_to_rem-1); x_ind_to_add; sl_ind(sl_ind_to_rem+1:list_length)];
        elseif sl_ind_to_add<sl_ind_to_rem
            sl_val = [sl_val(1:sl_ind_to_add-1);   val_to_add; sl_val(sl_ind_to_add:sl_ind_to_rem-1); sl_val(sl_ind_to_rem+1:list_length)];
            sl_ind = [sl_ind(1:sl_ind_to_add-1); x_ind_to_add; sl_ind(sl_ind_to_add:sl_ind_to_rem-1); sl_ind(sl_ind_to_rem+1:list_length)];
        else % pos_to_add>pos_to_remove
            sl_val = [sl_val(1:sl_ind_to_rem-1); sl_val(sl_ind_to_rem+1:sl_ind_to_add-1);   val_to_add; sl_val(sl_ind_to_add:list_length)];
            sl_ind = [sl_ind(1:sl_ind_to_rem-1); sl_ind(sl_ind_to_rem+1:sl_ind_to_add-1); x_ind_to_add; sl_ind(sl_ind_to_add:list_length)];
        end
    elseif x_ind_to_rem>=1 % remove only
        sl_val = [sl_val(1:sl_ind_to_rem-1); sl_val(sl_ind_to_rem+1:list_length)];
        sl_ind = [sl_ind(1:sl_ind_to_rem-1); sl_ind(sl_ind_to_rem+1:list_length)];
    elseif x_ind_to_add<=n % add only
        sl_val = [sl_val(1:sl_ind_to_add-1);   val_to_add; sl_val(sl_ind_to_add:list_length)];
        sl_ind = [sl_ind(1:sl_ind_to_add-1); x_ind_to_add; sl_ind(sl_ind_to_add:list_length)];
    else
        % do nothing
    end
    
    %% list is now sorted, extract percentiles
    if list_length ~= length(sl_val);
        list_length = length(sl_val);
        [a,b,ia,ib] = getPercentileFactors(list_length,percentiles);
    end
    
    result(ii,:) = a .* sl_val(ia) + b .* sl_val(ib);
end

function [a,b,ia,ib] = getPercentileFactors(list_length,percentiles)
% match indices with percentiles
ind = (list_length*(percentiles(:)/100))+.5;

% find interpolation factors a and b
a   = ceil(ind) - ind;
b   = 1-a;
% get indices ia and ib
ia = max(1,floor(ind));
ib = min(list_length,ceil(ind));