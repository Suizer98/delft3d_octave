function ITHK_writeGKL(filename, locs, ray_file)
%write GKL : Writes a unibest global wave climate file
%
%   Syntax:
%     function ITHK_writeGKL(filename, locs, ray_file)
% 
%   Input:
%     filename             string with output filename
%     locs                 string of polygon or [Nx2] matrix with x,y values
%     ray_file             string with name of the ray-file (either {Nx1} cellstr or 1 string (then a number is added automatically))
%  
%   Output:
%     .gkl file
%
%   Example:
%     ITHK_writeGKL('test.gkl', 'test.ldb', 'zeeland')
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

% $Id: ITHK_writeGKL.m 6382 2012-06-12 16:00:17Z boer_we $
% $Date: 2012-06-13 00:00:17 +0800 (Wed, 13 Jun 2012) $
% $Author: boer_we $
% $Revision: 6382 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ITHK/Matlab/preprocessing/operations/OLD/ITHK_writeGKL.m $
% $Keywords: $


%-----------Write data to file--------------
%-------------------------------------------
err=0;
if isstr(locs)
    dta1=readldb(locs);
    dta2=[dta1.x dta1.y];
elseif isnumeric(locs)
    dta2=locs;
else
    % error if 'locs' is not numeric nor a string
    err=1;
end

% error if cellstr length is smaller than length of outputlocs
% error if 'ray_file' is not a string nor a cellstr
if iscellstr(ray_file)
    if length(ray_file)<size(dta2,1)
        err=1;
    end    
elseif ~isstr(ray_file)
    err=1;
end

if err==0
    fid = fopen(filename,'wt');
    fprintf(fid,'%s\n','Number of Climates');
    fprintf(fid,'%s\n', num2str(size(dta2,1)));
    fprintf(fid,'%s\n','      Xw      Yw      .RAY');
    for i=1:size(dta2,1)
        if iscellstr(ray_file)
            fprintf(fid,'  %12.4f  %12.4f   ''%s'' \n',dta2(i,1:2), [ray_file{i}]);
        else
            fprintf(fid,'  %12.4f  %12.4f   ''%s'' \n',dta2(i,1:2), [ray_file,num2str(i,'%02.0f')]);
        end
    end
    fclose(fid);
else
    fprintf(' warning: input incorrectly specified!')
end

