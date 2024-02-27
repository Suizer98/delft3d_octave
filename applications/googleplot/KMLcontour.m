function varargout = KMLcontour(lat,lon,c,varargin)
% KMLCONTOUR   Just like contour
%
%    KMLcontour(lat,lon,c,<keyword,value>)
%
% For the <keyword,value> pairs and their defaults call
%
%    OPT = KMLcontour()
%
% The most important keywords are 'fileName', 'levels' and 'labelInterval';
%
%    KMLcontour(lat,lon,z,'fileName','mycontour.kml','levels',N)
%
% draws N contour lines when LENGTH(N)=1, or LENGTH(V) contour
% lines at the values specified in vector V. Use [v v] to plot
% a single contour at the level v. (same as CONTOUR). When
% 'labelInterval' is NaN (default) CLABEL is used to position
% the labels, otherwise the contour polygons are subsetted.
%
% The keyword 'colorMap' can either be a function handle to be sampled with
% keyword 'colorSteps', or a colormap rgb array (then 'colorSteps') is ignored).
%
% The kml code hat is written to file 'fileName' can optionally be returned.
%
%    kmlcode = KMLcontour(lat,lon,<keyword,value>)
%
% For 3D contours always use KMLcontour3.
%
% Example: 
%   [x,y,z] = peaks
%   KMLcontour(x,y,z)
%
% See also: googlePlot, contour, contour3, contour2poly

% 2014-mar-10 fixed contour2poly to deal with NaN in curvi-linear GCM models (Delft3D)

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

% $Id: KMLcontour.m 10373 2014-03-10 21:54:12Z boer_g $
% $Date: 2014-03-11 05:54:12 +0800 (Tue, 11 Mar 2014) $
% $Author: boer_g $
% $Revision: 10373 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/googleplot/KMLcontour.m $
% $Keywords: $

% TO DO: implement angle/rotation of Matlab clabels in KML_text()

   %% process <keyword,value>
   %  get colorbar and header options first
   OPT               = KMLcolorbar();
   OPT               = mergestructs(OPT,KML_header());
   % rest of the options
   OPT.levels        = 10;
   OPT.fileName      = '';
   OPT.lineWidth     = 1;
   OPT.lineAlpha     = 1;
   OPT.openInGE      = false;
   OPT.colorMap      = @(m) jet(m); % function(OPT.colorSteps) or an rgb array
   OPT.colorSteps    = 32;
   OPT.is3D          = false;
   OPT.cLim          = [];
   OPT.writeLabels   = true;
   OPT.colorbar      = 1;
   OPT.labelDecimals = 1;
   OPT.labelInterval = nan; % NaN means clabel is used
   OPT.zScaleFun     = @(z) (z+0)*0;
   OPT.extrude       = true;   

   OPT.zstride       = 1; % stride for interpolating z data to contours, only when z is supplied by KMLcontour3
  %OPT.zlim          = 1; % TO DO: call contour for z separately, and use those lines to interpolate z to c contour instead of griddata on full z matrix

%% 
   if nargin==0
    varargout = {OPT};
    return
   end
   
   if isvector(lat) & isvector(lon)
      [lat,lon] = meshgrid(lat,lon);
   end

%% check if labels are defined
%  see if height is defined
z = []; % empty means same as c
if ~isempty(varargin)
    if isnumeric(varargin{1})
        z = c;
        c = varargin{1}; % can be 'clampToGround',[] or array
        varargin(1) = [];
        OPT.writeLabels = true;
    else
        OPT.writeLabels = false;
    end
else
    OPT.writeLabels = false;
end

%% set properties

   [OPT, Set, Default] = setproperty(OPT, varargin{:});

%% input check

% correct lat and lon

   if any((abs(lat)/90)>1)
       error('latitude out of range, must be within -90..90')
   end
   lon = mod(lon+180, 360)-180;

% color limits

   if isempty(OPT.cLim)
       OPT.cLim = ([min(c(~isnan(c))) max(c(~isnan(c)))]);
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

%% find contours

   if OPT.writeLabels & isnan(OPT.labelInterval)
       FIG = figure('visible','on');
       [coords,h] = contour (lat,lon,c,OPT.levels);
   else
        coords    = contours(lat,lon,c,OPT.levels);
   end
   
   if length(coords)==0
       error(['no contours found, please check levels([1 end])=[',num2str(OPT.levels(1)),' - ',num2str(OPT.levels(end)),'] against c range [',num2str(min(c(:))),' - ',num2str(max(c(:))),']'])
   end

%% pre allocate into 2D array for KMLline

  [p.lat,p.lon,height,p.n ]=contour2poly(coords);
   p.lat = poly_split(p.lat);
   p.lon = poly_split(p.lon);

   if ~(ischar(z) | isempty(z))
   for i=1:length(p.lon)
   
   disp([mfilename,':',num2str(100.*i/length(p.lon),'% 0.3g'),' %, set ''zstride'' to speed this up.'])
   
   p.z{i} = griddata(lat(1:OPT.zstride:end,1:OPT.zstride:end),...
                     lon(1:OPT.zstride:end,1:OPT.zstride:end),...
                     z  (1:OPT.zstride:end,1:OPT.zstride:end),p.lat{i},p.lon{i});
   end
   z   = nan(max(p.n),length(p.n));
   end
   lat = nan(max(p.n),length(p.n));
   lon = nan(max(p.n),length(p.n));
   for ii=1:length(p.n)
       lat(1:p.n(ii),ii) = p.lat{ii};
       lon(1:p.n(ii),ii) = p.lon{ii};
       if ~(ischar(z) | isempty(z))
       z  (1:p.n(ii),ii) = p.z  {ii};
       end
   end
   c = repmat(height,max(p.n),1);
   
   sourceFiles = {};
   
