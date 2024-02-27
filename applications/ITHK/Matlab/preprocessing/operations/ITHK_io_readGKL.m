function [x,y,ray_file]=ITHK_io_readGKL(GKLfilename)
%read GKL : Reads a UNIBEST gkl-file
%   
%   Syntax:
%     function [x,y,rayfiles]=ITHK_io_readGKL(GKLfilename)
%   
%   Input:
%     GKLfilename         String with filename of gkl-file
%   
%   Output:
%     x                   X-coordinate of ray in CL-model
%     y                   Y-coordinate of ray in CL-model
%     ray_file            String with reference to a ray file
%   
%   Example:
%     [GKLdata]=ITHK_io_readGKL('test.gkl')
%   
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       Robin Morelissen, Cilia Swinkels, DJR Walstra 2006-2008
%       robin.morelissen@deltares.nl
% 
%       updated and submitted by BJA Huisman 2010
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

% $Id: ITHK_io_readGKL.m 7632 2012-11-04 20:09:08Z boer_we $
% $Date: 2012-11-05 04:09:08 +0800 (Mon, 05 Nov 2012) $
% $Author: boer_we $
% $Revision: 7632 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ITHK/Matlab/preprocessing/operations/ITHK_io_readGKL.m $
% $Keywords: $

fid=fopen(GKLfilename);

%Read comment line
lin=fgetl(fid);
% Read number of locations
lin=fgetl(fid);
nloc=strread(lin,'%d');;
%Read comment line
lin=fgetl(fid);
if isempty(nloc)
    error('Error reading 2nd line of LOC, number of locations. Reserve at least 10 characters for this number!');
    return
end

%Read data
for i=1:nloc
   lin = fgetl(fid);
   [x(i) y(i) ray_file(i) ]=strread(lin,'%f%f%s');
end
fclose(fid);
