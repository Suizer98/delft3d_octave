function [xvalues pdfvalues] = prob_inv2pdf(varargin)
%PROB_INV2PDF  create probability density function
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = prob_inv2pdf(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   prob_inv2pdf
%
%   See also 

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
% Created: 16 Aug 2010
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id: prob_inv2pdf.m 2956 2010-08-16 15:19:51Z heijer $
% $Date: 2010-08-16 23:19:51 +0800 (Mon, 16 Aug 2010) $
% $Author: heijer $
% $Revision: 2956 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/distributions/prob_inv2pdf.m $
% $Keywords: $

%%
OPT = struct(...
    'Pmin', 0,...
    'Pstep', 1e-5,...
    'Pmax', 1,...
    'parameters', {{}},...
    'inv_func', []);

OPT = setproperty(OPT, varargin{:});

%%
% create a series of P-values
P = OPT.Pmin:OPT.Pstep:OPT.Pmax;

% obtain the corresponding x-values
x = feval(OPT.inv_func, P, OPT.parameters{:});

% derive the pdf
pdfvalues = diff(P) ./ diff(x);

% the corresponding x-values are just in between the original ones
xvalues = mean([x(1:end-1); x(2:end)]);