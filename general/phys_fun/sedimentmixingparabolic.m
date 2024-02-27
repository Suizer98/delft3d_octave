function epsilon = sedimentmixingparabolic(epsmax, z_level, h)
%SEDIMENTMIXINGPARABOLIC   computes the sediment diffusivity.
%
% epsilon = sedimentmixingparabolic(epsmax, z_level, h)
% 
% computes the sediment diffusivity epsilon to be applied in an advection-diffusion model
% 
%   epsmax = 0.1 * UstarCW * h is the maximum sediment mixing coefficient at z/h = 0.5 
%   z_level is the height above the bed at which epsilon is computed
%   h is the water depth
%
%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Alkyon Hydraulic Consultancy & Research
%       grasmeijerb
%
%       bart.grasmeijer@alkyon.nl	
%
%       P.O. Box 248
%       8300 AE Emmeloord
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
% Created: 02 Sep 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id: sedimentmixingparabolic.m 5733 2012-01-20 16:11:22Z boer_g $
% $Date: 2012-01-21 00:11:22 +0800 (Sat, 21 Jan 2012) $
% $Author: boer_g $
% $Revision: 5733 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/phys_fun/sedimentmixingparabolic.m $
% $Keywords: $

%%

% Kappa = 0.4;
% epsbed = 0.07 * Udelta * DeltaW;                                          % Sistermans (2002) Thesis page 90
% epsbed = Kappa * UstarCW;
% epsbed = ls * ws;
% eps05h = 0.1 * UstarCW * h;
eps05h = epsmax;
% if(z_level < 0.5*h),
epsilon = eps05h.*(1-(1-2.*z_level./h).^2);
% else
%     epsilon = eps05h;
% end;

