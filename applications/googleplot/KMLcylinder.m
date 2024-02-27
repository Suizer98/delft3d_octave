function varargout = KMLcylinder(lat,lon,z,c,R,varargin)
%KMLcylinder   draw a 3D cylinder at a specific location
%
%   KMLcylinder(lat,lon,z,c,R,<keyword,value>)
%
%    lat,lon must be cells with one double each
%    z must be a cell with top and bottom coordinates of the layers (length(c)+1
%    c must be a cell with values that are colors of the layers     (length(z)-1)
%
% Saves layer as stacked elements of equal radius.
%
%  example:
%
%    KMLcylinder({51.9859},{4.3815},{[0 1 2 4 8 16 32]},{[1 2 3 4 5 6]},5e3,'fileName','KMLcylinder_test.kml')
%
% NOTE: for large sets of cylinders use KMLcolumn!
%
% See also: googlePlot, KMLcolumn

%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares for Building with Nature
%       Gerben J. de Boer
%
%       gerben.deboer@Deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% $Id: KMLcylinder.m 9588 2013-11-06 10:21:02Z boer_g $
% $Date: 2013-11-06 18:21:02 +0800 (Wed, 06 Nov 2013) $
% $Author: boer_g $
% $Revision: 9588 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/googleplot/KMLcylinder.m $
% $Keywords: $

%% process varargin

   % deal with colorbar options first
   OPT                    = KMLcolorbar();
   OPT                    = mergestructs(OPT,KML_header());
   % rest of the options
   OPT.nTH                = 12; % number of facets on side of cylinder
   OPT.epsg               = 23031;
   
   OPT.fileName           = '';
   OPT.kmlName            = '';
   OPT.name               = '';
   OPT.lineWidth          = 1;
   OPT.lineColor          = [0 0 0];
   OPT.lineAlpha          = 1;
OPT.colorMap           = @(z) jet(z);
OPT.colorSteps         = 32;
   OPT.fillAlpha          = 1;
  %OPT.lineOutline        = true;  % TO BE IMPLEMENTED, see KMLcolumn
   OPT.polyOutline        = false; % outlines the polygon, including extruded edges
   OPT.polyFill           = true;
   OPT.openInGE           = false;
   OPT.reversePoly        = [];

OPT.cLim               = [];
   OPT.zScaleFun          = @(z) 1000*z;
   OPT.timeIn             = [];
   OPT.timeOut            = [];
   OPT.dateStrStyle       = 'yyyy-mm-ddTHH:MM:SS';
OPT.colorbar           = 0;
      OPT.fillColor          = [];

   OPT.precision          = 8;
   OPT.tessellate         = false;

   if nargin==0
      varargout = {OPT};
      return
   end

   [OPT, Set, Default] = setproperty(OPT, varargin{:});
   
%% limited error check
    if ~iscell(lon); lon = {lon};end
    if ~iscell(lat); lat = {lat};end
    if ~iscell(z  ); z   = {z  };end
    if ~iscell(c  ); c   = {c  };end

    if ~isequal(size(lat),size(lon),size(c),size(z))
        error('lat and lon must be same size')
    end
    
%% get filename, gui for filename, if not set yet

   if isempty(OPT.fileName)
      [fileName, filePath] = uiputfile({'*.kml','KML file';'*.kmz','Zipped KML file'},'Save as',[mfilename,'.kml']);
      OPT.fileName = fullfile(filePath,fileName);
   end

%% set kmlName if it is not set yet

   if isempty(OPT.kmlName)
      [ignore OPT.kmlName] = fileparts(OPT.fileName);
   end
   
%% pre-process cylinder perimeter

   TH     = linspace(0,2*pi,OPT.nTH+1); % nTH is number of faces = non-overllaping edges (first=last)
  [TH, R] = meshgrid(TH,R);
  [dx,dy] = pol2cart(TH,R);
  
%% pre-process color data

   if isempty(OPT.cLim)
      OPT.cLim         = [min(cell2mat(c)) max(cell2mat(c))];
   end

   for i=1:length(c)
   if   ~isempty(OPT.fillColor) &  isempty(OPT.colorMap) & OPT.colorSteps==1
       colorRGB = OPT.fillColor;
       c{i}        = 1;
   elseif  isempty(OPT.fillColor) & ~isempty(OPT.colorMap);
   
       if isempty(OPT.colorSteps)
           OPT.colorSteps = size(OPT.colorMap,1);
       end

       colorRGB = OPT.colorMap(OPT.colorSteps);
      
       % clip c to min and max 
      
       c{i}(c{i}<OPT.cLim(1)) = OPT.cLim(1);
       c{i}(c{i}>OPT.cLim(2)) = OPT.cLim(2);
      
       %  convert color values into colorRGB index values
      
       c{i} = round(((c{i}-OPT.cLim(1))/(OPT.cLim(2)-OPT.cLim(1)+eps)*(OPT.colorSteps-1))+1);
    else
       
       error('fillColor and colorMap cannot be used simultaneously')
      
   end
   end   

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
            'name',OPT.name,...
       'styleName',['style' num2str(1)],...
          'timeIn',datestr(OPT.timeIn ,OPT.dateStrStyle),...
         'timeOut',datestr(OPT.timeOut,OPT.dateStrStyle),...
      'visibility',1,...
         'extrude',false,...
      'tessellate',OPT.tessellate,...
      'precision' ,OPT.precision);

   for i=1:length(lon) % cycle cylinders
   
       disp([mfilename,': processing ',num2str(i),'/',num2str(length(lon))])
       
       % preallocate output

       output = repmat(char(1),1,1e5);
       kk = 1;

   %% calculate projected cylinder layer 'in place'
       
       [x,y] = convertCoordinates(lon{i}(1),lat{i}(1),'persistent','CS1.code',4326,'CS2.code',OPT.epsg);% local center of circle
        x = x + dx;% local perimeter of circle
        y = y + dy;
       [lon1,lat1] = convertCoordinates(x,y,'persistent','CS1.code',OPT.epsg,'CS2.code',4326);% spherical perimeter of circle
       
   %% loop cylinder layers

        for ii=1:length(c{i}) % cycle layers

           OPT_poly.styleName = sprintf('style%d',c{i}(ii));

           %% draw cap
           newOutput = KML_poly(lat1(:),lon1(:),OPT.zScaleFun(lon1(:).*0+z{i}(end)),OPT_poly); % make sure that LAT(:),LON(:), Z(:) have correct dimension nx1
           output(kk:kk+length(newOutput)-1) = newOutput;
           kk = kk+length(newOutput);

           %% draw sides
           for iii=1:OPT.nTH

               LAT = [lat1(iii+1) lat1(iii+1) lat1(iii)  lat1(iii) lat1(iii+1)];
               LON = [lon1(iii+1) lon1(iii+1) lon1(iii)  lon1(iii) lon1(iii+1)];
               Z =   [z{i}(ii)    z{i}(ii+1)  z{i}(ii+1) z{i}(ii)  z{i}(ii)];

               newOutput = KML_poly(LAT(:),LON(:),OPT.zScaleFun(Z(:)),OPT_poly); % make sure that LAT(:),LON(:), Z(:) have correct dimension nx1
               output(kk:kk+length(newOutput)-1) = newOutput;
               kk = kk+length(newOutput);
               if kk>1e5
                   %then print and reset
                   fprintf(OPT.fid,output(1:kk-1));
                   kk = 1;
                   output = repmat(char(1),1,1e5);
               end
                
           end
        end
        fprintf(OPT.fid,output(1:kk-1)); % print output
        output = '';
   end
   
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
       system([OPT.fileName ' &']);
   end
   
   varargout = {};

%% EOF