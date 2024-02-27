function varargout = nc2kml_surface_imageOverlay(varargin)
%NC2KML_SURFACE_IMAGEOVERLAY  make kml tree of (x,y,t) netCDF bathymetry tiles
%
%   NC2KML_SURFACE_IMAGEOVERLAY makes a kml tree with KMLFIGURE_TILER
%   from a collection of (x,y,t) netCDF tiles generated with NCGEN.
%
%   Syntax:
%   kmlgen_surface_imageOverlay(<keyword,value>)
%
%   Input:
%   For <keyword,value> pairs call kmlgen_surface_imageOverlay()
%
%   Example
%   kmlgen_surface_imageOverlay
%
%   See also: ncgen, KMLfigure_tiler

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Van Oord
%       Thijs Damsma
%
%       tda@vanoord.com
%
%       Watermanweg 64
%       3067 GG
%       Rotterdam
%       Netherlands
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

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 02 May 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id: nc2kml_surface_imageOverlay.m 12849 2016-08-16 08:25:40Z rho.x $
% $Date: 2016-08-16 16:25:40 +0800 (Tue, 16 Aug 2016) $
% $Author: rho.x $
% $Revision: 12849 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/googleplot/nc2kml/nc2kml_surface_imageOverlay.m $
% $Keywords: $

%%
OPT                 = KMLfigure_tiler();

OPT.path_netcdf     = '';
OPT.path_kml        = '';

OPT.fileName        = 'Surface_overlay.kml';
OPT.colorMap        = @(m) colormap_cpt('bathymetry_vaklodingen',m);
OPT.colorSteps      = 256;
OPT.cLim            = [-50 25];
OPT.var_name        = 'z';
OPT.log             = 0;
OPT.dim             = 256;
OPT.dateStrStyle    = 'yyyy-mm-dd';
OPT.filledInTime    = true;
OPT.descriptivename = 'Surface overlay';
OPT.description     = ['generated: ' datestr(now())];
OPT.colorbar        = true;
OPT.highestLevel    = 1;
OPT.lowestLevel     = 15;
OPT.z_scale_factor  = 1;
OPT.lighting_effects = true;
%Added
OPT.renew            = true; %default was always remove old directories

if nargin==0
    varargout = {OPT};
    return
end

OPT = setproperty(OPT,varargin,'onExtraField',  'silentAppend'); %In order to pass settings of the colorbar

%% initialize waitbars

%     multiWaitbar('kml_print_all_tiles' ,'reset','label','Printing tiles: total'       ,'color',[0.0 0.3 0.6])
%     multiWaitbar('fig2png_print_tile'  ,'reset','label','Printing tiles: per file'    ,'color',[0.0 0.5 1.0])
%     multiWaitbar('merge_all_tiles'     ,'reset','label','Merging tiles: total'        ,'color',[0.5 0.1 0.1])
%     multiWaitbar('fig2png_merge_tiles' ,'reset','label','Merging tiles: per timestep' ,'color',[0.7 0.3 0.3])
%     multiWaitbar('fig2png_write_kml'   ,'reset','label','Writing KML: total'          ,'color',[0.9 0.4 0.1])

%     if isempty(OPT.lightAdjust)
%         OPT.lightAdjust = 2^(OPT.lowestLevel-16);
%     end

%% create kml directory if it does not yet exist
if OPT.renew
    if exist(OPT.path_kml,'dir')
        rmdir(OPT.path_kml,'s')
        pause(5)
    end
    mkdir(OPT.path_kml); %mkpath(OPT.path_kml);
else
    if ~exist(OPT.path_kml,'dir')
        mkdir(OPT.path_kml); %mkpath(OPT.path_kml);
    end        
end

%% run functions
[minlat,maxlat,minlon,maxlon] = print_tiles(OPT);
merge_tiles(OPT);
write_kml(OPT,minlat,maxlat,minlon,maxlon);

