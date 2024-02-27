function outLdb=shape2ldb(shapeName,saveFlag)
%SHAPE2LDB Converts a shape (.shp) file to a landboundary
%
% This routine reads coordinates from a ArcGIS shape file (.shp) and
% converts it to a landboundary.
%
% Syntax:
% ldbOut=shape2ldb(shapeName,saveFlag)
%
% shapeName:    name of shape-file (.shp)
% saveFlag:     save ldb to file immediately, yes (1) or no (0)
% ldbOut:       resulting landboundary [Mx2]
%
% See also: LDBTOOL, LDB2SHP, KML2SHP

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
if isempty(shapeName)
    [name,pat]=uigetfile('*.shp','Load shape file');

    if name==0
        return
    end

    shapeName=[pat name];
end

F=shape('open',shapeName);
outLdb=shape('read',F,0,'lines');

if saveFlag==1
landboundary('write',[shapeName(1:end-3) 'ldb'],outLdb);
disp('Done...');
end


