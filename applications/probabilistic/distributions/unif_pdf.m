function P = unif_pdf(X, a, b)
%UNIF_PDF  uniform probability density function (cdf)
%
%   This function returns the pdf of the uniform distribution, evaluated at
%   the values in X.
%
%   Syntax:
%   P = unif_pdf(X, a, b)
%
%   Input:
%   X = variable values
%   a = lower limit
%   b = upper limit
%
%   Output:
%   P = pdf
%
%   Example
%   unif_pdf
%
%   See also 

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Ferdinand Diermanse
%
%       F.diermanse@Deltares.nl	
%
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

% Created: 16 Mar 2009
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id: unif_pdf.m 8029 2013-02-05 07:33:41Z dierman $
% $Date: 2013-02-05 15:33:41 +0800 (Tue, 05 Feb 2013) $
% $Author: dierman $
% $Revision: 8029 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/distributions/unif_pdf.m $
% $Keywords:

%%
if nargin == 1
    a = 0;
    b = 1;
end

P = nan(size(X));

k = X > a & X < b & a < b;
if any(k)
    P(k) = 1 ./ (b - a);
end