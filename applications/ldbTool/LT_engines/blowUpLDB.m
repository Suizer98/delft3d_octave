function outLDB=blowUpLDB(Dist, ldb);
%BLOWUPLDB expand a landboundary with a certain distance
%
% BLOWUPLDB expands a landboundary with the specified distance. It will
% move each point of the landboundary perpendicular with respect to the 
% landboundary direction over the specified distance.
% This is useful when creating samples with polygon2samples in Quickin.
% For example: when you want to create a beach profile, with a beach slope
% of 1:10, you can create a landboundary at a distance of 100m of the
% original landboundary, which is the 10m-depth-contour. This contour can be
% used in Quikin to create 10m-deph samples.
%
% Syntax:
% outLDB=blowUpLDB(Dist, ldb);
%
% ldbDis:   the distance between the original landboundary and the
%           output-landboundary
% ldb:      the landboury, which should already be specified by the 
%           function ldb=landboundary('read','landboundary')
% outLDB:   output landboundary
%
% See also: LDBTOOL, THINOUTLDB, ASSIGNSAMPLES

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
outLDB=[];

if nargin==0
    if isempty(which('landboundary.m'))
        wlsettings;
    end
    ldb=landboundary('read');
end

if isempty(ldb)
    return
end

if ~isstruct(ldb)
    [ldbCell, ldbBegin, ldbEnd, ldbIn]=disassembleLdb(ldb);
else
    ldbCell=ldb.ldbCell;
    ldbBegin=ldb.ldbBegin;
    ldbEnd=ldb.ldbEnd;
end

% opblazen ldb segmenten
for ii=1:length(ldbCell);
    dx=ldbCell{ii}(1:end-1,1)-ldbCell{ii}(2:end,1);
    dy=ldbCell{ii}(1:end-1,2)-ldbCell{ii}(2:end,2);
    if ~isempty(dx)
        dx=[dx(1); 0.5*(dx(1:end-1)+dx(2:end)); dx(end)];
        dy=[dy(1); 0.5*(dy(1:end-1)+dy(2:end)); dy(end)];        
    end
    alfa=atan2(dy,dx);
    alfa(alfa<0)=alfa(alfa<0)+2*pi;
    ldbCell2{ii}=ldbCell{ii}(:,1)+Dist*sin(alfa);
    ldbCell2{ii}(:,2)=ldbCell{ii}(:,2)-Dist*cos(alfa);
    ldbBegin2(ii,:)=ldbCell2{ii}(1,:);
    ldbEnd2(ii,:)=ldbCell2{ii}(end,:);    
end

if ~isstruct(ldb)
    %herbouwen ldb
    outLDB=rebuildLdb(ldbCell2);
else
    outLDB.ldbCell=ldbCell2';
    outLDB.ldbBegin=ldbBegin2;
    outLDB.ldbEnd=ldbEnd2;
end