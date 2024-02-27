function json = line(lat,lon,varargin)
%line - create/write line (Feature) from 1D or 2D matrix
%
%  line(lat,lon,<keyword,value>)
%
% Example:
%  geojson.line([-75.1890 0.1275],[42.3482 51.5072],...
%   'name','NY2L',...
%   'description','NewYork 2 London',...
%   'fileName','NY2L.geojson')
%
%See also: KMLline, lines, http://geojson.org/

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Van Oord
%       Gerben de Boer, <gerben.deboer@vanoord.com>
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

% $Id: running_median_filter.m 10097 2014-01-29 23:02:09Z boer_g $
% $Date: 2014-01-30 00:02:09 +0100 (Thu, 30 Jan 2014) $
% $Author: boer_g $
% $Revision: 10097 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/signal_fun/running_median_filter.m $
% $Keywords: $

json = ''

   OPT.fileName      = '';
   OPT.name          = 'name';
   OPT.description   = 'description';
   
   if nargin==0
      varargout = {OPT};
      return
   end
   [OPT, Set, Default] = setproperty(OPT, varargin);


    json = sprintf([
        '\n{       "type": "Feature",\n'...
        '    "geometry":{"type":"LineString","coordinates": [']);
    
for i=1:size(lon,1)
     if i > 1
     json = strcat(json,sprintf(',\n'));
     end
     j=1;
     newjson = sprintf('%s',['[',num2str(lon(i,j)),',',num2str(lat(i,j)),']']);
     json = strcat(json,newjson);
     for j=2:size(lon,2)
         newjson = sprintf('%s',[',[',num2str(lon(i,j)),',',num2str(lat(i,j)),']']);
         json = strcat(json,newjson);
     end
end

json = strcat(json,sprintf([
']},\n "properties": {"name": "%s",  "description": "%s"}\n}'],OPT.name,OPT.description));

%% save to file
if ~isempty(OPT.fileName)
fid = fopen(OPT.fileName,'w');
fprintf(fid,'%s',json);
fclose(fid);
end