multiWaitbar('fig2png_merge_tiles','close')
multiWaitbar('merge_all_tiles','close')
multiWaitbar('kml_print_all_tiles','close')

function [minlat,maxlat,minlon,maxlon] = print_tiles(OPT)

ncfiles = get_nc_files(OPT.path_netcdf);

%% base figure (properties of which will be adjusted to print tiles)

figure('Visible','Off')
x       = linspace(0,1,100);
[x,y]   = meshgrid(x,x);
z       = kron([10 1;5 1],peaks(50))-rand(100);
z       = (z - min(z(:))) / (max(z(:)) -  min(z(:)));
h       = surf(x,y,z);

if OPT.lighting_effects
    hl      = light;
    material([0.87 0.1 0.07 150]);
    shading interp;lighting phong;axis off;
    axis tight;view(0,90);
    lightangle(hl,180,70);
else
    shading interp;
    axis off;
    axis tight;view(0,90);
end

clim(OPT.cLim);
if isa(OPT.colorMap,'function_handle')
    %Use the function handle
    colormap(OPT.colorMap(OPT.colorSteps));
else
    %Use the colormap (passed as array)
    colormap(OPT.colorMap)
end

%% pre-allocate

[minlat,minlon,maxlat,maxlon] = deal(nan);

%% MAKE TILES in this loop

for ii = 1:length(ncfiles);
    url  = ncfiles{ii};
    date = nc_cf_time(url,'time');
    
    if isempty(date)
        continue
    end
    
    lon       = ncread(url, 'lon');
    lat       = ncread(url, 'lat');
    
    % expand lat and lon in each direction to create some overlap
    lon = [lon(:,1) + (lon(:,1)-lon(:,2))*.55  lon  lon(:,end) + (lon(:,end)-lon(:,end-1))*.55];
    lat = [lat(:,1) + (lat(:,1)-lat(:,2))*.55  lat  lat(:,end) + (lat(:,end)-lat(:,end-1))*.55];
    lon = [lon(1,:) + (lon(1,:)-lon(2,:))*.55; lon; lon(end,:) + (lon(end,:)-lon(end-1,:))*.55];
    lat = [lat(1,:) + (lat(1,:)-lat(2,:))*.55; lat; lat(end,:) + (lat(end,:)-lat(end-1,:))*.55];
    
    % extend last time interval for visibility period in Google Earth
    date(isnan(date)) = nanmax(date);
    date4GE          = date;
    date4GE(end+1,1) = date(end)+1;
    
    % get dimension info of z
    z_dim_info = ncinfo(url,OPT.var_name) ;
    time_dim   = strcmp({z_dim_info.Dimensions.Name},'time');
    x_dim      = strcmp({z_dim_info.Dimensions.Name},'x');
    y_dim      = strcmp({z_dim_info.Dimensions.Name},'y');
    
    z_start0 = [1 1 1];
    z_count  = [z_dim_info.Dimensions.Length];
    z_count(time_dim) = 1;
    for jj = size(date4GE,1)-1:-1:1
        % load z data
        z = OPT.z_scale_factor * ncread(url,OPT.var_name,...
            z_start0 + time_dim*(jj-1),z_count);
        
        % rearrange array into order [x,y]
        z = squeeze(permute(z,[find(time_dim) find(x_dim) find(y_dim)]));
        
        if sum(~isnan(z(:)))<3
            returnmessage(OPT.log,'data coverage is %0.1f%%, no files created\n',sum(~isnan(z(:)))/numel(z)*100);
            continue
        end
        %                 if ~OPT.quiet
        returnmessage(OPT.log,'data coverage is %0.1f%%\n',sum(~isnan(z(:)))/numel(z)*100);
        %                 end
        
        % Expand Z in all sides by replicating edge values;
        z = z([1 1 1:end end end],:); z = z(:,[1 1 1:end end end]); % expand z
        
        % This bit of code makes sure 'holes' in the surface drawn
        % with the surf command only have the size of a cell,
        % instead of one missing data value 'erasing' all four
        % surrounding cells.
        mask = ~isnan(z);
        mask = ...
            mask(1:end-2,1:end-2)+...
            mask(2:end-1,1:end-2)+...
            mask(3:end-0,1:end-2)+...
            mask(1:end-2,2:end-1)+...
            mask(3:end-0,2:end-1)+...
            mask(1:end-2,3:end-0)+...
            mask(2:end-1,3:end-0)+...
            mask(3:end-0,3:end-0);
        mask(~isnan(z(2:end-1,2:end-1)))=0;
        mask = mask>0;
        
        for kk = 2:size(z,1)-1
            for ll = 2:size(z,2)-1
                if mask(kk-1,ll-1)
                    temp = z(kk-1:kk+1,ll-1:ll+1);
                    z(kk,ll) = nanmean(temp(:));
                end
            end
        end
        z = z(2:end-1,2:end-1);
        
        %% MAKE TILES
        multiWaitbar('kml_print_all_tiles',(ii - (jj / size(date4GE,1)))/length(ncfiles),...
            'label',sprintf('%s - %s',url,datestr(date(jj),29)))
        
        %Get defaults
        OPTdefaults = KMLfigure_tiler;
        
        %Pass some tiler options (with other names)
        OPTkml          = OPT;
        OPTkml.basePath = OPT.path_kml;
        
        %Overrule defaults and capture the other passed tiler options
        OPTkml = setproperty(OPTdefaults,{OPTkml},'onExtraField',  'silentIgnore'); 

        KMLfigure_tiler(h,lat,lon,z,OPTkml,... % pass back all overwritten-defaults here, requires setproperty 7189+
            'timeIn'            ,date4GE(jj),...
            'timeOut'           ,date4GE(jj+1),...
            'fileName'          ,[datestr(date(jj),29) '.kml'],...
            'drawOrder'         ,round(date(jj)),...
            'printTiles'        ,true,...  % 1 (below 0)!
            'joinTiles'         ,false,... % 0 (below 1)!
            'makeKML'           ,false,... % 0 (done in this mfile)!
            'mergeExistingTiles',true);  % 1 ! overwrite tiles, don't remove anything
        
