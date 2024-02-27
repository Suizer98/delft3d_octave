function varargout = nc_multibeam_to_kml_tiled_png(varargin)
%NC_MULTIBEAM_TO_KML_TILED_PNG  Generate a tiled png from data in nc files
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
%   varargout = nc_multibeam_to_kml_tiled_png(varargin)
%
%   nc_multibeam_to_kml_tiled_png
%
%See also: nc_multibeam, snctools

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 <COMPANY>
%       Thijs
%
%       <EMAIL>
%
%       <ADDRESS>
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

% $Id: nc_multibeam_to_kml_tiled_png.m 5978 2012-04-16 13:57:51Z santinel $
% $Date: 2012-04-16 21:57:51 +0800 (Mon, 16 Apr 2012) $
% $Author: santinel $
% $Revision: 5978 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/nc_processing/nc_multibeam/nc_multibeam_to_kml_tiled_png.m $
% $Keywords: $
%
%       nc_SetOptions  can be used to collect the input parameters
%       Example
%       OPT = nc_SetOptions
%       nc_multibeam_to_kml_tiles_png(OPT.kml)
%
%%
set(0,'defaultFigureWindowStyle','normal')

if nargin==0
    varargout = {'Input parameters are not given'};
    return
end

OPT = setproperty(varargin{:});

if OPT.make
    %% find nc files, and remove catalog.nc from the files if found
    OPT.opendap = strcmpi(OPT.ncpath(1:4),'http')||strcmpi(OPT.ncpath(1:3),'www');
    if OPT.opendap
        % opendap_catalog should in fact handle that itself
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
    multiWaitbar( 'CloseAll' );
    %     multiWaitbar('kml_print_all_tiles' ,'close')
    %     multiWaitbar('fig2png_print_tile'  ,'close')
    %     multiWaitbar('merge_all_tiles'     ,'close')
    %     multiWaitbar('fig2png_merge_tiles' ,'close')
    %     multiWaitbar('fig2png_write_kml'   ,'close')
    
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
    
    if isempty(OPT.relativepath)
        OPT.relativepath = filesep;
    else
        if path2os(OPT.relativepath(end)) == filesep
           OPT.relativepath = OPT.relativepath(1:end-1); % remove trailing slash, gives issues
        end
    end
    
    if exist(fullfile(OPT.basepath_local,OPT.relativepath),'dir')
        try
            rmdir(fullfile(OPT.basepath_local,OPT.relativepath), 's')
        catch
            % do nothing
        end
    end
    mkpath(fullfile(OPT.basepath_local,OPT.relativepath))
    
    
    %% get total file size
    
    WB.bytesToDo = 0;
    WB.bytesDone = 0;
    for ii = 1:length(fns)
        tmp = fns(ii).bytes;
        if isempty(tmp)
            tmp = 0;
        end
