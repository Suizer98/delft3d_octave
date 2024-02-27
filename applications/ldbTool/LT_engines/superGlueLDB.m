function outLDB=superGlueLDB(ldbDis,ldb,hW)
%SUPERGLUELDB Connect ldb segments based on threshold distance
%
% SUPERGLUELDB has the same funcationality as GLUELDB, but a more advanced
% gluing method is used, which is also much more time consuming. The tool 
% can be used to connect segments in a landboundary to each other, when the 
% distance between the start/end points of the segments is lower than the 
% specified threshold distance. Because after glueing two segments to each 
% other, the landboundary changes, it will not always to be able to connnect 
% all segments that should be connected. In that case repeat SUPERGLUELDB. 
% Repeatedly calling this routine can be automized by using ULTRAGLUELDB.
%
% Syntax:
% outLDB=superGlueLDB(ldbDis,ldb)
%
% ldbDis:   [dis1 dis2 dis3 .... disN] (N = number of iterations)
% inLdb:    landboundary to be glued [Mx2]
%
% See also: LDBTOOL, ULTRAGLUELDB, GLUELDB, GLUELDB, IPGLUELDB

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

ldbGlueCell=ldbCell;

hhW=get(hW,'Children');
set(get(hhW(2),'Title'),'String','Progress of current pass - sub-session 1/3');
for jj=1:size(ldbBegin,1)
    if jj>size(ldbBegin,1)
        break
    end
    %first look for similarity between begin and end-points
    
    for ii=1:size(ldbBegin,1)
        ldbDist=sqrt((ldbEnd(:,1)-ldbBegin(ii,1)).^2+(ldbEnd(:,2)-ldbBegin(ii,2)).^2);
        Bep{ii}=find(ldbDist<ldbDis);
        for kk=1:length(Bep{ii})
            if kk>length(Bep{ii})
                break
            end
            %             if ii==Bep{ii}(kk)
            %                 Bep{ii}(kk)=[];
            %             end
            if ~isempty(Bep{ii})
                if ii==Bep{ii}(1)
                    Bep{ii}=Bep{ii}(Bep{ii}~=ii); % toegevoegd (voor een ldb met louter losse punten), bij fouten deze regels disablen en regels hierboven enablen!
                end
            end
        end
    end
    
    if ~isempty(Bep{jj})
        ldbGlueCell{Bep{jj}(1)}=[ldbGlueCell{Bep{jj}(1)}; ldbGlueCell{jj}];
        ldbEnd(Bep{jj}(1),:)=ldbGlueCell{Bep{jj}(1)}(end,:);
        ldbBegin(Bep{jj}(1),:)=ldbGlueCell{Bep{jj}(1)}(1,:);
        ldbGlueCell{jj}=[];
        ldbBegin(jj,:)=[nan nan];
        ldbEnd(jj,:)=[nan nan];    
    end
    
    cwaitbar([2 jj/size(ldbBegin,1)]);
end
ldbEnd(cellfun('isempty',ldbGlueCell),:)=[];
ldbBegin(cellfun('isempty',ldbGlueCell),:)=[];
ldbGlueCell(cellfun('isempty',ldbGlueCell))=[];

clear id;

hhW=get(hW,'Children');
set(get(hhW(2),'Title'),'String','Progress of current pass - sub-session 2/3');

for jj=1:size(ldbBegin,1)
    if jj>size(ldbBegin,1)
        break
    end
    %now for similar begin points
    for ii=1:size(ldbBegin,1)
        ldbDist=sqrt((ldbBegin(:,1)-ldbBegin(ii,1)).^2+(ldbBegin(:,2)-ldbBegin(ii,2)).^2);
        ldbDist(ii)=nan;
        Bbp{ii}=find(ldbDist<ldbDis);
    end
    
    if ~isempty(Bbp{jj})
        ldbGlueCell{jj}=[flipud(ldbGlueCell{jj}) ; ldbGlueCell{Bbp{jj}(1)}];
        ldbEnd(jj,:)=ldbGlueCell{jj}(end,:);
        ldbBegin(jj,:)=ldbGlueCell{jj}(1,:);
        ldbGlueCell{Bbp{jj}(1)}=[];
        ldbBegin(Bbp{jj}(1),:)=[nan nan];
        ldbEnd(Bbp{jj}(1),:)=[nan nan]; 
    end
    
    cwaitbar([2 jj/size(ldbBegin,1)]);
end

ldbBegin(cellfun('isempty',ldbGlueCell),:)=[];
ldbEnd(cellfun('isempty',ldbGlueCell),:)=[];
ldbGlueCell(cellfun('isempty',ldbGlueCell))=[];

clear id;

hhW=get(hW,'Children');
set(get(hhW(2),'Title'),'String','Progress of current pass - sub-session 3/3');

for jj=1:size(ldbBegin,1)
    if jj>size(ldbBegin,1)
        break
    end
    %now for similar end points
    for ii=1:size(ldbEnd,1)
        ldbDist=sqrt((ldbEnd(:,1)-ldbEnd(ii,1)).^2+(ldbEnd(:,2)-ldbEnd(ii,2)).^2);
        ldbDist(ii)=nan;
        Eep{ii}=find(ldbDist<ldbDis);
    end
    
    if ~isempty(Eep{jj})
        ldbGlueCell{jj}=[ldbGlueCell{Eep{jj}(1)} ; flipud(ldbGlueCell{jj})];
        ldbEnd(jj,:)=ldbGlueCell{jj}(end,:);
        ldbBegin(jj,:)=ldbGlueCell{jj}(1,:);
        ldbGlueCell{Eep{jj}(1)}=[];
        ldbBegin(Eep{jj}(1),:)=[nan nan];
        ldbEnd(Eep{jj}(1),:)=[nan nan];         
    end
    
    cwaitbar([2 jj/size(ldbBegin,1)]);
end

ldbBegin(cellfun('isempty',ldbGlueCell),:)=[];
ldbEnd(cellfun('isempty',ldbGlueCell),:)=[];
ldbGlueCell(cellfun('isempty',ldbGlueCell))=[];

if ~isstruct(ldb)
    outLDB=rebuildLdb(ldbGlueCell);
else
    outLDB.ldbCell=ldbGlueCell;
    outLDB.ldbBegin=ldbBegin;
    outLDB.ldbEnd=ldbEnd;
end