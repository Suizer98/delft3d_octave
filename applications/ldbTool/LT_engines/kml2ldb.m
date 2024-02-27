function [ldb,names]=kml2ldb(saveOutput,inFile)
%KML2LDB Converts kml-file to ldb-file
%
% Reads x and y coordinates from a kml-file and saves them to a
% landboundary file.
%
% Syntax:
% ldb = KML2LDB(saveOutput, inFile)
%
% saveOutput:   set to 1 to save output to ldb-file
% inFile:       input kml-file (optional)
% ldb:          output ldb [Mx2} array
%
% See also: LDBTOOL, KML2LDB3D, LDB2KML, GOOGLEPLOT, KML2Coordinates

%% Copyright notice
%   -------------------- ------------------------------------------------
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

%get polygon names
nameStart=findstr('<name>',char(kmlFile)')+6;
nameStop=findstr('</name>',char(kmlFile)')-1;


ldb=[nan nan];

%If a kml file has only polygons, the tag <name> appears twice before the
%first polygon name. Thus: numel(nameStart)=numel(coorsStart)+2; 
%I (V. Chavarrias) have only checked this type of file and I prevent a
%possible error by not saving the names in case numel is inconsisten. 

np=numel(coorsStart); %number of polygons
names=cell(1,np); %cell to store the name of the polygons
save_names=false; %use names
if numel(nameStart)==np+2
    save_names=true;
end

for ii=1:length(coorsStart)
    tLdb=str2num(char(kmlFile(coorsStart(ii):coorsStop(ii)))');
    if mod(size(tLdb,2),3)==0 && mod(size(tLdb,2),2)~=0 % J. Groenenboom - take 2 different kml formats into account
        ldb=[ldb;tLdb(1:3:end)' tLdb(2:3:end)'; nan nan]; % kml consist of [lon,lat,z]-coordinates
    elseif mod(size(tLdb,2),3)~=0 && mod(size(tLdb,2),2)==0
        ldb=[ldb;tLdb(1:2:end)' tLdb(2:2:end)'; nan nan]; % kml consist of [lon,lat]-coordinates
    else % if size(tLdb,2) is a multiple of 2,3 and factor n
        if length(unique(tLdb(3:3:end)))==1 % z-value is always the same
            ldb=[ldb;tLdb(1:3:end)' tLdb(2:3:end)'; nan nan]; % kml consist of [lon,lat,z]-coordinates
        else
            ldb=[ldb;tLdb(1:2:end)' tLdb(2:2:end)'; nan nan]; % kml consist of [lon,lat]-coordinates
        end
    end
    %names
    if save_names
%         names=[names(:)',{char(kmlFile(nameStart(ii+2):nameStop(ii+2))')}];
        names{ii}=char(kmlFile(nameStart(ii+2):nameStop(ii+2))');
    end
end

if saveOutput==1
    if save_names
        landboundary('write',[fPat filesep fName '.ldb'],ldb,'names',names,'dosplit');
    else
        landboundary('write',[fPat filesep fName '.ldb'],ldb,'dosplit');
    end
end
