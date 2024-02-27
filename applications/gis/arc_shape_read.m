function [S,M] = arc_shape_read(filename)
%ARC_SHAPE_READ   Read vector features and attributes from shapefile
%
%    R    = arc_shape_read(filename)
%   [R,M] = arc_shape_read(filename)
%
% returns the data in struct R, and the meta-data in struct M,
% where filename is an arcview file name without the extension.
%
% R has fields:
% - BoundingBox = [xmin ymin; xmax ymax]
% - X: NaN-separated polygon, (anti)clockwise for positive areas.
% - Y: NaN-separated polygon, (anti)clockwise for negative areas.
% - one field per variable in the dbf file.
%
% Note 1: cannot read yet character attributes from dbf file, 
%         these are read erronously as numbers.
% Note 2: *.prj file is not interpreted yet, please specify epsg code manually.
%
% see also: POLYFUN, ARCGISREAD, ARC_INFO_BINARY, SHAPEREAD (in optional mapping toolbox)

%% Copyright
%  written by: James P. LeSage 12/2003
%  University of Toledo
%  Department of Economics
%  Toledo, OH 43606
%  jlesage@spatial-econometrics.com

%% arguments

   if nargin ~= 1
      error('shpfile_read: Wrong # of input arguments');
   end;

   if strcmpi(filename(end-3:end),'.shp')
   filename = filename(1:end-4);
   end

%% call to mex file
%
% uses: a c-mex function shp_read.c, compile with mex shp_read.c shapelib.c
%
% to compile use:
%
% mex shp_read.c shapelib.c
%
% which creates shp_read.dll
%
% mex dbf_read.c shapelib.c
%
% which creates dbf_read.dll

try

      [cartex,cartey,xmin,xmax,ymin,ymax,nvertices,nparts,R.xc,R.yc,shp_type] = shp_read(filename);
   
   %% interpret arrays
   
      ind        = find(cartex ~= 0);
      long       = cartex(ind,1);
      latt       = cartey(ind,1);
      npoly      = length(xmin);
      x          = long(1:end-1,1);
      y          = latt(1:end-1,1);
      
      clear long latt;
   
   %% Process chunks separated by NaN .................
   
      in  = [0; find(isnan(x))];
      n   = length(in); % length of segments > npoly due to na-separation inside segmnent
      if ~isnan(x(end))
      in = [in; length(x)+1];
      end   
      
      cnt = 1; % number of multi-segment objects
      jj  = 1; % number of segments
      while (jj <= n)
         jj0 = jj;
         S(cnt,1).BoundingBox = [xmin(cnt) ymin(cnt);xmax(cnt) ymax(cnt)];
         if nparts(cnt,1) == 1
            jj = jj+1;
         else
            for k=1:nparts(cnt,1);
             jj = jj+1;
            end;
         end;
         cnt = cnt+1;
         if jj <= n
         ii         = [in(jj0)+1:in(jj)-1];
         S(cnt-1,1).X = [x(ii)' NaN];
         S(cnt-1,1).Y = [y(ii)' NaN];
         end
      end;
         ii         = [in(end-1)+1:in(end)-1];
         S(cnt-1,1).X = [x(ii)' NaN];
         S(cnt-1,1).Y = [y(ii)' NaN];
      
      clear xmin xmax ymin ymax;
      clear nvertices nparts;
   
   %% now read the dbf file and place the data into a structure
   
      [datamatrix,vnames] = dbf_read(filename);
      
      if size(datamatrix,1) ~= npoly
         warning('shpfile_read: # of shapefile polygons do not match # of data observations in dbf file');
      end;
      
      for ivar=1:size(datamatrix,2)
      for iobs=1:size(datamatrix,1)
      
         vname            = mkvar(vnames{ivar});
         S(iobs).(vname)  = datamatrix(iobs,ivar);
         if   shp_type(iobs)==0;S(iobs).Geometry = 'Polygon';
         else                   S(iobs).Geometry = 'Polygon';
         end
      
      end
      end
      
catch

      warning(['Error reading: ',filename])
  
end
   
%% read meta-data

   if exist([filename,'.shp.xml'])
      M = xml_read([filename,'.shp.xml']);
   else
      M = [];
      warning(['Missing: ',filename,'.shp.xml'])
   end

end

%% EOF   
