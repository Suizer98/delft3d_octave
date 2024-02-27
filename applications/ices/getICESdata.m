function varargout = getICESdata(varargin)
%GETICESDATA web service for ICES oceanographic data
%
% [D,A] = getICESdata(<keyword,value>)
%
% where D is a array of structs (tuples) and A a struct 
% with arrays for easy plotting.
%
% Example:
%  [D,A] = getICESdata('ParameterCode','PSAL','t0',datenum(2009,1,1),'t1',datenum(2010,1,1),...
%              'lon',[-2  9],... % bounding box longitude 
%              'lat',[49 57],... % bounding box latitude
%              'p'  ,[0 1e5],... % bounding box depth (pressure)
%         'fileName','salinity.kml')
%
%See also: getICESdataAverage, getndbcdata, getcoopsdata, getICESparameters

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Gerben J. de Boer
%
%       gerben.deboer@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: getICESdata.m 12693 2016-04-20 12:13:43Z gerben.deboer.x $
% $Date: 2016-04-20 20:13:43 +0800 (Wed, 20 Apr 2016) $
% $Author: gerben.deboer.x $
% $Revision: 12693 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ices/getICESdata.m $
% $Keywords$

OPT.ParameterCode = 'PSAL';
OPT.t0            = [];        % datenum(2009,1,1);
OPT.t1            = [];        % datenum(2010,1,1);
OPT.lon           = [nan nan]; % [-2  9];
OPT.lat           = [nan nan]; % [49 57];
OPT.p             = [nan nan]; % [0 1e5];
OPT.fileName      = '';
OPT.kmlName       = '';

if nargin==0
   varargout = {OPT};
   return
end

OPT = setproperty(OPT,varargin);

[A.code, A.name,~,A.units] = getICESparameters(OPT.ParameterCode);

D = GetICEData(ICES_Oceanographic_Web_Service,OPT.ParameterCode,...
               year(OPT.t0),year(OPT.t1),month(OPT.t0),month(OPT.t1),...
               OPT.lon(1),OPT.lon(2),...
               OPT.lat(1),OPT.lat(2),...
               OPT.p  (1),OPT.p  (2));

if isempty(D)
   varargout = {D,A};    
   return
end
    
D = D.ICEData;

for i=1:length(D)

    D(i).Longitude = str2num(D(i).Longitude );
    D(i).Latitude  = str2num(D(i).Latitude  );
    D(i).Pressure  = str2num(D(i).Pressure  );
    D(i).Value     = str2num(D(i).Value     );
    D(i).datenum   = datenum(D(i).DateTime,'yyyy-mm-ddTHH:MM:SS');
    D(i).name      = A. name;
    D(i).units     = A.units;
    
end

if nargout==1
   varargout = {D};
else
   A.Longitude = [D.Longitude];
   A.Latitude  = [D.Latitude];
   A.Pressure  = [D.Pressure];
   A.Value     = [D.Value];
   A.datenum   = [D.datenum];
   varargout = {D,A};
end

%% debug

if ~isempty(OPT.fileName)
   KMLscatter(A.Latitude,A.Longitude,A.Value,...
               'fileName',OPT.fileName,...
           'CBcolorTitle',['ICES ', A.name,' [',A.units,']'],...
       'scalenormalState',1,...       
                'visible',0,...       
                'kmlName',OPT.kmlName,...       
                 'timeIn',floor(A.datenum),...
                'timeOut',ceil(A.datenum+eps))
end
