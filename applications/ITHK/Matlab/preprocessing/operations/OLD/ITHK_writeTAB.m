function ITHK_writeTAB(filename, TABdata)
%write TAB : Writes a unibest TAB file
%
%   Syntax:
%     function ITHK_writeTAB(filename, time, qsblock)
% 
%   Input:
%     filename             string with output filename
%     TABdata              strcuture with the following fields:
%         .time            array [Nx1] with time fields
%         .qsblock         array [NxM] with nourishment rate (m3/yr) for each time field.
%                          Each column contains the data for a seperate source.
%  
%   Output:
%     .TAB file
%
%   Example:
%     ITHK_writeTAB('test.TAB', [1:100]' , rand(100,3))
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

% $Id: ITHK_writeTAB.m 6497 2012-06-21 08:17:27Z huism_b $
% $Date: 2012-06-21 16:17:27 +0800 (Thu, 21 Jun 2012) $
% $Author: huism_b $
% $Revision: 6497 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ITHK/Matlab/preprocessing/operations/OLD/ITHK_writeTAB.m $
% $Keywords: $

%% Write header of file
fid = fopen(filename,'wt');
fprintf(fid,'%1.0f\n',size(TABdata.qsblock,2));
fprintf(fid,'%1.0f\n',size(TABdata.qsblock,1));
fprintf(fid,'TIME');
for ii=1:size(TABdata.qsblock,2)
    fprintf(fid,['COL_',num2str(ii)]);
end
fprintf(fid,['\n']);

%% Write sources and sinks
for ii=1:size(TABdata.qsblock,1)
    fprintf(fid,'%8.2f ',TABdata.time(ii));
    for jj=1:size(TABdata.qsblock,2)
        fprintf(fid,'%10.0f ',TABdata.qsblock(ii,jj));
    end
    fprintf(fid,'\n');
end
fclose(fid);
