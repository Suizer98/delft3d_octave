function ncgen_mainFcn_test





schemaFcn   = @(OPT)              ncgen_schemaFcn_surface  (OPT);
readFcn     = @(OPT,writeFcn,fns) ncgen_readFcn_surface_xyz(OPT,writeFcn,fns);
writeFcn    = @(OPT,data)         ncgen_writeFcn_surface   (OPT,data);
OPT         = ncgen_mainFcn(schemaFcn,readFcn,writeFcn);

if exist('D:\checkouts\vodata\projects\154302_ijmuiden_onderhoud\elevation_data\multibeam_top_of_mud\raw','dir')
    OPT.main.path_source = 'D:\checkouts\vodata\projects\154302_ijmuiden_onderhoud\elevation_data\multibeam_top_of_mud\raw';
else
    OPT.main.path_source = '\\vnlhq1-apd\D\checkouts\vodata\projects\154302_ijmuiden_onderhoud\elevation_data\multibeam_top_of_mud\raw';
end
% filename = '110926_loding_IJmuidenBuitenhaven_1x1.xyz';
OPT.main.dateFcn        = @(filename) datenum(filename(1:6),'yymmdd');
OPT.main.path_netcdf    = 'F:\nc';
OPT.main.path_unzip_tmp = 'F:\unzip';
OPT.main.zip            = false;
OPT.main.zip_file_incl  = '\.7z$';
OPT.main.file_incl      = '\.xyz$';

OPT.read.delimiter      = ' ';
OPT.read.format         = '%f%f%f';
OPT.read.headerlines    = 0;

OPT.schema.grid_cellsize   = 1;
OPT.schema.grid_tilesize  = 1000;
OPT.schema.grid_offset    = 0.5;
OPT.schema.z_datatype     = 'uint16';
OPT.schema.z_scale_factor = -0.001;
OPT.schema.z_add_offset   = 10;

OPT.schema.meta           = struct('history','Version 1');
%%
 ncgen_mainFcn(schemaFcn,readFcn,writeFcn,OPT);
%%