function pol=kml2pol(saveOutput,inFile)
%KML2LDB Converts kml-file to ldb-file
%
% Reads x and y coordinates from a kml-file and saves them to a
% landboundary file.
%
% Syntax:
% ldb = KML2LDB(saveOutput, inFile)
%
% saveOutput:   set to 1 to save output to pol-file
% inFile:       input kml-file (optional)
% ldb:          output ldb [Mx2} array
%
% See also: LDBTOOL, KML2LDB3D, LDB2KML, GOOGLEPLOT, KML2Coordinates

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Deltares
%       Ymkje Huismans
%
%       ymkje.huismans@deltares.nl
%
%       sript based on kml2ldb from Arjan Mol (2010)
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
    
    saveOutput=input('Save the output to a .pol file? [Y/N] ','s');
    if strcmpi(saveOutput,'Y')
        saveOutput=1;
    else
        saveOutput=0;
    end
end

if nargin == 2
    [fPat fName] = fileparts(inFile);
end
if isempty(fPat)
    fPat=cd;
end

fid=fopen(inFile);
kmlFile=fread(fid,'char');
coorsStart=findstr('<coordinates>',char(kmlFile)')+13;
coorsStop=findstr('</coordinates>',char(kmlFile)')-1;

pol=[];
for ii=1:length(coorsStart)
    tLdb=str2num(char(kmlFile(coorsStart(ii):coorsStop(ii)))');
%     pol=[tLdb(1:3:end) tLdb(2:3:end)];
    pol=[pol; tLdb];
end
fclose(fid);

%reshape polygon to [nrows,3] if coordinates where supplied as one line
sz = size(pol);
if max(sz)>3 && min(sz) == 1
    nrows = max(sz)/3;
    pol = reshape(pol,3,nrows);
    pol = pol';
end

if saveOutput==1
io_polygon('write',[fPat filesep fName '.pol'],pol(:,1:2));
end

