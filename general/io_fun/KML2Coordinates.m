function varargout = KML2Coordinates(FileName,varargin)
% KML2COORDINATES transforms .kml polygons/paths into a Matlab cell
% 
%   [LAT,lon,z,<names>] = KML2COORDINATES(FileName,<keyword,value>) returns
%   NaN-separated arrays (NOTE LAT 1sT), with a NaN between each placemark.
%   The Folder structure of the is lost, one overall polygon is returned.
%
%   out = KML2COORDINATES(FileName) returns a cell of arrays MX3. 
%   The arrays are double arrays, each composed of xyz coordinates of the points 
%   of the specific polygon (path).  Cell size depends on the number
%   of polygons/paths (placemarks) in the file. 
%
%   Example:
%       % polygons of buildings
%       FileName = 'http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/landboundaries/holland_fillable.nc';
%       lat = nc_varget(FileName,'lat');
%       lon = nc_varget(FileName,'lon');
%       KMLline(lat,lon,'fileName','holland_fillable.kml','lineColor',[1 .5 0],'lineWidth', 2);
%
%       p = KML2Coordinates('holland_fillable.kml');
%       p.lon = tmp{1}(:,1);
%       p.lat = tmp{1}(:,2);
%       [p.x,p.y]=convertCoordinates(p.lon,p.lat,'CS1.code',4326,'CS2.code',28992)
%       plot(p.x,p.y)
%       landboundary('write','doc.ldb',p.x,p.y)
%
% See also: googleplot, line, patch, KMl2ldb, landboundary, poly_fun

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

% $Id: KML2Coordinates.m 17101 2021-03-02 14:21:45Z bj.vanderspek.x $
% $Date: 2021-03-02 22:21:45 +0800 (Tue, 02 Mar 2021) $
% $Author: bj.vanderspek.x $
% $Revision: 17101 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/io_fun/KML2Coordinates.m $
% $Keywords$

OPT.method = 'xml'; % safer for comments etc, but somewhat slower. Can handle nested kml.s

OPT = setproperty(OPT,varargin);

if strcmp(FileName(end-3:end),'.kmz')
   unzip(FileName);
   kmlname = [FileName(1:end-4) '.kml'];
elseif strcmp(FileName(end-3:end),'.kml')
   kmlname = FileName;
else
   kmlname = [FileName '.kml'];
end

switch OPT.method
 case 'xml'
    xml = xml_read(kmlname);
   [names,coordCell]=kml_placemark_folder_read(xml.Document,1);

 case 'fgetl' % has issues for manually edited kml: <coordinates> in same line as </coordinates>
	fid = fopen(kmlname);
    jj  = 0;
    while ~feof(fid)
        next = 0;
        newline = fgetl(fid);
        if any(strfind(newline,'<coordinates>'))
            ind1 = strfind(newline,'<coordinates>')+13;
            ind2 = strfind(newline,'</coordinates>')-1;
            if isempty(ind2);ind2 = length(newline);else;error('<coordinates> and </coordinates> on same line not yet implemented');end
            coordline = newline(ind1:ind2);% remaining data in <coordinates> line
            if isempty(coordline);
            coordline = fgetl(fid);
            end
            jj = jj+1;
            names{jj} = '';
            % coordinates x,y,z can be column-wise, row-wise,
            % or mixed,. end-tag coordinates can be 
            % on same line as  x,y,z  or newline.
                kk = 0;
                t = char(regexp(coordline,'</coordinates>','match'));
                while ~strcmp(t,'</coordinates>')
                    coordline = reshape(str2num(coordline),3,[]);
                    for ii=1:size(coordline,2)
                       kk = kk+1;
                       coord{kk,:} =  coordline(:,ii)';
                    end
                    coordline = fgetl(fid);
                    t = char(regexp(coordline,'</coordinates>','match'));
                    % parse coord when end-tag is on same line
                    if strcmp(t,'</coordinates>')
                       ind = strfind(coordline,'</coordinates>');
                       kk = kk+1;
                       coord{kk,:} = str2num(coordline(1:ind-1));
                    end
                end
                coordCell{jj} = cell2mat(coord);
                clear coord;
        end

    end
    fclose(fid);
 end % case

if nargout==1
    varargout = {coordCell};
elseif nargout>1
    % make NaN-seperated polygons from seperate cells
    lon = cell2mat(cellfun(@(x) [x(:,1)' nan],coordCell,'UniformOutput',0));lon = lon(1:end-1);
    lat = cell2mat(cellfun(@(x) [x(:,2)' nan],coordCell,'UniformOutput',0));lat = lat(1:end-1);
    z   = cell2mat(cellfun(@(x) [x(:,3)' nan],coordCell,'UniformOutput',0));z  = z  (1:end-1);
    if nargout==2
    varargout = {lat,lon}; 
    elseif nargout==3
    varargout = {lat,lon,z}; 
    elseif nargout==4
    varargout = {lat,lon,z,names}; 
    end
end 

%%
function [names,coordCell,metadata]= kml_placemark_folder_read(p,varargin)

if nargin==1
   nest = 1;
else
   nest = varargin{1};
end

%% load files at this level and then ...
if isfield(p,'Placemark')
   [names,coordCell,metadata]=kml_placemark_read(p.Placemark);
else
   names     = [];
   coordCell = {};
   metadata  = [];
end
   disp(['nest ',num2str(nest),'    # ',num2str(length(names))])

%% ... recursively loop all folder
if isfield(p,'Folder')
   for i=1:length(p.Folder)
     [Dnames,DcoordCell,Dmetadata]= kml_placemark_folder_read(p.Folder(i),nest+1);
      names     = [names     Dnames    ];
      coordCell = [coordCell DcoordCell];
      metadata  = [metadata  Dmetadata ];
      disp(['nest ',num2str(nest),' ',num2str(i,'%0.2d'),' # ',num2str(length(Dnames))])
   end
end

%% kml_placemark_read
function[names,coordCell,metadata]= kml_placemark_read(p)

   names     = [];
   coordCell = {};
   metadata  = {};

    for jj=1:length(p)
       names{jj} = p(jj).name;
       if isnumeric(names{jj})
           names{jj} = num2str(names{jj});
       end
       if isfield(p(jj),'LineString')
           tmp = p(jj).LineString.coordinates;
            if ~isnumeric(tmp); % some are already converted to numbers, apparently
              tmp = str2num(tmp);
           end
          if size(tmp,1) == 1
             coordCell{jj} = reshape(tmp,3,[])';
          else
             coordCell{jj} = tmp;
          end
       else
           tmp = p(jj).Polygon.outerBoundaryIs.LinearRing.coordinates;
           if ~isnumeric(tmp); % some are already converted to numbers, apparently
              tmp = str2num(tmp);
           end
           coordCell{jj} = reshape(tmp,3,[])';
       end
    end
    
    %disp(['# ',num2str((length(names)))])
