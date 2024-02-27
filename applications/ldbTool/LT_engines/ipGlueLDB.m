function outLDB=ipGlueLDB(ldb)
%IPGLUELDB Connects segments of a landboundary
%
% IPGLUELDB connects identical start points, identical start and end points
% and identical end points of ldb segments. 
% Very useful to apply on output of dxf2tek because of the strong 
% reduction of the number of ldb segments of the dxf2tek-output (which
% slows down superGlueLDB). After ipGlueLDB, glueLDB or superGlueLDB may be
% applied to finish the job!
%
% Syntax:
% outLDB=ipGlueLDB(ldb)
%
% ldb:      the landboury, which should already be specified by the 
%           function ldb=landboundary('read','landboundary')
% outLDB:   output landboundary
%
% See also: LDBTOOL, GLUELDB, SUPERGLUELDB

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
  
     [ldbCell, ldbBegin, ldbEnd]=disassembleLdb(ldb);
     
else
    ldbCell=ldb.ldbCell;
    ldbBegin=ldb.ldbBegin;
    ldbEnd=ldb.ldbEnd;
    
end


numOfCell=0
while numOfCell~=length(ldbCell)
    numOfCell=length(ldbCell);
    ldbEmpt=1;
    while find(ldbEmpt)
        disp(['Checking for identical start and end points...']);tic;
        [dum,ia,ib]=intersect(ldbBegin,ldbEnd,'rows');
        for ii=1:length(ia)
            if ia(ii)~=ib(ii)
                ldbCell{ia(ii)}=[ldbCell{ib(ii)}; ldbCell{ia(ii)}];
                ldbBegin(ia(ii),:)=ldbCell{ia(ii)}(1,:);
                ldbEnd(ia(ii),:)=ldbCell{ia(ii)}(end,:);    
                ia(ia==ib(ii))=ia(ii);
                ldbCell{ib(ii)}=[];
            end
        end
        ldbEmpt = cellfun('isempty',ldbCell);
        ldbCell=ldbCell(ldbEmpt==0);
        ldbBegin=ldbBegin(ldbEmpt==0,:);
        ldbEnd=ldbEnd(ldbEmpt==0,:);
        t=toc;
        disp([num2str(length(find(ldbEmpt))) ' segments glued']);
    end
    
    ldbEmpt=1;
    while find(ldbEmpt)
        disp(['Checking for identical start and start points...']);tic;
        [dum,ia,ib]=unique(ldbBegin,'rows');
        for ii=1:length(ib)
            id=find(ib(ii+1:end)==ib(ii))+ii;
            if ~isempty(id)
                id=id(1);
                ldbCell{ii}=[flipud(ldbCell{ii}); ldbCell{id}];
                ldbBegin(ii,:)=ldbCell{ii}(1,:);
                ldbEnd(ii,:)=ldbCell{ii}(end,:);
                ldbCell{id}=[];
            end
        end
        ldbEmpt = cellfun('isempty',ldbCell);
        ldbCell=ldbCell(ldbEmpt==0);
        ldbBegin=ldbBegin(ldbEmpt==0,:);
        ldbEnd=ldbEnd(ldbEmpt==0,:);
        t=toc;
        disp([num2str(length(find(ldbEmpt))) ' segments glued']);
    end
    
    ldbEmpt=1;
    while find(ldbEmpt)
        disp(['Checking for identical end and end points...']);tic;
        [dum,ia,ib]=unique(ldbEnd,'rows');
        for ii=1:length(ib)
            id=find(ib(ii+1:end)==ib(ii))+ii;
            if ~isempty(id)
                id=id(1);
                ldbCell{ii}=[ldbCell{ii}; flipud(ldbCell{id})];
                ldbBegin(ii,:)=ldbCell{ii}(1,:);
                ldbEnd(ii,:)=ldbCell{ii}(end,:);
                ldbCell{id}=[];
            end
        end
        ldbEmpt = cellfun('isempty',ldbCell);
        ldbCell=ldbCell(ldbEmpt==0);
        ldbBegin=ldbBegin(ldbEmpt==0,:);
        ldbEnd=ldbEnd(ldbEmpt==0,:);
        t=toc;
        disp([num2str(length(find(ldbEmpt))) ' segments glued']);
    end
end

if ~isstruct(ldb)
    outLDB=rebuildLdb(ldbCell);
else
    outLDB.ldbCell=ldbCell;
    outLDB.ldbBegin=ldbBegin;
    outLDB.ldbEnd=ldbEnd;
end