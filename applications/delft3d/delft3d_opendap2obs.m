function varargout = delft3d_opendap2obs(varargin)
%DELFT3D_OPENDAP2OBS   get observation points from netCDF time series collection
%
%   delft3d_opendap2obs(<keyword,value>)
%
% Example:
%
%  OPT.epsg = 28992; % Dutch RD
%
%  delft3d_opendap2obs('ncbase','F:\opendap\thredds\rijkswaterstaat/waterbase/sea_surface_height',...
%                        'epsg', OPT.epsg,...
%                        'file',['F:\unstruc\run01\rijkswaterstaat_waterbase_sea_surface_height_',num2str(OPT.epsg),'.obs'],...
%                         'grd', 'F:\unstruc\run01\wadden4.grd',...
%                        'plot', 1)
%
%See also: unstruc.opendap2obs, delft3d_io_obs, unstruc.analyseHis, vs_trih2netcdf

%% settings

% TO DO: use catalog.nc

   OPT.ncbase  = 'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/waterbase/sea_surface_height/catalog.html';
   OPT.epsg    = []; % Dutch RD
   OPT.file    = ['delft3d_opendap2obs_',num2str(OPT.epsg),'.obs'];
   OPT.grd     =  '';
   OPT.plot    = 1;
   
   OPT = setproperty(OPT,varargin);
   
   if nargin==0
      varargout = {OPT};
      return
   end

%% query opendap

  list         = opendap_catalog(OPT.ncbase);
  list         = sort(list);
  nobs         = length(list);

  D.lon        = repmat(nan,[1 nobs]);
  D.lat        = repmat(nan,[1 nobs]);
  D.station_id =        cell(1,nobs);

  for i=1:nobs
    disp([num2str(i,'%0.3d'),'/',num2str(nobs,'%0.3d')])
    try
    D.lon(i)        = nc_varget(list{i},'lon',0,1);
    D.lat(i)        = nc_varget(list{i},'lat',0,1);
    end
    D.station_id{i} = nc_varget(list{i},'station_id');
  end
  
  [D.x,D.y] = convertCoordinates(D.lon,D.lat,'CS1.code',4326,'CS2.code',OPT.epsg);

%% get m,n indices

   G = delft3d_io_grd('read',OPT.grd);

  [D.n,D.m] = xy2mn(G.cen.x,G.cen.y,D.x,D.y); % G is (2:nmax-1) x (2:mmax-1)
   D.n = D.n + 1; % Delt3D-FLOW has a dummy row/col !!!
   D.m = D.m + 1;
  
%% remove stations outside polygon
%  make x-y line of first enclosure polygon
   
   m0 = G.Enclosure(1,1);
   n0 = G.Enclosure(1,2);
   
   m  = G.Enclosure(:,1);
   n  = G.Enclosure(:,2);
   ind = find(m==m0 & n==n0);
   m  = G.Enclosure(1:ind(2),1);
   n  = G.Enclosure(1:ind(2),2);
   
      x = [];
      y = [];
   for ip=1:length(m)-1
      sdm = sign(m(ip+1)-m(ip));sdm(sdm==0)=1;
      sdn = sign(n(ip+1)-n(ip));sdn(sdn==0)=1;
      dx  = G.cend.x(n(ip):sdn:n(ip+1),m(ip):sdm:m(ip+1));
      dy  = G.cend.y(n(ip):sdn:n(ip+1),m(ip):sdm:m(ip+1));
      x   = [x dx(:)'];
      y   = [y dy(:)'];
   end
   
%% mask for presence in model extent

   mask = inpolygon(D.x,D.y,x,y);
  
   D.station_id = D.station_id(mask);
   D.lon        = D.lon(mask);
   D.lat        = D.lat(mask);
   D.x          = D.x  (mask);
   D.y          = D.y  (mask);
   D.n          = D.n  (mask);
   D.m          = D.m  (mask);

%% mask for presence in model extent

   if OPT.plot
      TMP = figure();
      grid_plot(G.cor.x,G.cor.y,'color',[.5 .5 .5],'DisplayName','grid corners')
      hold on
      plot(x,y,'.-','DisplayName','1st enclosure')
      plot(D.x,D.y,'ro','DisplayName','observation points')
      text(D.x,D.y,D.station_id)
      tickmap('xy')
      print2screensize(strrep(OPT.file,'obs','png'))
   end

%% save obs and xyn file (to have x,y too and for unstruc)

   fmn = fopen(OPT.file,'w');
   fxy = fopen(strrep(OPT.file,'obs','xyn'),'w');
   for i=1:length(D.m)
    if ~isnan(D.x(i))
     fprintf(fmn,'%-20s %0.4d %0.4d \n'  ,D.station_id{i},D.m(i),D.n(i));
     fprintf(fxy,'%10.3f %10.3f ''%s''\n',D.x(i),D.y(i),D.station_id{i});
    end
   end
   fclose(fmn);
   fclose(fxy);
