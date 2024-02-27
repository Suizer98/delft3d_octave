function [C IA IC] = nanunique(A, varargin)
%NANUNIQUE  Set unique, considering all nan-values as equal.
%
%    C = unique(A) for the array A returns the same values as in A but with 
%    no repetitions. C will be sorted. Unlike UNIQUE, C has one NaN
%    at most, positioned at then end. See UNIQUE fore more details. 
%
%    [C,IA,IC] = unique(A) also returns index vectors IA and IC such that
%    C = A(IA) and A = C(IC).
%
%   Example:
%
%     nanunique([1 2 nan nan])
%     unique   ([1 2 nan nan])
%
%   See also: unique, sortrows, poly_unique, unique_rows_tolerance

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 26 Oct 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id: nanunique.m 9854 2013-12-09 11:31:51Z boer_g $
% $Date: 2013-12-09 19:31:51 +0800 (Mon, 09 Dec 2013) $
% $Author: boer_g $
% $Revision: 9854 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/nan_fun/nanunique.m $
% $Keywords: $

%%
% derive the maximum finite value in a
maxval = max(A(isfinite(A(:))));
if isempty(maxval)
    maxval = 0;
end
% create dummy-value for NaN which is larger than the maximum value
nandummyval = maxval + 1;

% replace all NaN-values with this dummy-value
A(isnan(A)) = nandummyval;

% run the unique function
[C IA IC] = unique(A, varargin{:});

% replace the dummy-value by NaN
C(C == nandummyval) = NaN;