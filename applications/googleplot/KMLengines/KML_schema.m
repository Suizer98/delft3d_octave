function varargout = KML_schema(data,varargin)
%KML_schema low-level routine for creating KML string of line style
%
%   kmlstring = KML_style(<keyword,value>)
%
% where the following <keyword,value> pairs have been implemented:
%
%   * name        name of style (default '')
%   * lineColor   color of the lines in RGB (0..1) values, default white ([0 0 0])
%   * lineAlpha   transparency of the line, (0..1) with 0 transparent
%   * lineWidth   line width, can be a fraction (default 1)
%
% See also: KML_footer, KML_header, KML_line, KML_poly, KML_stylePoly,
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

% $Id: KML_schema.m 9214 2013-09-11 12:20:21Z boer_g $
% $Date: 2013-09-11 20:20:21 +0800 (Wed, 11 Sep 2013) $
% $Author: boer_g $
% $Revision: 9214 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/googleplot/KMLengines/KML_schema.m $
% $Keywords: $

%% Properties
OPT.name = 'schema1';

if nargin==0; varargout = {OPT}; return; end

OPT = setproperty(OPT,varargin);

output = sprintf(...
    '<Schema id="%s">\n',... OPT.name
    OPT.name);

for ii = 1:length(data)
    output = [output sprintf([...
        ' <gx:SimpleArrayField name="%s" type="%s">\n'...id
        ...'  <displayName><![CDATA[<i>%s</i>]]></displayName>\n'...name
        '   <displayName>%s</displayName>\n'...name
        ' </gx:SimpleArrayField>\n'],...
        data(ii).id,data(ii).type,data(ii).name)]; %#ok<AGROW>
end

varargout = {[output '</Schema>\n']};

%% EOF