function varargout = KMLfigure_tiler(h,lat,lon,z,varargin)
%KMLFIGURE_TILER   makes a tiled png figure for google earth
%
%   h = surf(lon,lat,z)
%   KMLfigure_tiler(h,lat,lon,z,<keyword,value>)
%
% make a surf or pcolor in lon/lat/z, and then pass it to KMLfigure_tiler
%
% For the <keyword,value> pairs and their defaults call
%
%    OPT = KMLfigure_tiler()
%
% where Lod = Level of Detail.
%
% For plots with    light effects set:  'scaleHeight',true ,...
% For plots without light effects set:  'scaleHeight',false,...
%
% fileName  relative filename, incl relative subPath.
% basePath  absolute path where to write kml files (will not appear inside kml, those contain only fileName)
% baseUrl   absolute url where kml will appear. (A webkml needs absolute url, albeit only needed in the mother KML, local files can have relative paths.)
% bgcolor   rgb color that is made transparent in GE. This applies to the values 
%           that are NaN in Matlab. Make sure this color is NOT in your
%           (interpolated) colorMap. By default is it olive-green 
%           ([100 155 100]) that is not in the default jet colormap.
%
% Notes:    - See example in https://repos.deltares.nl/repos/OpenEarthTools/test/
%           - Please close all other figures before calling this function
%           - To increase number of zoom levels increase 'lowestLevel' (to e.g. 14)
%           - The parent axes of h are changed: axis normal; axis off
%           - Alpha: wwe recommend not to use a uniform alpha, you'd better drag the alpha
%             slider in Google earth for that. For non-uniform alpha, use the alphaChannel
%             added in the framework of the FloodControl2015 project 'Global Flood Observatory':
%             alphaChannel overrides alpha and is a handle to a figure of exactly 
%             the same size as the original figure to be plotted, but contains 
%             only black-and-white. Black areas are 100% transparent while white 
%             areas will be made 100% visible. Gray areas are obviously somewhere in between.
%           - For large data KMLfigure_tiler can be run in 2 sub modes
%             1) tile generation in a file loop: save data or sub data to tiles
%             2) tile joing: aggregate  all tiles to higher levels and generate
%                mother kml that binds them all.
%             lowestLevel = 13;
%             for =1:n
%               [lon,lat,z]=load(files{i}))
%               clf
%               set(gca,'Color',[100 155 100]./255); % color not in jet()
%               hold off
%               h = pcolor(lon,lat,z)                % NOTE ORDER LON,LAT
%               axis off                             % do NOT use axis equal
%               caxis([-20 0])                       % manual clim required !
%               KMLfigure_tiler(h,lat,lon,z,...      % NOTE ORDER LAT,LON
%                 'bgcolor'           ,[100 155 100],... % this color is made transparent in GE
%                 'lowestLevel'       ,lowestLevel,...    % +1 results in a x4 times larger dataset
%                 'printTiles'        ,true,...  % this loop prints all tiles
%                 'joinTiles'         ,false,... % do not join untill all tiles are there
%                 'makeKML'           ,false,... % do not do untill all tiles are there
%                 'mergeExistingTiles',true);    % merge partially overlapping tiles
%             end
%
%             % in the joining phase set handle to nan, lat and lon to extent to be
%             % joined (bounding box), and z does not matter
%             KMLfigure_tiler([],[30 60],[-10 40],nan,...
%                'highestLevel'      ,[],...    % is set to whole world when lat=nan
%                'lowestLevel'       ,lowestLevel,...    % +1 results in a x4 times larger dataset
%                'printTiles'        ,false,... % this was done in phase 1
%                'joinTiles'         ,true,...  % this is what we do now
%                'makeKML'           ,true,...  % this is what we do now
%                'mergeExistingTiles',true);    % 1 ! irrelevant when printTiles==0
%
% See also: GOOGLEPLOT, PCOLOR, KMLimage, nc2kml

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

% $Id: KMLfigure_tiler.m 12766 2016-06-07 14:17:44Z gerben.deboer.x $
% $Date: 2016-06-07 22:17:44 +0800 (Tue, 07 Jun 2016) $
% $Author: gerben.deboer.x $
% $Revision: 12766 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/googleplot/KMLfigure_tiler.m $
% $Keywords: $

% TO DO: ignore colorbar, if present
% TO DO: also correct kml if hightest levels < default highestLevel

OPT                    = KML_header();

