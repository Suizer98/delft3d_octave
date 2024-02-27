function B = array_downsize(A,nn)
%ARRAY_DOWNSIZE  Downsizes array using averaging
%
%   Reduces an array by for example a factor 2; takes the average of 2^2
%   gridpoints and saves as oe in a new array. NaN's are ignored, only when
%   all points in the reduced array are NaN a NaN is returned. 
%
%   Syntax:
%   B = array_downresize(A,nn)
%
%   Input:
%   nn  =  downsize factor (must be integer, and a fraction of the size of A)
%
%   Output:
%   B = reduced array
%
%   Example
%     mm = 800;
%     A = peaks(mm);
%     A(rand(mm)>0.1)=nan;
%     nn = 32;
%     B = array_downsize(A,nn);
%     surf(B)
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 <COMPANY>
%       tda
%
%       <EMAIL>	
%
%       <ADDRESS>
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 15 Sep 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id: array_downsize.m 3232 2010-11-05 15:45:55Z thijs@damsma.net $
% $Date: 2010-11-05 23:45:55 +0800 (Fri, 05 Nov 2010) $
% $Author: thijs@damsma.net $
% $Revision: 3232 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/grid_fun/array_downsize.m $
% $Keywords: $

%%

N = zeros(size(A)/nn);
B = zeros(size(A)/nn);

for ii = 1:nn
    a = A(ii:nn:end,ii:nn:end);
    N = N+~isnan(a);
    B(~isnan(a)) = B(~isnan(a)) + a(~isnan(a));
end

B(N>0) = B(N>0)./N(N>0);
B(N==0) = nan;