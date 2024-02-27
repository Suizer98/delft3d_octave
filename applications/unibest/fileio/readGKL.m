function [GKLdata]=readGKL(GKLfilename)
%read GKL : Reads a UNIBEST gkl-file
%   
%   Syntax:
%     function  [GKLdata]=readGKL(GKLfilename)
%          or : [x,y,rayfiles]=readGKL(GKLfilename)
%   
%   Input:
%     GKLfilename         String with filename of gkl-file
%   
%   Output:
%     GKLdata
%             .x          X-coordinate of ray in CL-model
%             .y          Y-coordinate of ray in CL-model
%             .ray_file   String with reference to a ray file
%   
%   Example:
%     [GKLdata]=readGKL('test.gkl')
%   
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Deltares
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
% Created: 14 Apr 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: readGKL.m 17266 2021-05-07 08:01:51Z huism_b $
% $Date: 2021-05-07 16:01:51 +0800 (Fri, 07 May 2021) $
% $Author: huism_b $
% $Revision: 17266 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/unibest/fileio/readGKL.m $
% $Keywords: $

fid=fopen(GKLfilename);

%Read comment line
lin=fgetl(fid);
% Read number of locations
lin=fgetl(fid);
nloc=strread(lin,'%d');
%Read comment line
lin=fgetl(fid);
if isempty(nloc)
    error('Error reading 2nd line of LOC, number of locations. Reserve at least 10 characters for this number!');
    return
end


x=[];
y=[];
ray_file={};

%Read data
for i=1:nloc
   lin = fgetl(fid);
   [x(i) y(i) ray_file(i) ]=strread(lin,'%f%f%s');
   ray_file{i}=regexprep(ray_file{i},'''','');
end
fclose(fid);

[pathnm,filenm,extnm]=fileparts(GKLfilename);

GKLdata = struct;
GKLdata.filenm = [filenm,extnm];
GKLdata.pathnm = pathnm;
GKLdata.x = x;
GKLdata.y = y;
GKLdata.ray_file = ray_file;