%         KMLfigure_tiler(h,lat,lon,z,OPT,... % pass back all overwritten-defaults here, requires setproperty 7189+
%             'highestLevel'      ,OPT.highestLevel,...
%             'lowestLevel'       ,OPT.lowestLevel,...
%             'timeIn'            ,date4GE(jj),...
%             'timeOut'           ,date4GE(jj+1),...
%             'fileName'          ,[datestr(date(jj),29) '.kml'],...
%             'dateStrStyle'      ,OPT.dateStrStyle,...
%             'drawOrder'         ,round(date(jj)),...
%             'printTiles'        ,true,...  % 1 (below 0)!
%             'joinTiles'         ,false,... % 0 (below 1)!
%             'makeKML'           ,false,... % 0 (done in this mfile)!
%             'mergeExistingTiles',true,...  % 1 ! overwrite tiles, don't remove anything
%             'dim'               ,OPT.dim,...
%             'baseUrl'           ,OPT.baseUrl,... % needed for web-access to kml tree
%             'basePath'          ,OPT.path_kml);
        
        % keep track of min and max
        minlat = min(minlat,min(lat(:)));
        minlon = min(minlon,min(lon(:)));
        maxlat = max(maxlat,max(lat(:)));
        maxlon = max(maxlon,max(lon(:)));
        
    end
end
multiWaitbar('kml_print_all_tiles',1);

function merge_tiles(OPT)

tiles = dir2(OPT.path_kml,'depth',0);
tiles = tiles([tiles.isdir]);
tiles(1) = [];

