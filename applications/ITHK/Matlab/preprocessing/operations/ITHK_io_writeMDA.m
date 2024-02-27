function ITHK_io_writeMDA(mda_filename, reference_line, Y1, Y2, griddensity)
%write MDA : Writes a unibest mda-file (also computes cross-shore distance between reference line and shoreline)
%
%   Syntax:
%     function ITHK_io_writeMDA2(mda_filename, reference_line, Y1, Y2, griddensity)
% 
%   Input:
%     mda_filename        string with output filename of mda-file
%     reference_line      string with filename of polygon of reference line  OR  X,Y coordinates of ref.line [Nx2]
%     Y1                  (optional) array with Y1 values (set to Y1=0 if not specified)
%     Y2                  (optional) array with Y2 values (not set if not specified / or leave empty)
%     griddensity         (optional) array with grid density (set to 1 gridcell per reference point if not set)
% 
%   Output:
%     .mda file
%
%   Example:
%     x = [1:10:1000]';
%     y = x.^1.2;
%     ITHK_io_writeMDA2('test.mda', [x,y]);
%     ITHK_io_writeMDA2('test.mda', [x,y], [x*0+20], [x*0]);
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

% $Id: ITHK_io_writeMDA.m 6477 2012-06-19 16:44:39Z huism_b $
% $Date: 2012-06-20 00:44:39 +0800 (Wed, 20 Jun 2012) $
% $Author: huism_b $
% $Revision: 6477 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ITHK/Matlab/preprocessing/operations/ITHK_io_writeMDA.m $
% $Keywords: $


%% Analyse data
if isstr(reference_line) % load baseline
    baseline=landboundary('read',reference_line);
    X=baseline(:,1);
    Y=baseline(:,2);
else
    X=reference_line(:,1);
    Y=reference_line(:,2);
end
if nargin<3
    Y1=zeros(length(X),1);
end
if nargin<4
    Y2 = [];
end
if nargin<5
    griddensity = ones(length(X),1);
end
griddensity(1)=0;

%% Write data to mda-file
fid=fopen(mda_filename,'wt');
fprintf(fid,'%s\n',' BASISPOINTS');
fprintf(fid,'%4.0f\n',length(X));
fprintf(fid,'%s\n','     Xw             Yw             Y              N              Ray');
for ii=1:length(X)
    if ~isempty(Y2)
        if ~isempty(Y2(ii)) && Y2(ii)~=Y1(ii) && ~isnan(Y2(ii))
            fprintf(fid,'%13.2f   %13.2f %10.2f %10.0f %10.0f\n',X(ii),Y(ii),Y1(ii),griddensity(ii),ii);
            fprintf(fid,'%40.2f\n',Y2(ii));
        else
            fprintf(fid,'%13.1f   %13.1f %10.2f %10.0f %10.0f\n',X(ii),Y(ii),Y1(ii),griddensity(ii),ii);
        end
    else
        fprintf(fid,'%13.1f   %13.1f %10.2f %10.0f %10.0f\n',X(ii),Y(ii),Y1(ii),griddensity(ii),ii);
    end
end
fclose(fid);
