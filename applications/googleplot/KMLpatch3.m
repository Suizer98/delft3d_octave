function varargout = KMLpatch3(lat,lon,z,varargin)
%KMLPATCH3 Just like patch
%
%    KMLpatch3(lat,lon,z,<C>,<keyword,value>)
% 
% adds the "patch" or filled 2-D polygon defined by
% vectors lat and lon.
%
% lat and lon and z must be vectors. Each column of lat, lon and 
% z after the first is interpreted as an inner boundary (hole) of 
% the first polygon (see KML_poly).
%
% Color C of the faces ("flat" coloring) be specified on two 
% ways, coloring of the vertices ("interpolated" coloring) is not 
% possible in contrast to Matlab's PATCH.
% * An RGB triplet can be specified by leaving out the optional argument
%   C and setting the fillColor property to an RGB triplet [0..1].
% * If C is a scalar it is interpretered as the color of the face(s) 
%   by indexing into the colormap property specified with 'colormap',
%   'colorSteps' and 'cLim'.
%
% KMLpatch3 works for 
% * single patches: lat, lon and z must be vectors, c a scalar, and
%   fillColor a single rgb triplet.
% * a set of patches: lat, lon and z must be cell arrays, c must be
%   a regular array with the same length as the cells or a scalar.
%   NB If your patches are only triangles you might better use KMLtrisurf.
%
% For other the <keyword,value> pairs and their defaults call:
%
%    OPT = KMLpatch()
%
% See also: googlePlot, KMLpatch, KMLtrisurf, KML_poly, patch

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

% $Id: KMLpatch3.m 10249 2014-02-19 15:59:44Z bartjan.spek.x $
% $Date: 2014-02-19 23:59:44 +0800 (Wed, 19 Feb 2014) $
% $Author: bartjan.spek.x $
% $Revision: 10249 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/googleplot/KMLpatch3.m $
% $Keywords: $

%% process varargin

    % deal with colorbar options first
    OPT                    = KMLcolorbar();
    OPT                    = mergestructs(OPT,KML_header());
    % rest of the options
    OPT.fileName           = '';
    OPT.kmlName            = '';
    OPT.name               = '';
    OPT.lineWidth          = 1;
    OPT.lineColor          = [0 0 0];
    OPT.lineAlpha          = 1;
    OPT.colorMap           = [];
    OPT.colorSteps         = 1;
    OPT.fillAlpha          = 0.3;
    OPT.polyOutline        = false; % outlines the polygon, including extruded edges
    OPT.polyFill           = true;
    OPT.openInGE           = false;
    OPT.extrude            = true;

    OPT.cLim               = [];
    OPT.zScaleFun          = @(z) (z+0).*1;
    OPT.timeIn             = now;%[];
    OPT.timeOut            = now;%[];
    OPT.dateStrStyle       = 'yyyy-mm-ddTHH:MM:SS';
    OPT.colorbar           = 0;
    OPT.fillColor          = [];

    OPT.text               = '';
    OPT.latText            = [];
    OPT.lonText            = [];
    OPT.precision          = 8;
    OPT.tessellate         = false;
    OPT.lineOutline        = true; % draws a separate line element around the polygon. Outlines the polygon, excluding extruded edge
   
   if nargin==0
      varargout = {OPT};
      return
   else
       OPT.latText     = lat(1);
       OPT.lonText     = lon(1);
   end

   if ~odd(nargin) % x,y,z,c
       if isstruct(varargin{1})
           c = [];
           OPT = setproperty(OPT, varargin{:});
       else
           c            = varargin{1};
           OPT.colorbar = 1;
           OPT = setproperty(OPT, varargin{2:end});
       end
   else % x,y,z
       if isstruct(varargin{2})
           c            = varargin{1};
           OPT.colorbar = 1;
           OPT = setproperty(OPT, varargin{2});
       else
           c = [];
           OPT = setproperty(OPT, varargin{:});
       end
   end
   
%% limited error check

    if ~isequal(size(lat),size(lon))
        error('lat and lon must be same size')
    end
    if ischar(z)
        if ~strcmp(z,'clampToGround')
            error('z and lon must be same size, or z must be a single level, or z must be clampToGround')
        end
        z = {z};
        OPT.zScaleFun = @(z) z;
    else
        if ~isequal(size(z),size(lat));
            if numel(z) == 1
                z = zeros(size(lat))+z;
            else
                error('z and lon must be same size, or z must be a single level, or z must be clampToGround')
            end
        end
    end

%% get filename, gui for filename, if not set yet

   if isempty(OPT.fileName)
    [fileName, filePath] = uiputfile({'*.kmz','Zipped KML file';'*.kml','KML file + separate image files'},'Save as',[mfilename,'.kmz']);
      OPT.fileName = fullfile(filePath,fileName);
   end

%% set kmlName if it is not set yet

   if isempty(OPT.kmlName)
      [~, OPT.kmlName] = fileparts(OPT.fileName);
   end


