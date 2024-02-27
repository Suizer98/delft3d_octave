function varargout = KMLcolumn(lat,lon,z,c,varargin)
%KMLcolumn   draw a 3D cylinder at a specific location
%
%   KMLcolumn(lat,lon,z,c,R,<keyword,value>)
%
%    lat,lon cells with one double each
%    z       cell with top & bottom coordinates of the layers (length(c)+1)
%    c       cell with values that are colors of the layers   (length(z)-1)
%    R       Radius of the cylinder (double)
%
% Saves layers as nested columns of decreasing radius, each  
% extruded to the Earth's surface. All segments are extruded  
% to ground level, floating columns are not possible, use  
% KMLcylinder for that (slower in Google Earth though).
%
%  example:
%
%    KMLcolumn({51.9859},{4.3815},{[0 1 2 4 8 16 32]},{[1 2 3 4 5 6]},5e3,'fileName','KMLcylinder_test.kml')
%
% See also: googlePlot, KMLcylinder

%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares for NMDC.eu
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

% $Id: KMLcolumn.m 10615 2014-04-28 10:03:00Z boer_g $
% $Date: 2014-04-28 18:03:00 +0800 (Mon, 28 Apr 2014) $
% $Author: boer_g $
% $Revision: 10615 $
% % $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/googleplot/KMLcolumn.m $
% $Keywords: $

%% process varargin

   % deal with colorbar options first
   OPT                    = KMLcolorbar();
   OPT                    = mergestructs(OPT,KML_header());
   % rest of the options
   OPT.nTH                = 12; % number of facets on side of cylinder
   OPT.R                  = 1000; % radius in m
   OPT.dR                 = 10; % reduction of Radius per layer
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
   OPT.lineOutline        = true;  % outlines the interface between column segments, EXCLUDING EXTRUDED EDGES
   OPT.polyOutline        = false; % outlines the all polygon faces, INCLUDING EXTRUDED EDGES
   OPT.polyFill           = true;
   OPT.openInGE           = false;
   OPT.reversePoly        = [];
   OPT.colorNaN           = [.5 .5 .5]; % 

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

% for cap

   if OPT.lineOutline
   OPT_stylePoly = struct(...
       'name'       ,['style0' ],...
       'lineColor'  ,OPT.lineColor,...
       'lineAlpha'  ,OPT.lineAlpha,...
       'lineWidth'  ,OPT.lineWidth,...
       'polyFill'   ,false,...
       'polyOutline',OPT.lineOutline); 
      output = [output KML_stylePoly(OPT_stylePoly)];
   end

% for body faces

   OPT_stylePoly = struct(...
       'name'       ,['style' num2str(1)],...
       'lineColor'  ,OPT.lineColor,...
       'lineAlpha'  ,OPT.lineAlpha,...
       'lineWidth'  ,OPT.lineWidth,...
       'fillColor'  ,colorRGB(1,:),...
       'fillAlpha'  ,OPT.fillAlpha,...
       'polyFill'   ,OPT.polyFill,...
       'polyOutline',OPT.polyOutline); 
   for ii = 1:OPT.colorSteps
       OPT_stylePoly.name = ['style' num2str(ii)];
       OPT_stylePoly.fillColor = colorRGB(ii,:);
       output = [output KML_stylePoly(OPT_stylePoly)];
   end

% for base for floating column

   OPT_stylePoly = struct(...
       'name'       ,['styleNaN' ],...
       'lineColor'  ,OPT.lineColor,...
       'lineAlpha'  ,OPT.lineAlpha,...
       'lineWidth'  ,OPT.lineWidth,...
       'fillColor'  ,OPT.colorNaN,...
       'fillAlpha'  ,OPT.fillAlpha,...
       'polyFill'   ,OPT.polyFill,...
       'polyOutline',OPT.polyOutline); 
      output = [output KML_stylePoly(OPT_stylePoly)];

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
         'extrude',true,...
      'tessellate',OPT.tessellate,...
      'precision' ,OPT.precision);

   if OPT.lineOutline
   OPT_polycap = OPT_poly;
   OPT_polycap.styleName = 'style0';
   OPT_polycap.extrude   = 0;
   end

%% pre-process cylinder perimeter

   TH0     = linspace(0,2*pi,OPT.nTH+1); % nTH is number of faces = non-overllaping edges (first=last)

   for i=1:length(lon) % cycle cylinders
   
       if mod(i,10)==0
       disp([mfilename,': processing ',num2str(i),'/',num2str(length(lon))])
       end
       
       % preallocate output

       output = repmat(char(1),1,1e5);
       kk = 1;

   %% calculate projected cylinder layer 'in place'
       
       % TO DO: move outside loop?
       [x,y] = convertCoordinates(lon{i}(1),lat{i}(1),'persistent','CS1.code',4326,'CS2.code',OPT.epsg);% local center of circle
       
   %% loop cylinder layers

        lat1 = repmat(nan,[OPT.nTH+1,length(c{i})]);
        lon1 = repmat(nan,[OPT.nTH+1,length(c{i})]);
        dx   = repmat(nan,[OPT.nTH+1,length(c{i})]);
        dy   = repmat(nan,[OPT.nTH+1,length(c{i})]);
        X    = repmat(  x,[OPT.nTH+1,length(c{i})]);
        Y    = repmat(  y,[OPT.nTH+1,length(c{i})]);
        
        for ii=length(c{i}):-1:1 % cycle layers
          [TH, R] = meshgrid(TH0,OPT.R - (ii-1).*OPT.dR);
          [dx(:,ii),dy(:,ii)] = pol2cart(TH,R);
        end

       [lon1,lat1] = convertCoordinates(X+dx,Y+dy,'persistent','CS1.code',OPT.epsg,'CS2.code',4326);% spherical perimeter of circle
       
        for ii=length(c{i}):-1:1 % cycle layers
        
        % draw cap to be extruded

           OPT_poly.styleName = sprintf('style%d',c{i}(ii));
           newOutput = KML_poly(lat1(:,ii),lon1(:,ii),OPT.zScaleFun(lon1(:,ii).*0+z{i}(ii+1)),OPT_poly); % make sure that LAT(:),LON(:), Z(:) have correct dimension nx1
           output(kk:kk+length(newOutput)-1) = newOutput;
           kk = kk+length(newOutput);
           
        % draw outline of cap (not to be extruded)

           if OPT.lineOutline
           newOutput = KML_poly(lat1(:,ii),lon1(:,ii),OPT.zScaleFun(lon1(:,ii).*0+z{i}(ii+1)),OPT_polycap); % make sure that LAT(:),LON(:), Z(:) have correct dimension nx1
           end
           output(kk:kk+length(newOutput)-1) = newOutput;
           kk = kk+length(newOutput);

        % handle cylinder where lowest segment does not go down to earth
        % this one has no additional dR, so you see it flickering in Google

           if  ii==1 & ~(z{i}(1)==0)
           disp('warning: KMLcolumn: column extended down to earth')
           OPT_poly.styleName = 'styleNaN';
           newOutput = KML_poly(lat1(:,ii),lon1(:,ii),OPT.zScaleFun(lon1(:,ii).*0+z{i}(ii)),OPT_poly); % make sure that LAT(:),LON(:), Z(:) have correct dimension nx1
           output(kk:kk+length(newOutput)-1) = newOutput;
           kk = kk+length(newOutput);
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
       system(OPT.fileName);
   end
   
   varargout = {};

%% EOF