multiWaitbar('merge_all_tiles'     ,0,'label','Merging tiles: total')
for ii = 1:length(tiles)
    multiWaitbar('merge_all_tiles' ,(ii-1)/length(tiles),'label',sprintf('Merging tiles: %d/%d',ii-1,length(tiles)))
    OPT.Path = tiles(ii).pathname;
    OPT.Name = tiles(ii).name;
    KML_figure_tiler_joinTiles(OPT)
end

if OPT.filledInTime
    KML_figure_tiler_MergeTilesInTime(OPT.path_kml);
end

multiWaitbar('fig2png_merge_tiles','close')
multiWaitbar('merge_all_tiles',1,'label','Merging tiles')

function write_kml(OPT,minlat,maxlat,minlon,maxlon)

% multiWaitbar('fig2png_write_kml'   ,0,'label','Writing KML - Getting unique png file names...','color',[0.9 0.4 0.1])
mkdir(fullfile(OPT.path_kml,'KML'));

% make general
sourcePath = OPT.path_kml;
destPath = fullfile(OPT.path_kml,'KML');
timeDependant = true;

write_kml_per_folder(OPT,sourcePath,destPath,timeDependant)

subfolders = dir2(OPT.path_kml,'depth',0,'dir_excl','^KML$');
subfolders = subfolders([subfolders.isdir]);
subfolders = subfolders(2:end);

timeDependant = false;
previousSourcePaths = {};
for ii = 1:length(subfolders)
    sourcePath = [subfolders(ii).pathname subfolders(ii).name];
    destPath = sourcePath;
    write_kml_per_folder(OPT,sourcePath,destPath,timeDependant,previousSourcePaths)
    previousSourcePaths(end+1) = {sourcePath};
end

%%

OPT_header = struct(...
    'kmlName',       OPT.descriptivename,...
    'open',          1,...
    'description',   OPT.description,...
    'cameralon',    mean([maxlon minlon]),...
    'cameralat',    mean([maxlat minlat]),...
    'cameraz',      5e4);

datenums = datenum({subfolders.name});
if length(datenums) == 1;
    OPT_header.timeIn  = min(datenums);
elseif OPT.filledInTime
    OPT_header.timeIn  = max(datenums);
elseif length(datenums) < 3
    OPT_header.timeIn  = min(datenums);
    OPT_header.timeOut = max(datenums);
else
    OPT_header.timeIn  =  min(datenums(end-2:end));
    OPT_header.timeOut =  max(datenums);
end

output = KML_header(OPT_header);

%% start KML folder
output = [output sprintf([...
    '<Folder>\n'...
    '<name>overlay</name>'...
    '<open>1</open>\n'...
    '<Style><ListStyle>\n'...
    '  <listItemType>radioFolder</listItemType>\n'...
    '</ListStyle></Style>\n'])];

%% create link to dynamic kml
output = [output sprintf([...
    '<NetworkLink>\n'...
    '<name>Time animated</name>'...   % name
    '<open>0</open>\n'...
    '<Style><ListStyle>\n'...
    '  <listItemType>checkHideChildren</listItemType>\n'...
    '</ListStyle></Style>\n'...
    '<Link><href>KML/0.kml</href></Link>'...                                    
    '</NetworkLink>\n'])];
    
%% create link to static kml's
    output = [output sprintf([...
    '<Folder>\n'...
    '<name>Static</name>'...
    '<visibility>0</visibility>',...
    '<open>1</open>\n'...
    '<Style><ListStyle>\n'...
    '  <listItemType>radioFolder</listItemType>\n'...
    '</ListStyle></Style>\n'])];

for ii = 1:length(subfolders)
    output = [output sprintf([...
        '<NetworkLink>'...
        '<name>%s</name>'...
        '<visibility>0</visibility>',...
        '<Style><ListStyle>\n'...
        '  <listItemType>checkHideChildren</listItemType>\n'...
        '</ListStyle></Style>\n',...
        '<Link><href>%s</href></Link>'... % link
        '</NetworkLink>\n'],...
        subfolders(ii).name,...
        [subfolders(ii).name '/' subfolders(ii).name '_0.kml'])]; 
