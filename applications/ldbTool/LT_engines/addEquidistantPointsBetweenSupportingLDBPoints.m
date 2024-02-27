function outLDB=addEquidistantPointsBetweenSupportingLDBPoints(dx,ldb)
%ADDEQUIDISTANTPOINTSBETWEENSUPPORTINGLDBPOINTS Increase resolution of ldb
%
% This tools adds new point between original ldb points at specified the
% resolution.
%
% Syntax:
% out=addEquidistantPointsBetweenSupportingLDBPoints(dx,ldb)
%
% ldb   input landboundary, [Mx2] matrix
% dx    required resolution of ldb
% out   resulting landboundary, [Mx2] matrix
%
% See also: LDBTOOL, THINOUTLDB

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


for cc=1:length(ldbCell)
    
    in=ldbCell{cc};
    out=[];
    
    for ii=1:size(in,1)-1
        
        %Determine distance between two points 
        dist=sqrt((in(ii+1,1)-in(ii,1)).^2 + (in(ii+1,2)-in(ii,2)).^2);
        
        ox=interp1([0 dist],in(ii:ii+1,1),0:dx:dist)';
        oy=interp1([0 dist],in(ii:ii+1,2),0:dx:dist)';

        out=[out ; [ox oy]];
        
    end
    
    outCell{cc}=[out; in(end,:)];
    
end

out=rebuildLdb(outCell);

if ~isstruct(ldb)
    outLDB=rebuildLdb(outCell);
else
    outLDB.ldbCell=outCell;
    outLDB.ldbBegin=ldbBegin;
    outLDB.ldbEnd=ldbEnd;
end