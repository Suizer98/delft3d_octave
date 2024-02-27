function outLDB=addEquidistantPointsBetweenSupportingLDBPoints(dx,ldb)
%addEquidistantPointsBetweenSupportingLDBPoints - does what it says
%
%   Syntax:
%     outLDB=addEquidistantPointsBetweenSupportingLDBPoints(dx,ldb)
% 
%   Input:
%     ldb          coordinates of landboundary points ([Nx2] vector)
%     dx           distance between points
% 
%   Output:
%     outLDB       coordinates of densified landboundary points ([Nx2] vector)
%   
%   Example:
%     outLDB=addEquidistantPointsBetweenSupportingLDBPoints(1,[30,1000;1000,2000]);
%     
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       Arjan Mol, Robin Morelissen, Bas Huisman
%
%       bas.huisman@deltares.nl	
%
%       Deltares
%       Rotterdamseweg 185
%       PO Box Postbus 177
%       2600MH Delft
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 16 Sep 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: add_equidist_points.m 3258 2012-01-24 15:02:48Z huism_b $
% $Date: 2012-01-24 16:02:48 +0100 (Tue, 24 Jan 2012) $
% $Author: huism_b $
% $Revision: 3258 $
% $HeadURL: https://repos.deltares.nl/repos/mctools/trunk/matlab/applications/UNIBEST_CL/engines/add_equidist_points.m $
% $Keywords: $

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
    outCell{cc}=out;
end

out=rebuildLDB(outCell);

if ~isstruct(ldb)
    outLDB=rebuildLDB(outCell);
else
    outLDB.ldbCell=outCell;
    outLDB.ldbBegin=ldbBegin;
    outLDB.ldbEnd=ldbEnd;
end