end
output = [output '</Folder>']; 
output = [output '</Folder>']; 

%% COLORBAR

if OPT.colorbar
    
    %Get default options
    OPTdefaults = KMLcolorbar;
    
    %Pass some options (with other names)
    OPTcb              = OPT;
    OPTcb.CBcLim       = OPT.cLim;
    OPTcb.CBfileName   = fullfile(OPT.path_kml,'KML','colorbar');
    OPTcb.CBcolorMap   = OPT.colorMap;
    OPTcb.CBcolorSteps = OPT.colorSteps;
    
    %Overrule defaults and capture the other passed tiler options
    OPTcb = setproperty(OPTdefaults,{OPTcb},'onExtraField',  'silentIgnore'); 

    clrbarstring = KMLcolorbar(OPTcb);
%     OPT.cLim,...
%         'CBfileName',           fullfile(OPT.path_kml,'KML','colorbar') ,...
%         'CBcolorMap',           OPT.colorMap,...
%         'CBcolorSteps',         OPT.colorSteps,...
%         'CBcolorbarlocation',   OPT.CBcolorbarlocation,...
%         'CBcolorTick',          OPT.CBcolorTick,...
%         'CBfontrgb',            OPT.CBfontrgb,...
%         'CBbgcolor',            OPT.CBbgcolor,...
%         'CBcolorTitle',         OPT.CBcolorTitle,...
%         'CBframergb',           OPT.CBframergb,...
%         'CBalpha',              OPT.CBalpha,...
%         'CBtemplateHor',        OPT.CBtemplateHor,...
%         'CBtemplateVer',        OPT.CBtemplateVer);
    clrbarstring = strrep(clrbarstring, '<Icon><href>colorbar_', '<Icon><href>KML/colorbar_');
    output = [output clrbarstring];
end

%% FOOTER

output = [output KML_footer];

fid = fopen(fullfile(OPT.path_kml,OPT.fileName),'w');
fprintf(fid,'%s',output);
fclose(fid);


%% generate different versions of the KML
% copyfile(fullfile(OPT.path_kml,OPT.fileName),fullfile(OPT.path_kml, [OPT.fileName(1:end-4) '_localmachine.kml']))
% copyfile(fullfile(OPT.path_kml,OPT.fileName),fullfile(OPT.path_kml, [OPT.fileName(1:end-4) '_server.kml']))

% strrep_in_files(fullfile(OPT.basepath_local,path, [fname ext '_server.kml']),...
%     ['<href>' fname ext                                           filesep 'KML' filesep],...
%     ['<href>' OPT.basepath_www  path2os(fullfile(filesep,OPT.relativepath,'KML',filesep),'/')],...
%     'quiet',true);
% if OPT.make_kmz
%     zip     (fullfile(OPT.basepath_local,path,[fname ext '.zip']),fullfile(OPT.basepath_local,OPT.relativepath))
%     movefile(fullfile(OPT.basepath_local,path,[fname ext '.zip']),fullfile(OPT.basepath_local,path,[fname ext '_portable.kmz']))
% end
% delete(fullfile(OPT.basepath_local,OPT.relativepath, 'doc.kml'))
% 
% multiWaitbar('fig2png_write_kml'  ,'close')
% multiWaitbar('merge_all_tiles'    ,'close')
% multiWaitbar('kml_print_all_tiles',1,'label','Writing of KML files')
% 
% sprintf('\ngeneration of kml files completed\n');
% 
% %% merge kml files in time

