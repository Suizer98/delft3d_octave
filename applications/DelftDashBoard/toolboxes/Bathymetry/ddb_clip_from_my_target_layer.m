function [status, file_name, saveing_dir] = ddb_clip_from_my_target_layer(geoserver_url,python_code_identifier, boundary_box, target_layer, saveing_dir)
% clip_from_my_target_layer2  DDB Tab for extracting data from geoserver

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
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
% Created: 01 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: ddb_BathymetryToolbox_fillcache.m 12732 2016-05-12 15:47:18Z nederhof $
% $Date: 2016-05-12 17:47:18 +0200 (Thu, 12 May 2016) $
% $Author: nederhof $
% $Revision: 12732 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/Bathymetry/ddb_BathymetryToolbox_fillcache.m $
% $Keywords: $

url = geoserver_url;
identifier = python_code_identifier;

% Specify process inputs
inputs = strcat('bbox=' , boundary_box , ';layer=' , target_layer , ';crs=3857');

% Pass the required parameters to read the process' meta data
xml = urlread([url 'cgi-bin/pywps.cgi?&service=wps&version=1.0.0&request=Execute&service=wps&version=1.0.0&identifier=' identifier '&DataInputs=' inputs]);

% Now we have to save the XML file otherwise we can't use xmlread
fid = fopen('file.xml','w');
fwrite(fid, xml);
fclose(fid);

% Read the XML file we just saved
xmldoc = xmlread(fullfile('file.xml'));
url_data = xmldoc.getElementsByTagName('wps:ProcessOutputs');
url_data = url_data.item(0);
url_data = url_data.getElementsByTagName('wps:Output');
url_data = url_data.item(0);
url_data = url_data.getElementsByTagName('wps:Data');
url_data = url_data.item(0);
url_data = url_data.getElementsByTagName('wps:LiteralData').item(0).getFirstChild.getData;
url_to_mytiff = char(url_data);
file_name =  [boundary_box target_layer '.tif'];
file_name = strrep(file_name,':','_');
file_name = strrep(file_name,',','_');
full_path = [saveing_dir '\' file_name];
[filestr,status] = urlwrite(url_to_mytiff, full_path);
end 
