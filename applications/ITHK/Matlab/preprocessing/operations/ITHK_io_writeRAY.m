function ITHK_io_writeRAY(inhoudRAY)
%write RAY : Writes a RAY file
%
%   Syntax:
%     function ITHK_io_writeRAY(inhoudRAY)
% 
%   Input:
%     inhoudRAY       struct with contents of ray file
%                     .name    :  cell with filenames
%                     .path    :  cell with path of files
%                     .info    :  cell with header info of RAY file (e.g. pro-file used)
%                     .equi    :  equilibrium angle degrees relative to 'hoek'
%                     .c1      :  coefficient c1 [-] (used for scaling of sediment transport of S-phi curve)
%                     .c2      :  coefficient c2 [-] (used for shape of S-phi curve)
%                     .h0      :  active height of profile [m]
%                     .hoek    :  coast angle specified in LT computation
%                     .fshape  :  shape factor of the cross-shore distribution of sediment transport [-]
%                     .Xb      :  coastline point [m]
%                     .perc2   :  distance from coastline point beyond which 2% of transport is located [m]
%                     .perc20  :  distance from coastline point beyond which 20% of transport is located [m]
%                     .perc50  :  distance from coastline point beyond which 50% of transport is located [m]
%                     .perc80  :  distance from coastline point beyond which 80% of transport is located [m]
%                     .perc100 :  distance from coastline point beyond which 100% of transport is located [m] 
% 
%   Output:
%     .ray files
%
%   Example:
%     inhoudRAY = readRAY('test.ray')
%     ITHK_io_writeRAY(inhoudRAY);
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

% $Id: ITHK_io_writeRAY.m 6477 2012-06-19 16:44:39Z huism_b $
% $Date: 2012-06-20 00:44:39 +0800 (Wed, 20 Jun 2012) $
% $Author: huism_b $
% $Revision: 6477 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ITHK/Matlab/preprocessing/operations/ITHK_io_writeRAY.m $
% $Keywords: $

for ii=1:length(inhoudRAY.name)
    fid4 = fopen([inhoudRAY.path{ii},'\',char(inhoudRAY.name{ii})],'wt');
    for iii=1:6
        fprintf(fid4,'%s\n',inhoudRAY.info{ii,iii});
    end
    fprintf(fid4,'    equi      c1     c2   h0    angle   fshape\n');
    fprintf(fid4,'%8.2e %12.8f %8.4f %5.1f %9.2f %9.2f\n',[inhoudRAY.equi(ii) inhoudRAY.c1(ii) inhoudRAY.c2(ii) inhoudRAY.h0(ii) inhoudRAY.hoek(ii) inhoudRAY.fshape(ii)]);
    fprintf(fid4,'       Xb      2 %%      20%%      50%%      80%%     100%%\n');
    fprintf(fid4,'%9.1f %9.1f %9.1f %9.1f %9.1f %9.1f\n',[inhoudRAY.Xb(ii) inhoudRAY.perc2(ii) inhoudRAY.perc20(ii) inhoudRAY.perc50(ii) inhoudRAY.perc80(ii) inhoudRAY.perc100(ii)]);
    fclose(fid4);
end
