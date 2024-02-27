function out = parse_coordinates(in,varargin)
%parse_coordinates  convert donar value to coordinate [degrees]
%
%   out = donar.parse_coordinates(in)
%
% where in can be one value, or an array, such as the 
% 1st of 2nd column of  block_data = donar.read_block();
%
% TO DO handle other coordinate systems than (lon,lat) WGS84.
%
%See also: parse_time

% use varargin for handling coordinate type

%%  --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares 4 Rijkswaterstaat (SPA Eurotracks)
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: parse_coordinates.m 10137 2014-02-05 09:50:57Z boer_g $
% $Date: 2014-02-05 17:50:57 +0800 (Wed, 05 Feb 2014) $
% $Author: boer_g $
% $Revision: 10137 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/+donar/parse_coordinates.m $
% $Keywords: $

out = dms2degrees([mod(fix(in/1000000),100), ...
                   mod(fix(in/10000  ),100), ...
                   mod(    in,10000  )/100]);