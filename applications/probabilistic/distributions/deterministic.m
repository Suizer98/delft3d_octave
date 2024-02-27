function X = deterministic(P, x, varargin)
%DETERMINISTIC  deterministic "distribution function"
%
%   This funtion returns X = x for all values in P.
%
%   Syntax:
%   varargout = deterministic(varargin)
%
%   Input:
%   P = cdf
%   x = deterministic variable value
%
%   Output:
%   X = variable values
%
%   Example
%   deterministic
%
%   See also FORM MC

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Kees den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
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
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% Created: 09 Mar 2009
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id: deterministic.m 6097 2012-05-01 10:25:31Z hoonhout $
% $Date: 2012-05-01 18:25:31 +0800 (Tue, 01 May 2012) $
% $Author: hoonhout $
% $Revision: 6097 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/distributions/deterministic.m $
% $Keywords:

%%
if isscalar(x)
    X = repmat(x, size(P));
else
    X = x;
end