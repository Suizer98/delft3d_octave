function varargout = ncgen_readFcn_surface_adf(OPT,writeFcn,fns)
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
    OPT.checkFcn_args       = {};
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

multiWaitbar('Processing file','reset','label',sprintf('Processing %s', fullfile(fns.pathname, fns.name)))

WB.tic = tic;

[X, Y, D, M] = arc_info_binary(fns.pathname,...
    'debug', 0,...
    'warning', 0); %#ok<NASGU>

WB.todo = fns.bytes*2;
WB.done = 0;

ncols = length(X);
nrows = length(Y);

[X, Y, D, result, mess] = ncgen_checkFcn_surface(X, Y, D,...
    'fname', fns.pathname,...
    'grid_cellsize', OPT.schema.grid_cellsize,...
    'grid_offset', OPT.schema.grid_offset,...
    'sort', true,...
    OPT.read.checkFcn_args{:});

if ~result
    fprintf('%s\n', mess);
    return
elseif ~isempty(mess)
    fprintf('%s\n', mess);
end
% % make sure X is sorted in ascending order
% if ~issorted(X)
%     [X, ix] = sort(X);
%     D = D(:,ix);
% end
% 
% % given that X is ascending, diff will always give a positive result
cellsizex = unique(diff(X));
% if ~isscalar(cellsizex)
%     error('cellsize in x direction is not constant')
% end
% 
% % make sure Y is sorted in ascending order
% if ~issorted(Y)
%     [Y, iy] = sort(Y);
%     D = D(iy,:);
% end
% 
% % given that Y is ascending, diff will always give a positive result
cellsizey = unique(diff(Y));
% if ~isscalar(cellsizey)
%     error('cellsize in y direction is not constant')
% end
%
cellsize = unique([cellsizex cellsizey]);
% if cellsizex == cellsizey
%     cellsize = cellsizex;
% else
%     error('cellsizes in x and y direction are different')
% end
% 
% if ~(cellsize == OPT.schema.grid_cellsize) % gridsizex==gridsizey already checked above
%     error('cellsize ~= OPT.schema.grid_cellsize')
% end

%% calculate x,y of cell CENTRES, by adding half a grid cell
%  to the cell CORNERS. From now on we only use x and y where data reside
%  i.e. the centers [xllcenter +/- cellsize,yllcorner +/- cellsize]

xllcenter = min(X);
yllcenter = min(Y);

%% write data to nc files

minx    = xllcenter;
miny    = yllcenter;
maxx    = max(X);
maxy    = max(Y);
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
y       =         yllcenter:cellsize:yllcenter + cellsize*(nrows-1);

multiWaitbar('Processing file',WB.done/WB.todo,'label',sprintf('Processing %s; writing data', fullfile(fns.pathname, fns.name)));
WB.n     = 0;
WB.steps = length(minx : mapsizex : maxx) * length(miny : mapsizey : maxy);

for x0      = minx : mapsizex : maxx % loop over tiles in x direction within data range
    for y0  = miny : mapsizey : maxy % loop over tiles in y direction within data range
        % isolate data within current tile
        ix = find(x     >=x0            ,1,'first'):find(x     <x0+mapsizex,1,'last');
        iy = find(y     >=y0            ,1,'first'):find(y     <y0+mapsizey,1,'last');
        
        z = D(iy,ix) * OPT.read.z_scalefactor;
        
        if any(~isnan(z(:)))
            data.x = x0 + (0:grid_tilesizex-1) * grid_spacingx;
            data.y = y0 + (0:grid_tilesizey-1) * grid_spacingy;
            
            data.z = nan(grid_tilesizex, grid_tilesizey);
            data.z(...
                find(data.x  >=x(ix(1)  ),1,'first'):+1:find(data.x  <=x(ix(end)  ),1,'last' ),...
                find(data.y  <=y(iy(1)),1,'last' ):+1:find(data.y  >=y(iy(end)),1,'first')) = z';
            
            data.time             = fns.date_from_filename;
            data.source_file_hash = fns.hash;
            data.filename         = fns.name;
            data.source           = double(~isnan(data.z));
            data.message          = mess;
            
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