%         WB.bytesToDo = WB.bytesToDo+fns(ii).bytes;
        WB.bytesToDo = WB.bytesToDo+tmp;
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
                z_reference = double(nc_varget(url_reference,OPT.var_name,[ 0, 0, 0],[1,-1,-1])); % [OPT.stride ???]
                
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
        % OPT.calculate_latlon_local==0: do not convert but reuse lat/lon from file
        % OPT.calculate_latlon_local==1: conversion do for whole matrix
        % OPT.calculate_latlon_local>1:  convert calculate_latlon_local lines at a time
        if  OPT.calculate_latlon_local > 0
            x         = double(nc_varget(url, 'x',0,-1,OPT.stride));
            y         = double(nc_varget(url, 'y',0,-1,OPT.stride));
            [x,y]     = meshgrid(x,y);
            
            if (OPT.calculate_latlon_local > 1) && ~isinf(OPT.calculate_latlon_local)
                dline = OPT.calculate_latlon_local;
                for itmp=1:dline:size(x,1)
                    iitmp = itmp+(1:dline)-1;
                    iitmp = iitmp(iitmp <= size(x,1));
                    disp(['converting coordinates to (lat,lon): ',num2str(min(iitmp)),'-',num2str(max(iitmp)),'/',num2str(size(x,1))])
                    [lon(iitmp,:),lat(iitmp,:)] = convertCoordinates(x(iitmp,:),y(iitmp,:),'CS1.code',OPT.EPSGcode,'CS2.code',4326);
                end
            else % 0 or Inf
                [lon,lat] = convertCoordinates(x,y,'CS1.code',OPT.EPSGcode,'CS2.code',4326);
            end
            
        else
                lon       = double(nc_varget(url, 'lon',[0 0],[-1 -1],[OPT.stride OPT.stride]));
                lat       = double(nc_varget(url, 'lat',[0 0],[-1 -1],[OPT.stride OPT.stride]));
        end
        
        clear x y % save memory
        
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
        z_dim_info = nc_getvarinfo(url,OPT.var_name) ;
        time_dim   = strcmp(z_dim_info.Dimension,'time');
        x_dim      = strcmp(z_dim_info.Dimension,'x');
        y_dim      = strcmp(z_dim_info.Dimension,'y');
        
        stride = [OPT.stride OPT.stride OPT.stride];stride(time_dim)=1;
        
        for jj = size(date4GE,1)-1:-1:1
            % load z data
            z = double(nc_varget(url,OPT.var_name,...
                [ 0, 0, 0] + (jj-1)*time_dim,...
                [-1,-1,-1] + 2*time_dim,stride));
            
            % rearrange array into order [x,y]
            z = squeeze(permute(z,[find(time_dim) find(x_dim) find(y_dim)]));
            
            % subtract reference plane form data (reference plane is zeros
            % if not set otherwise
            if numel(z_reference) == 1 && isnan(z_reference)
                z = nan;
            else
                z = z-z_reference;
            end
            
            if sum(~isnan(z(:)))>=3
                if ~OPT.quiet
                    disp(['data coverage is ' num2str(sum(~isnan(z(:)))/numel(z)*100) '%'])
                end
                
                % Expand Z in all sides by replicating edge values;
                z = z([1 1 1:end end end],:); z = z(:,[1 1 1:end end end]); % expand z
                
                % This bit of code makes sure 'holes' in the surface drawn
                % with the surf command only have the size of a cell,
                % insteda of one missing data value 'erasing' all four
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
                KMLfigure_tiler(h,lat,lon,z*OPT.lightAdjust,...
                    'highestLevel'      ,OPT.highestLevel,...
                    'lowestLevel'       ,OPT.lowestLevel,...
                    'timeIn'            ,date4GE(jj),...
                    'timeOut'           ,date4GE(jj+1),...
                    'fileName'          ,[datestr(date(jj),29) '.kml'],...
                    'dateStrStyle'      ,'yyyy-mm-dd',...
                    'drawOrder'         ,round(date(jj)),...
                    'printTiles'        ,true,...  % 1 (below 0)!
                    'joinTiles'         ,false,... % 0 (below 1)!
                    'makeKML'           ,false,... % 0 (done in this mfile)!
                    'mergeExistingTiles',true,...  % 1 ! overwrite tiles, don't remove anything
                    'dim'               ,OPT.tiledim,...
                    'basePath'          ,fullfile(OPT.basepath_local,OPT.relativepath));
                
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
    for ii = 3:length(fns)
        multiWaitbar('merge_all_tiles' ,(ii-3)/(length(fns)-2),'label',sprintf('Merging tiles: %d/%d',ii-3,length(fns)-2))
        if fns(ii).isdir
            OPT2 = KMLfigure_tiler(h,lat,lon,z,...
                'highestLevel'      ,OPT.highestLevel,...
                'lowestLevel'       ,OPT.lowestLevel,...
                'timeIn'            ,datenum(fns(ii).name),...
                'timeOut'           ,datenum(fns(ii).name)+1,...
                'basePath'          ,fullfile(OPT.basepath_local,OPT.relativepath),...
                'fileName'          ,fullfile([fns(ii).name '.kml']),...
                'dateStrStyle'      ,'yyyy-mm-dd',...
                'drawOrder'         ,round(datenum(fns(ii).name)),...
                'printTiles'        ,false,... % 0 (above 1)!
                'joinTiles'         ,true,...  % 1 (above 0)!
                'makeKML'           ,false,... % 0 (done in this mfile)!
                'mergeExistingTiles',true,...  % 1 ! irrelevant when printTiles==0
                'dim'               ,OPT.tiledim);
        end
        multiWaitbar('merge_all_tiles' ,(ii-2)/(length(fns)-2),'label',sprintf('Merging tiles: %d/%d',ii-2,length(fns)-2))
    end
    multiWaitbar('fig2png_merge_tiles','close')
    multiWaitbar('merge_all_tiles',1,'label','Merging tiles')
    
    %% make kml files
    
    multiWaitbar('fig2png_write_kml'   ,0,'label','Writing KML - Getting unique png file names...','color',[0.9 0.4 0.1])
    mkdir(fullfile(OPT.basepath_local,OPT.relativepath,'KML'));
    dates               = dir2(fullfile(OPT.basepath_local,OPT.relativepath),'depth',0,'dir_excl','^KML$');
    dates               = dates(2:end);
    dates               = strcat({dates([dates.isdir]).name}');
    datenums            = datenum(dates,'yyyy-mm-dd');
    tiles               = dir2(fullfile(OPT.basepath_local,OPT.relativepath),'file_incl','\.png$');
    tiles               = tiles(~[tiles.isdir]);
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
    
    %% MAKE KML
    
    multiWaitbar('fig2png_write_kml'   ,0,'label','Writing KML...','color',[0.9 0.4 0.1])
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
            iTiles = find(allTileNumbers ==  sscanf(tilesOnLevel(nn,:),'%lo'));
            for iTile = 1:length(iTiles)
                pngFile = tiles(iTiles(iTile)).name;
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
                    '<Icon><href>..\\%s/%s</href></Icon>\n'...%file_link
                    '<LatLonAltBox><north>%3.8f</north><south>%3.8f</south><west>%3.8f</west><east>%3.8f</east></LatLonAltBox>\n' ...N,S,W,E
                    '</GroundOverlay>\n'],...
                    minLod,maxLod,B.N,B.S,B.W,B.E,...
                    tilesOnLevel(nn,:),...
                    OPT2.drawOrder+level,OPT2.timeSpan,...
                    pngFile(1:underscorePos-1),pngFile,...
                    B.N,B.S,B.W,B.E)];
                
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
    [path,fname,ext] = fileparts(OPT.relativepath);
    for k = 1:size(fileID,1)
