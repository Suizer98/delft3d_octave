function outLDB=glueLDB(ldbDis,ldb,hW)
%GLUELDB Connect ldb segments based on threshold distance
%
% This tool can be used to connect segments in a landboundary to each
% other, when the distance between the start/end points of the segments is
% lower than the specified threshold distance. Because after glueing two
% segments to each other, the landboundary changes, it will not always to
% be able to connnect all segments that should be connected. In that case
% repeat GLUELDB. Repeatedly calling this routine can be automized by using 
% ULTRAGLUELDB. For cases it won't work, use SUPERGLUELDB.
%
% Syntax:
% outLDB=glueLDB(ldbDis,ldb)
%
% ldbDis:   [dis1 dis2 dis3 .... disN] (N = number of iterations)
% inLdb:    landboundary to be glued [Mx2]
%
% See also: LDBTOOL, ULTRAGLUELDB, SUPERGLUELDB, GLUELDB, IPGLUELDB

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

if nargin==1
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

cwaitbar([2 1/12]);

%first look for similarity between begin and end-points
for ii=1:size(ldbBegin,1)
    ldbDist=sqrt((ldbEnd(:,1)-ldbBegin(ii,1)).^2+(ldbEnd(:,2)-ldbBegin(ii,2)).^2);
    Bep{ii}=find(ldbDist<ldbDis);
    %     if ii==Bep{ii}
    %         Bep{ii}=[];
    if ~isempty(Bep{ii})
        if ii==Bep{ii}(1)
            Bep{ii}=Bep{ii}(Bep{ii}~=ii); % toegevoegd (voor een ldb met louter losse punten), bij fouten deze regels disablen en regels hierboven enablen!
        end
    end
end
cwaitbar([2 2/12]);

ldbGlueCell=ldbCell;

for jj=1:length(Bep)
    if ~isempty(Bep{jj})
        ldbGlueCell{Bep{jj}(1)}=[ldbGlueCell{Bep{jj}(1)}; ldbGlueCell{jj}];
        ldbBegin(Bep{jj}(1),:)=ldbGlueCell{Bep{jj}(1)}(1,:);
        ldbEnd(Bep{jj}(1),:)=ldbGlueCell{Bep{jj}(1)}(end,:);
        ldbGlueCell{jj}=[];
    end
end
cwaitbar([2 3/12]);

ldbBegin(cellfun('isempty',ldbGlueCell),:)=[];
ldbEnd(cellfun('isempty',ldbGlueCell),:)=[];
ldbGlueCell(cellfun('isempty',ldbGlueCell))=[];
ldbCell=ldbGlueCell;

cwaitbar([2 4/12]);

clear ldbGlueCell;
clear id;

cwaitbar([2 5/12]);

%now for similar begin points
for ii=1:size(ldbBegin,1)
    ldbDist=sqrt((ldbBegin(:,1)-ldbBegin(ii,1)).^2+(ldbBegin(:,2)-ldbBegin(ii,2)).^2);
    ldbDist(ii)=100000;
    Bbp{ii}=find(ldbDist<ldbDis);
    %     if ii==Bbp{ii}
    %         Bbp{ii}=[];
    if ~isempty(Bbp{ii})
        if ii==Bbp{ii}(1)
            Bbp{ii}=Bbp{ii}(Bbp{ii}~=ii); % toegevoegd (voor een ldb met louter losse punten), bij fouten deze regels disablen en regels hierboven enablen!
        end
    end
end
cwaitbar([2 6/12]);

ldbGlueCell=ldbCell;
for jj=1:length(Bbp)
    if ~isempty(Bbp{jj})
        ldbGlueCell{Bbp{jj}(1)}=[flipud(ldbGlueCell{jj}) ; ldbGlueCell{Bbp{jj}(1)}];
        ldbBegin(Bbp{jj}(1),:)=ldbGlueCell{Bbp{jj}(1)}(1,:);
        ldbEnd(Bbp{jj}(1),:)=ldbGlueCell{Bbp{jj}(1)}(end,:);
        ldbGlueCell{jj}=[];
    end
end
cwaitbar([2 7/12]);

ldbBegin(cellfun('isempty',ldbGlueCell),:)=[];
ldbEnd(cellfun('isempty',ldbGlueCell),:)=[];
ldbGlueCell(cellfun('isempty',ldbGlueCell))=[];
ldbCell=ldbGlueCell;

cwaitbar([2 8/12]);

clear ldbGlueCell;
clear id;

cwaitbar([2 9/12]);

%now for similar end points
for ii=1:size(ldbEnd,1)
    ldbDist=sqrt((ldbEnd(:,1)-ldbEnd(ii,1)).^2+(ldbEnd(:,2)-ldbEnd(ii,2)).^2);
    ldbDist(ii)=100000;
    Eep{ii}=find(ldbDist<ldbDis);
    %     if ii==Eep{ii}
    %         Eep{ii}=[];
    if ~isempty(Eep{ii})
        if ii==Eep{ii}(1)
            Eep{ii}=Eep{ii}(Eep{ii}~=ii); % toegevoegd (voor een ldb met louter losse punten), bij fouten deze regels disablen en regels hierboven enablen!
        end
    end    
end
cwaitbar([2 10/12]);

ldbGlueCell=ldbCell;
for jj=1:length(Eep)
    if ~isempty(Eep{jj})
        ldbGlueCell{Eep{jj}(1)}=[ldbGlueCell{Eep{jj}(1)}; flipud(ldbGlueCell{jj})];
        ldbBegin(Eep{jj}(1),:)=ldbGlueCell{Eep{jj}(1)}(1,:);
        ldbEnd(Eep{jj}(1),:)=ldbGlueCell{Eep{jj}(1)}(end,:);
        ldbGlueCell{jj}=[];
    end
end
cwaitbar([2 11/12]);

ldbBegin(cellfun('isempty',ldbGlueCell),:)=[];
ldbEnd(cellfun('isempty',ldbGlueCell),:)=[];
ldbGlueCell(cellfun('isempty',ldbGlueCell))=[];
ldbCell=ldbGlueCell;

if ~isstruct(ldb)
    outLDB=rebuildLdb(ldbGlueCell);
else
    outLDB.ldbCell=ldbCell;
    outLDB.ldbBegin=ldbBegin;
    outLDB.ldbEnd=ldbEnd;
end
cwaitbar([2 12/12]);
