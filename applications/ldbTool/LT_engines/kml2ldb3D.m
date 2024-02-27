function ldb=kml2ldb3D(saveOutput)
%KML2LDB3D Converts kml-file to 3-column ldb-file (incl. z-coordinates)
%
% Reads x, y and z coordinates from a kml-file and saves them to a
% three column landboundary file.
%
% Syntax:
% ldb = KML2LDB3D(saveOutput, inFile)
%
% saveOutput:   set to 1 to save output to ldb-file
% inFile:       input kml-file (optional)
% ldb:          output ldb [Mx2} array
%
% See also: LDBTOOL, KML2LDB3D, LDB2KML, GOOGLEPLOT

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
if nargin < 2
    [nam pat]=uigetfile('*.kml','Select kml file');
    if nam==0
        return
    end
    [fPat fName]=fileparts([pat nam]);
    inFile = [pat nam];
end

fid=fopen(inFile);
kmlFile=fread(fid,'char');
coorsStart=findstr('<coordinates>',char(kmlFile)')+13;
coorsStop=findstr('</coordinates>',char(kmlFile)')-1;

ldb=[nan nan nan];
for ii=1:length(coorsStart)
    tLdb=str2num(char(kmlFile(coorsStart(ii):coorsStop(ii)))')';
    ldb=[ldb;tLdb(1:3:end) tLdb(2:3:end) tLdb(3:3:end); nan nan nan];
end

if saveOutput==1
landboundary('write',[fPat filesep fName '.ldb'],ldb');
end