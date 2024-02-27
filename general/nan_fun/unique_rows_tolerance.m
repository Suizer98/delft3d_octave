function [C,dummy,IC]= unique_rows_tolerance(A0,varargin)
% unique_rows_tolerance  unique rows with tolerance
%
%   [C,~,IC]= unique_rows_tolerance(A,tolerance)
%
% where C are the unique rows in A, and IC are the indices
% that the rows of A have in C such that A = C(IC,:).
% (The ~ is scaffolding for IA from unique that are not yet implemented.)
%
% unique_rows_tolerance does the very same as unique(M,'rows'),
% but allows for extra specification of tolerance.
%
% Example:
%
%  [C,~,  ]=unique               ([1 1.11 2 2.1 1.2]','rows')
%  [C,~,IC]=unique_rows_tolerance([1 1.11 2 2.1 1.2]')     % 5 uniques
%  [C,~,IC]=unique_rows_tolerance([1 1.11 2 2.1 1.2]',0  ) % 5 uniques
%  [C,~,IC]=unique_rows_tolerance([1 1.11 2 2.1 1.2]',.10) % 4 uniques
%  [C,~,IC]=unique_rows_tolerance([1 1.11 2 2.1 1.2]',.11) % 3 uniques
%  [C,~,IC]=unique_rows_tolerance([1 1.11 2 2.1 1.2]',.12) % 2 uniques
%  [C,~,IC]=unique_rows_tolerance([1 1.11 2 2.1 1.2]',2  ) % 1 uniques
% 
%
%See also: unique, nanunique, poly_unique

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares 4 Rijkswaterstaat
%       Gerben de Boer
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
% $Id: nanunique.m 3186 2010-10-26 11:40:42Z heijer $
% $Date: 2010-10-26 13:40:42 +0200 (di, 26 okt 2010) $
% $Author: heijer $
% $Revision: 3186 $
% $HeadURL: https://repos.deltares.nl/repos/OpenEarthTools/trunk/matlab/general/nan_fun/nanunique.m $
% $Keywords: $


if nargin==2
    unique_eps = varargin{1};
else
    unique_eps = eps;    
end

[A,Ix]  = sortrows(A0);
% get inverse index (do not fully understand myself yet)
[~,Iy] = sortrows(Ix);

A0     = true([1 size(A,2)]);
mask   = any([A0;~(abs(diff(A,1,1))<unique_eps)],2);
C      = A(mask,:);
IC     = cumsum(mask);
IC     = IC(Iy);
dummy  = [];
