function varargout = vs_trim2kml(varargin)
%VS_TRIM2KML make a Google Earth movie tiles of one scaler variable
%
% Example:
%
% OPT.filename    = 'trim-001.dat';
% OPT.epsg        = 28992; % Rijksdriehoek
% OPT.group       = 'map-sed-series';
% OPT.element     = 'DPS';
% OPT.colormap    = colormap_cpt('bathymetry_vaklodingen',500);
% OPT.clim        = [-25 -5];
% OPT.description = 'defense Mick van der Wegen 26nd May 2010';
% OPT.fileName    = 'allemaal.kml';
% OPT.kmlName     = '';
% OPT.logo        = 'ihe.gif';
% 
% vs_trim2kml(OPT)
% 
%See also: KMLFIG2PNGNEW, VS_DISP

%%  --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares for Building with Nature
%
%       Gerben de Boer
%
%       gerben.deboer@deltares.nl	
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

%% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
%  OpenEarthTools is an online collaboration to share and manage data and 
%  programming tools in an open source, version controlled environment.
%  Sign up to recieve regular updates of this function, and to contribute 
%  your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
%  $Id: vs_trim2kml.m 5410 2011-11-02 08:46:10Z boer_g $
%  $Date: 2011-11-02 16:46:10 +0800 (Wed, 02 Nov 2011) $
%  $Author: boer_g $
%  $Revision: 5410 $
%  $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/vs_trim2kml.m $
%  $Keywords: $

% f:/../oetsettings.m
% addpath('C:\Delft3D\w32\matlab\')

OPT.filename          = '';
OPT.epsg              = 28992;
OPT.group             = 'map-sed-series';
OPT.element           = 'DPS';
OPT.colormap          = colormap_cpt('bathymetry_vaklodingen',500);
OPT.clim              = [-25 -5];
OPT.description       = '';
OPT.mergedkmlfilename = '';                                                 % was OPT.fileName in previous version
OPT.kmlName           = '';
OPT.logo              = '';
OPT.basePath          = '';
OPT.highestLevel      = [];
OPT.lowestLevel       = [];
OPT.mask              = false;                                              % masks on active velocity points
OPT.CBcolorbartitle   = OPT.element;
OPT.CBtemplateHor     = 'KML_colorbar_template_horizontal.png';
OPT.CBtemplateVer     = 'KML_colorbar_template_vertical.png';

if nargin==0
   varargout = {OPT};
   return
end

OPT = setproperty(OPT,varargin{:});

if isempty(OPT.mergedkmlfilename)
    OPT.mergedkmlfilename = [filename(OPT.filename),'_',OPT.element,'.kmz'];
end

%% load time and grid

 trimfile   = vs_use(OPT.filename);
 G          = vs_meshgrid2dcorcen(trimfile);
 T          = vs_time(trimfile);
 
[G.cen.lon,...
 G.cen.lat] = convertCoordinates(G.cen.x,G.cen.y,'CS1.code',OPT.epsg,'CS2.code',4326);

dt    = unique(diff(T.datenum));
dt    = dt(1);
first = 1;

%% time loop

for it=1:T.nt_storage

    if findstr(OPT.element,'DPS')
        D.cen.dep = -vs_let_scalar(trimfile,OPT.group,{it},OPT.element);
    else
        D.cen.dep = vs_let_scalar(trimfile,OPT.group,{it},OPT.element);
    end

    if OPT.mask
        mymask = vs_let_scalar(trimfile,'map-series',{it},'KFU');
        mymask(mymask==0) = NaN;
        D.cen.dep = D.cen.dep.*mymask;
    end
   
%% plot one timestep

   FIG = figure('Visible','Off');
   h   = surf(G.cen.lon,G.cen.lat,D.cen.dep);
   shading    interp;
  %material  ([.90 0.08 .07]);
   material  ([.88 0.11 .08]);
   lighting   phong
   axis       off;
   axis       tight;
   view      (0,90);
   lightangle(0,90)
   colormap  (OPT.colormap);
   clim      (OPT.clim);

%% make one kml per timestep
   
   kmlname{it} = [num2str(it,'%0.3d'),'.kml'];

   if first
   KMLfigure_tiler(h,G.cen.lat,G.cen.lon,D.cen.dep,...
                  'kmlName',['timestep ',num2str(it,'%0.3d')],... 
                     'logo',OPT.logo,...
                   'timeIn',T.datenum(it),...
                  'timeOut',T.datenum(it) + dt,...
             'highestLevel',OPT.highestLevel,...
              'lowestLevel',OPT.lowestLevel,...
                  'bgcolor',[255 0 255],...
          'CBcolorbartitle','depth [m]',...
                 'fileName',kmlname{it},...
                 'basePath',OPT.basePath,...
                 'CBtemplateVer',OPT.CBtemplateVer,...
                 'CBtemplateHor',OPT.CBtemplateHor);
   else
   KMLfigure_tiler(h,G.cen.lat,G.cen.lon,D.cen.dep,...
                  'kmlName',['timestep ',num2str(it,'%0.3d')],... 
                   'timeIn',T.datenum(it),...
                  'timeOut',T.datenum(it) + dt,...
             'highestLevel',OPT.highestLevel,...
              'lowestLevel',OPT.lowestLevel,...
                  'bgcolor',[255 0 255],...
                 'colorbar',0,...
                 'fileName',kmlname{it},...
                 'basePath',OPT.basePath);
   end
   
   try;close(FIG);end
   
   first=0;

end

%% merge all timesteps
% KMLmerge_files('sourceFiles',kmlname,...
%    'fileName',[OPT.basePath,OPT.fileName],...
% 'description',OPT.description,...
%     'kmlName',OPT.kmlName)

files = dir([OPT.basePath,'*.kml']);
for ii = 1:length(files)
    sourceFiles{ii} = [OPT.basePath,files(ii).name];
end
KMLmerge_files('fileName',[OPT.basePath,OPT.mergedkmlfilename],'sourceFiles',sourceFiles)