%         if size(fileID,1)>1
%             fileID = fileID(k,:);
%         end
        tmpkml(k,:) = ['doc', num2str(k),'.kml'];
        output = sprintf([...
            '<NetworkLink>'...
            '<name>files</name>'...                                                                                             % name
            '<Link><href>%s</href><viewRefreshMode>onRegion</viewRefreshMode></Link>'...                                     % link
            '</NetworkLink>'],...
            fullfile([fname ext], 'KML', [fileID(k,:) '.kml'])); % TO DO: issue when OPT.lowestLevel too small

        OPT2.fid=fopen(fullfile(OPT.basepath_local,OPT.relativepath,tmpkml(k,:)),'w');

        OPT_header = struct(...
            'kmlName',       OPT.descriptivename,...
            'open',          0,...
            'description',   OPT.description,...
            'cameralon',    mean([maxlon minlon]),...
            'cameralat',    mean([maxlat minlat]),...
            'cameraz',      1e4);

        if length(datenums) == 1;
            OPT_header.timeIn  = min(datenums);
        elseif OPT.filledInTime
            OPT_header.timeIn  = max(datenums);
        elseif length(datenums) < 5
            OPT_header.timeIn  = min(datenums);
            OPT_header.timeOut = max(datenums);
        else
            OPT_header.timeIn  =  min(datenums(end-4:end));
            OPT_header.timeOut =  max(datenums(end-4:end));
        end

        output = [KML_header(OPT_header) output];

        %% COLORBAR

        if OPT.colorbar
            clrbarstring = KMLcolorbar('CBcLim',OPT.clim,...
                'CBfileName',           fullfile(OPT.basepath_local,OPT.relativepath,'KML','colorbar') ,...
                'CBcolorMap',           OPT.colorMap,...
                'CBcolorSteps',         OPT.colorSteps,...
                'CBcolorbarlocation',   OPT.CBcolorbarlocation,...
                'CBcolorTick',          OPT.CBcolorTick,...
                'CBfontrgb',            OPT.CBfontrgb,...
                'CBbgcolor',            OPT.CBbgcolor,...
                'CBcolorTitle',         OPT.CBcolorTitle,...
                'CBframergb',           OPT.CBframergb,...
                'CBalpha',              OPT.CBalpha,...
                'CBtemplateHor',        OPT.CBtemplateHor,...
                'CBtemplateVer',        OPT.CBtemplateVer);
            clrbarstring = strrep(clrbarstring,'<Icon><href>colorbar_',['<Icon><href>' [fname ext filesep 'KML' filesep 'colorbar'] '_']);
            output = [output clrbarstring];
        end

        %% FOOTER

        output = [output KML_footer];
        fprintf(OPT2.fid,'%s',output);

        %% close KML

        fclose(OPT2.fid);
    end
    
   sfiles = dir([fullfile(OPT.basepath_local,OPT.relativepath,filesep),'*.kml']);
   tmp = [];
   for j = 1:size(sfiles,1)
       tmp = [{[fullfile(OPT.basepath_local,OPT.relativepath,filesep,getfield(sfiles(j),'name'))]} , tmp];
   end
   if size(sfiles,1)>1
        disp('additional merging of kml files is carried out to temporary solve the multiple fileIDs (CAT hor must agree)')
   end
   KMLmerge_files('fileName',fullfile(OPT.basepath_local,OPT.relativepath,filesep,'doc.kml'),'kmlName', OPT.descriptivename ,'sourceFiles',tmp,'deleteSourceFiles', true);

