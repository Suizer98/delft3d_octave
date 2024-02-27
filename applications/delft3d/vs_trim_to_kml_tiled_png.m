function varargout = vs_trim_to_kml_tiled_png(varargin)
%vs_trim_to_kml_tiled_png  generates a tiled png from data in a Delft3D trim file.
%
%See also: delft3d_3d_visualisation_example, vs_trim2nc

% It firstly converts the trim file to nc using vs_trim2nc if the nc
% file does not exist yet.
%  **********BETA: only works with surface elevation**********
%
%   This function is intended to provide a fully automated routine to
%   generate an animated kml file for viewing in google earth from a dataset
%   provided in a (set of) nc file(s) the data in an nc file of set of
%   tiled nc files.
%
%   The NC file must contain z and time data and either x,y or lat,lon
%   data. If the NC File contains x,y data, Latitude and
%   Longitude data are calculated from the x and y data with
%   convertCoordinates using OPT.EPSGcode and OPT.calculate_latlon_local.
%
%   Syntax:
%   varargout = vs_trim_to_kml_tiled_png(varargin)
%
%   Output:
%   varargout =
%
%   Example;
%    OPT.trimfile       = 'c:\Data\A2512_SAMARES_Oosterschelde\Delft3D\computations\RG20\trim-RG20.dat';
%    OPT.basepath_local = 'c:\Data\A2512_SAMARES_Oosterschelde\googleearth\fromnc\';
%    OPT.relativepath   = 'myrelativepath';
%
%    vs_trim_to_kml_tiled_png('trimfile',OPT.trimfile,'basepath_local',OPT.basepath_local,'relativepath',OPT.relativepath);
%
%   See also vs_trim2nc, KMLfigure_tiler, nc_multibeam_to_kml_tiled_png, delft3d_mdf2kml

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 ARCADIS
%       Bart Grasmeijer
%
%       bart.grasmeijer@arcadis.nl
%
%       Voorsterweg 28, 8316 PT, Marknesse, The Netherlands
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 20 Jun 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id: vs_trim_to_kml_tiled_png.m 9034 2013-08-12 09:16:50Z boer_g $
% $Date: 2013-08-12 17:16:50 +0800 (Mon, 12 Aug 2013) $
% $Author: boer_g $
% $Revision: 9034 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/vs_trim_to_kml_tiled_png.m $
% $Keywords: $

%%

OPT.make                    = true;
OPT.copy2server             = false;

OPT.trimfile                = [];
OPT.ncpath                  = [];
OPT.ncfile                  = '*.nc';
OPT.relativepath            = [];

OPT.referencepath           = [];       % is provided, nc files with are expected here that define a reference plane which is to be subtracted from the data before plotting

OPT.basepath_local          = [];
OPT.basepath_network        = [];
OPT.basepath_www            = [];
OPT.serverURL               = [];       % if a KML file is intended to be placed on the server, the path must be hardcoded in the KML file

OPT.make_kmz                = false;    % this packs the entire file tree to a sing kmz file, convenient for portability
OPT.lowestLevel             = 14;       % integer; Detail level of the highest resultion png tiles to generate. Advised range 12 to 18;
% dimension of individual pixels in Lat and Lon can be calculated as follows:
% 360/(2^OPT.lowestLevel) / OPT.tiledim
OPT.tiledim                 = 256;      % dimension of tiles in pixels.

OPT.clim                    = [-50 25]; % limits of color scale
OPT.colorMap                = @(m) colormap_cpt('bathymetry_vaklodingen',m);
OPT.colorSteps              = 500;
OPT.CBtemplateHor           = 'KML_colorbar_template_horizontal.png';
OPT.CBtemplateVer           = 'KML_colorbar_template_vertical.png';
OPT.colorbar                = true;
OPT.description             = [];
OPT.descriptivename         = [];
OPT.lightAdjust             = [];      % if set to true, the shading/lighting of the figure is scaled to be independant of OPT.lowestLevel.

OPT.quiet                   = true;    % suppress some progress information
OPT.calculate_latlon_local  = false;   % use if x and y data are provided to be converted to lat and lon
OPT.EPSGcode                = [];      % code of coordinate system to convert x and y projection to Lat and Lon
%OPT.dateFcn                 = @(time) (time); % use nc_cf_time so it works with any units

