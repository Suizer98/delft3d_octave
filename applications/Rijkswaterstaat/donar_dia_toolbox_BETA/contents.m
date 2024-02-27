%donar_dia_toolbox
%
% GENERAL CONVERSIONS PROCESSING CHAIN
% 
% thedon_dia2donarmat -  convert dia files into donar mat files	
% donar_dia2donarMat  -  ,, subsidiary
%
% thedon_donarmat2NC  -  convert donar mat files into netCDF-CF
% donar_donarMat2nc   -  ,, subsidiary
%
% thedon_nc2kml       -  convert netCDF-CF into kml files
% donar_nc2scatter    -  ,, subsidiary
%
% Name convention where [sensor_name] is {'CTD','FerryBox','ScanFish'}
%
%    Raw:    [OPT.diadir]\[sensor_name]\raw\
%
%    Mat:    [OPT.diadir]\[sensor_name]\mat\[sensor_name]_[year]_the_compend
%    Mat:    [OPT.diadir]\[sensor_name]\mat\[sensor_name]_[year]_withFlag
%
%    netCDF:  [OPT.ncdir]\[sensor_name]\[sensor_name]_[year]_[parameter]
%
%
% PLOTTING PROCESSING CHAIN
%
%
%
%
%See also: netcdf, waterbase