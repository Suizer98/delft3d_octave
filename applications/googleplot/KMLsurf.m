function varargout = KMLsurf(lat,lon,z,varargin)
% KMLSURF Just like surf, writes closed OGC KML LinearRing Polygons
%
%   KMLsurf(lat,lon,z,<keyword,value>)
%   KMLsurf(lat,lon,z,c,<keyword,value>)
%
% where z needs to be specified at the corners (same size as lon,lat
% wheras c can be specified  either at the corners or at the centers.
% If c and lat/lon have the same dimensions, c is interpolated to be 
% the mean value of the surrounding gridpoints with corner2center().Therefore
% the resulting kml file always has 'shading flat' look since Google Earth
% does not support 'shading interp' look.
% Note: lat, and lon can be either vectors or full curvi-linear matrices.
% Note: when z is empty, z=0 is assumed.
%
% Note: for large grids, KMLpcolor objects migth be slow in Google 
% Earth, use KMLfigure_tiler instead, that uses the native Google Earth
% technology to speed up visualisation of enormous grids. KMLfigure_tiler
% does not support z data though, so behaves as KMLpcolor (a wrapper for KMLsurf).
% KMLmesh order of magnitude faster then KMLsurf, KMLmesh is recommended to
% test KMLsurf calls during debugging (KML has no colors).
%
% For the <keyword,value> pairs and their defaults call
%
%    OPT = KMLsurf()
%
% The keyword 'colorMap' can either be a function handle to be sampled with
% keyword 'colorSteps', or a colormap rgb array (then 'colorSteps' is ignored).
%
% Example:
%
%  [x,y,z]=peaks;
%  KMLsurf(x,y,z,'fileName','peaks.kml','zScaleFun',@(z) 1e5*z + 1e5)
%
% See also: googlePlot, surf

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

% $Id: KMLsurf.m 12177 2015-08-17 01:39:00Z r.measures.x $
% $Date: 2015-08-17 09:39:00 +0800 (Mon, 17 Aug 2015) $
% $Author: r.measures.x $
% $Revision: 12177 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/googleplot/KMLsurf.m $
% $Keywords: $

%% process <keyword,value>
   % get colorbar options first
   OPT                    = KMLcolorbar();
   OPT                    = mergestructs(OPT,KML_header());
   % rest of the options
   OPT.fileName           = '';
   OPT.lineWidth          = 1;
   OPT.lineColor          = [0 0 0];
   OPT.lineAlpha          = 1;
   OPT.colorMap           = @(m) jet(m); % function(OPT.colorSteps) or an rgb array
   OPT.colorSteps         = 16;
   OPT.fillAlpha          = 1.0; % you cna use the alpha slider in Google Earth
   OPT.polyOutline        = false;
   OPT.polyFill           = true;
   OPT.openInGE           = false;
   OPT.reversePoly        = false;
   OPT.extrude            = false;                                          % when true: tethered to the ground by a tail
   OPT.clampToGround      = false;                                          % when true: ignore Z and clamp to ground
   OPT.cLim               = [];
   OPT.zScaleFun          = @(z) (z+20).*5;
   OPT.colorbar           = 1;
   OPT.disp               = 1;
   OPT.CBtemplateHor      = 'KML_colorbar_template_horizontal.png';
   OPT.CBtemplateVer      = 'KML_colorbar_template_vertical.png';
   OPT.CBcolorTitle       = '';
   OPT.CBfontrgb          = [0 0 0];        % black
   OPT.CBalpha            = 0.8;            % transparency
   
   if nargin==0
      varargout = {OPT};
      return
   end
   
%% 
   if isvector(lat) & isvector(lon)
      [lat,lon] = meshgrid(lat,lon);
   end
   
   if isempty(z)
      z = 0.*lat;
   else
   end

%% assign c if it is given

   if ~isempty(varargin)
       if ~ischar(varargin{1})&&~isstruct(varargin{1});
           c = varargin{1};
           varargin = varargin(2:length(varargin));
       else
           c = z;
       end
   else
       c = z;
   end

%% set properties

   [OPT, Set, Default] = setproperty(OPT, varargin{:});

%% get filename, gui for filename, if not set yet

   if isempty(OPT.fileName)
    [fileName, filePath] = uiputfile({'*.kmz','Zipped KML file';'*.kml','KML file + separate image files'},'Save as',[mfilename,'.kmz']);
      OPT.fileName = fullfile(filePath,fileName);
   end

%% set kmlName if it is not set yet

   if isempty(OPT.kmlName) & ~(OPT.fileName==-1)
      [ignore OPT.kmlName] = fileparts(OPT.fileName);
   end

%% error check

   if all(isnan(z(:)))
      disp('warning: No surface could be constructed, because there was no valid height data provided...') %#ok<WNTAG>
      return
   end

%% calaculate center color values

   if all(size(c)==size(lat))
       c = (c(1:end-1,1:end-1)+...
            c(2:end-0,2:end-0)+...
            c(2:end-0,1:end-1)+...
            c(1:end-1,2:end-0))/4;
   elseif ~all(size(c)+[1 1]==size(lat))
       error('wrong color dimension, must be equal or one less as lat/lon')
   end

%% pre-process color data

   if isempty(OPT.cLim)
      OPT.cLim         = [min(c(:)) max(c(:))];
   end

   if isnumeric(OPT.colorMap)
      OPT.colorSteps = size(OPT.colorMap,1);
   end
   
   if isa(OPT.colorMap,'function_handle')
     colorRGB           = OPT.colorMap(OPT.colorSteps);
   elseif isnumeric(OPT.colorMap)
     if size(OPT.colorMap,1)==1
       colorRGB         = repmat(OPT.colorMap,[OPT.colorSteps 1]);
     elseif size(OPT.colorMap,1)==OPT.colorSteps
       colorRGB         = OPT.colorMap;
     else
       error(['size ''colorMap'' (=',num2str(size(OPT.colorMap,1)),') does not match ''colorSteps''  (=',num2str(OPT.colorSteps),')'])
     end
   end

   % clip c to min and max 

   c(c<OPT.cLim(1)) = OPT.cLim(1);
   c(c>OPT.cLim(2)) = OPT.cLim(2);

   %  convert color values into colorRGB index values

   c = round(((c-OPT.cLim(1))/(OPT.cLim(2)-OPT.cLim(1)+eps)*(OPT.colorSteps-1))+1);

%% start KML

if ~(OPT.fileName==-1)

   OPT.fid=fopen(OPT.fileName,'w');
   output = KML_header(OPT); % only subset of fields

   if OPT.colorbar
     [clrbarstring,pngNames] = KMLcolorbar(OPT);
      output = [output clrbarstring];
   else
      pngNames = {};
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
       OPT_stylePoly.name      = ['style' num2str(ii)];
       OPT_stylePoly.fillColor = colorRGB(ii,:);
       if strcmpi(OPT.lineColor,'fillColor')
           OPT_stylePoly.lineColor = colorRGB(ii,:);
       end
       output = [output KML_stylePoly(OPT_stylePoly)];
   end
   
   % print and clear output
   
   output = [output '<!--############################-->' fprinteol];
   fprintf(OPT.fid,'%s',output); output = '';
   fprintf(OPT.fid,'<Folder>');
   fprintf(OPT.fid,'  <name>patches</name>');
   fprintf(OPT.fid,'  <open>0</open>');
   
end

%% POLYGON

   OPT_poly = struct(...
   'name'      ,'',...
   'styleName' ,['style' num2str(1)],...
   'timeIn'    ,datestr(OPT.timeIn ,OPT.dateStrStyle),...
   'timeOut'   ,datestr(OPT.timeOut,OPT.dateStrStyle),...
   'visibility',1,...
   'extrude'   ,OPT.extrude);
   
   % preallocate output
   
   output = repmat(char(1),1,1e5);
   kk = 1;
   
   % put nan values in lat and lon on a size -1 array
   
   lat_nan = isnan(lat(1:end-1,1:end-1)+...
                   lat(2:end-0,2:end-0)+...
                   lat(2:end-0,1:end-1)+...
                   lat(1:end-1,2:end-0));
   lon_nan = isnan(lon(1:end-1,1:end-1)+...
                   lon(2:end-0,2:end-0)+...
                   lon(2:end-0,1:end-1)+...
                   lon(1:end-1,2:end-0)); 
   col_nan = isnan(c);
   
   % add everything into a 'not'nan' array, of size: size(lat)-[1 1]
   
   not_nan = ~(lat_nan|lon_nan|col_nan);         
   disp(['creating surf with ' num2str(sum(sum(not_nan))) ' elements...'])
   
   for ii=1:length(lat(:,1))-1
       if OPT.disp
          disp(['progress ',num2str(ii),'/',num2str(length(lat(:,1))-1)])
       end
       for jj=1:length(lon(1,:))-1
           if not_nan(ii,jj)
               LAT = [lat(ii+1,jj) lat(ii+1,jj+1) lat(ii,jj+1) lat(ii,jj) lat(ii+1,jj)];
               LON = [lon(ii+1,jj) lon(ii+1,jj+1) lon(ii,jj+1) lon(ii,jj) lon(ii+1,jj)];
               Z =   [  z(ii+1,jj)   z(ii+1,jj+1)   z(ii,jj+1)   z(ii,jj)   z(ii+1,jj)];
               OPT_poly.styleName = sprintf('style%d',c(ii,jj));
               if OPT.reversePoly
                   LAT = LAT(end:-1:1);
                   LON = LON(end:-1:1);
                     Z =   Z(end:-1:1);
               end
               if OPT.clampToGround
                   newOutput = KML_poly(LAT(:),LON(:),'clampToGround',OPT_poly);
               else
                   newOutput = KML_poly(LAT(:),LON(:),OPT.zScaleFun(Z(:)),OPT_poly); % make sure that LAT(:),LON(:), Z(:) have correct dimension nx1
               end
               output(kk:kk+length(newOutput)-1) = newOutput;
               kk = kk+length(newOutput);
               if kk>length(output)
                   if ~(OPT.fileName==-1)
                      %then print and reset
                      fprintf(OPT.fid,output(1:kk-1));
                      kk = 1;
                      output = repmat(char(1),1,1e5);
                   else % each time make twice as big
                      output0 = output;
                      output = repmat(char(1),1,2*length(output));
                      output(1:kk-1) = output0(1:kk-1);
                      clear outpout0
                   end
               end
           end
       end
   end
   
if ~(OPT.fileName==-1)
   
   fprintf(OPT.fid,output(1:kk-1)); % print
   
   fprintf(OPT.fid,'</Folder>');

%% close KML

   fprintf(OPT.fid,KML_footer);
   fclose(OPT.fid);

%% compress to kmz and include image fileds

   if strcmpi  ( OPT.fileName(end-2:end),'kmz')
      movefile( OPT.fileName,[OPT.fileName(1:end-3) 'kml'])
      if OPT.colorbar
          files = [{[OPT.fileName(1:end-3) 'kml']},pngNames];
      else
          files =  {[OPT.fileName(1:end-3) 'kml']};
      end
      zip     ( OPT.fileName,files);
      for ii = 1:length(files)
          delete  (files{ii})
      end
      movefile([OPT.fileName '.zip'],OPT.fileName)
   end

%% openInGoogle?

   if OPT.openInGE
       system(OPT.fileName);
   end
   
end

if nargout==1
   varargout = {output(1:kk-1)};
elseif nargout==2
   varargout = {output(1:kk-1),pngNames};
end

%% EOF
