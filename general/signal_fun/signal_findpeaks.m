function pks = signal_findpeaks(X, varargin)
%SIGNAL_FINDPEAKSTROUGHS  locates peaks of a vector.
%
%   Function to locate the peaks of an arbitrary vector. The result is a 
%   boolean with the locations of the peaks being true. In case of peaks
%   which cover several points, both edges are recognised as peaks. Troughs
%   can be found similarly by applying this function to -X.
%
%   Syntax:
%   [pks trs] = signal_findpeakstroughs(X, varargin)
%
%   Input:
%   X        = vector
%   varargin =
%
%   Output:
%   pks      = boolean with same size as X, indicating the peaks
%
%   Example
%   X = [0 1 0 2 2 2 1 5];
%   pks = signal_findpeaks(X)
%   trs = signal_findpeaks(-X)
%
%   See also findpeaks

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Delft University of Technology
%       Kees den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
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
% Created: 24 Mar 2010
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id: signal_findpeaks.m 2337 2010-03-24 15:27:48Z heijer $
% $Date: 2010-03-24 23:27:48 +0800 (Wed, 24 Mar 2010) $
% $Author: heijer $
% $Revision: 2337 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/signal_fun/signal_findpeaks.m $
% $Keywords: $

%% check input
if ~isvector(X)
    error('X should be a vector')
end

columnvector = ~issorted(size(X));
% transpose if required (row vector is needed)
if columnvector
    X = X';
end

[idplus idmin] = deal(true(size(X)));
% first and last points are by definition considered as no peak or trough
idplus(1) = false;
idmin(end) = false;

pks = ([X(idmin) > X(idplus) false] & [false X(idplus) >= X(idmin)]) |...
    ([X(idmin) >= X(idplus) false] & [false X(idplus) > X(idmin)]);

% transpose result again if required
if columnvector
    pks = pks';
end