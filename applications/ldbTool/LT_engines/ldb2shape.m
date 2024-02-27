function ldb2shape(ldbName,varargin)
%LDB2SHAPE Convert ldb to Pharos layout file
%
% Input is the name of the ldb-file or a nx2 matrix
% Converts ldb-file (landboundary) to Pharos-layout-file (txt)
% and checks whether directions (clockwise or anti-clockwise) are ok
% and flips layout if necessary
% You can also perform translation in x and/or y direction
%
% Syntax:
% ldb2shape(ldb,type)
%
% ldb:      the landboury, which should already be specified by the 
%           function ldb=landboundary('read','landboundary')
%           (optional)
% type:     'polyline' or 'polygon' (filled)
% 
%
% See also: LDBTOOL, LDB2KML, LDB2PHAROS

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Arjan Mol 
%
%       arjan.mol@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%   Updated (2014) BJT van der Spek Royal HaskoningDHV
% 
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Code
if nargin==0
    if isempty(which('landboundary.m'))
        wlsettings;
    end
    [nam, pat]=uigetfile('*.ldb','Select landboundary-file');
    ldbName = [pat nam];
end

if isnumeric(ldbName)
    ldb=ldbName;
    [nam,pat]=uiputfile('*.shp','Export to shape-file');
    shpName=[pat nam];
else
    ldb=landboundary('read',ldbName);
    shpName=[ldbName(1:end-4) '.shp'];
end

if isempty(ldb)
    return
end

if size(ldb,2) > 2
    ldb = ldb(:,1:2);
end

if ~isnan(ldb(1,1))
    ldb=[nan nan;ldb];
end

if ~isnan(ldb(end,1))
    ldb=[ldb;nan nan];
end

id=find(isnan(ldb(:,1)));

for ii=1:length(id)-1
    ldbCell{ii}=ldb(id(ii)+1:id(ii+1)-1,:);
end

ldbCell = ldbCell(find(cellfun('size',ldbCell,1)>1));

if nargin>1;
    if strcmp(varargin{1},'polyline')
     shpOutput='polyline';
    elseif strcmp(varargin{2},'polygon')
     shpOutput='polygon';
    else
    disp([varargin{2},'not known'])
    shpOutput=questdlg('Select type of shape-ouput','ldb2shape','polyline','polygon (filled)','polyline');
    end
else
shpOutput=questdlg('Select type of shape-ouput','ldb2shape','polyline','polygon (filled)','polyline');
end

switch shpOutput
    case 'polyline' 
        shapewrite(shpName,'polyline',ldbCell)
    case 'polygon (filled)',
        shapewrite(shpName,'polygon',ldbCell)         
end