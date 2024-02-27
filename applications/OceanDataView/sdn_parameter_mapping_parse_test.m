function sdn_verify_test()
% SDN_PARAMETER_MAPPING_PARSE_TEST test for sdn_verify
%  
% More detailed description of the test goes here.
%
%
%   See also oceandataview, nerc_verify

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
% Created: 22 Jun 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id: sdn_parameter_mapping_parse_test.m 4452 2011-04-13 07:08:26Z boer_g $
% $Date: 2011-04-13 15:08:26 +0800 (Wed, 13 Apr 2011) $
% $Author: boer_g $
% $Revision: 4452 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/OceanDataView/sdn_parameter_mapping_parse_test.m $
% $Keywords: $

MTestCategory.DataAccess;
if TeamCity.running
    TeamCity.ignore('Test takes too long');
    return;
end

%% Original code of sdn_verify_test.m

% 'SDN_parameter_mapping
sdn_verify('<subject>SDN:LOCAL:PRESSURE</subject><object>SDN:P011::PRESPS01</object><units>SDN:P061::UPDB</units>');
sdn_verify('<subject>SDN:LOCAL:T90</subject><object>SDN:P011::TEMPS901</object><units>SDN:P061::UPAA</units>');
sdn_verify('<subject>SDN:LOCAL:Salinity</subject><object>SDN:P011::PSALPR02</object><units>SDN:P061::UUUU</units>');
sdn_verify('<subject>SDN:LOCAL:fluorescence</subject><object>SDN:P011::CPHLPM01</object><units>SDN:P061::UGPL</units>');
sdn_verify('<subject>SDN:LOCAL:Trans_red_25cm</subject><object>SDN:P011::POPTDR01</object><units>SDN:P061::UPCT</units>');
sdn_verify('<subject>SDN:LOCAL:POTM</subject><object>SDN:P011::POTMCV01</object><units>SDN:P061::UPAA</units>');
sdn_verify('<subject>SDN:LOCAL:Density</subject><object>SDN:P011::SIGTPR01</object><units>SDN:P061::UKMC</units>');

% 'SDN_parameter_mapping
sdn_verify('<subject>SDN:LOCAL:Air_pressure(p)</subject><object>SDN:P011::CAPASS01</object><units>SDN:P061::UPBB</units>');
sdn_verify('<subject>SDN:LOCAL:Wind_direction(dd)</subject><object>SDN:P011::EWDAZZ01</object><units>SDN:P061::UABB</units>');
sdn_verify('<subject>SDN:LOCAL:Wind_speed(ff)</subject><object>SDN:P011::ESSAZZ01</object><units>SDN:P061::UVAA</units>');
sdn_verify('<subject>SDN:LOCAL:Wind_bft(bft)</subject><object>SDN:P011::WMOCWFBF</object><units>SDN:P061::USPC</units>');
sdn_verify('<subject>SDN:LOCAL:Wave_period(pw)</subject><object>SDN:P011::GTCAEV01</object><units>SDN:P061::UTBB</units>');
sdn_verify('<subject>SDN:LOCAL:Wave_height(hw)</subject><object>SDN:P011::GCARVS01</object><units>SDN:P061::ULAA</units>');
sdn_verify('<subject>SDN:LOCAL:Wave_direction_1(dw1)</subject><object>SDN:P011::GDSWEV01</object><units>SDN:P061::UABB</units>');
sdn_verify('<subject>SDN:LOCAL:Wave_period_1(pw1)</subject><object>SDN:P011::GPSWEV01</object><units>SDN:P061::UTBB</units>');
sdn_verify('<subject>SDN:LOCAL:Wave_period_1_code_1(pw1k1)</subject><object>SDN:P011::WMOCWPXX</object><units>SDN:P061::USPC</units>');
sdn_verify('<subject>SDN:LOCAL:Wave_height_1(hw1)</subject><object>SDN:P011::GHSWEV01</object><units>SDN:P061::ULAA</units>');
sdn_verify('<subject>SDN:LOCAL:Wave_direction_2(dw2)</subject><object>SDN:P011::GSD2VS01</object><units>SDN:P061::UABB</units>');
sdn_verify('<subject>SDN:LOCAL:Wave_period_2(pw2)</subject><object>SDN:P011::GSZ2VS01</object><units>SDN:P061::UTBB</units>');
sdn_verify('<subject>SDN:LOCAL:Wave_height_2(hw2) </subject><object>SDN:P011::GCH2VS01</object><units>SDN:P061::ULAA</units>');
sdn_verify('<subject>SDN:LOCAL:Clouds_height(h)</subject><object>SDN:P011::WMOCCBLW</object><units>SDN:P061::USPC</units>');
sdn_verify('<subject>SDN:LOCAL:Cloud_amount(n)</subject><object>SDN:P011::WMOCCCAC</object><units>SDN:P061::USPC</units>');
sdn_verify('<subject>SDN:LOCAL:Amount_lowest_cloud(nh)</subject><object>SDN:P011::WMOCCCLM</object><units>SDN:P061::USPC</units>');
sdn_verify('<subject>SDN:LOCAL:Air_temperature(t)</subject><object>SDN:P011::CDTBSS01</object><units>SDN:P061::UPAA</units>');
sdn_verify('<subject>SDN:LOCAL:Dew-point_temp(td)</subject><object>SDN:P011::CDEWCVWD</object><units>SDN:P061::UPAA</units>');
sdn_verify('<subject>SDN:LOCAL:Wet-bulb_temp (tb)</subject><object>SDN:P011::CWETSS01</object><units>SDN:P061::UPAA</units>');
sdn_verify('<subject>SDN:LOCAL:Sea-surface_temp(tw)</subject><object>SDN:P011::PSSTTS01</object><units>SDN:P061::UPAA</units>');