%% pre-process color data

   if   ~isempty(OPT.fillColor) &&  isempty(OPT.colorMap) && OPT.colorSteps==1
       colorRGB = OPT.fillColor;
       c = 1;
   elseif  isempty(OPT.fillColor) && ~isempty(OPT.colorMap)
   
       if isempty(OPT.cLim)
          OPT.cLim         = [min(c(:)) max(c(:))];
       end
      
       colorRGB = OPT.colorMap(OPT.colorSteps);
      
       % clip c to min and max 
      
       c(c<OPT.cLim(1)) = OPT.cLim(1);
       c(c>OPT.cLim(2)) = OPT.cLim(2);
      
       %  convert color values into colorRGB index values
      
       c = round(((c-OPT.cLim(1))/(OPT.cLim(2)-OPT.cLim(1)+eps)*(OPT.colorSteps-1))+1);
       
   elseif   isempty(OPT.fillColor) && isempty(OPT.colorMap) && OPT.colorSteps==1

       error('either keyword fillColor or keyword colorMap needs to be specified')

   else
       
       error('keywords fillColor and colorMap cannot be used simultaneously')
      
   end

%% start KML

   OPT.fid=fopen(OPT.fileName,'w');

   output = KML_header(OPT);

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
       OPT_stylePoly.name = ['style' num2str(ii)];
       OPT_stylePoly.fillColor = colorRGB(ii,:);
       output = [output KML_stylePoly(OPT_stylePoly)];
   end

   % print and clear output
   
   output = [output '<!--############################-->' fprinteol];
   fprintf(OPT.fid,output);output = '';

%% POLYGON
if isempty(OPT.timeIn)
    tIn=[];
    tOut=[];
else
    tIn=datestr(OPT.timeIn (1),OPT.dateStrStyle);
    tOut=datestr(OPT.timeOut(1),OPT.dateStrStyle);
end

   OPT_poly = struct(...
            'name',OPT.name,...
       'styleName',['style' num2str(1)],...
      'visibility',1,...
         'extrude',OPT.extrude,...
          'timeIn',tIn,...
         'timeOut',tOut,...
      'tessellate',OPT.tessellate,...
      'precision' ,OPT.precision);
   
   if iscell(lat) && iscell(lon)
       
       if length(c)==1 % c can be constant for all patches
          csize = 1;
       else
          csize = length(c);
       end
       
       if length(z)==1 % z can be constant for all patches: a value but not yet 'clampToGround'
           zsize = 1;
       else
           zsize = length(z);
       end
       
       % preallocate output
       
       output = repmat(char(1),1,1e5);
       kk = 1;
       
       disp(['creating patch with ' num2str(length(lat)) ' elements...'])
       if length(OPT.timeIn)>1
           timeIn  = datestr(OPT.timeIn ,OPT.dateStrStyle);
           timeOut = datestr(OPT.timeOut,OPT.dateStrStyle);
       end
%                  'timeIn',datestr(OPT.timeIn ,OPT.dateStrStyle),...
%          'timeOut',datestr(OPT.timeOut,OPT.dateStrStyle),...
         
     
       for ii=1:length(lat)
           iic = min(ii,csize); % for constant c and z
           iiz = min(ii,zsize); % for constant c and z
           OPT_poly.styleName = sprintf('style%d',c(iic));
           if length(OPT.timeIn)>1
               OPT_poly.timeIn  = timeIn(ii,:);
               OPT_poly.timeOut = timeOut(ii,:);
           end
           % TO DO : deal with constant z, constant per patch or 'clampToGround';
           newOutput = KML_poly(lat{ii},...
               lon{ii},...
               OPT.zScaleFun(z{iiz}),OPT_poly);  % make sure that LAT(:),LON(:), Z(:) have correct dimension nx1
           
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
   else
       OPT_poly.styleName = sprintf('style%d',c);
       output = [output KML_poly(lat,lon,OPT.zScaleFun(z),OPT_poly)]; % make sure that lat(:),lon(:) have correct dimension nx1
   end
   
   if OPT.lineOutline && isempty(c)
       OPT_line = struct(...
            'name','',...
       'styleName','style',...
          'timeIn',tIn,...
         'timeOut',tOut,...
      'visibility',1,...
      'tessellate',OPT.tessellate,...   
      'precision' ,OPT.precision);
       
       lat(end+1,:) = nan;
       lon(end+1,:) = nan;
       if ~ischar(z)
           z  (end+1,:) = nan;
       end
       output = [output KML_line(lat,lon,OPT.zScaleFun(z),OPT_line)];
   end


%% text

   if ~isempty(OPT.text)
      output = [output KML_text(OPT.latText,OPT.lonText,OPT.text)];
   end

   fprintf(OPT.fid,output); % print output

%% close KML

   output = KML_footer;
   fprintf(OPT.fid,output);
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
   
   varargout = {};

%% EOF
