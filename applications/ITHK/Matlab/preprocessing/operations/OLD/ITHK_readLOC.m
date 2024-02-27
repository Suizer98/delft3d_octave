function [x,y,angle,rayfiles]=ITHK_readLOC(LOCfilename)
%read LOC : Reads a unibest location input file for coupling file with SWAN
%
%   Syntax:
%     function [x,y,angle,rayfiles]=ITHK_readLOC(LOCfilename)
% 
%   Input:
%     LOCfilename          string with .loc filename
%  
%   Output:
%     x                    x-coordinate of output location
%     y                    y-coordinate of output location
%     angle                coast angle (often not specified, then angle=nan)
%     rayfiles             string with name of output location
%
%   Example
%     ITHK_writeLOC('test.loc', [33203,423000;33845,425500;32393,465023], 'zeeland');
%     [x,y,angle,rayfiles]=ITHK_readLOC('test.loc');
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

% $Id: ITHK_readLOC.m 6382 2012-06-12 16:00:17Z boer_we $
% $Date: 2012-06-13 00:00:17 +0800 (Wed, 13 Jun 2012) $
% $Author: boer_we $
% $Revision: 6382 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ITHK/Matlab/preprocessing/operations/OLD/ITHK_readLOC.m $
% $Keywords: $

%% Read header
fid=fopen(LOCfilename);
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

%% Read data
% check type of loc-file
loctype=0;
try
    [x(1) y(1) angle(1)]=strread(lin,'%f%f%f');
catch loctype=1;
    try
        [x(1) y(1) rayfiles(1)]=strread(lin,'%f%f%s');
    catch
        lin=fgetl(fid);
        [x(1) y(1) rayfiles(1)]=strread(lin,'%f%f%s');
    end
    angle(1,1)=nan;    
end

% read the rest of loc-file
if loctype==0
    lin = fgetl(fid);
    rayfiles{1} = strread(lin,'%s');
    for i=2:nloc
       lin = fgetl(fid);
       [x(ii,1) y(ii,1) angle(ii,1)]=strread(lin,'%f%f%f');
       lin = fgetl(fid);
       rayfiles(ii) = strread(lin,'%s');
    end
elseif loctype==1
    for ii=2:nloc
       lin = fgetl(fid);
       [x(ii,1) y(ii,1) rayfiles(ii)]=strread(lin,'%f%f%s');
       angle(ii,1)=nan;
    end
end
fclose(fid);
