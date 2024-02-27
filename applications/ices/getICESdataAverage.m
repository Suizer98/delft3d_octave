function varargout = getICESdataAverage(varargin)
%getICESdataAverage web service for ICES oceanographic data
%
% [D,A] = getICESdataAverage(<keyword,value>)
%
% where D is a array of structs (tuples) and A a struct 
% with arrays for easy plotting.
%
% Example:
%  [D,A] = getICESdataAverage('ParameterCode','PSAL','t0',datenum(2009,1,1),'t1',datenum(2010,1,1),...
%              'lon',[-2  9],... % longitude bounding box
%              'lat',[49 57],... % latitude  bounding box
%              'p'  ,[0 1e5],'kml','salinity.kml')
%
%See also: getICESdata, getndbcdata, getcoopsdata, getICESparameters

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
% $Id: getICESdataAverage.m 8464 2013-04-17 06:44:03Z boer_g $
% $Date: 2013-04-17 14:44:03 +0800 (Wed, 17 Apr 2013) $
% $Author: boer_g $
% $Revision: 8464 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ices/getICESdataAverage.m $
% $Keywords$

OPT.ParameterCode = 'PSAL';
OPT.t0            = [];        % datenum(2009,1,1);
OPT.t1            = [];        % datenum(2010,1,1);
OPT.lon           = [nan nan]; % [-2  9];
OPT.lat           = [nan nan]; % [49 57];
OPT.p             = [nan nan]; % [0 1e5];
OPT.kml           = '';

if nargin==0
   varargout = {OPT};
   return
end

OPT = setproperty(OPT,varargin);

D = GetICEDataAverage(ICES_Oceanographic_Web_Service,OPT.ParameterCode,...
               year(OPT.t0),year(OPT.t1),month(OPT.t0),month(OPT.t1),...
               OPT.lon(1),OPT.lon(2),...
               OPT.lat(1),OPT.lat(2),...
               OPT.p  (1),OPT.p  (2));

D = D.ICEDataAverage;

[A.code, A.name,~,A.units] = getICESparameters(OPT.ParameterCode);

for i=1:length(D)

    D(i).Longitude = str2num(D(i).Longitude );
    D(i).Latitude  = str2num(D(i).Latitude  );
    D(i).Number    = str2num(D(i).Number    ); % int
    D(i).Minimum   = str2num(D(i).Minimum   );
    D(i).Maximum   = str2num(D(i).Maximum   );
    D(i).Average   = str2num(D(i).Average   );
    D(i).name      = A. name;
    D(i).units     = A.units;
    
end

if nargout==1
   varargout = {D};
else
   A.Longitude = [D.Longitude];
   A.Latitude  = [D.Latitude];
   A.Number    = [D.Number];
   A.Minimum   = [D.Minimum];
   A.Maximum   = [D.Maximum];
   A.Average   = [D.Average];
   varargout = {D,A};
end

%% debug

if ~isempty(OPT.kml)
   KMLscatter(A.Latitude,A.Longitude,A.Minimum,'fileName','min.kml',...
       'CBcolorTitle',['Min (',A.name,') [',A.units,']'])
   KMLscatter(A.Latitude,A.Longitude,A.Average,'fileName','avg.kml',...
       'CBcolorTitle',['Average (',A.name,') [',A.units,']'])
   KMLscatter(A.Latitude,A.Longitude,A.Maximum,'fileName','max.kml',...
       'CBcolorTitle',['Max (',A.name,') [',A.units,']'])
   KMLscatter(A.Latitude,A.Longitude,A.Number,'fileName','num.kml',...
       'CBcolorTitle',['Number (',A.name,') ']);
   KMLmerge_files('fileName',OPT.kml,'sourceFiles',{'min.kml','avg.kml','max.kml','num.kml'},'deleteSourceFiles',1)
end
