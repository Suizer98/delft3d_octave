function ARS = prob_ars_struct_mult(varargin)
%PROB_ARS_STRUCT  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = prob_ars_struct(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   prob_ars_struct
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
% Created: 24 Aug 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: prob_ars_struct_mult.m 7527 2012-10-18 15:21:25Z bieman $
% $Date: 2012-10-18 23:21:25 +0800 (Thu, 18 Oct 2012) $
% $Author: bieman $
% $Revision: 7527 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/engines/AdaptiveResponseSurface/prob_ars_struct_mult.m $
% $Keywords: $

%% create ARS struct

ARS = struct( ...
    'hasfit',           false,  ...
    'active',           [],     ...
    'b',                [],     ...
    'u',                [],     ...
    'z',                [],     ...
    'aggregateFunction',[],    ...
    'b_BS',             [],     ...
    'u_BS',             [],     ...
    'z_BS',             [],     ...
    'idx_BS',           [],     ...
    'betamin',          Inf,    ...
    'dbeta',            Inf,    ...
    'b_DP',             [],     ...
    'u_DP',             [],     ...
    'idx_DP',           [],     ...
    'fit',              struct());

ARS = setproperty(ARS, varargin{:});
