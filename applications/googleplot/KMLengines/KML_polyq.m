function [output] = KML_polyq(lat,lon,varargin)
%KML_POLYq  low-level routine for creating KML string of polygon	
%
%   kmlstring = KML_poly(lat,lon,<z>,<keyword,value>)
%
% where z can be 'clampToGround'.
%
% If lat and lon have multiple rows, these rows are seen as  separate polygons.
%
% The implemented <keyword,value> pairs and their defaults are given by
%
%   OPT = KML_line()
%
% Note that Google Earth shows a a KML_poly unsharp at small view 
% angles, whereas a KML_line is shown sharp at all view angles. 
% A recommendation is therefore to plot edges with KML_line too.
%
% See also: KML_footer, KML_header, KML_line, KML_style, KML_stylePoly,
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

% $Id: KML_polyq.m 4894 2011-07-21 20:47:45Z boer_g $
% $Date: 2011-07-22 04:47:45 +0800 (Fri, 22 Jul 2011) $
% $Author: boer_g $
% $Revision: 4894 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/googleplot/KMLengines/KML_polyq.m $
% $Keywords: $

if nargin==2
   z       = 'clampToGround';
   nextarg = 1;
elseif nargin==3
   z       = varargin{1};
else
   if  ( odd(nargin) & ~isstruct(varargin{2})) | ...
       (~odd(nargin) &  isstruct(varargin{2}));
      z       = varargin{1};
      nextarg = 2;
   else
      z       = 'clampToGround';
      nextarg = 1;
   end
end

if length(size(lon)) > 2
   error('lat,lon should be to have size nx1, or nxm, NOT have more than 2 dimensions.')
end
if size(lon,1)==1
   error('lat,lon should be to have size nx1, or nxm, NOT 1xn.')
end

%% keyword,value
% 
%    OPT.styleName  = [];
%    OPT.visibility = 1;
%    OPT.extrude    = 0;
%    OPT.timeIn     = [];
%    OPT.timeOut    = [];
%    OPT.name       = 'poly';
%    OPT.precision  = 8;
%    
%    OPT = setproperty(OPT,varargin{nextarg:end});
%    
%    if nargin==0
%       output = OPT;
%       return
%    end
% 
% if isempty(OPT.styleName)
%    warning('property ''stylename'' required');
% end
OPT = varargin{nextarg};
%%

if all(isnan(z(:)))
    output = '';
    return
end

%% preprocess visibility
if  ~OPT.visibility
    visibility = '<visibility>0</visibility>\n';
else
    visibility = '';
end
%% preprocess extrude
if  OPT.extrude
    extrude = '<extrude>1</extrude>\n';
else
    extrude = '';
end
%% preproces timespan
if  ~isempty(OPT.timeIn)
    if ~isempty(OPT.timeOut)
        timeSpan = sprintf([...
            '<TimeSpan>\n'...
            '<begin>%s</begin>\n'...% OPT.timeIn
            '<end>%s</end>\n'...    % OPT.timeOut
            '</TimeSpan>\n'],...
            OPT.timeIn,OPT.timeOut);
    else
        timeSpan = sprintf([...
            '<TimeStamp>\n'...
            '<when>%s</when>\n'...  % OPT.timeIn
            '</TimeStamp>\n'],...
            OPT.timeIn);
    end
else
    timeSpan ='';
end
%% preproces altitude mode
if strcmpi(z,'clampToGround')
    altitudeMode = sprintf([...
        '<altitudeMode>clampToGround</altitudeMode>\n']);
    z = zeros(size(lon));
else
    altitudeMode = sprintf([...
        '%s'...extrude
        '<altitudeMode>absolute</altitudeMode>\n'],...
        extrude);
end
%% preproces coordinates
% outer coordinates
ii=1;
nn = ~isnan(lon(:,ii));
coords=[lon(nn,ii)'; lat(nn,ii)'; z(nn,ii)'];

coordPrintString = sprintf('%%3.%df,%%3.%df,%%3.3f\\n',OPT.precision,OPT.precision);

outerCoords  = sprintf([...
    '<outerBoundaryIs>\n'...
    '<LinearRing>\n'...
    '<coordinates>\n'...
    '%s'...                        % coordinates
    '</coordinates>\n'...
    '</LinearRing>\n'...
    '</outerBoundaryIs>\n'],...
    sprintf(...
       coordPrintString,...       % coords (separated by \n or space)
    coords));


% inner coordinates
if size(lat,2)>1 % only add if they are there
    innerCoords = sprintf([...
        '<innerBoundaryIs>\n']);
    for ii = 2:size(lat,2)
        nn = ~isnan(lon(:,ii));
        coords=[lon(nn,ii)'; lat(nn,ii)'; z(nn,ii)'];
        
        innerCoords  = sprintf([...
            '%s'...
            '<LinearRing>\n'...
            '<coordinates>\n'...
            '%s'...                        % coordinates
            '</coordinates>\n'...
            '</LinearRing>\n'],...
            innerCoords,...
            sprintf(...
            '%3.8f,%3.8f,%3.3f\n',...       % coords (separated by \n or space)
            coords));
    end
    innerCoords = sprintf([...
        '%s'...
        '</innerBoundaryIs>\n'],...
        innerCoords);
else
    innerCoords = '';
end






%% generate output
output = sprintf([...
    '<Placemark>\n'...
    '%s'...                        % visibility
    '%s'...                        % timeSpan
    '<name>%s</name>\n'...         % OPT.name
    '<styleUrl>#%s</styleUrl>\n'...% OPT.styleName
    '<Polygon>\n'...
    '%s'...                        % altitudeMode
    '%s'...                        % outer coordinates
    '%s'...                        % inner coordinates
     '</Polygon>\n'...
    '</Placemark>\n'],...
    visibility,timeSpan,OPT.name,OPT.styleName,altitudeMode,outerCoords,innerCoords);

%% EOF