function varargout = arc_info_binary(varargin)
%ARC_INFO_BINARY  Read gridded data set in Arc Binary Grid Format
%
%        D    = arc_info_binary(name)
%   [X,Y,D]   = arc_info_binary(name)
%   [X,Y,D,M] = arc_info_binary(name)
%
% reads an Arc/Info Binary Grid fileset (*.adf) in directory 'name' into matrix D,
% with optionally coordinate axes [X,Y] and complete meta-info M using the
% the reverse engineered file specifications from <a href="http://home.gdal.org/projects/aigrid/">GDAL</a>.
%
% The Arc/Info Binary Grid format is the internal working format of the
% Arc/Info Grid product. It is also usable and creatable within the spatial
% analyst component of ArcView. It is a tiled (blocked) format with run
% length compression capable of holding raster data of up to 4 byte integers
% or 4 byte floating data.
%
% This format should not be confused with the Arc/Info ASCII Grid format
% which is the interchange format for grids. Files can be converted between
% binary and ASCII format with the GRIDASCII and ASCIIGRID commands in
% Arc/Info. This format is also different than the flat binary raster output
% of the GRIDFLOAT command. The Arc/Info binary float, and ASCII formats are
% also accessable from within ArcView.
%
% This format should also not be confused with what I know as ESRI BIL
% format. This is really a standard ESRI way of creating a header file (.HDR)
% describing the data layout a binary raster file containing raster data.
%
% A grid coverage actually consists of a number of files. A grid normally
% lives in it's own directory named after the grid. For instance, the grid
% nwgrd1 lives in the directory nwgrd1, and has the following component files:
%
% -rwxr--r--   1 warmerda users          32 Jan 22 16:07 nwgrd1/dblbnd.adf
% -rwxr--r--   1 warmerda users         308 Jan 22 16:07 nwgrd1/hdr.adf
% -rwxr--r--   1 warmerda users          32 Jan 22 16:07 nwgrd1/sta.adf
% -rwxr--r--   1 warmerda users        2048 Jan 22 16:07 nwgrd1/vat.adf
% -rwxr--r--   1 warmerda users      187228 Jan 22 16:07 nwgrd1/w001001.adf
% -rwxr--r--   1 warmerda users        6132 Jan 22 16:07 nwgrd1/w001001x.adf
% ..........   . ........ .....           . ... .. ..... nwgrd1/metadata.xml
%
% Sometimes datasets will also include a prj.adf files containing the
% projection definition in the usual ESRI format. Grids also normally have
% associated tables in the info directory. This is beyond the scope of my
% discussion for now.
%
% The files have the following roles:
%
% * dblbnd.adf:   Contains the bounds (LLX, LLY, URX, URY) of the portion
%                 of utilized portion of the grid.
% * hdr.adf:      This is the header, and contains information on the tile
%                 sizes, and number of tiles in the dataset. It also
%                 contains assorted other information I have yet to identify.
% * sta.adf:      This contains raster statistics. In particular, the
%                 raster min, max, mean and standard deviation.
% * vat.adf:      This relates to the value attribute table. This is the
%                 table corresponding integer raster
%                 values with a set of attributes. I presume it is really
%                 just a pointer into info in a
%                 manner similar to the pat.adf file in a vector coverage,
%                 but I haven't investigated yet.
% * w001001.adf:  This is the file containing the actual raster data.
% * w001001x.adf: This is an index file containing pointers to each of the
%                 tiles in the w001001.adf raster file.
% * metadata.xml: contains log of process that created the file
%
% If you get out of memory errors, set the 'output_mode' option.
% This prevents matlab from allocating a lot of memory for empty tiles.
% You can for instance only query the meta-data:
% 
%    M = arc_info_binary(name,'output_mode','metadata')
%
% Or you can set it to 'struct' or 'nansparse' as in this example 
% for collecting sparse output:
%
%     [x,y,Z,D] = arc_info_binary('base','testfile','output_mode','nansparse');
%     for t = 1:D.nTiles
%         if numel(Z{t})>1
%             % calculate x y coordinates of points
%             [i,j]=ind2sub([D.HTilesPerRow D.HTilesPerColumn],t);
%             dim1 = (j -1)*D.HTileYSize+1:j*D.HTileYSize;
%             dim2 = (i -1)*D.HTileXSize+1:i*D.HTileXSize;
%
%             dim1(dim1>length(y)) = [];
%             dim2(dim2>length(x)) = [];
%
%             [X,Y] = meshgrid(x(dim2),y(dim1));
%
%             % remove empty (nan) values
%             nn = ~isnan(Z{t});
%             nn = nn(:);
%
%             if ~isequal(size(Z{t}),size(X))
%                 error('Something went terribly wrong...')
%             end
%
%             pointsInTile = [X(nn),Y(nn),Z{t}(nn)];
%         end
%     end
%
%See also: arcgrid, ARC_SHAPE_READ