%% make labels
   
   if OPT.writeLabels
       if ~isnan(OPT.labelInterval)
           latText    = lat(1:OPT.labelInterval:end,:);
           lonText    = lon(1:OPT.labelInterval:end,:);
           zText      =   c(1:OPT.labelInterval:end,:);
           zText      =   zText(~isnan(latText));
           labels     =   zText;
           latText    = latText(~isnan(latText));
           lonText    = lonText(~isnan(lonText));
       else
           t = clabel(coords,h);
           for i=1:length(t)
               p = get(t(i),'Position');
               latText(i) = p(1);
               lonText(i) = p(2);
               labels {i} = get(t(i),'String');
               zText      = str2num(char(labels));
           end
           close(FIG);
       end
       KMLtext(latText,lonText,labels,OPT.zScaleFun(zText),'fileName',[OPT.fileName(1:end-4) 'labels.kml'],...
           'kmlName','labels','timeIn',OPT.timeIn,'timeOut',OPT.timeOut,'labelDecimals',OPT.labelDecimals);
       
       sourceFiles = [sourceFiles,{[OPT.fileName(1:end-4) 'labels.kml']}];
       
   end

%% draw the lines

height(height<OPT.cLim(1)) = OPT.cLim(1);
height(height>OPT.cLim(2)) = OPT.cLim(2);

if isnumeric(OPT.colorMap)
    OPT.colorSteps = size(OPT.colorMap,1);
end
if OPT.colorSteps==1
    OPT.colorbar = 0;
end

level      = round((height-OPT.cLim(1))/(OPT.cLim(2)-OPT.cLim(1))*(OPT.colorSteps-1))+1;

%%  get colormap

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

lineColors = colorRGB(level,:);

if OPT.is3D

    if nargout==1
       if isempty(z)
        kmlcode = KMLline(lat,lon,OPT.zScaleFun(c),'fileName',[OPT.fileName(1:end-4) 'lines.kml'],...
            'is3D'     ,true,...
            'kmlName'  ,'lines',...
            'timeIn'   ,OPT.timeIn,...
            'timeOut'  ,OPT.timeOut,...
            'lineColor',lineColors,...
            'lineWidth',OPT.lineWidth,...
            'fillColor',lineColors,...
            'extrude'  ,OPT.extrude);
       else
        kmlcode = KMLline(lat,lon,OPT.zScaleFun(z),'fileName',[OPT.fileName(1:end-4) 'lines.kml'],...
            'is3D'     ,true,...
            'kmlName'  ,'lines',...
            'timeIn'   ,OPT.timeIn,...
            'timeOut'  ,OPT.timeOut,...
            'lineColor',lineColors,...
            'lineWidth',OPT.lineWidth,...
            'fillColor',lineColors,...
            'extrude'  ,OPT.extrude);
       end
    else
       if isempty(z)
        kmlcode = KMLline(lat,lon,OPT.zScaleFun(c),'fileName',[OPT.fileName(1:end-4) 'lines.kml'],...
            'is3D'     ,true,...
            'kmlName'  ,'lines',...
            'timeIn'   ,OPT.timeIn,...
            'timeOut'  ,OPT.timeOut,...
            'lineColor',lineColors,...
            'lineWidth',OPT.lineWidth,...
            'fillColor',lineColors,...
            'extrude'  ,OPT.extrude);
       else
        kmlcode = KMLline(lat,lon,OPT.zScaleFun(z),'fileName',[OPT.fileName(1:end-4) 'lines.kml'],...
            'is3D'     ,true,...
            'kmlName'  ,'lines',...
            'timeIn'   ,OPT.timeIn,...
            'timeOut'  ,OPT.timeOut,...
            'lineColor',lineColors,...
            'lineWidth',OPT.lineWidth,...
            'fillColor',lineColors,...
            'extrude'  ,OPT.extrude);
       end
    end
else
    if nargout==1
        kmlcode = KMLline(lat,lon,'fileName',[OPT.fileName(1:end-4) 'lines.kml'],...
            'kmlName'  ,'lines',...
            'timeIn'   ,OPT.timeIn,...
            'timeOut'  ,OPT.timeOut,...
            'lineColor',lineColors,...
            'lineWidth',OPT.lineWidth);
    else
        KMLline(lat,lon,'fileName',[OPT.fileName(1:end-4) 'lines.kml'],...
            'kmlName'  ,'lines',...
            'timeIn'   ,OPT.timeIn,...
            'timeOut'  ,OPT.timeOut,...
            'lineColor',lineColors,...
            'lineWidth',OPT.lineWidth);
    end
end

%% colorbar

if OPT.colorbar
    OPT.CBfileName = [OPT.fileName(1:end-4) '_colorbar.kml'];
   [clrbarstring,pngNames] = KMLcolorbar(OPT);
    sourceFiles = [sourceFiles {OPT.CBfileName}];
else
    pngNames = [];
end

%% merge labels, lines and colorbar

sourceFiles = [sourceFiles {[OPT.fileName(1:end-4) 'lines.kml']}];

KMLmerge_files('fileName',OPT.fileName,...
    'sourceFiles',sourceFiles);

for i=1:length(sourceFiles)
    delete(sourceFiles{i});
end

if nargout >0
    varargout = {kmlcode,pngNames};
end

%% EOF


