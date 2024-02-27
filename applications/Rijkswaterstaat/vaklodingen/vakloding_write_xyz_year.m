function [xyz]=vakloding_write_xyz_year(vl_name,varargin)
%% read vakloding data for given kaartblad name such as 'KB121_2524', for dataset closest to a certain year 
% write .xyz file and return x, y and z values
%
% varargin can be 'year': vaklodingen year as string
%                 'before': if 1, then only data before or in 'year' considered
%                 'url' : opendap url with vaklodingen data
%                 'filout': filename of output
%                 'polygon': tekal polygon file to spatially constrain data
%                            points. Can contain multiple polygons.
%                 'plot': plot data as scatter plot
% 
% to find vl_name check 
% http://kml.deltares.nl/kml/rijkswaterstaat/vaklodingen_overview.kml
%
% Dano Roelvink, 2014
% Adapted Johan Reyns, 2018

OPT.year   = '2000';
OPT.url    = 'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/';
OPT.filout = [vl_name '.xyz'];
OPT.polygon = '';
OPT.plot = 0;
OPT.before = 0;
OPT = setproperty(OPT, varargin);

url = [OPT.url 'vaklodingen' vl_name '.nc']; 
x = nc_varget(url, 'x');
y = nc_varget(url, 'y');
time=nc_varget(url,'time');
[X,Y]=meshgrid(x,y);

time = time+datenum('19700101','yyyymmdd');
timind(1) = find(time<=datenum(OPT.year,'yyyy'),1,'last');
if ~OPT.before
   timind(2) = find(time>=datenum(OPT.year,'yyyy'),1,'first');
   timi = find(abs(time(timind)-datenum(OPT.year,'yyyy'))==min(abs(time(timind)-datenum(OPT.year,'yyyy'))));
else
   timi = 1;
end
if timind(timi)==0; timind(timi)=1;end
Z = squeeze(nc_varget(url, 'z', [timind(timi)-1 0 0], [1 -1 -1]));
disp(['Downloaded data for the closest year to the requested date, which is ' datestr(time(timind(timi)),'yyyy') '.']);
x=X(:); y=Y(:); z=Z(:);
x=x(~isnan(z)); y=y(~isnan(z)); z=z(~isnan(z));
xyz = [];
if ~isempty(OPT.polygon)
  pol = tekal('open',OPT.polygon,'loaddata');
  for ip = 1:length(pol.Field)
     ind = inpolygon(x,y,pol.Field(ip).Data(:,1),pol.Field(ip).Data(:,2));
     xyz = vertcat(xyz,[x(ind) y(ind) z(ind)]);
  end
else
   xyz = [x y z];
end
save(OPT.filout,'xyz','-ascii');

if OPT.plot
   figure;
   scatter(xyz(:,1),xyz(:,2),5,xyz(:,3)); axis equal;
   xlabel('x [m RDNew]','FontSize',10); ylabel('y [m RDNew]','FontSize',10);
   set(gca, 'FontSize', 10); colorbar;
   title(['Vaklodingen in ' datestr(time(timind(timi)),'yyyy') ' in area ' vl_name],'FontSize',11,'Interpreter', 'none');
end