%%  --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
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

% TO DO: add file names to M
% TO DO: add support for *.prj file if any
% TO DO: add option to read part of a file based on start, stride, count as nc_varget
% TO DO: read *.rrd: Reduced Resolution Dataset (RRD) files
%        http://webhelp.esri.com/arcgisdesktop/9.1/body.cfm?tocVisable=1&ID=-1&TopicName=About%20auxiliary%20%28AUX%29%20files
%        The AUX file will also store a pointer to the pyramid file (RRD file) if pyramids have been created for your raster dataset. If you use the operating system to move the raster from its directory after pyramids have been built, the software will look in the location the pointer indicates to find the RRD file. If it cannot find the RRD file there, it will look in the directory into which you have moved the dataset. It is recommended that you copy or move datasets using ArcCatalog or ArcInfo Workstation (if it is installed) to make sure you copy all related files.
% TO DO: read /info directory
% TO DO: read *.aux files
%        http://support.esri.com/index.cfm?fa=knowledgebase.techarticles.articleShow&d=32344
%        Question
%        Why does my raster dataset no longer have an AUX file in ArcGIS 9.2?
%
%        Answer
%        At the release of ArcGIS 9.2, two different libraries are used to read raster formats: RDO and GDAL.
%        With 9.2, all GDAL format rasters have an AUX.XML file created, that stores projection, statistics, and other additional information. RDO format rasters always use the AUX file but are also capable of using the AUX.XML format as well.
%        Since all versions prior to 9.2 just use the AUX file to store this information, there is no capability for these versions to read the AUX.XML; it is not backwards compatible. This is a known limit for GDAL rasters.
%        When trying to define a projection for GDAL rasters they will display properly in 9.2 but not in 9.1/9.0/8.X. RDO rasters should behave the same through all versions.
%        In short, GDAL rasters will have AUX.XML in 9.2. RDO rasters will always have AUX in all versions.
%        Prior to 9.2 all rasters were read using RDO.
%
%        http://webhelp.esri.com/arcgisdesktop/9.1/body.cfm?tocVisable=1&ID=-1&TopicName=About%20auxiliary%20%28AUX%29%20files
%        The information stored in an AUX file is only accessible using a product from ESRI, ERDAS, or a third-party product derived from the RDO/ERaster library.

%% This tool is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
%  OpenEarthTools is an online collaboration to share and manage data and
%  programming tools in an open source, version controlled environment.
%  Sign up to recieve regular updates of this function, and to contribute
%  your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
%  $Id: arc_info_binary.m 10938 2014-07-07 20:23:54Z heijer $
%  $Date: 2014-07-08 04:23:54 +0800 (Tue, 08 Jul 2014) $
%  $Author: heijer $
%  $Revision: 10938 $
%  $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/gis/arc_info_binary.m $
%  $Keywords: $

%% keywords

OPT.base        = [];
OPT.debug       = 0; % display some info (2 displays every integer run)
OPT.warning     = 1;
OPT.plot        = 0;
OPT.export      = 1;
OPT.vc          = 'http://opendap.deltares.nl:8080/thredds/dodsC/opendap/noaa/gshhs/gshhs_i.nc'; % vector coastline
OPT.long_name   = [];    % TO DO: get this from info directory
OPT.units       = '';    % TO DO: get this from info directory
OPT.epsg        = 32631; % TO DO: get this from *.prj file, if any
OPT.clim        = [];
OPT.data        = 1; % 0 means to get only meta-data and pointers
OPT.output_mode = 'normal'; % can be 'normal, 'nansparse' or 'struct'. if set to false, this greatly reduces the memory requirements of this routine.
OPT.waitbar     = true; % adds a waitbar
OPT.nodatavalue = -realmax('single'); %-3.4028234663852885e+038; % value in arc gis file

%  realmax('single'); = 3.402823e+038
%  realmin('single'); = 1.175494e-038

