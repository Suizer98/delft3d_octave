function z = prob_quadratic_RS_concave_x2z_test(varargin)
%PROB_QUADRATIC_RS_CONCAVE_X2Z_TEST  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = prob_quadratic_RS_concave_x2z_test(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   prob_quadratic_RS_concave_x2z_test
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl	
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
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
% Created: 31 Aug 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: prob_grooteman_05_concave_x2z_test.m 9606 2013-11-08 13:40:20Z bieman $
% $Date: 2013-11-08 21:40:20 +0800 (Fri, 08 Nov 2013) $
% $Author: bieman $
% $Revision: 9606 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/ObjectOrientedProbabilistics/examples/prob_grooteman_05_concave_x2z_test.m $
% $Keywords: $

%% settings

OPT = struct(...
    'U1', [],...
    'U2', []);

OPT = setproperty(OPT, varargin{:});

%% limit state function

z = -0.5*(OPT.U1-OPT.U2).^2-(OPT.U1+OPT.U2)/sqrt(2)+3;
