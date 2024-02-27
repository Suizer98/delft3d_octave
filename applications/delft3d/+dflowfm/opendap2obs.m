function varargout = opendap2obs(varargin)
%OPENDAP2OBS   get list of observation points from netCDF (OPeNDAP) time series collection
%
%    dflowfm.opendap2obs(<keyword,value>)
%
% Example: 
%
%  delft3d_opendap2obs('ncbase','F:\opendap\thredds\rijkswaterstaat/waterbase/sea_surface_height',...
%                        'epsg', OPT.epsg,...
%                        'file',['F:\delft3dfm\run01\rijkswaterstaat_waterbase_sea_surface_height_',num2str(OPT.epsg),'.obs'])
%
%See also: delft3d_opendap2obs, dflowfm.analyseHis, delft3d

%% settings

   OPT.ncbase  = 'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/waterbase/sea_surface_height/catalog.html';
   OPT.epsg    = 28992; % Dutch RD
   OPT.file    = ['rijkswaterstaat_waterbase_sea_surface_height_',num2str(OPT.epsg),'.xyn'];
   
   OPT = setproperty(OPT,varargin);
   
   if nargin==0
      varargout = {OPT};
      return
   end

%% query opendap

  list         = opendap_catalog(OPT.ncbase);
  list         = sort(list);
  n            = length(list);

  D.lon        = repmat(nan,[1 n]);
  D.lat        = repmat(nan,[1 n]);
  D.station_id =        cell(1,n);

  for i=1:n
    disp([num2str(i,'%0.3d'),'/',num2str(n,'%0.3d')])
    try
    D.lon(i)        = nc_varget(list{i},'lon',0,1);
    D.lat(i)        = nc_varget(list{i},'lat',0,1);
    end
    D.station_id{i} = nc_varget(list{i},'station_id');
  end
  
  [D.x,D.y] = convertCoordinates(D.lon,D.lat,'CS1.code',4326,'CS2.code',OPT.epsg)

%% TO DO: exclude points outside dflowfm extent,
%  not really needed as dflowfm already uses only points within set of associated gridcell

%% save file

   fid = fopen(OPT.file,'w');
   for i=1:n
    if ~isnan(D.x(i))
     fprintf(fid,'%10.3f %10.3f ''%s''\n',D.x(i),D.y(i),D.station_id{i});
    end
   end
   fclose(fid);
