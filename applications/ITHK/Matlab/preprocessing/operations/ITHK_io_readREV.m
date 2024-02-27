function [REVdata]=ITHK_io_readREV(filename)
%REVdata = readREV(filename)
%Reads a unibest revetment file
%
%   Syntax:
%     function ITHK_io_readREV(filename)
% 
%   Input:
%     filename             string with filename
%
%   Output:
%     REVdata              Mx1 structure (where M correponds to number of )
%           .filename             name of the .REV file
%           .Npoints              number of xy-points for each revetment
%           .Option               option for each revetment
%                                 (0) offset relative to shoreline
%                                 (1) offset relative to reference line
%                                 (2) offset relative to shoreline, automatic landfill for offshore revetment
%                                 (3) offset relative to reference line, automatic landfill for offshore revetment
%           .Xw                   x values for each revetment ([Nx1] matrix in meters)
%           .Yw                   y values for each revetment ([Nx1] matrix in meters)
%           .Top                  cross-shore distance of revetment relative to reference line ([Nx1] matrix in meters)
%           
%   Example:
%     REVdata = ITHK_io_readREV('test.rev')
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Wiebe de Boer
%
%       wiebe.deboer@deltares.nl	
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
% Created: 12 Sep 2011
% Created with Matlab version: 7.11.0 (R2010b)

%-----------Read data of revetments------------
%-------------------------------------------
REVdata=struct;
REVdata.filename = filename;
fid = fopen(filename,'rt');
line = fgetl(fid);
line = fgetl(fid);
number_of_revetments = str2double(line);

for ii=1:number_of_revetments
    line = fgetl(fid);
    while ~isempty(strfind(lower(line),'number'))
        line = fgetl(fid);
        [REVdata(ii).Npoints,REVdata(ii).Option] = strread(line,'%f %f','delimiter',' ');
        line = fgetl(fid);
        for jj=1:REVdata(ii).Npoints
            line = fgetl(fid);
            [REVdata(ii).Xw(jj),REVdata(ii).Yw(jj),REVdata(ii).Top(jj)] = strread(line,'%f %f %f','delimiter',' ');
        end
    end
end
fclose(fid);