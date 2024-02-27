function varstruct = nccreateVarstruct_crs(EPSGcode,varargin)
%NCCREATEVARSTRUCT  Subsidiary of nccreateSchema to create cf compliant crs variable
%
% varstruct = nccreateVarstruct_crs(EPSGcode)
%
%See also: nc_cf_grid_mapping, convertCoordinates

OPT = nccreateVarstruct;
OPT.Name     = 'crs';
OPT.Datatype = 'int16';

OPT = setproperty(OPT,varargin);

Attributes     = get_Attributes_from_epsgcode(EPSGcode);
OPT.Attributes = [OPT.Attributes Attributes];
varstruct      = nccreateVarstruct(OPT);


function Attributes = get_Attributes_from_epsgcode(EPSGcode)

   [~,~,OPT] = convertCoordinates([],[],'persistent','CS1.code',EPSGcode,'CS2.code',4326);
   
%% grid_mapping_name

   Attributes = [];
   if isequal(OPT.datum_trans,'no transformation required');
       Attributes.grid_mapping_name  = 'latitude_longitude';
   else
       Attributes.grid_mapping_name  = strrep(lower(OPT.proj_conv1.method.name),' ','_');
   end

   % limit to CF Appendix F. Grid Mappings
   % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#appendix-grid-mappings

    grid_mapping_names = ...
    {'albers_conical_equal_area',...
     'azimuthal_equidistant',...
     'lambert_azimuthal_equal_area',...
     'lambert_conformal_conic',...
     'lambert_cylindrical_equal_area',...
     'latitude_longitude',...
     'mercator',...
     'orthographic',...
     'polar_stereographic',...
     'rotated_latitude_longitude',...
     'stereographic',...
     'vertical_perspective',...
     'transverse_mercator'};

   if isempty(strmatch(lower(Attributes.grid_mapping_name),grid_mapping_names))
      Attributes.grid_mapping_name = '';
   end
   
%% paramaters

   Attributes.semi_major_axis    = OPT.CS1.ellips.semi_major_axis;
   Attributes.semi_minor_axis    = OPT.CS1.ellips.semi_minor_axis;
   Attributes.inverse_flattening = OPT.CS1.ellips.inv_flattening;
   
   if isequal(OPT.datum_trans,'no transformation required');
   else
       for ii = 1:length(OPT.proj_conv1.param.name)
           attname = OPT.proj_conv1.param.name{ii};
           attname = lower(attname);
           attname = strrep(attname,' ','_');
           attname = strrep(attname,'natural','projection');
           Attributes.(attname)= OPT.proj_conv1.param.value(ii);
       end
   end
   
   Attributes.esri_pe_string = epsg_wkt(EPSGcode);

%% ADAGUC
%  http://adaguc.knmi.nl/contents/documents/docs/ADAGUC_Standard_v1_1.pdf, Table 4-4

   Attributes.projection_name = OPT.CS1.name;
   Attributes.EPSG_code       = sprintf('EPSG:%d',EPSGcode);
   Attributes.proj4_params    = epsg_proj4(EPSGcode);
   
   Attributes = reshape([fieldnames(Attributes) struct2cell(Attributes)]',1,[]);

