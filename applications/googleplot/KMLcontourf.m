function varargout = KMLcontourf(lat,lon,z,varargin)
% KMLCONTOURF Just like contourf (BETA!!!)
%
% The main function used by KMLtricontourf, KMLtricontourf3, KMLcontourf3.
% KMLcontourf can also be used by itself. Function is still very BETA.
% Please discuss suggestions for improvements wit me (Thijs), or just put
% them on the TODO list. 
%
%    KMLcontourf(lat,lon,z,      <keyword,value>)
%    KMLcontourf(lat,lon,z,<tri>,<keyword,value>)
% 
% For the <keyword,value> pairs and their defaults call
%
%    OPT = KMLcontourf()
%
% TODO: Still needs lots of testing. Known problems:
%       * big holes in grids are not properly supported, can cause the
%         function to hang
%       * polygons for holes are drawn
%       * tidey up the test functions
%
% See also: googlePlot, contour, contourf, contour3,
%           KMLtricontour, KMLtricontour3, KMLcontour, KMLcontour3
%           KMLtricontourf, KMLtricontourf3, KMLcontourf3

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
%       Gerben J. de Boer
%
%       gerben.deboer@Deltares.nl
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

% $Id: KMLcontourf.m 12330 2015-10-28 07:10:17Z jagers $
% $Date: 2015-10-28 15:10:17 +0800 (Wed, 28 Oct 2015) $
% $Author: jagers $
% $Revision: 12330 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/googleplot/KMLcontourf.m $
% $Keywords: $

%% process varargin
   % get colorbar options first
   OPT                = KMLcolorbar();
   % rest of the options
   OPT.levels         = 10;
   OPT.fileName       = [];
   OPT.kmlName        = [];
   OPT.lineWidth      = 3;
   OPT.lineColor      = [0 0 0];
   OPT.lineAlpha      = 1;
   OPT.fillAlpha      = 1;
   OPT.polyOutline    = false;
   OPT.polyFill       = true;
   OPT.openInGE       = false;
   OPT.colorMap       = @(m) jet(m);
   OPT.colorSteps     = [];   
   OPT.colorLevels    = [];   
   OPT.timeIn         = [];
   OPT.timeOut        = [];
   OPT.is3D           = false;
   OPT.cLim           = [];
   OPT.writeLabels    = true;
   OPT.labelDecimals  = 1;
   OPT.labelInterval  = 5;
   OPT.zScaleFun      = @(z) z;
   OPT.colorbar       = 1;
   OPT.colorbartitle  = '';
   OPT.extrude        = false;
   OPT.staggered      = true;
   OPT.debug          = false;
   OPT.verySmall      = [];
   
   % see if a triangluation has been given
   tri = [];
   if ~isempty(varargin)
       if ~ischar(varargin{1})&&~isstruct(varargin{1});
           tri = varargin{1};
           varargin(1) = [];
       end
   end
   
   if nargin==0
      varargout = {OPT};
      return
   end

%% set properties

OPT = setproperty(OPT, varargin{:});

%% input check

if isempty(OPT.verySmall); OPT.verySmall = eps(30*max([lat(:);lon(:)])); end

% vectorize input for triangluar grids
if ~isempty(tri)
    lat = lat(:);
    lon = lon(:);
    z   =   z(:);
end

% check for nan values
if any(isnan(lat+lon)) & ~isempty(tri)
    error('KMLtricontourf does not accept nan values (yet) in the lat and lon data')
end

% correct lat and lon
if any((abs(lat)/90)>1)
    error('latitude out of range, must be within -90..90')
end
lon = mod(lon+180, 360)-180;

% color limits
if isempty(OPT.cLim)
    OPT.cLim = ([min(z(~isnan(z(:)))) max(z(~isnan(z(:))))]);
end

%% find contours and edges
if numel(OPT.levels)==1&&OPT.levels==fix(OPT.levels)&&OPT.levels>=0
    OPT.levels = linspace(min(z(:)),max(z(:)),OPT.levels+2);
    OPT.levels = OPT.levels(1:end-1);
end

if isempty(OPT.colorSteps), OPT.colorSteps = length(OPT.levels)+1; end

if ~isempty(tri)
    C = tricontourc(tri,lat,lon,z,OPT.levels);
    E = edges_tri_grid(tri,lat,lon,z);
else
    C = contours(lat,lon,z,OPT.levels);
    E = edges_structured_grid(lat,lon,z);
end

[latC,lonC,zC,contour] = KML_filledContoursProcess(OPT,E,C);

%% make kml file

KML_filledContoursWriteKML(OPT,lat,lon,z,latC,lonC,zC,contour);

