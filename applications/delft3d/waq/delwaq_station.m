%DELWAQ_STATION Gives informtaion about the most common stations in used in delwaq
%
%   [xparis yparis] = DELWAQ_STATION('xy',lon,lat) Gives back the x and y
%   coordinates corresponding to lon and lat value.
%
%   [lon lat] = DELWAQ_STATION('lonlat',Id) Gives back the longitude and latitude
%   coordinates of the station with the Id value
%
%   Id = DELWAQ_STATION('id',x,y) Gives back the Id of the station with x and y  
%    coordinates
%
%   Name = DELWAQ_STATION('name',Id) Gives back the long name of the station
%   with the Id value
%
%   Name = DELWAQ_STATION('name','id')
%       'xy '    - Coordinates: xparis yparis
%       'lonlat' - Coordinates: Longitud, Latitude
%       'id'     - Short name of the station (mostly delwaq Id names)
%       'name'   - Long name from NC files in
%                  P:\mcdata\opendap.deltares.nl\rijkswaterstaat\waterbase\
%
%   NOTE: you want to extend the list of stations in the file:
%         delwaq_stations.txt 
%
%   Example:
%   C = delwaq_station('name','noordwk10')
% 
%   C =
% 
%   Noordwijk 10 km from the coast  
%
%
%   See also: 

%   Copyright 2011 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   2011-Jul-12 Created by Gaytan-Aguilar
%   email: sandra.gaytan@deltares.com
%--------------------------------------------------------------------------
function varargout = delwaq_station(type,varargin)

fid = fopen('delwaq_stations.csv');

data = textscan(fid, '%f %f %f %f %s %s %s','commentStyle', '#','delimiter', ',');
fclose(fid);

stationLon = data{1};
stationLat = data{2};
stationX   = data{3};
stationY   = data{4};
stationId  = data{5};
stationName = data{6};
stationInst = data{7};

if nargin==3 && isnumeric(varargin{1}) && isnumeric(varargin{2})
   nout = size(varargin{1},1);
   [~, ixy1 ixy2] = match_coordinates(stationX,stationY,varargin{1},varargin{2});
   [~, ill1 ill2] = match_coordinates(stationLon,stationLat,varargin{1},varargin{2});
   if any(ixy1)
       index1 = ixy1;
       index2 = ixy2;
   elseif any(ill1)
       index1 = ill1;
       index2 = ill2;
   end

else
   if nargin==2 && ~iscell(varargin{1})
      varargin{1} = {varargin{1}}; %#ok<*CCAT1>
   end
   nout = length(varargin{1});
   [~, id1 id2] = match_names(stationId,varargin{:});
   [~, iname1 iname2] = match_names(stationName,varargin{:});
   if any(id1)
       index1 = id1;
       index2 = id2;
   elseif any(iname1)
       index1 = iname1;
       index2 = iname2;
   end
end

switch type
     case 'xy'         
         xout = nan(nout,1);
         yout = nan(nout,1);
         xout(index2,:) = stationX(index1,:);
         yout(index2,:) = stationY(index1,:);
         varargout{1} = xout;
         varargout{2} = yout;
     case 'lonlat'
         lon = nan(nout,1);
         lat = nan(nout,1);
         lon(index2,:) = stationLon(index1,:);
         lat(index2,:) = stationLat(index1,:);
         varargout{1} = lon;
         varargout{2} = lat;
     case 'id'
          Idout(1:nout) = {''};
          for i = 1:length(index1)
              Idout{index2(i)} = stationId{index1(i)};
          end
          if nout==1
              varargout = Idout;
          else
              varargout{1} = Idout;
          end
          
     case 'name'
          nameout(1:nout) = {''};
          for i = 1:length(index1)
              nameout{index2(i)} = stationName{index1(i)};
          end
          if nout==1
              varargout = nameout;
          else
              varargout{1} = nameout;
          end
     case 'inst'
          nameout(1:nout) = {''};
          for i = 1:length(index1)
              nameout{index2(i)} = stationInst{index1(i)};
          end
          if nout==1
              varargout = nameout;
          else
              varargout{1} = nameout;
          end
          
end
   
    
%--------------------------------------------------------------------------
% Match names
%--------------------------------------------------------------------------
function [names iname1 iname2] = match_names(name1,name2)

iname1 = [];
iname2 = [];
names  = [];

if ischar(name2)
   name2 = cellstr(name2);
elseif isnumeric(name2);
    if length(name2)==1 && name==0
       name2 = 1:length(name1);
    end
    name2 = name1(name2);
end

k = 0;
for i = 1:length(name2)
    isub1 = find(strcmpi(strtrim(name1),strtrim(name2{i})));
    if ~isempty(isub1)
       k = k+1;
       iname1(k) = isub1; %#ok<*AGROW>
       iname2(k) = i;
       names{k} = name2{i};
    end
end

%--------------------------------------------------------------------------
% Match Coordinates
%--------------------------------------------------------------------------
function [x i1 i2] = match_coordinates(x1,y1,x2,y2)

X1 = [x1 y1];
X2 = [x2 y2];

[x, i1, i2] = intersect(X1, X2, 'rows');

