function [output] = KML_footer(varargin)
%KML_FOOTER  low-level routine for creating KML string of footer
%
%   kml = KML_footer
%
% See also: KML_header, KML_line, KML_poly, KML_style, KML_stylePoly,
% KML_text, KML_upload

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
%       Thijs Damsma
%
%       Thijs.Damsma@deltares.nl	
%
%       Deltares
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

% $Id: KML_footer.m 739 2009-07-28 15:04:13Z boer_g $
% $Date: 2009-07-28 23:04:13 +0800 (Tue, 28 Jul 2009) $
% $Author: boer_g $
% $Revision: 739 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/googleplot/KMLengines/KML_footer.m $
% $Keywords: $

%% type HEADER
output = sprintf([...
    '</Document>\n'...
    '</kml>\n'...
    ]);
