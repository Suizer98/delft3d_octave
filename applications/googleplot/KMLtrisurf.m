function [OPT, Set, Default] = KMLtrisurf(tri,lat,lon,z,varargin)
% KMLTRISURF   Just like trisurf
%
%   [OPT, Set, Default] = KMLtrisurf(tri,lat,lon,z  ,<keyword,value>)
%   [OPT, Set, Default] = KMLtrisurf(tri,lat,lon,z,c,<keyword,value>)
%
% use in combination with delaunay_simplified to make simple grids
% that google can easily display 
%
% For the <keyword,value> pairs and their defaults call
%
%    OPT = KMLtrisurf()
%
% See also: googlePlot, surf, delaunay_simplified

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

% $Id: KMLtrisurf.m 7951 2013-01-25 14:26:27Z bcj@X $
% $Date: 2013-01-25 22:26:27 +0800 (Fri, 25 Jan 2013) $
% $Author: bcj@X $
% $Revision: 7951 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/googleplot/KMLtrisurf.m $
% $Keywords: $

%% process varargin

   % deal with colorbar options first
   OPT                    = KMLcolorbar();
   OPT                    = mergestructs(OPT,KML_header());
   % rest of the options
   OPT.fileName           = '';
   OPT.lineWidth          = 1;
   OPT.lineColor          = [0 0 0];
   OPT.lineAlpha          = 1;
   OPT.colorMap           = @(m) jet(m);
   OPT.colorSteps         = 16;
   OPT.fillAlpha          = 0.6;

   OPT.polyOutline        = false; % outlines the polygon, including extruded edges
   OPT.polyFill           = true;
   OPT.openInGE           = false;
   OPT.reversePoly        = false;
   OPT.extrude            = false;

   OPT.cLim               = [];
   OPT.zScaleFun          = @(z) (z+20).*5;
   OPT.colorbar           = 1;

   OPT.precision          = 8;
   OPT.tessellate         = false;
   OPT.is3D               = true;
   
if nargin==0
  return
end

%% limited error check

   if ~isequal(size(lat),size(lon))
       error('lat and lon must be same size')
   end
   if all(isnan(z(:)))
       disp('warning: No surface could be constructed, because there was no valid height data provided...') %#ok<WNTAG>
       return
   end

%% determine if 3D
if strcmpi(z,'clampToGround') || ~OPT.is3D
   OPT.is3D = false;
else
   OPT.is3D = true;
end

%% vectorize inputs
lat = lat(:);
lon = lon(:);
z   = z(:);

%% assign c if it is given

   if ~isempty(varargin)
       if ~ischar(varargin{1})&&~isstruct(varargin{1});
           c = varargin{1};
           varargin = varargin(2:length(varargin));
       else
           c =  mean(z(tri),2);
       end
   else
       c =  mean(z(tri),2);
   end

%% set properties
[OPT, Set, Default] = setproperty(OPT, varargin{:});

%% get filename, gui for filename, if not set yet

   if isempty(OPT.fileName)
      [fileName, filePath] = uiputfile({'*.kml','KML file';'*.kmz','Zipped KML file'},'Save as',[mfilename,'.kml']);
      OPT.fileName = fullfile(filePath,fileName);
   end

%% set kmlName if it is not set yet

   if isempty(OPT.kmlName)
      [ignore OPT.kmlName] = fileparts(OPT.fileName);
   end

%% pre-process color data

   if isempty(OPT.cLim)
      OPT.cLim         = [min(c(:)) max(c(:))];
   end

   colorRGB = OPT.colorMap(OPT.colorSteps);

   % clip c to min and max 

   c(c<OPT.cLim(1)) = OPT.cLim(1);
   c(c>OPT.cLim(2)) = OPT.cLim(2);

   %  convert color values into colorRGB index values

   c = round(((c-OPT.cLim(1))/(OPT.cLim(2)-OPT.cLim(1))*(OPT.colorSteps-1))+1);

%% start KML

   OPT.fid=fopen(OPT.fileName,'w');
   
   output = KML_header(OPT);
   
   if OPT.colorbar
      clrbarstring = KMLcolorbar(OPT);
      output = [output clrbarstring];
   end

%% STYLE

   OPT_stylePoly = struct(...
       'name'       ,['style' num2str(1)],...
       'fillColor'  ,colorRGB(1,:),...
       'lineColor'  ,OPT.lineColor,...
       'lineAlpha'  ,OPT.lineAlpha,...
       'lineWidth'  ,OPT.lineWidth,...
       'fillAlpha'  ,OPT.fillAlpha,...
       'polyFill'   ,OPT.polyFill,...
       'polyOutline',OPT.polyOutline); 
   for ii = 1:OPT.colorSteps
       OPT_stylePoly.name = ['style' num2str(ii)];
       OPT_stylePoly.fillColor = colorRGB(ii,:);
       output = [output KML_stylePoly(OPT_stylePoly)];
   end
   
   % print and clear output
   
   output = [output '<!--############################-->' fprinteol];
   fprintf(OPT.fid,output);output = '';
   
%% POLYGON

   OPT_poly = struct(...
            'name','',...
       'styleName',['style' num2str(1)],...
          'timeIn',datestr(OPT.timeIn ,OPT.dateStrStyle),...
         'timeOut',datestr(OPT.timeOut,OPT.dateStrStyle),...
      'visibility',1,...
         'extrude',OPT.extrude,...
      'tessellate',OPT.tessellate,...
      'precision' ,OPT.precision);
   
   % preallocate output
   
   output = repmat(char(1),1,1e5);
   kk = 1;
   
   disp(['creating surf with ' num2str(size(tri,1)) ' elements...'])
   
   if OPT.reversePoly
      tri =  tri(:,[3 2 1]);
   end
   
   for ii=1:size(tri,1)
       OPT_poly.styleName = sprintf('style%d',c(ii));
       if OPT.is3D
           newOutput = KML_poly(lat(tri(ii,[1:3 1])),...
               lon(tri(ii,[1:3 1])),...
               OPT.zScaleFun(z(tri(ii,[1:3 1]))),OPT_poly);  % make sure that LAT(:),LON(:), Z(:) have correct dimension nx1
       else
           newOutput = KML_poly(lat(tri(ii,[1:3 1])),...
               lon(tri(ii,[1:3 1])),...
               'clampToGround',OPT_poly);  % make sure that LAT(:),LON(:), Z(:) have correct dimension nx1
       end
       output(kk:kk+length(newOutput)-1) = newOutput;
       kk = kk+length(newOutput);
       if kk>1e5
           %then print and reset
           fprintf(OPT.fid,output(1:kk-1));
           kk = 1;
           output = repmat(char(1),1,1e5);
       end
   end
   fprintf(OPT.fid,output(1:kk-1)); % print output
   output = '';

%% close KML

   output = KML_footer;
   fprintf(OPT.fid,output);
   fclose(OPT.fid);

%% compress to kmz?

   if strcmpi  ( OPT.fileName(end-2:end),'kmz')
       movefile( OPT.fileName,[OPT.fileName(1:end-3) 'kml'])
       zip     ( OPT.fileName,[OPT.fileName(1:end-3) 'kml']);
       movefile([OPT.fileName '.zip'],OPT.fileName)
       delete  ([OPT.fileName(1:end-3) 'kml'])
   end

%% openInGoogle?

   if OPT.openInGE
       system(OPT.fileName);
   end

%% EOF
