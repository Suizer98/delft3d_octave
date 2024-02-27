function donar_nc2scatter(ncfile,deltares_names)
%donar_nc2scatter  plot one netcdf files as kml
%
%See also: donar_nc2scatter

  disp(ncfile)
  [D,M] = nc2struct(ncfile);
  for j=1:length(deltares_names)
    standard_name = deltaresname2standardnames(deltares_names{j});
    if isfield(D,standard_name)
     kmzname = [filepathstrname(ncfile),'_',standard_name,'.kmz'];
     kmzname = strrep(kmzname,'\nc\','\kml\');
     KMLscatter(D.latitude,D.longitude,D.(standard_name),...
     'fileName',kmzname,...
     'CBcolorTitle',[mktex(standard_name),' [',M.(standard_name).units,']'],...
     'timeIn',D.datenum-.5,'timeOut',D.datenum+.5)
    end
  end % names
