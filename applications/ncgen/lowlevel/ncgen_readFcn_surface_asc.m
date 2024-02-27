function varargout = ncgen_readFcn_surface_asc(OPT,writeFcn,fns)
% OPT is a struct with fields
%
% fns is a struct with the following fields:
%     name
%     date
%     bytes
%     isdir
%     datenum
%     pathname
%     date_from_filename
%     hash
%
% ncschema is schema created by either ncinfo or nccreateSchema

if nargin==0 || isempty(OPT)
    % return OPT structure with options specific to this function
    OPT.block_size          = 1e6;
    OPT.z_scalefactor       = 1; %scale factor of z values to metres altitude
    OPT.xref_cell = 'xllcorner';
    OPT.yref_cell = 'yllcorner';
    varargout = {OPT};
    return
else
    if datenum(version('-date'), 'mmmm dd, yyyy') < 734729
        % version 2011a and older
        error(nargchk(3,3,nargin)) %#ok<NCHKN>
    else
        % version 2011b and newer
        narginchk(3,3)
    end
end

multiWaitbar('Processing file','reset','label',sprintf('Processing %s', fns.name))

fid = fopen([fns.pathname fns.name]);
WB.todo = fns.bytes*2;
WB.done = 0;
WB.tic  = tic;

s = textscan(fid,'%s %f',6);

ncols        = s{2}(strcmpi(s{1},'ncols'       ));
nrows        = s{2}(strcmpi(s{1},'nrows'       ));
cellsize     = s{2}(strcmpi(s{1},'cellsize'    ));
xll    = s{2}(strcmpi(s{1},OPT.read.xref_cell ));
if strcmp(OPT.read.xref_cell, 'xllcorner')
    % xllcorner given
    xllcorner = xll;
    % derive xllcenter
    xllcenter = xll + cellsize/2;
    if ~(mod(xllcorner,cellsize)==0)
        % error(['xllcorner has offset: ',num2str(mod(xllcorner,cellsize))])
        returnmessage(2,'in %s, WARNING: xllcorner has offset: %s. Values have been assigned to centers. \n',...
                [fns.pathname fns.name],num2str(mod(xllcorner,cellsize)))
        xllcorner = xll - cellsize/2;
        xllcenter = xll;
    end
elseif strcmp(OPT.read.xref_cell, 'xllcenter')
    % xllcenter given
    xllcenter = xll;
    % derive xllcorner
    xllcorner = xll - cellsize/2;
else
    error('xref_cell value "%s" not recognized', OPT.read.xref_cell)
end
yll    = s{2}(strcmpi(s{1},OPT.read.yref_cell ));
if strcmp(OPT.read.yref_cell, 'yllcorner')
    % yllcorner given
    yllcorner = yll;
    % derive yllcenter
    yllcenter = yll + cellsize/2;
    if ~(mod(yllcorner,cellsize)==0)
        % error(['yllcorner has offset: ',num2str(mod(yllcorner,cellsize))])
        returnmessage(2,'in %s, WARNING: yllcorner has offset: %s. Values have been assigned to centers.  \n',...
                [fns.pathname fns.name],num2str(mod(yllcorner,cellsize)))
        yllcorner = yll - cellsize/2;
        yllcenter = yll;
    end
elseif strcmp(OPT.read.yref_cell, 'yllcenter')
    % yllcenter given
    yllcenter = yll;
    % derive yllcorner
    yllcorner = yll - cellsize/2;
else
    error('yref_cell value "%s" not recognized', OPT.read.yref_cell)
end
nodata_value = s{2}(strcmpi(s{1},'nodata_value'));
if isempty(ncols)||isempty(nrows)||isempty(xllcorner)||isempty(yllcorner)||isempty(cellsize)||isempty(nodata_value)
    error('reading asc file')
end

%% read file chunkwise
WB.tic = tic;
small_number  = 1e-16;