% 
% 
% % %% copy files to server
% %
% % if OPT.copy2server
% %     multiWaitbar('kml_copy',0,...
% %         'label','Copying of KML files','color',[0 0.4 0.2]);
% %     [path,fname,ext] = fileparts(OPT.relativepath);
% %     % delete current kml files
% %     if exist (fullfile(OPT.basepath_network,OPT.relativepath),'dir')
% %         rmdir(fullfile(OPT.basepath_network,OPT.relativepath), 's')
% %     end
% %     if exist  (fullfile(OPT.basepath_network,path,[fname ext '.kml']),'file')
% %         delete(fullfile(OPT.basepath_network,path,[fname ext '.kml']))
% %     end
% %     if exist  (fullfile(OPT.basepath_network,path,[fname ext '_portable.kmz']),'file')
% %         delete(fullfile(OPT.basepath_network,path,[fname ext '_portable.kmz']))
% %     end
% %
% %     mkpath(fullfile(OPT.basepath_network,OPT.relativepath));
% %
% %     fns = findAllFiles('pattern_incl', 'basepath', fullfile(OPT.basepath_local,OPT.relativepath), 'recursive', false) ;
% %     for ii = 1:length(fns)
% %         multiWaitbar('kml_copy',ii/length(fns),...
% %             'label',['copying files in ' fullfile([fname ext], fns{ii}) ' to the server']);
% %         copyfile(...
% %             fullfile(OPT.basepath_local  ,OPT.relativepath,fns{ii}),...
% %             fullfile(OPT.basepath_network,OPT.relativepath,fns{ii}))
% %     end
% %
% %     copyfile(fullfile(OPT.basepath_local,path,[fname ext '_server.kml']),fullfile(OPT.basepath_network,path,[fname ext '.kml']))
% %     if OPT.make_kmz
% %         copyfile(fullfile(OPT.basepath_local,path,[fname ext '_portable.kmz']),fullfile(OPT.basepath_network,path,[fname ext '_portable.kmz']))
% %     end
% %     multiWaitbar('kml_copy',1,'label','Copying of KML files');
% % end
% 
% varargout = {OPT};

function write_kml_per_folder(OPT,sourcePath,destPath,timeDependant,previousSourcePaths)
tiles               = dir2(sourcePath,'file_incl','\.png$','no_dirs',1);
if isempty(tiles)
    return
end

underscorePos       = strfind(tiles(1).name,'_');

allTileCodes   = nan(length(tiles),50);
allTileNumbers = uint64(nan(length(tiles), 1));
for ii = 1:length(tiles)
    tileCode = tiles(ii).name(underscorePos+1:end-4);
    allTileCodes(ii,1:length(tileCode)) = tileCode;
    allTileNumbers(ii) = sscanf(tileCode,'%lo');
end

OPT2.lowestLevel    = max(sum(~isnan(allTileCodes),2));
OPT2.highestLevel   = min(sum(~isnan(allTileCodes),2));

OPT2.minLod0        =     -1; 
OPT2.maxLod0        =     -1;
OPT2.minLod         = round(  OPT.dim/1.5);
OPT2.maxLod         = round(3*OPT.dim);

if timeDependant
    kmlprefix = '';
else
    kmlprefix = tiles(1).name(1:underscorePos);
end
         
