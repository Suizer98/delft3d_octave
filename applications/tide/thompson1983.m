function varargout = thompson1983(varargin)
%THOMPSON1983   Tidal-killer filter 120i913 by Thompson, 1983, JPO 13 (June), pp 1077-1083.
%
% f = thompson1983             or
% f = thompson1983('onesided') where f contains 121 of the 240 filter points,
%                              viz. w_0 to w_k of the symmetric filter
%                              w_{-k} to w_k, with k ranging to 120.
%
% f = thompson1983('twosided') where f contains the whole 240-point filter
%                              w_{-k} to w_k, with k ranging to 120.
%
% [f,index] = thompson1983(...) also returns the indexes k of the filter
%
% The filter can be applied on hourly timeseries as:
%
%   f             = thompsonbrazil('twosided');
%   dat           = filter(f,1,hourly_raw);
%   hourly_smooth = dat(length(f):end)
%
% Returns the filter 120i913 listed in Table 3 of:
% 
%    Rory O.R.Y. Thompson, 1983. "Low-pass filters to suppress 
%    inertial and tidal frequencies", Journal of Physical Oceanography,
%    Volume 13, June, 1077-1083.
%
% 120i923 was designed to filter the specific constituents
% O1, K1, Q1, P1, M2, S2, N2 and the inertial frequency 16.7 deg-hr.
%
% See also: FILTER, T_TIDE, GODIN, fft_filter, godin_filter

% This function is part of the OpenEarthTools initiative.

%   --------------------------------------------------------------------
%   Copyright (C) 2007 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl	
%
%       Environmental Fluid Mechanics Section
%       Faculty of Civil Engineering and Geosciences
%       PO Box 5048
%       2600 GA Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA or 
%   http://www.gnu.org/licenses/licenses.html,
%   http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

sides = 'onesided';

if nargin>0
   sides = varargin{1};
end


f=[...
 0.059983763
 0.059619747
 0.058536421
 0.056759542
 0.054330728
 0.051305694
 0.047752118
 0.043747394
 0.039376438
 0.034729681
 0.029901225
 0.024987093
 0.020083436
 0.015284565
 0.010680746
 0.006355800
 0.002384577
-0.001169390
-0.004255895
-0.006839458
-0.008899966
-0.010432516
-0.011446533
-0.011964332
-0.012019343
-0.011654239
-0.010919123
-0.009869873
-0.008566628
-0.007072349
-0.005451338
-0.003767607
-0.002083090
-0.000455716
 0.001062503
 0.002427191
 0.003601933
 0.004564057
 0.005294783
 0.005788778
 0.006048247
 0.006082735
 0.005907861
 0.005544148
 0.005016057
 0.004351217
 0.003579781
 0.002733785
 0.001846365
 0.000950771
 0.000079158
-0.000738753
-0.001476983
-0.002114382
-0.002635339
-0.003030001
-0.003294021
-0.003427916
-0.003436243
-0.003326761
-0.003109790
-0.002797825
-0.002405415
-0.001949182
-0.001447799
-0.000921726
-0.000392583
 0.000117891
 0.000589202
 0.001003568
 0.001347253
 0.001611461
 0.001792637
 0.001892088
 0.001915023
 0.001869252
 0.001763818
 0.001607903
 0.001410196
 0.001178827
 0.000921769
 0.000647487
 0.000365519
 0.000086704
-0.000177148 
-0.000414169 
-0.000613794 
-0.000768246 
-0.000873771 
-0.000931275 
-0.000946117 
-0.000927041 
-0.000884426 
-0.000828245 
-0.000766179 
-0.000702370 
-0.000637083 
-0.000567392 
-0.000488692 
-0.000396663 
-0.000289156 
-0.000167514 
-0.000036947 
 0.000034135
 0.000215700
 0.000318158
 0.000394386
 0.000441163
 0.000459624
 0.000454605
 0.000433032
 0.000401795
 0.000365685
 0.000325996
 0.000280202
 0.000222875
 0.000147642
 0.000049698
-0.000071792
-0.000212081
-0.000360537
];


if     strcmpi(sides,'twosided')
   f     = [flipud(f); f(2:end)];
   index = -120:120;
elseif strcmpi(sides,'onesided')
   index = 0:120;
else
   error(['invalid option: onesided or twosided, not ',sides])
end


if     nargout ==1
   varargout = {f};
elseif nargout ==2
   varargout = {f,index};
end

%% EOF