OPT.ha                 =     []; % handle to axes
OPT.hf                 =     []; % handle to figure
OPT.dim                =    256; % tile size in pixels
OPT.dimExt             =     16; % render tiles expanded by n pixels, to remove edge effects
OPT.bgcolor            = [100 155 100];  % faux background color to be made transparent
OPT.alpha              =      1;
OPT.fileName           =     []; % relative filename, incl relative subpath
OPT.basePath           =     ''; % absolute path where to write kml files (will not appear inside kml, those remain relative)
OPT.baseUrl            =     ''; % absolute url where kml will appear. (A webkml needs absolute url, albeit only needed in the mother KML, local files can have relative paths.)
OPT.logo               =     [];
OPT.alphaChannel       =     NaN;% add possibility for spatially variable transparency. alphaChannel is a handle to a black-and-white figure which gives a mask of transparency values (black = opaque zero, white = opaque 100%)
OPT.alpha              =      1;
OPT.minLod             =     []; % minimum level of detail to keep a tile in view. Is calculated when left blank.
OPT.minLod0            =     -1; % minimum level of detail to keep most detailed tile in view. Default is -1 (don't hide when zoomed in a lot)
OPT.maxLod             =     [];
OPT.maxLod0            =     -1;
OPT.fixZlim            =  false; % sets z scaling equal to x/y scale. This makes the part outside clim blaknk in kml, instead of saturated. 
OPT.dWE                =     []; % determines how much extra data to tiles to be able
OPT.dNS                =     []; % to generate them as fraction of size of smallest tile
OPT.drawOrder          =      1;
OPT.colorbar           =   true;
OPT.CBcolorbarlocation =  {'W'}; %{'N','E','S','W'}; %{'N','NNE','ENE','E','ESE','SSE','S','SSW','WSW','W','WNW','NNW'};
OPT.CBcolorbartitle    =     '';
OPT.mergeExistingTiles =   true; % does not work when changing dim
OPT.printTiles         =   true;
OPT.joinTiles          =   true;
OPT.makeKML            =   true;
OPT.basecode           =     '';
OPT.highestLevel       =     [];
OPT.lowestLevel        =     [];
OPT.debug              =      0;  % display some progress info
OPT.CBtemplateHor      = 'KML_colorbar_template_horizontal.png';
OPT.CBtemplateVer      = 'KML_colorbar_template_vertical.png';

if nargin==0
   varargout = {OPT};
   return
else
   D.lat = lat;
   D.lon = lon;
   D.z   = z;

   %if ~isequal(size(D.lon) - size(D.z),[0 0])
   %  D.z = addrowcol(D.z,1,1,Inf); % no, lat KML_figure_tiler_printTile handles that
   %end
   D.N   = max(D.lat(:));
   D.S   = min(D.lat(:));
   D.W   = min(D.lon(:));
   D.E   = max(D.lon(:));
   
   OPT.basecode = KML_figure_tiler_SmallestTileThatContainsAllData(D); 
end

OPT.h    = h;  % handle to input surf object

if ishandle(OPT.h)
OPT.ax = get(OPT.h,'parent');
if strcmpi(get(OPT.ax,'climMode'),'auto')
   error([mfilename,' manual clim required for identical colormapping in tiles']);
end
axis(OPT.ax,'off')
axis(OPT.ax,'normal')
end

OPT = setproperty(OPT, varargin);

if isempty(OPT.lowestLevel)
    OPT.lowestLevel = length(OPT.basecode)+4;
end

if isempty(OPT.highestLevel)
    OPT.highestLevel = min(length(OPT.basecode),OPT.lowestLevel);
end

if length(OPT.basecode)>(OPT.lowestLevel-1)
    OPT.basecode = OPT.basecode(1:(OPT.lowestLevel-1));
end

% If individual pixels have individual alpha levels....
% if ndims(OPT.alpha) == 2
%     D.alpha = OPT.alpha;
% end

%% initialize waitbars

if OPT.printTiles
    multiWaitbar('fig2png_print_tile' ,0,'label','Printing tiles' ,'color',[0.0 0.4 0.9])
end
if OPT.joinTiles
   multiWaitbar('fig2png_merge_tiles' ,0,'label','Merging tiles'  ,'color',[0.6 0.2 0.2])
end
if OPT.makeKML
    multiWaitbar('fig2png_write_kml'  ,0,'label','Writing KML'    ,'color',[0.9 0.4 0.1])
end

%% make sure you always see something in GE, even at really low lowestLevel
if OPT.lowestLevel <= OPT.highestLevel
   disp(['OPT.lowestLevel (',num2str(OPT.lowestLevel),') set to OPT.highestLevel (',num2str(OPT.highestLevel ),') + 1 = ',num2str(OPT.highestLevel+1)])
   OPT.lowestLevel = OPT.highestLevel + 1;
end

OPT.highestLevel  = max(OPT.highestLevel,1);

%% set tile margins
% determines how much extra data to pass on to tiles to avoid holes in the
% plotted mesh at tile boundaries. Defaults to 20% on all sides
if  isempty(OPT.dWE)
    OPT.dWE           = 0.2*360/(2^OPT.lowestLevel);
end
if isempty(OPT.dNS)
    OPT.dNS           = 0.2*360/(2^OPT.lowestLevel);
end

%% set maxLod and minLod defaults
if isempty(OPT.minLod),                 OPT.minLod = round(  OPT.dim/1.5); end
% Inserted by Hessel Winsemius to enable use of alpha as grid
if size(OPT.alpha,1)==1 && size(OPT.alpha,2)==1
    if isempty(OPT.maxLod)&&OPT.alpha  < 1, OPT.maxLod = round(2*OPT.dim/1.5); end % you see 1 layers always
    if isempty(OPT.maxLod)&&OPT.alpha == 1, OPT.maxLod = round(4*OPT.dim/1.5); end % you see 2 layers, except when fully zoomed in
else
    if isempty(OPT.maxLod), OPT.maxLod = round(2*OPT.dim/1.5);end
end

if isempty(OPT.basePath)
    OPT.basePath = pwd;
end

%% filename
%            fileName:           relative link in kml
%   Path    /-------------\      where to save files (fopen, mkdir)
% /----------------\
% basePath + subPath + Name
%
% baseUrl  + subPath + Name
% \-----------------------/
%  Url                           absolute link in mother kml
%
% gui for filename, if not set yet
if isempty(OPT.fileName)
    [OPT.Name, OPT.Path] = uiputfile({'*.kml','KML file';'*.kmz','Zipped KML file'},'Save as','renderedPNG.kml');
    OPT.fileName = fullfile(OPT.Name);
    OPT.subPath  =  '';       % relative part of path that will appear in kml
    OPT.basePath =  OPT.Path; % here we do not know difference between basepath
else
    [OPT.subPath OPT.Name] = fileparts(OPT.fileName);
    OPT.Path = [OPT.basePath filesep OPT.subPath];
end

% set kmlName if it is not set yet
[ignore OPT.Name] = fileparts(OPT.fileName);
if isempty(OPT.kmlName)
    OPT.kmlName = OPT.Name;
end

% make a folder for the sub files
if ~exist([OPT.basePath filesep OPT.Name],'dir')
     mkdir(fullfile(OPT.basePath,OPT.Name));
end

%% preproces timespan
%  http://code.google.com/apis/kml/documentation/kmlreference.html#timespan

if  ~isempty(OPT.timeIn)
    if ~isempty(OPT.timeOut)
        OPT.timeSpan = sprintf([...
            '<TimeSpan>\n'...
            '<begin>%s</begin>\n'...% OPT.timeIn
            '<end>%s</end>\n'...    % OPT.timeOut
            '</TimeSpan>\n'],...
            datestr(OPT.timeIn,OPT.dateStrStyle),datestr(OPT.timeOut,OPT.dateStrStyle));
    else
        OPT.timeSpan = sprintf([...
            '<TimeStamp>\n'...
            '<when>%s</when>\n'...  % OPT.timeIn
            '</TimeStamp>\n'],...
            datestr(OPT.timeIn,OPT.dateStrStyle));
    end
else
    OPT.timeSpan ='';
end

%% figure settings
if ishandle(OPT.h)
    % Some settings for the figure to make sure it is printed correctly
    OPT.ha  = get(OPT.h ,'Parent');
    OPT.hf  = get(OPT.ha,'Parent');
    daspect(OPT.ha,'auto') % repair effect of for instance axislat()

    set(OPT.ha,'Position',[0 0 1 1])
    set(OPT.hf,'PaperUnits', 'inches','PaperPosition',...
    [0 0 OPT.dim+2*OPT.dimExt OPT.dim+2*OPT.dimExt],...
    'color',OPT.bgcolor/255,'InvertHardcopy','off');
end
if ishandle(OPT.alphaChannel)
    OPT.ha_alpha = get(OPT.alphaChannel, 'Parent');
    OPT.hf_alpha = get(OPT.ha_alpha,'Parent');
    set(OPT.ha_alpha,'Position',[0 0 1 1])
    set(OPT.hf_alpha,'PaperUnits', 'inches','PaperPosition',...
    [0 0 OPT.dim+2*OPT.dimExt OPT.dim+2*OPT.dimExt],...
    'color',[0 0 0],'InvertHardcopy','off');
end
%% run scripts (These are the core functions)
%  some more background info: http://www.realityprime.com/articles/how-google-earth-really-works

%   --------------------------------------------------------------------
% Generates tiles at most detailed level
if OPT.printTiles && ishandle(OPT.h)
    KML_figure_tiler_printTile(OPT.basecode,D,OPT)
end

%   --------------------------------------------------------------------
% Generates tiles other levels based on already created tiles (merging & resizing)
if OPT.joinTiles
   KML_figure_tiler_joinTiles(OPT)
end

%   --------------------------------------------------------------------
% Generates KML based on png file names
if OPT.makeKML
    KML_figure_tiler_makeKML(OPT)
end
%   --------------------------------------------------------------------

%% and write the 'mother' KML

if OPT.makeKML
    if ~isempty(OPT.baseUrl)
        if ~strcmpi(OPT.baseUrl(end),'/');
            OPT.baseUrl = [OPT.baseUrl '\'];
        end
    end

    % relative for local files
    if isempty(OPT.baseUrl)
       href.kml = fullfile(             OPT.subPath, OPT.Name, [OPT.Name '_' OPT.basecode(1:OPT.highestLevel) '.kml']);
    else
       href.kml = fullfile(OPT.baseUrl, OPT.subPath, OPT.Name, [OPT.Name '_' OPT.basecode(1:OPT.highestLevel) '.kml']);
    end

    href.kml = path2os(href.kml,'h'); % always use HTTP slashes

    output = sprintf([...
        '<NetworkLink>'...
        '<name>network-linked-tiled-pngs</name>'...
        '<visibility>%d</visibility>'...
        '%s'...              % timespan                                                                                                          % time
        '<Link><href>%s</href><viewRefreshMode>onRegion</viewRefreshMode></Link>'... % link
        '</NetworkLink>'],...
        OPT.visible,OPT.timeSpan,href.kml);
    file.kml = fullfile(OPT.basePath,OPT.fileName);
    OPT.fid=fopen(file.kml,'w');

 %% LOGO
 %  add png to directory of tiles (split png and href in KMLcolorbar)

 if isempty(OPT.logo)
     logo   = '';
 else

      % add to one level deeper
     file.logo = fullfile(OPT.basePath,OPT.Name, [filename(OPT.logo),'4GE.png']);

     % relative for local files
     if isempty(OPT.baseUrl)
        href.logo = fullfile(             OPT.subPath, OPT.Name, filenameext(file.logo));
     else
        href.logo = fullfile(OPT.baseUrl, OPT.subPath, OPT.Name, filenameext(file.logo));
     end

     href.logo = path2os(href.logo,'h'); % always use HTTP slashes

     logo   = ['<Folder>' KMLlogo(OPT.logo,'fileName',0,'kmlName', 'logo',...
         'logoName',file.logo) '</Folder>'];
     logo = strrep(logo,['<Icon><href>' filenameext(file.logo)],...
                        ['<Icon><href>' href.logo]);
 end
    output = [KML_header(OPT) logo output];

 %% COLORBAR
 %  add png to directory of tiles (split png and href in KMLcolorbar)

    if OPT.colorbar

       % add to one level deeper
       file.CB = fullfile(OPT.basePath, OPT.Name, [OPT.Name]);

       % relative for local files
       if isempty(OPT.baseUrl)
          href.CB = fullfile(             OPT.subPath, OPT.Name, [OPT.Name]);
       else
          href.CB = fullfile(OPT.baseUrl, OPT.subPath, OPT.Name, [OPT.Name]);
       end
       href.CB = path2os(href.CB,'h');
       href.CB = path2os(href.CB,'h'); % always use HTTP slashes
       if ishandle(OPT.ha)
       [clrbarstring,pngNames] = KMLcolorbar('CBcLim',clim(OPT.ha),...
                              'CBfileName',file.CB,...
                               'CBkmlName','colorbar',...
                              'CBcolorMap',colormap(OPT.ha),...
                            'CBcolorTitle',OPT.CBcolorbartitle,...
                      'CBcolorbarlocation',OPT.CBcolorbarlocation,...
                               'CBvisible',OPT.visible,...
                           'CBtemplateVer',OPT.CBtemplateVer,...
                           'CBtemplateHor',OPT.CBtemplateHor);

        % refer to one level deeper,  KMLcolorbar chops directory in <href>
       clrbarstring = strrep(clrbarstring,['<Icon><href>' filename(file.CB)],...
                                          ['<Icon><href>' href.CB]);
       output = [output clrbarstring];
       end
    end

    if OPT.debug
    var2evalstr(href)
    var2evalstr(file)
    end

 %% FOOTER

    output = [output KML_footer];
    fprintf(OPT.fid,'%s',output);

    % close KML
    fclose(OPT.fid);
    multiWaitbar('fig2png_write_kml'   ,1,'label','Writing KML'    ,'color',[0.9 0.4 0.1])
%% restore

    set(OPT.ha,'DataAspectRatio',daspect); % restore
end

if nargout==1
   varargout = {OPT};
elseif nargout==2
   varargout = {OPT,pngNames};
end

%% EOF