% multiWaitbar('fig2png_write_kml'   ,0,'label','Writing KML...','color',[0.9 0.4 0.1])
for level = OPT2.highestLevel:OPT2.lowestLevel
    
    WB.a = 0.25.^(OPT.lowestLevel - level)*.25;
    WB.b = 0.25.^(OPT.lowestLevel - level)*.75;
    
    tileCodes    = char(allTileCodes(sum(~isnan(allTileCodes),2)==level,1:level));
    tilesOnLevel = unique(tileCodes(:,1:end),'rows');
    if level == OPT2.highestLevel
        fileID = tilesOnLevel;
    end
    
    if level == OPT2.lowestLevel
        tilesOnNextLevel = [];
    else
        tileCodesNextLevel    = char(allTileCodes(sum(~isnan(allTileCodes),2)==level+1,1:level+1));
        tilesOnNextLevel = unique(tileCodesNextLevel(:,1:end),'rows');
    end
    
    addCode = ['01';'23'];
    
    if level == OPT2.highestLevel
        minLod = OPT2.minLod0;
    else
        minLod = OPT2.minLod;
    end
    
    if level == OPT.lowestLevel
        maxLod = OPT2.maxLod0;
    else
        maxLod = OPT2.maxLod;
    end
    
    for nn = 1:size(tilesOnLevel,1)
        output = '';
        %% networklinks to children files
        if level ~= OPT2.lowestLevel
            for ii = 1:2
                for jj = 1:2
                    code = [tilesOnLevel(nn,:) addCode(ii,jj)];
                    B = KML_figure_tiler_code2boundary(code);
                    if  any(ismember(tilesOnNextLevel,num2str(code),'rows'))
                        output = [output sprintf([...
                            '<NetworkLink>\n'...
                            '<name>%s</name>\n'...name
                            '<Region>\n'...
                            '<Lod><minLodPixels>%d</minLodPixels><maxLodPixels>%d</maxLodPixels></Lod>\n'...minLod,maxLod
                            '<LatLonAltBox><north>%3.8f</north><south>%3.8f</south><west>%3.8f</west><east>%3.8f</east></LatLonAltBox>\n' ...N,S,W,E
                            '</Region>\n'...
                            '<Link><href>%s%s.kml</href><viewRefreshMode>onRegion</viewRefreshMode></Link>\n'...kmlname
                            '</NetworkLink>\n'],...
                            code,...
                            minLod,-1,...
                            B.N,B.S,B.W,B.E,...
                            kmlprefix,code)];
                    else
                        % for static kml files that are filled in time,
                        % sometimes links to kml files from previous timesteps
                        % should be linked.
                        if OPT.filledInTime && ~timeDependant  && exist('previousSourcePaths','var')
                            if ~isempty(previousSourcePaths)
                                kmlname = [code '.kml'];
                                % check if exists in KML dir
                                if exist(fullfile(sourcePath,'..','KML',kmlname),'file')
                                    % if so, then check if exists in previous
                                    % files
                                    
                                    for kk = length(previousSourcePaths):-1:1
                                        [~,prefix] = fileparts(previousSourcePaths{kk});
                                        kmlname = fullfile('..',prefix,[prefix '_' code '.kml']);
                                        if exist(fullfile(sourcePath,kmlname),'file')
                                            output = [output sprintf([...
                                                '<NetworkLink>\n'...
                                                '<name>%s</name>\n'...name
                                                '<Region>\n'...
                                                '<Lod><minLodPixels>%d</minLodPixels><maxLodPixels>%d</maxLodPixels></Lod>\n'...minLod,maxLod
                                                '<LatLonAltBox><north>%3.8f</north><south>%3.8f</south><west>%3.8f</west><east>%3.8f</east></LatLonAltBox>\n' ...N,S,W,E
                                                '</Region>\n'...
                                                '<Link><href>%s</href><viewRefreshMode>onRegion</viewRefreshMode></Link>\n'...kmlname
                                                '</NetworkLink>\n'],...
                                                code,...
                                                minLod,-1,...
                                                B.N,B.S,B.W,B.E,...
                                                kmlname)];
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        %% add png icon links to kml
        B = KML_figure_tiler_code2boundary(tilesOnLevel(nn,:));
        iTiles = find(allTileNumbers ==  sscanf(tilesOnLevel(nn,:),'%lo'));
        for iTile = 1:length(iTiles)
            pngFile = tiles(iTiles(iTile)).name;
            if timeDependant
                if OPT.filledInTime
                    OPT2.timeIn    = tiles(iTiles(iTile)).name(1:underscorePos-1);
                    if iTile == length(iTiles)
                        OPT2.timeOut   = tiles(end)            .name(1:underscorePos-1);
                    else
                        OPT2.timeOut   = tiles(iTiles(iTile+1)).name(1:underscorePos-1);
                    end
                    OPT2.timeSpan  = sprintf(...
                        '<TimeSpan><begin>%s</begin><end>%s</end></TimeSpan>\n',...
                        OPT2.timeIn,OPT2.timeOut);
                else
                    OPT2.timeSpan  = sprintf(...
                        '<TimeStamp><when>%s</when></TimeStamp>\n',...
                        pngFile(1:underscorePos-1));
                end
                subfolder = ['../' pngFile(1:underscorePos-1) '/'];
            else
                subfolder = '';
                OPT2.timeSpan  = '';
            end
            OPT2.drawOrder = datenum(pngFile(1:underscorePos-1));
            
            output = [output sprintf([...
                '<Region>\n'...
                '<Lod><minLodPixels>%d</minLodPixels><maxLodPixels>%d</maxLodPixels></Lod>\n'...minLod,maxLod
                '<LatLonAltBox><north>%3.8f</north><south>%3.8f</south><west>%3.8f</west><east>%3.8f</east></LatLonAltBox>\n' ...N,S,W,E
                '</Region>\n'...
                '<GroundOverlay>\n'...
                '<name>%s</name>\n'...kml_id
                '<drawOrder>%0.0f</drawOrder>\n'...drawOrder
                '%s'...timeSpan
                '<Icon><href>%s%s</href></Icon>\n'...%image_link
                '<LatLonAltBox><north>%3.8f</north><south>%3.8f</south><west>%3.8f</west><east>%3.8f</east></LatLonAltBox>\n' ...N,S,W,E
                '</GroundOverlay>\n'],...
                minLod,maxLod,B.N,B.S,B.W,B.E,...
                tilesOnLevel(nn,:),...
                OPT2.drawOrder+level,OPT2.timeSpan,...
                subfolder,pngFile,...
                B.N,B.S,B.W,B.E)];
        end
             kmlname = fullfile(destPath,[kmlprefix tilesOnLevel(nn,:) '.kml']);
        fid=fopen(kmlname,'w');
        OPT_header = struct(...
            'name',tilesOnLevel(nn,:),...
            'open',0);
        output = [KML_header(OPT_header) output];
        
        % FOOTER
        output = [output KML_footer]; %#ok<*AGROW>
        fprintf(fid,'%s',output);
        
        % close KML
        fclose(fid);
        
