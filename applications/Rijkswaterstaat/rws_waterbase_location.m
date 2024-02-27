function varargout=rws_waterbase_location(IDs)
%RWS_WATERBASE_LOCATION   inquire waterbase location meta-data web-service
%
%    S = rws_waterbase_locations(ID)
%    [lon,lat,<description,ID,url>]=rws_waterbase_locations(ID)
%
% Examples
%  S                  = rws_waterbase_location('DENHDR')
%  S                  = rws_waterbase_location({'DENHDR','DENOVBTN'})
%  [x,y,name,ID,epsg0]= rws_waterbase_location('DENHDR')
%  [x,y,name,ID,epsg0]= rws_waterbase_location({'DENHDR','DENOVBTN'})
%
%See also: rws_waterbase_get_locations, http://live.waterbase.nl/metis/

if ischar(IDs);
   IDs = cellstr(IDs);
end

baseurl = 'http://live.waterbase.nl/metis/cgi-bin/mivd.pl?action=value&format=xml&lang=nl&order=code&type=loc&code=';

for i=1:length(IDs)

   url{i} = [baseurl,IDs{i}];
   disp([num2str(i),':',url{i}]);
   X = xml2struct(url{i},'structuretype','long');
   
   %var2evalstr(X)
   ID{i}            = X.Seq.Seq.li.li.Location.Location.code.code.value;
   description{i}   = X.Seq.Seq.li.li.Location.Location.description.description.value;
   srsName          = X.Seq.Seq.li.li.Location.Location.geometry.geometry.x_Features.x_Features.Featuremember.Featuremember.Point.Point.ATTRIBUTES.srsName.value;
   [nx ny] = size(srsName); srsName = srsName(1:(ny-1));
   epsg(i)          = str2num(srsName(6:end));
   xy               = X.Seq.Seq.li.li.Location.Location.geometry.geometry.x_Features.x_Features.Featuremember.Featuremember.Point.Point.Coordinates.Coordinates.value;
   ind              = strfind(xy,',');
   x                = str2num(xy(1:ind-1));
   y                = str2num(xy(ind+1:end));
   [lon(i),lat(i)]  = convertCoordinates(x,y,'CS1.code',epsg(i),'CS2.code',4326);
   
end

if nargout < 2
   varargout = {struct('url',url,'lon',lon,'lat',lat,'description',description,'ID',ID,'epsg',epsg)};
elseif nargout == 2
   varargout = {lon,lat};
elseif nargout == 3
   varargout = {lon,lat,description};
elseif nargout == 4
   varargout = {lon,lat,description,ID};
elseif nargout == 5
   varargout = {lon,lat,description,ID,epsg};
elseif nargout == 6
   varargout = {lon,lat,description,ID,epsg,url};
end