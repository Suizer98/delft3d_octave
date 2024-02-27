function [phihs] = hinderedsettlingfactor(c, cgel)
%HINDEREDSETTLINGFACTOR reduction in settling velocity due to gelling
%
%   [phihs] = hinderedsettlingfactor(c, cgel)
%
%   c: mass concentration (kg/m^3)
%   cgel: gelling mass concentration (kg/m^3), between 130 and 1722 kg/m^3
%
%   The relation used here is published by Van Rijn (2007a,b)
%
%   Example:
%   phihs = hinderedsettlingfactor(1,2650, 1)
%
% References
%   Van Rijn, L., 2007a. Unified View of Sediment Transport by Currents and
%   Waves. I: Initiation of Motion, Bed Roughness, and Bed-Load Transport.
%   Journal of Hydraulic Engineering, 133(6), 649-667
%
%   Van Rijn, L., 2007b. Unified View of Sediment Transport by Currents and 
%   Waves. II: Suspended Transport. 
%   Journal of Hydraulic Engineering, 133(6), 668-689.

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
% Created: 14 Jul 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id: hinderedsettlingfactor.m 5733 2012-01-20 16:11:22Z boer_g $
% $Date: 2012-01-21 00:11:22 +0800 (Sat, 21 Jan 2012) $
% $Author: boer_g $
% $Revision: 5733 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/phys_fun/hinderedsettlingfactor.m $
% $Keywords: $

%%

phihs = (1-0.65.*c./cgel).^5;