kk = 0;
while ~feof(fid)
    % read the file
    kk       = kk+1;
    D{kk}    = textscan(fid,'%f64',floor(OPT.read.block_size/ncols)*ncols,'CollectOutput',true); %#ok<AGROW>
    D{kk}{1} = reshape(D{kk}{1},ncols,[])'; %#ok<AGROW>
    if all(abs(D{kk}{1}(:) - nodata_value) < small_number)
        D{kk}{1} = nan; %#ok<AGROW>
    else
        D{kk}{1}(abs(D{kk}{1}-nodata_value) < small_number) = nan; %#ok<AGROW>
    end
    if toc(WB.tic) > 0.2
        multiWaitbar('Processing file',ftell(fid)/fns.bytes/2,'label',sprintf('Processing %s; reading data', fns.name));
        WB.tic = tic;
    end
end
fclose(fid);
if ~(cellsize == OPT.schema.grid_cellsize) % gridsizey==gridsizey already checked above
    error('cellsize ~= OPT.schema.grid_cellsize')
end

%% write data to nc files

minx    = xllcenter;
miny    = yllcenter;
maxx    = xllcenter + cellsize.*(ncols-1);
maxy    = yllcenter + cellsize.*(nrows-1);
% grid_spacing, grid_tilesize and grid_offset can be either scalars or
% 2-element vectors indicating equal respectively seperately specified x
% and y direction values.
[grid_spacingx,  grid_spacingy ] = deal(OPT.schema.grid_cellsize(1), OPT.schema.grid_cellsize(end));
[grid_tilesizex, grid_tilesizey] = deal(OPT.schema.grid_tilesize(1), OPT.schema.grid_tilesize(end));
mapsizex = grid_spacingx * grid_tilesizex;
mapsizey = grid_spacingy * grid_tilesizey;
minx    = floor(minx/mapsizex)*mapsizex + OPT.schema.grid_offset(1);
miny    = floor(miny/mapsizey)*mapsizey + OPT.schema.grid_offset(end);

x       =         xllcenter:cellsize:xllcenter + cellsize*(ncols-1);
y       = flipud((yllcenter:cellsize:yllcenter + cellsize*(nrows-1))');
y(:,2)  = ceil((1:size(y,1))'./ floor(OPT.read.block_size/ncols));
y(:,3)  = mod ((0:size(y,1)-1)',floor(OPT.read.block_size/ncols))+1;

multiWaitbar('Processing file',WB.done/WB.todo,'label',sprintf('Processing %s; writing data', fns.name));
WB.n     = 0;
WB.steps = length(minx : mapsizex : maxx) * length(miny : mapsizey : maxy);

for x0      = minx : mapsizex : maxx % loop over tiles in x direction within data range
    for y0  = miny : mapsizey : maxy % loop over tiles in y direction within data range
        % isolate data within current tile
        ix = find(x     >=x0            ,1,'first'):find(x     < x0+mapsizex,1,'last');
        iy = find(y(:,1)< y0+mapsizey   ,1,'first'):find(y(:,1)>=y0         ,1,'last');
        
        z = nan(length(iy),length(ix));
        for iD = unique(y(iy,2))'
            if ~(numel(D{iD}{1})==1&&isnan(D{iD}{1}(1))) % shouldn't this be something like any(~isnan(D{iD}{1}(:))) ??
                z(y(iy,2)==iD,:) = D{iD}{1}(y(iy(y(iy,2)==iD),3),ix)*OPT.read.z_scalefactor;
            end
        end
        
        if any(~isnan(z(:)))
            data.x = x0 + (0:grid_tilesizex-1) * grid_spacingx;
            data.y = y0 + (0:grid_tilesizey-1) * grid_spacingy;
            
            data.z = nan(grid_tilesizex, grid_tilesizey);
            data.z(...
                find(data.x  >=x(ix(1)  ),1,'first'):+1:find(data.x  <=x(ix(end)  ),1,'last' ),...
                find(data.y  <=y(iy(1),1),1,'last' ):-1:find(data.y  >=y(iy(end),1),1,'first')) = z';
            
            data.time              = fns.date_from_filename;
            data.source_file_hash  = fns.hash;
            data.filename          = fns.name;
            data.source            = double(~isnan(data.z));
            
            writeFcn(OPT,data)
        end
        
        WB.n = WB.n+1;
        if toc(WB.tic) > 0.2
            multiWaitbar('Processing file',0.5+WB.n/WB.steps/2);
            WB.tic = tic;
        end
    end
end
multiWaitbar('Processing file',1);


