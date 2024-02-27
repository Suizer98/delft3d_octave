function varargout=thinOutLDB(Thresh_Dist, ldb,varargin)
% THINOUTLDB  remove points from polygon
%	
% Returns a landboundary that is thinned out so that every point is
% seperated by at least a distance Thres_Dist. Makes use of REDUCEPOINTS.
%
% Syntax:
% outLDB = thinOutLDB(Thresh_Dist,<ldb>);
% [x,y]  = thinOutLDB(Thresh_Dist,<ldb>);
%
% Thresh_Dist =   threshold distance
% ldb         =   the landboury, as 
%                 * filename or 
%                 * array ldb as read by the ldb=landboundary('read','landboundary')
%                 * struct with fields ldbCell, ldbBegin, ldbEnd
%                 * no 2nd argument launches GUI
%
% outLDB = fillUpLDB(Thresh_Dist,ldb,<ldbout>);
%
% ldbout      =   the landboundary filename to save to
%
% by A.C.S. Mol, 2006 
%
% 2008, June, Gerben de Boer: added option to pass ldb as filename, 
%                             added option to save to another filename
%                             added error message when nargin==0
%
% See also: REDUCEPOINTS, REDUCEPNTSQ, GLUELDB, IPGLUELDB, THINOUTLDB

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
   error('syntax: outLDB=fillUpLDB(Thresh_Dist, <ldb>);')
end

if nargin==1
    if isempty(which('landboundary.m'))
        wlsettings;
    end
    ldb=landboundary('read');
end

if ischar(ldb)
    ldb=landboundary('read',ldb);
end

if isempty(ldb)
    return
end

if ~isstruct(ldb)
    [ldbCell, ldbBegin, ldbEnd, ldbIn]=disassembleLdb(ldb);
else
    ldbCell  = ldb.ldbCell;
    ldbBegin = ldb.ldbBegin;
    ldbEnd   = ldb.ldbEnd;

end

%% thin out (uitdunnen)

for ii=1:length(ldbCell);
    % note reducepoints is in private folder and unknown here. for now, 
    % these functions were copied tot ldbtool engines
    ldbCell{ii} = [ldbCell{ii}(1,:); ldbCell{ii}(1+reducepoints(Thresh_Dist,ldbCell{ii}(2:end-1,1),ldbCell{ii}(2:end-1,2)),:) ; ldbCell{ii}(end,:)];
end

if ~isstruct(ldb)

    %% See also POLYJOIN of matlab mapping toolbox fo action below

    %herbouwen ldb
    ldb=rebuildLdb(ldbCell2);
    
    if nargout==1
       varargout = {ldb};
    elseif nargout==2
       varargout = {ldb(:,1),ldb(:,2)};
    end
    
   if nargin==3
      ldbnameout = varargin{1};
      landboundary('write',ldbnameout,ldb);
   end   
    
else

    if nargout==1
       outLDB.ldbCell  = ldbCell;
       outLDB.ldbBegin = ldbBegin;
       outLDB.ldbEnd   = ldbEnd;
       varargout       = {outLDB};
    elseif nargout==2
       error('Not implemented [x,y] output for isstruct(ldb)')
    end

end

%% EOF