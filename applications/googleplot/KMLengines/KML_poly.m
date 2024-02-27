function varargout = KML_poly(lat,lon,varargin)
%KML_POLY  low-level routine for creating KML string of polygon
%
%   kmlstring = KML_poly(lat,lon,<z>,<keyword,value>)
%
% lat and lon and z must be vectors. Each column of lat, lon and 
% z after the first is interpreted as an inner boundary (hole) of 
% the first polygon (see KML_poly).
%
% z can be an arry too, or 'clampToGround'.
%
% The implemented <keyword,value> pairs and their defaults are given by
%
%   OPT = KML_line()
%
% Note that Google Earth shows an KML_poly object unsharp at small view 
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

% $Id: KML_poly.m 12864 2016-08-23 10:12:21Z huism_b $
% $Date: 2016-08-23 18:12:21 +0800 (Tue, 23 Aug 2016) $
% $Author: huism_b $
% $Revision: 12864 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/googleplot/KMLengines/KML_poly.m $
% $Keywords: $


%% keyword,value

   OPT.styleName   = [];
   OPT.visibility  = 1;
   OPT.extrude     = 0;
   OPT.timeIn      = [];
   OPT.timeOut     = [];
   OPT.name        = 'poly';
   OPT.tessellate  = 0;
   OPT.precision   = 8;
   OPT.description = '';
   
if nargin==0; varargout = {OPT}; return; end

if nargin==2
   z       = 'clampToGround';
   nextarg = 1;
elseif nargin==3
   z       = varargin{1};
else
   if  ( odd(nargin) && ~isstruct(varargin{2})) || ...
       (~odd(nargin) &&  isstruct(varargin{2}));
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

   OPT = setproperty(OPT,varargin{nextarg:end});
   
   if nargin==0
      varargout = {OPT};
      return
   end

   if isempty(OPT.styleName)
      warning('property ''stylename'' required');
   end

%% check
if ~iscell(z)
   if all(isnan(z(:)))
      varargout = {''};
      return
   end
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

%% preprocess tessellate

if  OPT.tessellate
    tessellate = '<tessellate>1</tessellate>\n';
else
    tessellate = '';
end

%% preprocess description

if  ~isempty(OPT.description)
    description = ['<description>' OPT.description '</description>\n'];
else
    description = '';
end
   
%% preproces timespan

   timeSpan = KML_timespan('timeIn',OPT.timeIn,'timeOut',OPT.timeOut);

%% preproces altitude mode

   if strcmpi(z,'clampToGround')
       altitudeMode = sprintf([...
           '<altitudeMode>clampToGround</altitudeMode>\n']);
       z = zeros(size(lon));
   elseif strcmpi(z,'relativeToGround')
       altitudeMode = sprintf([...
           '<altitudeMode>relativeToGround</altitudeMode>\n']);
       z = zeros(size(lon))+0.1;
   else
       altitudeMode = sprintf([...
           '%s'...extrude
           '<altitudeMode>absolute</altitudeMode>\n'],...
           extrude);
   end

%% preproces coordinates
%  outer coordinates

  ii=1;
  nn = find(~isnan(lon(:,ii)));
  
  if isempty(nn)
     return
  end
  % always make polygons counter clockwise
  if poly_isclockwise(lon(nn,ii),lat(nn,ii))
      nn = flipud(nn);
  end
  coords=[lon(nn,ii)'; lat(nn,ii)'; z(nn,ii)'];
  
  coordPrintString = sprintf('%%3.%df,%%3.%df,%%3.3f\\n',OPT.precision,OPT.precision);
  
  outerCoords  = sprintf([...
      '<outerBoundaryIs>\n'...
      '<LinearRing>\n'...
      '%s'...                        % tessellate
      '<coordinates>\n'...
      '%s'...                        % coordinates
      '</coordinates>\n'...
      '</LinearRing>\n'...
      '</outerBoundaryIs>\n'],...
      tessellate,...
      sprintf(...
         coordPrintString,...       % coords (separated by \n or space)
      coords));

%% inner coordinates

   if size(lat,2)>1 % only add if they are there
      innerCoords = sprintf([...
          '<innerBoundaryIs>\n']);
      for ii = 2:size(lat,2)
          nn = find(~isnan(lon(:,ii)));
          
          % always make polygons counter clockwise
          if poly_isclockwise(lon(nn,ii),lat(nn,ii))
              nn = flipud(nn);
          end
          coords=[lon(nn,ii)'; lat(nn,ii)'; z(nn,ii)'];
          
          innerCoords  = sprintf([...
              '%s'...
              '<LinearRing>\n'...
              '%s'...                        % tessellate
              '<coordinates>\n'...
              '%s'...                        % coordinates
              '</coordinates>\n'...
              '</LinearRing>\n'],...
              innerCoords,...
              tessellate,...
              sprintf(...
              coordPrintString,...       % coords (separated by \n or space)
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
    '%s'...                        % description
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
    description,visibility,timeSpan,OPT.name,OPT.styleName,altitudeMode,outerCoords,innerCoords);
    
    varargout = {output};

%% EOF