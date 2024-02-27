function GROdata = readGRO(filename)
%GROdata = readGRO(filename)
%Writes a unibest groyne file
%
%   Syntax:
%     function readGRO(filename)
% 
%   Input:
%     filename             string with output filename
%     xy                   xy values ([Nx2] matrix or string with filename), note: if xy is empty, it is not required to specify parameters below (i.e. Yoffset, BlockPerc, Yreference)
%     Ycross               cross-shore distance of groyne ([Nx1] matrix in meters)
%     BlockPerc            blocking percentage ([Nx1] matrix in percentages)
%     Yreference           reference of Ycross ([Nx1] matrix with 0 = relative to shoreline (i.e. y(t)) and 1 = absolute, i.e. relative to reference line)
%     option               type of local rays (1= no rays, 2=between&right, 3=right, 4=left, 5=left&right, 6=between)
%  
%   Output:
%     GROdata              structure
%           .filename             string with output filename
%           .Xw                   x values for each groyne ([Nx1] matrix in meters)
%           .Yw                   x values for each groyne ([Nx1] matrix in meters)
%           .Length               cross-shore distance of groyne ([Nx1] matrix in meters)
%           .BlockPerc            blocking percentage ([Nx1] matrix in percentages)
%           .Yreference           reference of groyne ([Nx1] matrix with 0 = relative to shoreline (i.e. y(t)) and 1 = absolute, i.e. relative to reference line)
%           .option               type of local rays (1= no rays, 2=between&right, 3=right, 4=left, 5=left&right, 6=between)
%           .xy1                  cell with x,y coordinates of local rays [m] for each groyne
%           .ray_file1            cellstring with local ray filenames for each groyne
%
%   Example:
%     GROdata = readGRO('test.gro')
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

% $Id: readGRO.m 17266 2021-05-07 08:01:51Z huism_b $
% $Date: 2021-05-07 16:01:51 +0800 (Fri, 07 May 2021) $
% $Author: huism_b $
% $Revision: 17266 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/unibest/fileio/readGRO.m $
% $Keywords: $

%-----------Read data of groynes------------
%-------------------------------------------
if ~exist(filename,'file')
    fprintf('Error : Filename for groyne not found!\n');
    return
end
    
GROdata=struct;
fid = fopen(filename,'rt');
line1 = fgetl(fid);
line2 = fgetl(fid);
number_of_groynes = str2double(line2);

for ii=1:number_of_groynes
    line3 = fgetl(fid);
    line4 = fgetl(fid);
    [GROdata(ii).Xw,GROdata(ii).Yw,GROdata(ii).Length,GROdata(ii).BlockPerc,GROdata(ii).Yreference] = strread(line4,'%f %f %f %f %f','delimiter',' ');
    GROdata(ii).option='';
    
    line5 = fgetl(fid);
    while isempty(strfind(lower(line5),'end'));
        if ~isempty(strfind(lower(line5),'between')) || ~isempty(strfind(lower(line5),'left')) || ~isempty(strfind(lower(line5),'right'))
            id = findstr(line5,'''');
            SIDEstr = lower(line5(id(1)+1:id(2)-1));
            if ~isempty(strfind(lower(line5),'between')) || ~isempty(strfind(lower(line5),'left'))
                fieldnmXY = 'xyl';
                fieldnmRAY='ray_file1';
                GROdata(ii).SIDES{1}=upper(SIDEstr);
            else
                fieldnmXY = 'xyr';
                fieldnmRAY='ray_file2';
                GROdata(ii).SIDES{2}=upper(SIDEstr);
            end
            if isempty(GROdata(ii).option)
                GROdata(ii).option=SIDEstr;
            else
                GROdata(ii).option=[GROdata(ii).option,'&',SIDEstr];
            end
            line6 = fgetl(fid);
            line7 = fgetl(fid); number_of_rays1 = str2double(line7);
            line8 = fgetl(fid);
            for iii=1:number_of_rays1
                line9 = fgetl(fid);
                [GROdata(ii).(fieldnmXY)(iii,1),GROdata(ii).(fieldnmXY)(iii,2),rayfile] = strread(line9,'%f %f %s','delimiter',' ');
                rayfile = rayfile{1}(2:end-1);
                GROdata(ii).(fieldnmRAY){iii}=rayfile;
            end
        end
        line5 = fgetl(fid);
    end
end
fclose(fid);
