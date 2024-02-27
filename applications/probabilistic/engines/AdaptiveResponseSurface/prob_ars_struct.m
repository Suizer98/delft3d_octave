function ARS = prob_ars_struct(varargin)
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

% $Id: prob_ars_struct.m 5116 2011-08-25 16:39:09Z hoonhout $
% $Date: 2011-08-26 00:39:09 +0800 (Fri, 26 Aug 2011) $
% $Author: hoonhout $
% $Revision: 5116 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/engines/AdaptiveResponseSurface/prob_ars_struct.m $
% $Keywords: $

%% create ARS struct

ARS = struct( ...
    'hasfit',   false,  ...
    'n',        0,      ...
    'active',   [],     ...
    'u',        [],     ...
    'z',        [],     ...
    'betamin',  Inf,    ...
    'dbeta',    Inf,    ...
    'fit',      struct());

ARS = setproperty(ARS, varargin{:});

%% set length

if ~isempty(ARS.z)
    ARS.n = 1;
end
