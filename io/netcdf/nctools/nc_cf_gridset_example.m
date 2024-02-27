%function D = nc_cf_gridset_example(varargin)
%NC_CF_GRIDSET_TUTORIAL  how to acces a set of netCDF tiles
%
%  D = nc_cf_gridset_example(<keyword,value>)
%
% returns a struct D where every D(i) is a datasets
% with data in the box defined by keywords x and y.
%
% See also: snctools, opendap_catalog, grid_2D_orthogonal

%catalog_url = 'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/kustlidar/catalog.html';
catalog_url = '.'; % keep out 

%% get list of netCDF grid files from which to obtain data

nc_files  = opendap_catalog(catalog_url);

%% define bounding box of area where to get data

OPT.x       = [ 90010 109990 109990  90010  90010];
OPT.y       = [500010 500010 524990 524990 500010];
OPT.stride  = 5;
OPT.t       = datenum([2007 2015],1,1); % TO DO CHECK FOR THIS !!
OPT.epsg    = 28992; % TO DO CHECK FOR THIS !!

plot(OPT.x([1 2 2 1 1]),OPT.y([1 1 2 2 1]),'r')

hold on

%% loop all tiles

n = 0; % nr of datasets in bounding box

for i=1:length(nc_files)

   nc_file = nc_files{i};

   disp(['processing: ',nc_file])
   
   S.x       = nc_actual_range(nc_file,'x');
   S.y       = nc_actual_range(nc_file,'y');
   S.datenum = nc_cf_time     (nc_file);
   
   %% check whether any part of our search box is inside this tile
   %  or this tile is inside the search box
   
   if any(inpolygon(  S.x([1 2 2 1 1]),  S.y([1 1 2 2 1]),...
                    OPT.x([1 2 2 1 1]),OPT.y([1 1 2 2 1]))) | ... % large area of interest, small data tile (need to aggregate)
      any(inpolygon(OPT.x([1 2 2 1 1]),OPT.y([1 1 2 2 1]),...
                      S.x([1 2 2 1 1]),  S.y([1 1 2 2 1])))       % small area of interest, large data tile (need to subset   )
      
      n = n + 1;
   
      plot( S.x([1 2 2 1 1]), S.y([1 1 2 2 1]),'color','g')
      
      pausedisp

      for it=1 %:length(D.datenum)
      
         D(n).name    = nc_file;
         D(n).datenum = S.datenum(it);
         D(n).x       = nc_varget(nc_file,'x',       [0],    [ -1],             [OPT.stride]);
         D(n).y       = nc_varget(nc_file,'y',       [0],    [ -1],             [OPT.stride]);
         D(n).z       = nc_varget(nc_file,'z',[it-1 0 0],[1 -1 -1],[1 OPT.stride OPT.stride]);
      
         pcolorcorcen(D(n).x,D(n).y,D(n).z);
         
         hold on
      
      end % time
   
   else   % bounding box
   
      plot( S.x([1 2 2 1 1]), S.y([1 1 2 2 1]),'color',[.5 .5 .5])
      
   end    % bounding box

end % tiles

axis equal
colorbar
axis([min(OPT.x) max(OPT.x) min(OPT.y) max(OPT.y)])
grid on
tickmap('xy')

L = nc2struct('http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/landboundaries/holland_fillable.nc')
plot(L.x,L.y)