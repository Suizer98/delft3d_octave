function idx = prob_ars_inbetasphere(ARS, beta)
%PROB_ARS_INBETASPHERE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = prob_ars_inbetasphere(varargin)
%
%   Input: For <keyword,value> pairs call prob_ars_inbetasphere() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   prob_ars_inbetasphere
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       Rotterdamseweg 185
%       2629HD Delft
%       Netherlands
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
% Created: 15 Oct 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id: prob_ars_inbetasphere.m 7486 2012-10-15 13:09:43Z hoonhout $
% $Date: 2012-10-15 21:09:43 +0800 (Mon, 15 Oct 2012) $
% $Author: hoonhout $
% $Revision: 7486 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/engines/AdaptiveResponseSurface/prob_ars_inbetasphere.m $
% $Keywords: $

%% check which betas are in beta sphere

idx = beta <= min([ARS.betamin])+max([ARS.dbeta]) & beta > 0;