function nc_cf_gridset_get_list(varargin)
%NC_CF_GRIDSET_GET_LIST  list of all tiles and their times from opendap server
%
%    nc_cf_gridset_get_list(url,<keyword,value>)
%
% saves overview of grid tiles to *.txt file (and *.xls, *.mat and *.nc file), 
% choose custom names with keywords 'xlsname', 'matname', 'ncname' 
%
% Example: for OpenEarth test and production server
%
% RWS Jarkus Grids: production
%    nc_cf_gridset_get_list('http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/jarkus/grids/catalog.html')
%
% RWS Vaklodingen: production and test
%    nc_cf_gridset_get_list('http://dtvirt5.deltares.nl:8080/thredds/catalog/opendap/rijkswaterstaat/vaklodingen/catalog.xml')
%    nc_cf_gridset_get_list('http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/vaklodingen/catalog.xml')
%
% RWS Kustlidar: production and test
%    nc_cf_gridset_get_list('http://dtvirt5.deltares.nl:8080/thredds/catalog/opendap/rijkswaterstaat/kustlidar/catalog.html')
%    nc_cf_gridset_get_list('http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/kustlidar/catalog.html')
%
% NC_CF_GRIDSET_GET_LIST test all 5 above gridsets.
%
% A local netCDF gridset:
%    nc_cf_gridset_get_list(pwd)
%
% By default screen overview appears, save it to file with keyword 'fid' (default 1=to screen):
%    nc_cf_gridset_get_list(pwd,'fid','nc_cf_gridset_get_list.txt')
%
%See also: grid_2D_orthogonal, opendap_catalog, rijkswaterstaat

   if ~odd(nargin)
   % jarkus grid test + production
    urls{1}   = 'http://dtvirt5.deltares.nl:8080/thredds/catalog/opendap/rijkswaterstaat/jarkus/grids/catalog.html';
    urls{2}   = 'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/jarkus/grids/catalog.html';
   
   % vaklodingen grid test + production
    urls{3}   = 'http://dtvirt5.deltares.nl:8080/thredds/catalog/opendap/rijkswaterstaat/vaklodingen/catalog.xml';
    urls{4}   = 'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/vaklodingen/catalog.xml';
   
   % kustlidar grid test + production
    urls{5}   = 'http://dtvirt5.deltares.nl:8080/thredds/catalog/opendap/rijkswaterstaat/kustlidar/catalog.html';
    urls{6}   = 'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/kustlidar/catalog.html';
    firstarg  = 1;
   else
   urls     = varargin{1};
   firstarg = 2;
   end
   
  %OPT.xlsname = [mfilename('fullpath'),'.xls'];
   OPT.xlsname = ''; % add to output dir too
   OPT.matname = ''; % add to output dir too
   OPT. ncname = ''; % add to output dir too
   OPT.fid     = 1;
   OPT.bbfmt   = '%+09.1f';
   
   OPT = setproperty(OPT,varargin{firstarg:end});
   
   if ischar(OPT.fid)
      delete(OPT.fid);
      OPT.xlsname = [fileparts(OPT.fid),filesep,'nc_cf_gridset_get_list.xls']; % add to output dir too
      OPT.matname = [fileparts(OPT.fid),filesep,'nc_cf_gridset_get_list.mat']; % add to output dir too
      OPT. ncname = [fileparts(OPT.fid),filesep,'nc_cf_gridset_get_list.nc2']; % add to output dir too
      OPT.fid = fopen(OPT.fid,'w');
   end
   
   if ischar(urls); urls = cellstr(urls);end
   
for i=1:length(urls)   

   url = urls{i};
   
   disp(['Testing: ',url])

   %% get available files
   
      L = opendap_catalog(url);
      namewidth = max(21,size(filename(char(L)),2)); % width for printing names
      L = sort(L);
   
   %% get meta-info
   %  TO DO: get bounding box too
   
      %disp(['    ',pad('name  ',' ',namewidth),': first date - last date  nt  urlPath                                                   ']
      disp(['    ',pad('name  ',namewidth,'right',' '),': first date - last date  nt  urlPath                                                   '])
      for i=1:length(L)
         try
             t{i} = nc_cf_time(L{i},'time');
            t0(i) = t{i}(1);
            t1(i) = t{i}(end);
            xlim  = nc_actual_range(L{i},'x');
            ylim  = nc_actual_range(L{i},'y');
            x0(i) = xlim(1);
            x1(i) = xlim(2);
            y0(i) = ylim(1);
            y1(i) = ylim(2);
            nt(i) = length(t{i});
           %disp([num2str(i,'%0.3d'),'/',num2str(length(L),'%0.3d')])
            disp([num2str(i,'%0.3d'),' ',pad(filename(L{i}),namewidth,'right',' '),': ',datestr(t0(i),29),' - ',datestr(t1(i),29),' ',num2str(nt(i),'%0.3d'),' ',L{i}])
         catch
            error(['not a valid netCDF CF gridset file: ',L{i}]);
         end
      end
   
   %% get all available dates
   
      allt = [];
      for i=1:length(L)
      allt = [allt t{i}'];
      end
   
   %% make ascii table with available years
   
      years = unique(year(allt));
      array = repmat('~',[length(L) length(years)]);
      mask  = repmat(0  ,[length(L) length(years)]);
      dprintf(OPT.fid,'%s\n',[url,' ', datestr(now)]);
      yearheader = [addrowcol(num2str(years')',0,-(34+namewidth),' ')];
      for iy=1:size(yearheader,1)
      dprintf(OPT.fid,[yearheader(iy,:),'\n']);
      end
      spp = repmat(' ',[1 length(years)]);
      dprintf(OPT.fid,['#   ',pad('name',namewidth,'right',' '),': first date - last date  nt ',spp,'  [x0 x1 y0 y1]                                             \n'])
      for i=1:length(L)
         [dummy,dummy,ind]=intersect(year(t{i}),years);
         array(i,ind)='#';
         mask (i,ind)=1;
         dprintf(OPT.fid,[num2str(i,'%0.3d'),' ',pad(filename(L{i}),namewidth,'right',' '),': ',datestr(t0(i),29),' - ',datestr(t1(i),29),' ',num2str(nt(i),'%0.3d'),' ',array(i,:),' ',num2str(x0(i),OPT.bbfmt),' ',num2str(x1(i),OPT.bbfmt),' ',num2str(y0(i),OPT.bbfmt),' ',num2str(y1(i),OPT.bbfmt),'\n'])
      end
      
      if OPT.fid > 1
          fclose(OPT.fid);
      end
      
   %% make xls table with available years
      
      S.volgnummer = 1:length(L);
      S.name       = char(L);
      S.start      = datestr(t0,'yyyy-mm-dd HH:MM:SS');
      S.end        = datestr(t1,'yyyy-mm-dd HH:MM:SS');
      S.aantal     = nt;
   %%
      for i=1:length(years)
      varname = ['year_',(num2str(years(i)))];
      S.(varname) = mask(:,i);
      end

      if ~isempty(OPT.xlsname);delete(OPT.xlsname);struct2xls(OPT.xlsname,S,'header',{url,datestr(now),'Created with $nc_cf_gridset_get_list.m$'});end
      % in case there is no Excel installed make other formats too
      if ~isempty(OPT. ncname);delete(OPT. ncname);struct2nc  (OPT. ncname,S,'header',{url,datestr(now),'Created with $nc_cf_gridset_get_list.m$'});end
      if ~isempty(OPT.matname);delete(OPT.matname);save      (OPT.matname,'-struct','S');end
      

end