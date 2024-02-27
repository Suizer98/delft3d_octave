function KML_upload(fileName)
% KML_UPLOAD upload *.kml/*.kmz file to server, for viewing in Google Maps
%
% See also: KML_footer, KML_header, KML_line, KML_poly, KML_style, 
% KML_stylePoly, KML_text

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

% $Id: KML_upload.m 570 2009-06-22 11:01:10Z damsma $
% $Date: 2009-06-22 19:01:10 +0800 (Mon, 22 Jun 2009) $
% $Author: damsma $
% $Revision: 570 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/googleplot/KMLengines/KML_upload.m $
% $Keywords: $

%%

f = ftp('damsma.net','openearth@damsma.net','}BcIY6lHTZuV');
mput(f,fileName) ;
close(f);
url = ['http://maps.google.com/maps?f=q&source=s_q&hl=en&geocode=&q=http://www.damsma.net/openearth/' fileName];
disp(url)