%    OPT                   = KML_header();
%    OPT.fileName          = '';
%    OPT.sourceFiles       = {};
%    OPT.foldernames       = {}; % TO DO check for existing folder names
%    OPT.distinctDocuments = 0;  % avoids conflicts among styles (e.g. icon's and line's)
%    OPT.deleteSourceFiles = false;
    
    %% generate different versions of the KML
    copyfile(fullfile(OPT.basepath_local,OPT.relativepath, 'doc.kml'),fullfile(OPT.basepath_local,path, [fname ext '_localmachine.kml']))
    copyfile(fullfile(OPT.basepath_local,OPT.relativepath, 'doc.kml'),fullfile(OPT.basepath_local,path, [fname ext '_server.kml']))
    
    strrep_in_files(fullfile(OPT.basepath_local,path, [fname ext '_server.kml']),...
        ['<href>' fname ext                                           filesep 'KML' filesep],...
        ['<href>' OPT.basepath_www  path2os(fullfile(filesep,OPT.relativepath,'KML',filesep),'/')],...
        'quiet',true);
    if OPT.make_kmz
        zip     (fullfile(OPT.basepath_local,path,[fname ext '.zip']),fullfile(OPT.basepath_local,OPT.relativepath))
        movefile(fullfile(OPT.basepath_local,path,[fname ext '.zip']),fullfile(OPT.basepath_local,path,[fname ext '_portable.kmz']))
    end
    delete(fullfile(OPT.basepath_local,OPT.relativepath, 'doc.kml'))
    
    multiWaitbar('fig2png_write_kml'  ,'close')
    multiWaitbar('merge_all_tiles'    ,'close')
    multiWaitbar('kml_print_all_tiles',1,'label','Writing of KML files')
    
    sprintf('\ngeneration of kml files completed\n');
    
    %% merge kml files in time
    if OPT.filledInTime
        KML_figure_tiler_MergeTilesInTime(fullfile(OPT.basepath_local,OPT.relativepath));
    end
else
    disp('generation of kml files skipped')
end

%% copy files to server

if OPT.copy2server
    multiWaitbar('kml_copy',0,...
        'label','Copying of KML files','color',[0 0.4 0.2]);
    [path,fname,ext] = fileparts(OPT.relativepath);
    % delete current kml files
    if exist (fullfile(OPT.basepath_network,OPT.relativepath),'dir')
        rmdir(fullfile(OPT.basepath_network,OPT.relativepath), 's')
    end
    if exist  (fullfile(OPT.basepath_network,path,[fname ext '.kml']),'file')
        delete(fullfile(OPT.basepath_network,path,[fname ext '.kml']))
    end
    if exist  (fullfile(OPT.basepath_network,path,[fname ext '_portable.kmz']),'file')
        delete(fullfile(OPT.basepath_network,path,[fname ext '_portable.kmz']))
    end
    
    mkpath(fullfile(OPT.basepath_network,OPT.relativepath));
    
    fns = findAllFiles('pattern_incl', 'basepath', fullfile(OPT.basepath_local,OPT.relativepath), 'recursive', false) ;
    for ii = 1:length(fns)
        multiWaitbar('kml_copy',ii/length(fns),...
            'label',['copying files in ' fullfile([fname ext], fns{ii}) ' to the server']);
        copyfile(...
            fullfile(OPT.basepath_local  ,OPT.relativepath,fns{ii}),...
            fullfile(OPT.basepath_network,OPT.relativepath,fns{ii}))
    end
    
    copyfile(fullfile(OPT.basepath_local,path,[fname ext '_server.kml']),fullfile(OPT.basepath_network,path,[fname ext '.kml']))
    if OPT.make_kmz
        copyfile(fullfile(OPT.basepath_local,path,[fname ext '_portable.kmz']),fullfile(OPT.basepath_network,path,[fname ext '_portable.kmz']))
    end
    multiWaitbar('kml_copy',1,'label','Copying of KML files');
end

varargout = {OPT};