%         if mod(nn,5)==1;
%             multiWaitbar('fig2png_write_kml' ,WB.a + WB.b*nn/size(tilesOnLevel,1),'label','Writing KML...')
%         end
    end
end

function ncfiles = get_nc_files(path_netcdf)
%% find nc files, and remove catalog.nc from the files if found
%     opendap = strcmpi(OPT.path_netcdf(1:4),'http')||strcmpi(OPT.path_netcdf(1:3),'www');
%     if opendap
%         % opendap_catalog should in fact handle that itself
%         if ~(strcmp(OPT.path_netcdf(end-10:end),'catalog.xml') || ...
%                 strcmp(OPT.path_netcdf(end-11:end),'catalog.html'))
%             temp = opendap_catalog([OPT.path_netcdf '/catalog.xml']);
%         else
%             temp = opendap_catalog([OPT.path_netcdf]);
%         end
%         for ii=1:length(temp)
%             fns(ii).name  = temp{ii};
%             fns(ii).bytes = 1000;
%         end
%     else % local path
ncfiles = dir2(path_netcdf,...
    'file_incl','\.nc$',...
    ...'file_incl','x0709250y8616375\.nc$',...
    'file_excl','^catalog\.nc$',...
    'case_sensitive',false,...
    'no_dirs',true,...
    'depth',0);
ncfiles = strcat({ncfiles.pathname}, {ncfiles.name})';
%     end