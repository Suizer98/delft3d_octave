function replaceC1andC2(filedata,C1,C2,newdir)
%ReplaceC1andC2.m replaces the C1 and C2 coefficients of a ray file with new c1 and c2 coefficients.
%The new ray-files are written to a new directory (newdir)
%
%   Syntax:
%     function replaceC1andC2(filedata,C1,C2,newdir)
% 
%   Input:
%   filedata       cell with ray-files
%   C1             array with new C1 values
%   C2             array with new C2 values
%   newdir         outputpath
%  
%   Output:
%     .ray file
%
%   Example:
%     replaceC1andC2({'test1.ray','test2.ray'},[0.02;0.01],[0.1;0.3],'newC1andC2\')
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       Bas Huisman
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

% $Id: replaceC1andC2.m 2849 2010-10-01 08:30:33Z huism_b $
% $Date: 2010-10-01 10:30:33 +0200 (Fri, 01 Oct 2010) $
% $Author: huism_b $
% $Revision: 2849 $
% $HeadURL: https://repos.deltares.nl/repos/mctools/trunk/matlab/applications/UNIBEST_CL/engines/replaceC1andC2.m $
% $Keywords: $

filedata2={};
if isstr(filedata)
    filedata2={filedata};
elseif iscell(filedata)
    filedata2=filedata;
elseif isstruct(filedata)
    for jj=1:length(filedata)
        filedata2{jj}=filedata(jj).name;
    end
end

if ~exist(newdir,'dir')
    mkdir(newdir);
end

inhoudRAY2=inhoudRAY;
for ii=1:length(filedata)
    inhoudRAY2 = readRAY(filedata2{ii});
    inhoudRAY2.c1(ii) = C1(ii);
    inhoudRAY2.c2(ii) = C2(ii);
    inhoudRAY2.path(ii) = [inhoudRAY2.path(ii),filesep,newdir];
    writeRAY(inhoudRAY2);
end