nextarg = 1;
if nargin==0
    varargout = {OPT};
    return
end

if odd(nargin)
    if ischar(varargin{1})
        OPT.base = varargin{1};
        nextarg = 2;
    else
        % this exception is when varargin{1} is OPT
    end
end

OPT = setproperty(OPT,varargin{nextarg:end});

OPT.base = [OPT.base,filesep];
if isempty(OPT.long_name)
    OPT.long_name   = last_subdir(path2os(OPT.base)); % remove any // or \\
end

if OPT.warning
    disp('warning: arc_info_binary is a development in progress: integer data not yet fully implemented.')
end

%% initialize waitbar
if OPT.waitbar
    multiWaitbar('arc_info_binary','reset')
    multiWaitbar('arc_info_binary',0,'color',[.8 .6 0],'label',sprintf('Reading %s: Initializing...',OPT.base))
end
%% dblbnd.adf: Contains the bounds (LLX, LLY, URX, URY) of the portion of
%  utilized portion of the grid.

fid           = fopen(fullfile(OPT.base, 'dblbnd.adf'), 'r', 'ieee-be'); % MSB > 'ieee-be'
D.D_LLX       =      fread(fid,  1,'double');  % Lower left  X (easting)  of the grid. Generally -0.5 for an ungeoreferenced grid.
D.D_LLY       =      fread(fid,  1,'double');  % Lower left  Y (northing) of the grid. Generally -0.5 for an ungeoreferenced grid.
D.D_URX       =      fread(fid,  1,'double');  % Upper right X (northing) of the grid. Generally #Pixels-0.5 for an ungeoreferenced grid.
D.D_URY       =      fread(fid,  1,'double');  % Upper right Y (northing) of the grid. Generally #Lines-0.5  for an ungeoreferenced grid.
fclose(fid);

%% hdr.adf: This is the header, and contains information on the tile sizes,
%  and number of tiles in the dataset. It also contains assorted other
%  information I have yet to identify.

