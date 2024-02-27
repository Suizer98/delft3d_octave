function outLdb=ultraGlueLDB(ldbDis,inLdb,whichGlue)
%ULTRAGLUELDB Connect ldb segments based on threshold distance
%
% This tool can be used to connect segments in a landboundary to each
% other, when the distance between the start/end points of the segments is
% lower than the specified threshold distance. The routine makes use of two
% glue-engines: glueLdb and superGlueLdb. By specifying an array of ldb
% distances, it will call the specified glue function repeatedly.
%
% Syntax:
% outLdb=ultraGlueLDB(ldbDis,inLdb,whichGlue)
%
% ldbDis:       [dis1 dis2 dis3 .... disN] (N = number of iterations)
% inLdb:        landboundary to be glued [Mx2]
% whichGlue:    's' for super glue, otherwise normal glue will be used
%
% See also: LDBTOOL, SUPERGLUELDB, GLUELDB, IPGLUELDB

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
if nargin==2
    s=0;
else
    if whichGlue=='s'
        s=1;
    else
        s=0;
    end
end

hW=cwaitbar([0 0],{'Progress of total process','Progress of current pass'},{'r','r'});
for iii=1:length(ldbDis)
    switch s
        case 0
            ldb=glueLDB(ldbDis(iii),inLdb,hW);
        case 1
            ldb=superGlueLDB(ldbDis(iii),inLdb,hW);
    end
    inLdb=ldb;
    cwaitbar([1 iii/length(ldbDis)]);
end
outLdb=inLdb;

close(hW);