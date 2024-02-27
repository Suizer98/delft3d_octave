function varargout = grid_orth_getMapInfoFromDataset(dataset)
%GRID_ORTH_GETMAPINFOFROMDATASET  Extracts meta info from an OPeNDAP catalog or a local directory.
%
%   OPT = grid_orth_getmapinfofromdataset(url)
%   [urls, x_ranges, y_ranges] = grid_orth_getmapinfofromdataset(url)
%   [urls, x_ranges, y_ranges,...
%         <x_bounding_box,y_bounding_box>] = grid_orth_getmapinfofromdataset(url)
%
% where OPT has fields
% * urls
% * x_ranges
% * y_ranges

% x_bounding_box,y_bounding_box cells can be turned 
% into NaN-separated polygons with poly_join.
%
% extract meta info from an OPeNDAP catalog or a local directory.
%
% Example:
%
% [urls,x,y]=grid_orth_getMapInfoFromDataset('http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/DienstZeeland/catalog.html')
%  xx = cell2mat(cellfun(@(x) [x(1) x(2) x(2) x(1) x(1)]',x,'un',0));
%  yy = cell2mat(cellfun(@(x) [x(1) x(1) x(2) x(2) x(1)]',y,'un',0));
%  plot(xx,yy)
%  hold on
%  text(min(xx),min(yy),filename(urls),'rotation',45);
%  axis tight
%  tickmap('xy')
%  L = nc2struct('http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/landboundaries/holland_fillable.nc');
%  plot(L.x,L.y)
%
%See also: GRID_2D_ORTHOGONAL, POLY_JOIN

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

% $Id: grid_orth_getMapInfoFromDataset.m 8003 2013-02-01 16:32:23Z heijer $
% $Date: 2013-02-02 00:32:23 +0800 (Sat, 02 Feb 2013) $
% $Author: heijer $
% $Revision: 8003 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/grid_2D_orthogonal/grid_orth_getMapInfoFromDataset.m $
% $Keywords: $
  
OPT.dataset    = [];
OPT.catalognc  = []; % make sure urls and ranges come from same source: either 100% catalog.cn or 100% catalog.xml+nc_actual_range

if nargin==0
   varargout = {OPT};
   return
end
OPT.dataset    = dataset;

disp('Retrieving map info from dataset ...')

%% catalog.nc: direct dodsC url
if strcmpi(OPT.dataset(end-9:end),'catalog.nc')
    OPT.catalognc = OPT.dataset;
%% catalog.nc: check for presence of catalog.nc inside range of files listed in catalog.xml
else
    OPT.urls    = opendap_catalog(OPT.dataset,'ignoreCatalogNc',0);
    isCatalogNc = ~cellfun(@isempty, regexpi(OPT.urls, 'catalog.nc$', 'once'));
    if any(isCatalogNc)
        OPT.catalognc = OPT.urls{isCatalogNc};
        try
            urls = nc_varget(OPT.catalognc,'urlPath');
            % check whether urlPaths is not flipped (transposed)
            if find(size(urls) == sum(~isCatalogNc)) == 2
                % transpose
                urls = urls';
            end
            if size(urls,1) == sum(~isCatalogNc) &&...
                    size(urls,1) == length(unique(cellstr(urls)))
                % use urls from catalog.nc provided that the matrix of
                % urlPaths is not flipped AND the urls are not cut off
                OPT.urls = cellstr(urls);
            else
                % otherwise, ignore catalog.nc and use the remaining urls
                OPT.urls = OPT.urls(~isCatalogNc);
                OPT.catalognc  = [];
            end
        catch
            OPT.urls = OPT.urls(~isCatalogNc);
            OPT.catalognc  = [];
        end
%         OPT.urls      = []; % throw away urls from catalog as it's order is not in any sorted order: not related to catalog.nc contents
    end
end

if ~isempty(OPT.catalognc)
%     OPT.urls      = cellstr([nc_varget(OPT.catalognc,'urlPath')]);
% 
%     % temporary fix of very weird bug!!! Occasionally the char matrix or urlPaths in
%     % the catalog nc gets flipped!!!! If this happens flip it back.
%     if ~strcmp(OPT.urls{1}(end-2:end),'.nc')
%         OPT.urls = cellstr(char(OPT.urls)');
%     end
    
    if isempty(fileparts(OPT.urls{1}))
        fp=fileparts(OPT.catalognc);
        for i=1:length(OPT.urls)
            OPT.urls{i}=[fp '/' OPT.urls{i}];
        end
    else
       
%     if abspath
        if ~strcmpi(fileparts(OPT.catalognc),...
                   fileparts(OPT.urls{1}  ));
           fprintf(2,['Catalog \n'])
           fprintf(2,'%s\n',OPT.catalognc)
           fprintf(2,['is not in same directory as netCDF files \n'])
           fprintf(2,'%s\n',OPT.urls{1})
           fprintf(2,['Ignoring catalog and persueing with \n'])
           fprintf(2,'%s\n',fileparts(OPT.catalognc))
           error(mfilename)
        end
%     elseif replath
%         basepath = dir(catyalog.nc)
%         urls= [basepath urls]
%     end
    end
    
    try
        x_ranges = nc_varget(OPT.catalognc,'projectionCoverage_x'); % should be [n x 2], same as slow method.
        if size(x_ranges,2)>2
            x_ranges = x_ranges';
        end
        y_ranges = nc_varget(OPT.catalognc,'projectionCoverage_y');
        if size(y_ranges,2)>2
            y_ranges = y_ranges';
        end
    catch
        disp('there is a catalog nc, but it doens''t have the new projectionCoverage_x variable, so it cannot be used to speed up the tedious process of getting all the boundaries of the nc files')
        OPT = rmfield(OPT,'catalognc');
    end
    % put matrix into cell to avoid confusion with 1 or 3 tiles
    for i=1:size(x_ranges,1)
        OPT.x_ranges{i} = x_ranges(i,:);
        OPT.y_ranges{i} = y_ranges(i,:);
    end
else
    %% slow method for if there is no catalog nc
    wbh = waitbar(0,'Please wait ...');
    varname_x = nc_varfind(OPT.urls{1}, 'attributename','standard_name','attributevalue','projection_x_coordinate');
    varname_y = nc_varfind(OPT.urls{1}, 'attributename','standard_name','attributevalue','projection_y_coordinate');
    for i = 1:length(OPT.urls)
        waitbar(i/length(OPT.urls), wbh, 'Extracting map outlines from nc files ...')

        OPT.x_ranges{i} = nc_actual_range(OPT.urls{i}, varname_x);
        OPT.y_ranges{i} = nc_actual_range(OPT.urls{i}, varname_y);
        if ~isnumeric(OPT.x_ranges{i}) % backwards compatibility stuff ??
        OPT.x_ranges{i} = str2num(OPT.x_ranges{i}{1});   % <-- string to numerical format, otherwise 'grid_orth_getDataInPolygon.m' will not work anymore
        OPT.y_ranges{i} = str2num(OPT.y_ranges{i}{1});   % <-- string to numerical format, otherwise 'grid_orth_getDataInPolygon.m' will not work anymore
        end
        OPT.x_ranges{i} = sort(OPT.x_ranges{i});
        OPT.y_ranges{i} = sort(OPT.y_ranges{i});
    end
    close(wbh)
end

if nargout==1
   varargout = {OPT};
elseif nargout==3
   varargout = {OPT.urls,OPT.x_ranges,OPT.y_ranges};
elseif nargout==5
   [bbx,bby]=grid_orth_range2boundingbox(OPT.x_ranges,OPT.y_ranges);
   varargout = {OPT.urls,OPT.x_ranges,OPT.y_ranges,bbx,bby};
end
