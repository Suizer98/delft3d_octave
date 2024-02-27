function varargout = KMLtricontour(tri,lat,lon,z,varargin)
% KMLTRICONTOUR   Just like contour
%
%   KMLtricontour(tri,lat,lon,z,varargin)
%
% see the keyword/vaule pair defaults for additional options
%
% See also: googlePlot, contour

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

% $Id: KMLtricontour.m 5688 2012-01-11 15:21:15Z tda.x $
% $Date: 2012-01-11 23:21:15 +0800 (Wed, 11 Jan 2012) $
% $Author: tda.x $
% $Revision: 5688 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/googleplot/KMLtricontour.m $
% $Keywords: $

%% process varargin
   % get colorbar options first
   OPT               = KMLcolorbar();
   OPT               = mergestructs(OPT,KML_header());

   % rest of the options
   OPT.levels        = 10;
   OPT.fileName      = [];
   OPT.lineWidth     = 1;
   OPT.lineAlpha     = 1;
   OPT.openInGE      = false;
   OPT.colorMap      = @(m) jet(m);
   OPT.colorSteps    = [];   
   OPT.is3D          = false;
   OPT.cLim          = [];
   OPT.writeLabels   = false;
   OPT.labelDecimals = 1;
   OPT.labelInterval = 5;
   OPT.zScaleFun     = @(z) (z+0)*0;
   OPT.colorbar      = 1;

   if nargin==0
      varargout = {OPT};
      return
   end

%% check if labels are defined

   if ~isempty(varargin)
       if isnumeric(varargin{1})
           c = varargin{1};
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
%  vectorize input

   lat = lat(:);
   lon = lon(:);
   z = z(:);
   % correct lat and lon
   if any((abs(lat)/90)>1)
       error('latitude out of range, must be within -90..90')
   end
   lon = mod(lon+180, 360)-180;
   
   % color limits
   if isempty(OPT.cLim)
       OPT.cLim = ([min(z(~isnan(z))) max(z(~isnan(z)))]);
   end

    % interpret levels
    if numel(OPT.levels)==1&&OPT.levels==fix(OPT.levels)&&OPT.levels>=0
        OPT.levels = linspace(min(z),max(z),OPT.levels+2);
        OPT.levels = OPT.levels(1:end-1);
    end
    
    if isempty(OPT.colorSteps), OPT.colorSteps = length(OPT.levels)+1; end
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

   coords = tricontourc(tri,lat,lon,z,OPT.levels);

%% pre allocate, find dimensions

   max_size = 1;
   jj = 1;ii = 0;
   while jj<size(coords,2) 
       ii = ii+1;
       max_size = max(max_size,coords(2,jj));
       jj = jj+coords(2,jj)+1;
   end
   lat = nan(max_size,ii);
   lon = nan(max_size,ii);
   height = nan(1,ii);
   %%
   jj = 1;ii = 0;
   while jj<size(coords,2) 
       ii = ii+1;
       height(ii) = coords(1,jj);
       lat(1:coords(2,jj),ii) = coords(1,[jj+1:jj+coords(2,jj)]); 
       lon(1:coords(2,jj),ii) = coords(2,[jj+1:jj+coords(2,jj)]); 
       jj = jj+coords(2,jj)+1;
   end
   
%% make z

   z = repmat(height,size(lat,1),1);

%% make labels

   if OPT.writeLabels
       latText    = lat(1:OPT.labelInterval:end,:);
       lonText    = lon(1:OPT.labelInterval:end,:);
       zText      =   z(1:OPT.labelInterval:end,:);
       zText      =   zText(~isnan(latText));
       labels     =   zText;
       latText    = latText(~isnan(latText));
       lonText    = lonText(~isnan(lonText));
       OPT.kmlName  = 'labels';
       OPT.fileName = [OPT.fileName(1:end-4) 'labels.kml'];
       if OPT.is3D
           KMLtext(latText,lonText,labels,OPT.zScaleFun(zText),'fileName',OPT);
       else
           KMLtext(latText,lonText,labels,                     'fileName',OPT);
       end
   end
   
%% draw the lines

   height(height<OPT.cLim(1)) = OPT.cLim(1);
   
   height(height>OPT.cLim(2)) = OPT.cLim(2);
   
   level      = round((height-OPT.cLim(1))/(OPT.cLim(2)-OPT.cLim(1))*(OPT.colorSteps-1))+1;
   colors     = OPT.colorMap(OPT.colorSteps);
   lineColors = colors(level,:);
   

   OPTkmlline = KMLline;
   OPTkmlline = setproperty(OPTkmlline,{OPT},'onExtraField','silentIgnore');
   OPTkmlline.lineColor = lineColors;
   OPTkmlline.fillColor = lineColors;
   if OPT.is3D
       KMLline(lat,lon,z,OPTkmlline);
   else
       KMLline(lat,lon,OPTkmlline);
   end
%% colorbar
   if OPT.colorbar
      KMLcolorbar(OPT);
   end
   
%% openInGoogle?

   if OPT.openInGE
       system(OPT.fileName);
   end

%% EOF