fid           = fopen(fullfile(OPT.base, 'hdr.adf'), 'r', 'ieee-be');% MSB > 'ieee-be'
D.HMagic      = char(fread(fid,  8,'uchar' )');% Magic Number - always "GRID1.2\0"
dummy         =      fread(fid,  8,'uint8' );  % assorted data, I don't know the purpose.
D.HCellType   =      fread(fid,  1,'int32' );  % 1 = int cover, 2 = float cover.
dummy         =      fread(fid,236,'uint8' );  % assorted data, I don't know the purpose.
D.HPixelSizeX =      fread(fid,  1,'double');  % Width of a pixel in georeferenced coordinates. Generally 1.0 for ungeoreferenced rasters.
D.HPixelSizeY =      fread(fid,  1,'double');  % Height of a pixel in georeferenced coordinates. Generally 1.0 for ungeoreferenced rasters.
D.XRef        =      fread(fid,  1,'double');  % dfLLX-(nBlocksPerRow*nBlockXSize*dfCellSizeX)/2.0
D.YRef        =      fread(fid,  1,'double');  % dfURY-(3*nBlocksPerColumn*nBlockYSize*dfCellSizeY)/2.0

D.HTilesPerRow    =  fread(fid,  1,'int32' );  % The width of the file in tiles (often 8 for files of less than 2K in width).
D.HTilesPerColumn =  fread(fid,  1,'int32' );  % The height of the file in tiles. Note this may be much more than the number of tiles actually represented in the index file.
D.HTileXSize      =  fread(fid,  1,'int32' );  % The width of a file in pixels. Normally 256.
dummy             =  fread(fid,  1,'int32' );  % Unknown, usually 1.
D.HTileYSize      =  fread(fid,  1,'int32' );  % Height of a tile in pixels, usually 4.

fclose(fid);

%% sta.adf: This contains raster statistics. In particular, the raster min,
%  max, mean and standard deviation.

fid           = fopen(fullfile(OPT.base, 'sta.adf'), 'r', 'ieee-be'); % MSB > 'ieee-be'
D.SMin        =      fread(fid,  1,'double');
D.SMax        =      fread(fid,  1,'double');
D.SMean       =      fread(fid,  1,'double');
D.SStdDev     =      fread(fid,  1,'double');
fclose(fid);

%% Raster Size
%
% The size of a the grid isn't as easy to deduce as one might expect. The
% hdr.adf file contains the HTilesPerRow, HTilesPerColumn, HTileXSize, and
% HTileYSize fields which imply a particular raster space. However, it seems
% that this is created much larger than necessary to hold the users raster
% data. I have created 3x1 rasters which resulted in the standard 8x512
% tiles of 256x4 pixels each.
%
% It seems that the user portion of the raster has to be computed based on
% the georeferenced bounds in the dblbnd.adf file (assumed to be anchored
% at the top left of the total raster space), and the HPixelSizeX, and
% HPixelSizeY fields from hdr.adf.
%
% #Pixels = (D_URX - D_LRX) / HPixelSizeX (here called nRows)
%
% #Lines  = (D_URY - D_LRY) / HPixelSizeY (here called ncolumns)
%
% Based on this number of pixels and lines, it is possible to establish what
% portion out of the top left of the raster is really of interest. All
% regions outside this appear to empty tiles, or filled with no data markers.

D.nColumns     = (D.D_URX - D.D_LLX) / D.HPixelSizeX; % error in GDAL txt: LRX should be LLX
D.nColumnsTile = D.HTileXSize  * D.HTilesPerRow;

D.nRows        = (D.D_URY - D.D_LLY) / D.HPixelSizeY; % error in GDAL txt: LRY should be LLY
D.nRowsTile    = D.HTileYSize  * D.HTilesPerColumn;

D.X = D.D_LLX + (2*(1:D.nColumns)-1)/2*D.HPixelSizeX;
D.Y = D.D_URY - (2*(1:D.nRows   )-1)/2*D.HPixelSizeX;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                    :
%                    D_URX
%                    :
%          +---------+..D_URY..
%          |         |               ^
%          |         |               :
%          |         |               :
%          |         |   HTileYSize  * HTilesPerColumn  > (preallocated too much)
%          |         |   [#]         : [#]
%          |         |               :
%          |         |   HPixelSizeY * nRows            =  D_URY - D_LLY
%          |         |   [m]         : [#]
%          |         |               :
%          |         |               v
% ..D_LLY..+---------+
%          :
%          D_LLX
%          :
%          <.........>
%
%  HTileXSize  * HTilesPerRow > (preallocated too much)
%  [#]           [#]
%  HPixelSizeX * nColumns     =  D_URX - D_LLX
%  [m]           [#]
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% w001001x.adf: This is an index file containing pointers to each of the
%  tiles in the w001001.adf raster file.

fid           = fopen(fullfile(OPT.base, 'w001001x.adf'), 'r', 'ieee-be'); % MSB > 'ieee-be'
D.RMagic      =      fread(fid,  8,'uint8' );   % Magic Number (always hex 00 00 27 0A FF FF FC 14 or 00 00 27 0A FF FF FB F8 in some (all?) Arc8 products).  (dec2hex(D.RMagic) is indeed 00 00 27 0A FF FF FC 14)
dummy         =      fread(fid, 16,'uint8' );   % zero fill
D.RFileSize   =      fread(fid,  1,'uint32')*2; % Size of whole file in shorts (multiply by two to get file size in bytes). (ok with 'ieee-be')
dummy         =      fread(fid, 72,'uint8' );   % zero fill
t             = 0;

% process the adf file in chunks of 1e5 integers
while 1
    rec       =      fread(fid,  1e5,'uint32');
    rec       =      reshape(rec,2,[]);
    
    D.TileOffset(t+1:t+size(rec,2)) = rec(1,:); % Offset to tile t in w001001.adf measured in two byte shorts.
    D.TileSize  (t+1:t+size(rec,2)) = rec(2,:); % Size of tile t in 2 byte shorts.
    t         =      t + size(rec,2);
    if size(rec,2)<1e5/2
        break
    end
end
D.nTiles      = t;

fclose(fid);

%% w001001.adf: This is the file containing the actual raster data.

fid            = fopen(fullfile(OPT.base, 'w001001.adf'),'r','ieee-be'); % MSB > 'ieee-be'
D.RMagic       =      fread(fid,  8,'uint8' );   % Magic Number (always hex 00 00 27 0A FF FF FC 14 or 00 00 27 0A FF FF FB F8 in some (all?) Arc8 products).  (dec2hex(D.RMagic) is indeed 00 00 27 0A FF FF FC 14)
dummy          =      fread(fid, 16,'uint8' );   % zero fill
D.RFileSize    =      fread(fid,  1,'uint32')*2; % Size of whole file in shorts (multiply by two to get file size in bytes). (ok with 'ieee-be')
dummy          =      fread(fid, 72,'uint8' );   % zero fill
D.RTileSize    = 0*D.TileSize;
if D.HCellType==1
    D.RTileType    = 0*D.TileSize;
    D.RMinSize     = 0*D.TileSize;
    D.RMin         = 0*D.TileSize;
end
%if OPT.debug
%   D
%end

if (~OPT.data)

   switch OPT.output_mode
       case 'metadata'
           Data = D;
   end % switch OPT.output_mode

else

    %% pre allocate  output data
    if OPT.waitbar
        multiWaitbar('arc_info_binary',0,'label',sprintf('Reading %s: Preallocating Output...',OPT.base))
    end
    
    max_coverage = sum(D.TileSize/2)/(D.nRowsTile*D.nColumnsTile);
    
    if strcmpi(OPT.output_mode,'auto')
        if max_coverage<.25 || ...
                (D.nRowsTile*D.nColumnsTile) > 5e6
            %Put data in nansparse double matrix
            OPT.output_mode = 'nansparse';
        else
            %Put data in normal double matrix
            OPT.output_mode = 'normal';
        end
    end
    
    switch OPT.output_mode
        case 'normal'
            Data    = NaN([D.nRowsTile D.nColumnsTile]); % reduce to [D.nRows D.nColumns] after reading all tiles
        case {'struct','nansparse'}
            % even if the output mode is nansparse, the internal function uses
            % a structure. This structure is later converted to a nansparse,
            % because incremental writing of coordinates to a nansparse uses
            % progressivly more overhead for large arrays
            Data(1:D.HTilesPerRow,1:D.HTilesPerColumn) =  {NaN};
    end
    
    
    
    
    %% RTileType/RTileData
    %
    % Each tile contains HBlockXSize * HBlockYSize pixels of data:%
    %
    % * D.HCellType==1: For all integer tiles it is necessary to
    %                   interpret the RTileType to establish the
    %                   details of the tile organization:
    % * D.HCellType==2: For floating point blocks The data is just the
    %                   tile size (in two bytes) followed by the pixel
    %                   data as 4 byte MSB order IEEE floating point words.
    
    n = D.HTileXSize*D.HTileYSize; % tilesize in # pixels
    if OPT.waitbar
        timer = tic;
    end
    
    for t=1:D.nTiles
        if OPT.waitbar
            if toc(timer)>0.4
                multiWaitbar('arc_info_binary',t/D.nTiles,'label',sprintf('Reading %s: Processing data...',OPT.base))
                timer = tic;
            end
        end
        
        fseek(fid,D.TileOffset(t)*2,'bof'   ); % TileOffset is in 2 byte short, fseeks wants it in bytes
        D.RTileSize(t) = fread(fid,                1,'uint16'); % RTileSize is defined in 2 byte words, which is exactly the uint16 we have here
        
        [i,j]=ind2sub_q([D.HTilesPerRow D.HTilesPerColumn],t);
        dim1 = (j -1)*D.HTileYSize+1:j*D.HTileYSize;
        dim2 = (i -1)*D.HTileXSize+1:i*D.HTileXSize;
        
        if D.HCellType==1
            D.RTileType(t)=  fread(fid,             1,'uint8' ); % 1 byte
            D.RMinSize(t) =  fread(fid,             1,'uint8' ); % 1 byte
            if (D.RTileSize(t)==0)
                continue % D.RTileType(t)==hex2dec('00')
            end
            fmt = ['int',num2str(8*D.RMinSize(t))];              % (RMinSize bytes), 1 byte = int8
            if ~D.RMinSize(t)==0
                D.RMin(t)     =  fread(fid,             1,fmt); % int160 not possible, nor int416
            end
            
            if OPT.debug
                disp([pad(dec2hex(D.RTileType(t)),' ',-5),': ',...  % -5 = same length as float
                    num2str([t D.nTiles i j dim1([1 end]) dim2([1 end]) D.RTileSize(t)],'%d ')]);
            end
            
            %% RTileType = 0x00 (constant block)
            %  All pixels take the value of the RMin. Data is ignored. It appears
            %  there is sometimes a bit of meaningless data (up to four bytes) in the block.
            switch dec2hex(D.RTileType(t),2)
                case '00'
                    
                    %RTileData= repmat(D.RMin(t)     ,[D.HTileXSize D.HTileYSize]);
                    RTileData= nan([D.HTileXSize D.HTileYSize]);
                    
                    %% RTileType = 0x01 (raw 1bit data)
                    %  One full tile worth of data pixel values follows the RMin field, with 1bit per pixel.
                    
                case '01'
                    
                    RTileData      = fread(fid,n,'ubit1' );
                    RTileData      = reshape(RTileData,[D.HTileXSize D.HTileYSize]) + D.RMin(t);
                    
                    %% RTileType = 0x04 (raw 4bit data)
                    %  One full tiles worth of data pixel values (one byte per pixel) follows the RMin field.
                    %  ? The high order four bits of a byte comes before the low order four bits. ?
                    
                case '04'
                    
                    RTileData      = fread(fid,n,'ubit4' );
                    RTileData      = reshape(RTileData,[D.HTileXSize D.HTileYSize]) + D.RMin(t);
                    
                    %% RTileType = 0x08 (raw byte data)
                    %  One full tiles worth of data pixel values (one byte per pixel) follows the RMin field.
                    
                case '08'
                    
                    RTileData      = fread(fid,n,'uint8' );
                    RTileData      = reshape(RTileData,[D.HTileXSize D.HTileYSize]) + D.RMin(t);
                    
                    %% RTileType = 0x10 (raw byte data)
                    %  One full tiles worth of data pixel values (one byte per pixel) follows the RMin field.
                    
                case '10'
                    
                    RTileData      = fread(fid,n,'uint16');
                    RTileData      = reshape(RTileData,[D.HTileXSize D.HTileYSize]) + D.RMin(t);
                    
                    %% RTileType = 0x20 (raw byte data)
                    %  One full tiles worth of data pixel values follows the RMin field, with 32 bits per pixel (MSB).
                    
                case '20'
                    
                    RTileData      = fread(fid,n,'uint32');
                    RTileData      = reshape(RTileData,[D.HTileXSize D.HTileYSize]) + D.RMin(t);
                    
                    %% RTileType = 0xCF/D7 (literal runs/nodata runs)
                    %  The data is organized in a series of runs. Each run starts with a marker which should be interpreted as:
                    %    * Marker < 128: The marker is followed by Marker pixels of literal data with two MSB/one byte per pixel.
                    %    * Marker > 127: The marker indicates that 256-Marker pixels of no data pixels should be
                    %                    put into the output stream. No data (other than the next marker) follows this marker.
                    
                case {'CF','D7'}
                    switch dec2hex(D.RTileType(t),2)
                        case 'CF'
                            fmt = 'uint16';
                        case 'D7'
                            fmt = 'uint8';
                    end
                    
                    run        = 0;
                    nread      = 0;
                    RTileData  = nan([D.HTileXSize D.HTileYSize]);
                    
                    while nread < n
                        
                        marker     = fread(fid,     1,'uint8' );
                        
                        if isempty(marker)
                            bytes_read = D.RTileSize(t)*2;
                        else
                            if marker     < 128
                                count      = marker;
                                stream     = fread(fid,count,fmt);
                            elseif marker > 127
                                count      = 256 - marker;
                                stream     = nan(count,1);
                            end
                            
                            run    = run + 1;
                            nread  = nread + count;
                            RTileData(nread-count+1:nread) = stream;
                            
                            if OPT.debug > 1
                                disp(['    ',num2str([run count nread n],'%0.4d ')])
                            end
                            
                        end
                        
                    end
                    
                    RTileData = reshape(RTileData,[D.HTileXSize D.HTileYSize]) + D.RMin(t);
                    
                    %% RTileType = 0xDF (literal runs/nodata runs)
                    %  The data is organized in a series of runs. Each run starts with a marker which should be interpreted as:
                    %    * Marker < 128: The marker is followed by Marker pixels of literal data with one byte per pixel.
                    %    * Marker > 127: The marker indicates that 256-Marker pixels of no data pixels should be put
                    %      into the output stream. No data (other than the next marker) follows this marker.
                    %  This is similar to 0xD7, except that the data size is zero bytes instead of 1, so only RMin
                    %  values are inserted into the output stream.
                    
                case 'DF'
                    
                    run        = 0;
                    nread      = 0;
                    RTileData  = nan([D.HTileXSize D.HTileYSize]);
                    
                    while nread < n
                        
                        marker     = fread(fid,     1,'uint8' );
                        if marker     < 128
                            stream     = zeros(marker,1);
                            count      = marker;
                        elseif marker > 127
                            count      = 256 - marker;
                            stream     = nan(count,1);
                        end
                        
                        run    = run + 1;
                        nread  = nread + count;
                        RTileData(nread-count+1:nread) = stream;
                        
                        if OPT.debug > 1
                            disp(['    ',num2str([run count nread n],'%0.4d ')])
                        end
                        
                    end
                    
                    %if length(RTileData) > n
                    %   disp(['n_read n_required last_marker ( > 127 is NaNs):',num2str([length(RTileData ) n marker])])
                    %end
                    
                    %% chop data exceeding tilesize ??
                    
                    RTileData = reshape(RTileData,[D.HTileXSize D.HTileYSize]) + D.RMin(t);
                    
                    %% RTileType = F0 (run length encoded 16bit)
                    %  The data is organized in a series of runs. Each run starts with a
                    %  marker which should be interpreted as a count. The two bytes following
                    %  the count should be interpreted as an MSB Int16 value. They indicate
                    %  that count pixels of value should be inserted into the output stream.
                    
                case {'E0','F0','FC','F8'}
                    switch dec2hex(D.RTileType(t),2)
                        case 'E0'
                            fmt = 'uint32';
                        case 'F0'
                            fmt = 'uint16';
                        case {'FC','F8'}
                            fmt = 'uint8';
                    end
                    
                    
                    run        = 0;
                    nread      = 0;
                    RTileData  = nan([D.HTileXSize D.HTileYSize]);
                    
                    while nread < n
                        
                        count  = fread(fid,     1,'uint8');
                        value  = fread(fid,     1,fmt);
                        stream = repmat(value,[1 count]);
                        
                        run    = run + 1;
                        nread  = nread + count;
                        RTileData(nread-count+1:nread) = stream;
                        
                        if OPT.debug > 1
                            disp(['    ',num2str([run count nread n],'%0.4d ')])
                        end
                        
                    end
                    
                    RTileData = reshape(RTileData,[D.HTileXSize D.HTileYSize]) + D.RMin(t);
                    
                    %% RTileType = 0x??
                    
                otherwise
                    
                    RTileData= Inf([D.HTileXSize D.HTileYSize]);
                    fprintf(2,['error: arc_info_binary: integer data type ''',dec2hex(D.RTileType(t)),''' not yet implemented, inserted Inf.\n']);
                    
            end
            switch OPT.output_mode
                case 'normal'
                    Data(dim1,dim2)             = RTileData';
                case {'struct','nansparse'}
                    if all(all(isnan(RTileData)))
                        Data{i,j}               = NaN;
                    else
                        Data{i,j}               = RTileData';
                    end
            end
        else
            
            if OPT.debug
                disp(['float: ',num2str([t D.nTiles i j dim1([1 end]) dim2([1 end]) D.RTileSize(t)],'%d ')]);
            end
            
            if ~(D.TileSize(t)==0)
                RTileData      = fread(fid,D.TileSize(t)/2,'float' ); % TileSize in 2 byte words / 2 =  TileSize in 4 byte words
                RTileData      = reshape(RTileData,[D.HTileXSize D.HTileYSize]);
                RTileData(RTileData==OPT.nodatavalue) = nan;
            else
                RTileData      = nan([D.HTileXSize D.HTileYSize]);
            end
            
            switch OPT.output_mode
                case 'normal'
                    Data(dim1,dim2)             = RTileData';
                case {'struct','nansparse'}
                    if all(all(isnan(RTileData)))
                        Data{i,j}               = NaN;
                    else
                        Data{i,j}               = RTileData';
                    end
            end
        end
        
    end
    
    fclose(fid);
    
    %% remove redundant matrix space occupied by surplus of tiles
    
    switch OPT.output_mode
        case 'normal'
            Data = Data(1:D.nRows,1:D.nColumns);
        case 'nansparse'
            nValues = 0;
            for t = 1:D.nTiles
                if numel(Data{t})>1
                    nValues = nValues + sum(sum(~isnan(Data{t})));
                end
            end
            % preallocate xyz
            xyz = nan(nValues,3);
            
            nValues = 0;
            for t = 1:D.nTiles
                if numel(Data{t})>1
                    % calculate x y coordinates of points
                    [i,j] = ind2sub([D.HTilesPerRow D.HTilesPerColumn],t);
                    dim1  = (j - 1)*D.HTileYSize+1:j*D.HTileYSize;
                    dim2  = (i - 1)*D.HTileXSize+1:i*D.HTileXSize;
                    [X,Y] = meshgrid(dim2,dim1);
                    
                    % remove empty (nan) values
                    nn = ~isnan(Data{t});
                    
                    xyz(nValues+1:nValues+sum(sum(nn)),:) = [X(nn),Y(nn),Data{t}(nn)];
                    nValues = nValues+sum(sum(nn));
                end
            end
            Data = nansparse(xyz(:,1),xyz(:,2),xyz(:,3),D.nColumns,D.nRows)';
        case 'metadata'
            Data = D;
        case 'struct'
            if D.nRows<D.nRowsTile
                nn = floor(D.nRows/D.HTileYSize);
                for ii = 1:size(Data,1)
                    if numel(Data{ii,nn+1})>1
                        Data{ii,nn+1} = Data{ii,nn+1}(1:D.nRows - (D.HTileYSize*(nn)),:);
                    end
                end
            end
            if D.nColumns<D.nColumnsTile
                nn = floor(D.nColumns/D.HTileXSize);
                for ii = 1:size(Data,2)
                    if numel(Data{nn+1,ii})>1
                        Data{nn+1,ii} = Data{nn+1,ii}(:,1:D.nColumns - (D.HTileXSize*(nn)));
                    end
                end
            end
    end % switch OPT.output_mode
    
    if OPT.waitbar
        multiWaitbar('arc_info_binary',t/D.nTiles,'label',sprintf('Reading %s: completed, preparing output',OPT.base))
    end
    %% plot
    
    if OPT.plot
        figure
        pcolorcorcen(D.X,D.Y,full(Data));
        axis equal;
        caxis([D.SMin D.SMax]);
        colorbarwithtitle([mktex(OPT.long_name),' [',OPT.units,']'])
        grid on
        title(['min max: ',num2str([D.SMin D.SMax])])
        tickmap('xy')
        hold on
        plot(D.X                       ,repmat(D.Y(  1),size(D.X)),'color',[.5 .5 .5],'linewidth',2);
        plot(D.X                       ,repmat(D.Y(end),size(D.X)),'color',[.5 .5 .5],'linewidth',2);
        plot(repmat(D.X(  1),size(D.Y)),D.Y                       ,'color',[.5 .5 .5],'linewidth',2);
        plot(repmat(D.X(end),size(D.Y)),D.Y                       ,'color',[.5 .5 .5],'linewidth',2);
        axis tight
        if ~isempty(OPT.vc)
            L.lon = nc_varget(OPT.vc,'lon');
            L.lat = nc_varget(OPT.vc,'lat');
            [L.x,L.y] = convertcoordinates(L.lon,L.lat,'CS1.code',4326,'CS2.code',OPT.epsg);
            plot(L.x,L.y,'k');
        end
        %%
        if OPT.export
            if ~isempty(OPT.clim)
                print2a4overwrite(fullfile(OPT.base, 'w001001.png'))
                caxis([OPT.clim]);
                colorbarwithtitle([mktex(OPT.long_name),' [',OPT.units,']']);
                print2a4overwrite(fullfile(OPT.base, ['w001001_',num2str(OPT.clim(1)),'_',num2str(OPT.clim(2)),'.png']))
            end
        end
    end

end % OPT.data

%% metadata

if  exist(fullfile(OPT.base, 'metadata.xml'), 'file')
    % read metadata using urlread (not clear whether urlread is needed
    % here)
    D.metadata = urlread(['file:///', fullfile(abspath(OPT.base),'metadata.xml')]);
else
    if OPT.warning
        fprintf('"%s" missing\n', fullfile(OPT.base, 'metadata.xml'));
    end
    D.metadata = [];
end

%% output

if nargout==1
    varargout = {Data};
elseif nargout==3
    varargout = {D.X,D.Y,Data};
elseif nargout==4
    varargout = {D.X,D.Y,Data,D};
end

if OPT.waitbar
    multiWaitbar('arc_info_binary','close')
end

function [i,j] = ind2sub_q(siz,ind)
% simplified ind2sub with no overhead
j = ceil(ind/siz(1));
i = ind - (j-1).*siz(1);
%% EOF
