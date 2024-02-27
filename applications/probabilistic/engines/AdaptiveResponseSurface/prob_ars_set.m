function ARS = prob_ars_set(u, z, varargin)
%PROB_ARS_SET  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = prob_ars_set(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   prob_ars_set
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

% $Id: prob_ars_set.m 5129 2011-08-29 16:55:35Z hoonhout $
% $Date: 2011-08-30 00:55:35 +0800 (Tue, 30 Aug 2011) $
% $Author: hoonhout $
% $Revision: 5129 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/engines/AdaptiveResponseSurface/prob_ars_set.m $
% $Keywords: $

%% settings

OPT = struct(...
    'ARS',      prob_ars_struct,    ...
    'maxZ',     Inf                 ...
);

OPT = setproperty(OPT, varargin{:});

%% add data

ARS             = OPT.ARS;

ARS.n           = ARS.n+1;
ARS.u           = [ARS.u ; u(:,ARS.active)];
ARS.z           = [ARS.z ; z(:)];
ARS.betamin     = min([ARS.betamin sqrt(sum(u(end,:).^2,2))]);

%% fit data

notinf      = all(isfinite(ARS.u),2) & isfinite(ARS.z);
notout      = abs(ARS.z)<=OPT.maxZ;

if ARS.n >= 2*sum(ARS.active)+1
    ARS.fit     = polyfitn(ARS.u(notinf&notout,:), ARS.z(notinf&notout), 2);
    ARS.hasfit  = true;
end
