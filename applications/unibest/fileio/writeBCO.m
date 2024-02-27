function writeBCO(filename, bco_left, bco_right)
%write BCO : Writes a unibest boundary condition file
%
%   Syntax:
%     function writeBCO(filename, bco_left, bco_right)
% 
%   Input:
%     filename             string with filename
%     bco_left             left boundary
%     bco_right            right boundary
%                          specify type of boundary with a cell:
%                          - fixed Y                       {1}
%                          - fixed coast angle             {2}
%                          - Qs constant                   {3, transport}     [transport in m3/yr]
%                          - tab-file                      {4, tabfile_no, column}     (e.g. column 2 in 'tab003.tab' -> tabfile_no = 3, column = 2)
%  
%   Output:
%     .bco file
%
%   Example:
%     writeBCO('test.bco', {1}, {3, -10000})
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

% $Id: writeBCO.m 8631 2013-05-16 14:22:14Z heijer $
% $Date: 2013-05-16 22:22:14 +0800 (Thu, 16 May 2013) $
% $Author: heijer $
% $Revision: 8631 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/unibest/fileio/writeBCO.m $
% $Keywords: $

%-----------Write data to file--------------
%-------------------------------------------
fid = fopen(filename,'wt');

fprintf(fid,'Boundary conditions\n');

fprintf(fid,'Left side\n');
fprintf(fid,'         Type      Qs[k(m3/y)]    Nr. File       Column\n');
if bco_left{1}<3; %Yconst / %coast angle const
    fprintf(fid,'%12.0f %12.0f %12.0f %12.0f\n',[bco_left{1}, 0, 0, 0]);
elseif bco_left{1}==3; %Qs const
    fprintf(fid,'%12.0f %12.0f %12.0f %12.0f\n',[bco_left{1}, bco_left{2}, 0, 0]);
elseif bco_left{1}==4; %tabfile
    fprintf(fid,'%12.0f %12.0f %12.0f %12.0f\n',[bco_left{1}, 0, bco_left{2}, bco_left{3}]);
else
    fprintf('\n warning: incorrectly specified input parameters!\n');
end

fprintf(fid,'Right side\n');
fprintf(fid,'         Type      Qs[k(m3/y)]    Nr. File       Column\n');
if bco_right{1}<3; %Yconst / %coast angle const
    fprintf(fid,'%12.0f %12.0f %12.0f %12.0f\n',[bco_right{1}, 0, 0, 0]);
    fclose(fid);
elseif bco_right{1}==3; %Qs const
    fprintf(fid,'%12.0f %12.0f %12.0f %12.0f\n',[bco_right{1}, bco_right{2}, 0, 0]);
    fclose(fid);
elseif bco_right{1}==4; %tabfile
    fprintf(fid,'%12.0f %12.0f %12.0f %12.0f\n',[bco_right{1}, 0, bco_right{2}, bco_right{3}]);
    fclose(fid);
else
    fprintf('\n warning: incorrectly specified input parameters!\n');
end
