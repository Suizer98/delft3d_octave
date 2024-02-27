function inspire2nc
%inspire2nc
%
%See also: snctools

 ncfile = 'inspire_new.nc';
xmlfile = 'new.xml';

fid = fopen(xmlfile);xml = fscanf(fid,'%c');fclose(fid); % '%c' instead of '%s' to keep spaces + linefeeds!!

nc_create_empty(ncfile)
nc_attput      (ncfile,nc_global,'INSPIRE',xml);

nc.Name      = 'INSPIRE';
nc.Nctype    = 'char';
nc.Dimension = {'dummy'};
nc_adddim(ncfile,'dummy',length(xml));
nc.Attribute(    1) = struct('Name', 'Reference'   ,'Value', 'http://www.inspire-geoportal.eu/');
nc.Attribute(end+1) = struct('Name', 'Editor'      ,'Value', 'http://www.inspire-geoportal.eu/index.cfm/pageid/342');
nc.Attribute(end+1) = struct('Name', 'Validator'   ,'Value', 'http://www.inspire-geoportal.eu/index.cfm/pageid/48');
nc.Attribute(end+1) = struct('Name', 'Viewer'      ,'Value', 'http://www.inspire-geoportal.eu/index.cfm/pageid/341');

nc.Attribute(end+1) = struct('Name', 'created_at'  ,'Value', datestr(now,31));
nc.Attribute(end+1) = struct('Name', 'created_by'  ,'Value', '$Id: inspire2nc.m 3033 2010-09-08 11:25:15Z boer_g $');
nc.Attribute(end+1) = struct('Name', 'created_from','Value', xmlfile);

nc_addvar(ncfile,nc);
nc_varput(ncfile,'INSPIRE',xml);
