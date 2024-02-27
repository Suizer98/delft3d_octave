function sdn_parameter_mapping_resolve_test()
%SDN_PARAMETER_MAPPING_RESOLVE_TEST  test for nerc_verify
%  
%
%See also SDN_PARAMETER_MAPPING_RESOLVE

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltares.nl	
%
%       Rotterdamseweg 185
%       2629 HD Delft
%       P.O. 177
%       2600 MH Delft
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 09 Apr 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id: sdn_parameter_mapping_resolve_test.m 4385 2011-04-01 11:11:00Z boer_g $
% $Date: 2011-04-01 19:11:00 +0800 (Fri, 01 Apr 2011) $
% $Author: boer_g $
% $Revision: 4385 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/OceanDataView/sdn_parameter_mapping_resolve_test.m $
% $Keywords: $

MTestCategory.DataAccess;

try
a1 = nerc_verify('http://vocab.ndg.nerc.ac.uk/term/P061/current/UPBB');
b1 = nerc_verify('http://vocab.ndg.nerc.ac.uk/term/P011/current/PRESPS01');
catch
a1 = 'Millibars';
b1 = 'Pressure (measured variable) exerted by the water body by fixed in-situ pressure sensor and corrected to read zero at sea level';
end

a2 = nerc_verify('P061::UPBB');
b2 = nerc_verify('P011::PRESPS01');

assert(isequal(a1,a2) && isequal(b1,b2));