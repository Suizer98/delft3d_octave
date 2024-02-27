function [xcentr dPdx] = cdf2pdf(P, x)
%CDF2PDF  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = cdf2pdf(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   cdf2pdf
%
%   See also

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       C.(Kees) den Heijer
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

% Created: 06 Feb 2009
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id: cdf2pdf.m 4584 2011-05-23 10:13:14Z hoonhout $
% $Date: 2011-05-23 18:13:14 +0800 (Mon, 23 May 2011) $
% $Author: hoonhout $
% $Revision: 4584 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/general/cdf2pdf.m $

%% check input: both should be vectors with more than one element
if ~all([isvector(P)...
        ~isscalar(P)...
        size(P) == size(x)])
    error('CDF2PDF:wronginput', 'P and x should be vectors with the same size.')
end

%% transpose in case of column vector
Transpose = ~issorted(size(P));
if Transpose
    P = P';
    x = x';
end
        
%% derive probability density function
xcentr = mean([x(1:end-1); x(2:end)]);
dPdx = diff(P)./diff(x);

%% eventually transpose output arguments to be conform input
if Transpose
   xcentr = xcentr';
   dPdx = dPdx';
end