% add colorbar defualt options
OPT                         = mergestructs(OPT,KMLcolorbar);

if nargin==0
    varargout = {OPT};
    return
end

OPT = setproperty(OPT,varargin{:});

if ~exist([filepathstr(OPT.trimfile),filesep,filename(OPT.trimfile),'.nc'],'file')
    vs_trim2nc(OPT.trimfile,'epsg',28992);
else
    disp([filename(OPT.trimfile),'.nc',' already exists, therefore conversion to nc skipped'])
end

OPT.ncpath = filepathstr(OPT.trimfile);
OPT.ncfile = [filename(OPT.trimfile),'.nc'];

if OPT.make
    %% find nc files, and remove catalog.nc from the files if found
    OPT.opendap = strcmpi(OPT.ncpath(1:4),'http')||strcmpi(OPT.ncpath(1:3),'www');
    if OPT.opendap
        if ~(strcmp(OPT.ncpath(end-10:end),'catalog.xml') || ...
                strcmp(OPT.ncpath(end-11:end),'catalog.html'))
            temp = opendap_catalog([OPT.ncpath '/catalog.xml']);
        else
            temp = opendap_catalog([OPT.ncpath]);
        end
        for ii=1:length(temp)
            fns(ii).name  = temp{ii};
            fns(ii).bytes = 1000;
        end
    else % local path
        fns = dir(fullfile(OPT.ncpath,OPT.ncfile));
    end
    
    if OPT.calculate_latlon_local
        EPSG = load('EPSG');
    end
    
    jj = false(length(fns),1);
    for ii = 1:length(fns)
        if any(strfind(fns(ii).name,'catalog.nc'));
            jj(ii) = true;
        end
    end
    fns(jj) = [];
    
    disp('generating kml files... ')
    %% initialize waitbars
    multiWaitbar('kml_print_all_tiles' ,'close')
    multiWaitbar('fig2png_print_tile'  ,'close')
    multiWaitbar('merge_all_tiles'     ,'close')
    multiWaitbar('fig2png_merge_tiles' ,'close')
    multiWaitbar('fig2png_write_kml'   ,'close')
    
    multiWaitbar('kml_print_all_tiles' ,0,'label','Printing tiles: total'       ,'color',[0.0 0.3 0.6])
    multiWaitbar('fig2png_print_tile'  ,0,'label','Printing tiles: per file'    ,'color',[0.0 0.5 1.0])
    multiWaitbar('merge_all_tiles'     ,0,'label','Merging tiles: total'        ,'color',[0.5 0.1 0.1])
    multiWaitbar('fig2png_merge_tiles' ,0,'label','Merging tiles: per timestep' ,'color',[0.7 0.3 0.3])
    multiWaitbar('fig2png_write_kml'   ,0,'label','Writing KML: total'          ,'color',[0.9 0.4 0.1])
    
    if isempty(OPT.lightAdjust)
        OPT.lightAdjust = 2^(OPT.lowestLevel-16);
    end
    
    %% base figure (properties of which will be adjusted to print tiles)
    
    figure('Visible','Off')
    x       = linspace(0,0.01,100);
    [x,y]   = meshgrid(x,x);
    z       = kron([10 1;5 1],peaks(50))-rand(100);
    h       = surf(x,y,z);
    hl      = light;material([0.7 0.2 0.15 100]);shading interp;lighting phong;axis off;
    axis tight;view(0,90);lightangle(hl,180,65);
    colormap(OPT.colorMap(OPT.colorSteps));clim(OPT.clim*OPT.lightAdjust);
    
    %% create kml directory if it does not yet exist
    if exist(fullfile(OPT.basepath_local,OPT.relativepath),'dir')
        try
            rmdir(fullfile(OPT.basepath_local,OPT.relativepath), 's')
        end
    end
    mkpath(fullfile(OPT.basepath_local,OPT.relativepath))
    
    
    %% get total file size
    WB.bytesToDo = 0;
    WB.bytesDone = 0;
    for ii = 1:length(fns)
        WB.bytesToDo = WB.bytesToDo+fns(ii).bytes;
    end
    
    %% pre-allocate
    [minlat,minlon,maxlat,maxlon] = deal(nan);
    
    %% MAKE TILES in this loop
    for ii = 1:length(fns);
        if OPT.opendap
            url = fns(ii).name; %#ok<*ASGLU>
        else
            url = fullfile(OPT.ncpath,fns(ii).name); %#ok<*ASGLU>
        end
        
        if ~isempty(OPT.referencepath)
            url_reference = fullfile(OPT.referencepath,fns(ii).name); %#ok<*ASGLU>
            if exist(url_reference,'file')
                z_reference = nc_varget(url_reference,'z',[ 0, 0, 0],[-1,-1,-1]);
                
                % check if lat and lon are identical in the source and the
                % reference plane
                lonInfo = nc_getvarinfo(url, 'lon');
                
                lon1  = nc_varget(url          , 'lon',[0 0],[10 10],floor(lonInfo.Size/10));
                lat1  = nc_varget(url          , 'lat',[0 0],[10 10],floor(lonInfo.Size/10));
                lon2  = nc_varget(url_reference, 'lon',[0 0],[10 10],floor(lonInfo.Size/10));
                lat2  = nc_varget(url_reference, 'lat',[0 0],[10 10],floor(lonInfo.Size/10));
                
                if ~(isequalwithequalnans (lon1,lon2) && isequalwithequalnans (lat1,lat2))
                    error('the reference plane coordinates are not equal to the source plane coordinates')
                end
            else
                disp([fns(ii).name ' could not be found in directory ' OPT.referencepath])
                z_reference = nan;
            end
        else
            z_reference = 0;
        end
        
        date = nc_cf_time(url,'time');
        
        multiWaitbar('kml_print_all_tiles'  ,WB.bytesDone/WB.bytesToDo,...
            'label',sprintf('Printing tiles: %s Timestep: %d/%d',fns(ii).name,1,size(date,1)))
        
        % read lat,lon data or calculate lat,lon from x,y
        if  OPT.calculate_latlon_local
            x  = nc_varget(url, 'x');
            y  = nc_varget(url, 'y');
            [x,y] = meshgrid(x,y);
            [lon,lat] = convertCoordinates(x,y,'CS1.code',OPT.EPSGcode,'CS2.code',4326);
        else
            lon  = nc_varget(url, 'longitude');
            lat  = nc_varget(url, 'latitude');
        end
        
        % expand lat and lon in each direction to create some overlap
        lon = [lon(:,1) + (lon(:,1)-lon(:,2))*.55  lon  lon(:,end) + (lon(:,end)-lon(:,end-1))*.55];
        lat = [lat(:,1) + (lat(:,1)-lat(:,2))*.55  lat  lat(:,end) + (lat(:,end)-lat(:,end-1))*.55];
        lon = [lon(1,:) + (lon(1,:)-lon(2,:))*.55; lon; lon(end,:) + (lon(end,:)-lon(end-1,:))*.55];
        lat = [lat(1,:) + (lat(1,:)-lat(2,:))*.55; lat; lat(end,:) + (lat(end,:)-lat(end-1,:))*.55];
        
        % extend last time interval for visibility period in Google Earth
        date4GE          = date;
        date4GE(end+1,1) = date(end)+1;
        
        % get dimension info of z
        z_dim_info = nc_getvarinfo(url,'eta') ;
        time_dim = strcmp(z_dim_info.Dimension,'time');
        
        % for some reason this has to be set since the new nc toolbox was added;
        setpref('SNCTOOLS','PRESERVE_FVD',true)
        
        for jj = size(date4GE,1)-1:-1:1
            % load z data
            z = nc_varget(url,'eta',...
                [ 0, 0, 0] + (jj-1)*time_dim,...
                [-1,-1,-1] + 2*time_dim);
            
            KFU = nc_varget(url,'KFU',...
                [ 0, 0, 0] + (jj-1)*time_dim,...
                [-1,-1,-1] + 2*time_dim);

            % subtract reference plane form data (reference plane is zeros
            % if not set otherwise
            z = z-z_reference;
            
            if sum(~isnan(z(:)))>=3
                if ~OPT.quiet
                    disp(['data coverage is ' num2str(sum(~isnan(z(:)))/numel(z)*100) '%'])
                end
                z = z([1 1 1:end end end],:); z = z(:,[1 1 1:end end end]); % expand z
                KFU = KFU([1 1 1:end end end],:); KFU = KFU(:,[1 1 1:end end end]); % expand KFU
                
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
                KFU = KFU(2:end-1,2:end-1);
                z(KFU==0) = NaN;
                
                %                 figure;
                %                 pcolor(lon,lat,z);
                %                 shading interp;
                %                 axis equal
                % %                 pause;
                %                 clim([-2 2]);
                
                %% MAKE TILES
                myfileName = [datestr(date(jj),30) '.kml'];
                mydrawOrder = round(date(jj));
%                 KMLfigure_tiler(h,lat,lon,z*OPT.lightAdjust,...
                KMLfigure_tiler(h,lat,lon,z,...    
                    'highestLevel',10,...
                    'lowestLevel',OPT.lowestLevel,...
                    'timeIn',date4GE(jj),...
                    'timeOut',date4GE(jj+1),...
                    'fileName',myfileName,...
                    'timeFormat','yyyy-mm-ddTHH:MM:SS',...
                    'drawOrder',mydrawOrder,...
                    'joinTiles',false,...
                    'makeKML',false,...
                    'mergeExistingTiles',true,...
                    'dim',OPT.tiledim,...
                    'basePath',fullfile(OPT.basepath_local,OPT.relativepath));
                
                minlat = min(minlat,min(lat(:)));
                minlon = min(minlon,min(lon(:)));
                maxlat = max(maxlat,max(lat(:)));
                maxlon = max(maxlon,max(lon(:)));
                
            else
                disp(['data coverage is ' num2str(sum(~isnan(z(:)))/numel(z)*100) '%, no file created'])
            end
            WB.bytesDone =  WB.bytesDone + fns(ii).bytes/size(date,1);
            multiWaitbar('kml_print_all_tiles'  ,WB.bytesDone/WB.bytesToDo,...
                'label',sprintf('Printing tiles: %s Timestep: %d/%d',fns(ii).name,jj,size(date,1)))
        end
    end
    
    multiWaitbar('fig2png_print_tile','close')
    multiWaitbar('kml_print_all_tiles',1,'label','Printing tiles')
    
    %% JOIN TILES
    fns = dir(fullfile(OPT.basepath_local,OPT.relativepath));
    multiWaitbar('merge_all_tiles'     ,0,'label','Merging tiles: total')
    for ii = 3:length(fns)-1
        multiWaitbar('merge_all_tiles' ,(ii-3)/(length(fns)-2),'label',sprintf('Merging tiles: %d/%d',ii-3,length(fns)-2))
        mytimeIn = datenum(fns(ii).name,'yyyymmddTHHMMSS');
        mytimeOut = datenum(fns(ii+1).name,'yyyymmddTHHMMSS');
        mydrawOrder = round(datenum(fns(ii).name,'yyyymmddTHHMMSS'));
        if fns(ii).isdir
            OPT2 = KMLfigure_tiler(h,lat,lon,z,...
                'highestLevel',6,...
                'lowestLevel',OPT.lowestLevel,...
                'timeIn',mytimeIn,...
                'timeOut',mytimeOut,...
                'basePath',fullfile(OPT.basepath_local,OPT.relativepath),...
                'fileName',fullfile([fns(ii).name '.kml']),...
                'timeFormat','yyyy-mm-ddTHH:MM:SS',...
                'drawOrder',mydrawOrder,...
                'printTiles',false,...
                'joinTiles',true,...
                'makeKML',false,...
                'dim',OPT.tiledim);
        end
        multiWaitbar('merge_all_tiles' ,(ii-2)/(length(fns)-2),'label',sprintf('Merging tiles: %d/%d',ii-2,length(fns)-2))
    end
    multiWaitbar('fig2png_merge_tiles','close')
    multiWaitbar('merge_all_tiles',1,'label','Merging tiles')
    
    %% make kml files
    multiWaitbar('fig2png_write_kml'   ,0,'label','Writing KML - Getting unique png file names...','color',[0.9 0.4 0.1])
    OPT2.highestLevel  = inf;
    OPT2.lowestLevel   = OPT.lowestLevel;
    
    dates     = findAllFiles('basepath',fullfile(OPT.basepath_local,OPT.relativepath),'recursive',false);
    datenums  = datenum(dates,'yyyymmddTHHMMSS');
    
    tilefull  = findAllFiles('basepath',fullfile(OPT.basepath_local,OPT.relativepath),'pattern_incl','*.png');
    tilefull2 = tilefull;
    for ii = 1:length(tilefull)
        tilefull2{ii} = tilefull2{ii}(end-40:end);
    end
    tiles = cell(size(tilefull));
    [path, fname] = fileparts(tilefull{1}); %#ok<NASGU>
    id = strfind(tilefull{1},'_'); id = id(end)-length(path);
    
    for ii = 1:length(tilefull)
        [path, fname] = fileparts(tilefull{ii});
        tiles{ii} = fname(id:end);
        OPT2.highestLevel = min(length(tiles{ii}),OPT2.highestLevel);
        OPT2.lowestLevel  = max(length(tiles{ii}),OPT.lowestLevel);
    end
    mkdir(fullfile(OPT.basepath_local,OPT.relativepath,'KML'));
    
    %% MAKE KML
    multiWaitbar('fig2png_write_kml'   ,0,'label','Writing KML...','color',[0.9 0.4 0.1])
    for level = OPT2.highestLevel:OPT2.lowestLevel
        
        WB.a = 0.25.^(OPT.lowestLevel - level)*.25;
        WB.b = 0.25.^(OPT.lowestLevel - level)*.75;
        
        tileCodes = nan(length(tiles),level);
        for ii = 1:length(tiles)
            if length(tiles{ii}) == level
                tileCodes(ii,:) = tiles{ii};
            end
        end
        
        tileCodes(any(isnan(tileCodes),2),:) = [];
        tileCodes = char(tileCodes);
        tilesOnLevel = unique(tileCodes(:,1:end),'rows');
        if level == OPT2.highestLevel
            fileID = tilesOnLevel;
        end
        
        tileCodesNextLevel = nan(length(tiles),level+1);
        for ii = 1:length(tiles)
            if length(tiles{ii}) == level+1
                tileCodesNextLevel(ii,:) = tiles{ii};
            end
        end
        tileCodesNextLevel(any(isnan(tileCodesNextLevel),2),:) = [];
        tileCodesNextLevel = char(tileCodesNextLevel);
        tilesOnNextLevel = unique(tileCodesNextLevel(:,1:end),'rows');
        
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
                                '<Link><href>%s.kml</href><viewRefreshMode>onRegion</viewRefreshMode></Link>\n'...kmlname
                                '</NetworkLink>\n'],...
                                code,...
                                minLod,-1,...
                                B.N,B.S,B.W,B.E,...
                                code)];
                        end
                    end
                end
            end
            %% add png icon links to kml
            B = KML_figure_tiler_code2boundary(tilesOnLevel(nn,:));
            for iDate = 1: length(dates)
                pngFile = [dates{iDate} filesep dates{iDate} '_' tilesOnLevel(nn,:) '.png'];
                temp = fullfile(OPT.basepath_local,OPT.relativepath, pngFile);
                if any(strcmp(temp(end-40:end),tilefull2))
                    OPT2.timeIn    = datenums(iDate);
                    OPT2.timeOut   = OPT2.timeIn+1;
                    OPT2.drawOrder = datenums(iDate);
                    OPT2.timeSpan  = sprintf(...
                        '<TimeSpan><begin>%s</begin><end>%s</end></TimeSpan>\n',...OPT2.timeIn,OPT2.timeOut
                        datestr(OPT2.timeIn,OPT2.timeFormat),datestr(OPT2.timeOut,OPT2.timeFormat));
                    output = [output sprintf([...
                        '<Region>\n'...
                        '<Lod><minLodPixels>%d</minLodPixels><maxLodPixels>%d</maxLodPixels></Lod>\n'...minLod,maxLod
                        '<LatLonAltBox><north>%3.8f</north><south>%3.8f</south><west>%3.8f</west><east>%3.8f</east></LatLonAltBox>\n' ...N,S,W,E
                        '</Region>\n'...
                        '<GroundOverlay>\n'...
                        '<name>%s</name>\n'...kml_id
                        '<drawOrder>%0.0f</drawOrder>\n'...drawOrder
                        '%s'...timeSpan
                        '<Icon><href>..\\%s</href></Icon>\n'...%file_link
                        '<LatLonAltBox><north>%3.8f</north><south>%3.8f</south><west>%3.8f</west><east>%3.8f</east></LatLonAltBox>\n' ...N,S,W,E
                        '</GroundOverlay>\n'],...
                        minLod,maxLod,B.N,B.S,B.W,B.E,...
                        tilesOnLevel(nn,:),...
                        OPT2.drawOrder+level,OPT2.timeSpan,...
                        pngFile,...
                        B.N,B.S,B.W,B.E)];
                end
            end
            fid=fopen(fullfile(OPT.basepath_local,OPT.relativepath,'KML',[tilesOnLevel(nn,:) '.kml']),'w');
            OPT_header = struct(...
                'name',tilesOnLevel(nn,:),...
                'open',0);
            output = [KML_header(OPT_header) output];
            
            % FOOTER
            output = [output KML_footer]; %#ok<*AGROW>
            fprintf(fid,'%s',output);
            
            % close KML
            fclose(fid);
            
            if mod(nn,5)==1;
                multiWaitbar('fig2png_write_kml' ,WB.a + WB.b*nn/size(tilesOnLevel,1),'label','Writing KML...')
            end
        end
    end
    
    %% generate a locally readable kml file
    % if ~isempty(OPT2.baseUrl)
    %     if ~strcmpi(OPT2.baseUrl(end),'/');
    %         OPT2.baseUrl = [OPT2.baseUrl '\'];
    %     end
    % end
    
    OPT2.description = ['generated: ' datestr(now())];
    [path,fname] = fileparts(OPT.relativepath);
    output = sprintf([...
        '<NetworkLink>'...
        '<name>files</name>'...                                                                                             % name
        '<Link><href>%s</href><viewRefreshMode>onRegion</viewRefreshMode></Link>'...                                     % link
        '</NetworkLink>'],...
        fullfile(fname, 'KML', [fileID '.kml'])); % TO DO: issue when OPT.lowestLevel too small
    
    OPT2.fid=fopen(fullfile(OPT.basepath_local,OPT.relativepath, 'doc.kml'),'w');
    
    if length(datenums) == 1
        OPT_header = struct(...
            'name',         OPT.descriptivename,...
            'open',         0,...
            'description',  OPT.description,...
            'lon',          mean([maxlon minlon]),...
            'lat',          mean([maxlat minlat]),...
            'z',            1e4,...
            'timeIn',       min(datenums));
    elseif length(datenums) < 5
        OPT_header = struct(...
            'name',         OPT.descriptivename,...
            'open',         0,...
            'description',  OPT.description,...
            'lon',          mean([maxlon minlon]),...
            'lat',          mean([maxlat minlat]),...
            'z',            1e4,...
            'timeIn',       min(datenums),...
            'timeOut',      max(datenums));
    else
        OPT_header = struct(...
            'name',         OPT.descriptivename,...
            'open',         0,...
            'description',  OPT.description,...
            'lon',          mean([maxlon minlon]),...
            'lat',          mean([maxlat minlat]),...
            'z',            1e4,...
            'timeIn',       min(datenums(end-4:end)),...
            'timeOut',      max(datenums(end-4:end)));
    end
    
    output = [KML_header(OPT_header) output];
    
    %% COLORBAR
    
    if OPT.colorbar
        clrbarstring = KMLcolorbar('CBcLim',OPT.clim,...
            'CBfileName', fullfile(OPT.basepath_local,OPT.relativepath,'KML','colorbar') ,...
            'CBcolorMap',OPT.colorMap,'CBcolorSteps',OPT.colorSteps,'CBcolorbarlocation',OPT.CBcolorbarlocation,...
            'CBcolorTick',OPT.CBcolorTick,'CBfontrgb',OPT.CBfontrgb,'CBbgcolor',OPT.CBbgcolor,'CBcolorTitle',OPT.CBcolorTitle,...
            'CBframergb',OPT.CBframergb,'CBalpha',OPT.CBalpha,'CBtemplateHor',OPT.CBtemplateHor,'CBtemplateVer',OPT.CBtemplateVer);
        clrbarstring = strrep(clrbarstring,'<Icon><href>colorbar_',['<Icon><href>' [fname filesep 'KML' filesep 'colorbar'] '_']);
        output = [output clrbarstring];
    end
    
    %% FOOTER
    
    output = [output KML_footer];
    fprintf(OPT2.fid,'%s',output);
    
    %% close KML
    fclose(OPT2.fid);
    
    %% generate different versions of the KML
    copyfile(fullfile(OPT.basepath_local,OPT.relativepath, 'doc.kml'),fullfile(OPT.basepath_local,path, [fname '_localmachine.kml']))
    copyfile(fullfile(OPT.basepath_local,OPT.relativepath, 'doc.kml'),fullfile(OPT.basepath_local,path, [fname '_server.kml']))
    strrep_in_files(fullfile(OPT.basepath_local,path, [fname '_server.kml']),...
        ['<href>' fname filesep 'KML' filesep],...
        ['<href>' OPT.basepath_www  path2os(fullfile(filesep,OPT.relativepath,'KML',filesep),'/')],...
        'quiet',true);
    if OPT.make_kmz
        zip     (fullfile(OPT.basepath_local,path,[fname '.zip']),fullfile(OPT.basepath_local,OPT.relativepath))
        movefile(fullfile(OPT.basepath_local,path,[fname,'.zip']),fullfile(OPT.basepath_local,path,[fname '_portable.kmz']))
    end
    delete(fullfile(OPT.basepath_local,OPT.relativepath, 'doc.kml'))
    
    multiWaitbar('fig2png_write_kml'  ,'close')
    multiWaitbar('merge_all_tiles'    ,'close')
    multiWaitbar('kml_print_all_tiles',1,'label','Writing of KML files')
    
    disp('generation of kml files completed')
else
    disp('generation of kml files skipped')
end

%% copy files to server
if OPT.copy2server
    multiWaitbar('kml_copy',0,...
        'label','Copying of KML files','color',[0 0.4 0.2]);
    [path,fname] = fileparts(OPT.relativepath);
    % delete current kml files
    if exist (fullfile(OPT.basepath_network,OPT.relativepath),'dir')
        rmdir(fullfile(OPT.basepath_network,OPT.relativepath), 's')
    end
    if exist  (fullfile(OPT.basepath_network,path,[fname '.kml']),'file')
        delete(fullfile(OPT.basepath_network,path,[fname '.kml']))
    end
    if exist  (fullfile(OPT.basepath_network,path,[fname '_portable.kmz']),'file')
        delete(fullfile(OPT.basepath_network,path,[fname '_portable.kmz']))
    end
    
    mkpath(fullfile(OPT.basepath_network,OPT.relativepath));
    
    fns = findAllFiles('pattern_incl', 'basepath', fullfile(OPT.basepath_local,OPT.relativepath), 'recursive', false) ;
    for ii = 1:length(fns)
        multiWaitbar('kml_copy',ii/length(fns),...
            'label',['copying files in ' fullfile(fname, fns{ii}) ' to the server']);
        copyfile(...
            fullfile(OPT.basepath_local  ,OPT.relativepath,fns{ii}),...
            fullfile(OPT.basepath_network,OPT.relativepath,fns{ii}))
    end
    
    copyfile(fullfile(OPT.basepath_local,path,[fname '_server.kml']),fullfile(OPT.basepath_network,path,[fname '.kml']))
    if OPT.make_kmz
        copyfile(fullfile(OPT.basepath_local,path,[fname '_portable.kmz']),fullfile(OPT.basepath_network,path,[fname '_portable.kmz']))
    end
    multiWaitbar('kml_copy',1,'label','Copying of KML files');
end

varargout = {OPT};
