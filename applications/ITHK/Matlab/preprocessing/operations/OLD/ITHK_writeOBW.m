function ITHK_writeOBW(filename, varargin)
%write OBW : Creates an OBW-file
%
%   Syntax:
%     function ITHK_writeOBW(filename, locations, localrays)
% 
%   Input:
%     filename             string with output filename
%     locations            (optional) cellstring with location of OBWs {[A_x1,A_y2,A_x2,A_y2],[B_x1,B_y2,B_x2,B_y2], etc}
%     localrays            (optional) cellstring with local rays for each OBW (leave empty if no local rays) { { }, {10,2,'Bray1';12,1,'Bray2'} }
% 
%   Output:
%     .obw file
%
%   Example:
%     ITHK_writeOBW('test.obw', {[100,200,400,200],[600,150,700,150]}, {{},{600,50,'ray1';750,50,'ray2'}})
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

% $Id: ITHK_writeOBW.m 6382 2012-06-12 16:00:17Z boer_we $
% $Date: 2012-06-13 00:00:17 +0800 (Wed, 13 Jun 2012) $
% $Author: boer_we $
% $Revision: 6382 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ITHK/Matlab/preprocessing/operations/OLD/ITHK_writeOBW.m $
% $Keywords: $

%-----------Write data to file--------------
%-------------------------------------------

err=0;
if nargin==1
    locations = {};
    localrays = {};
elseif nargin==2
    locations = varargin{1};
    for ii=1:length(locations)
        localrays{ii}={};
    end
elseif nargin==3
    locations = varargin{1};
    localrays = varargin{2};
else
    fprintf('\n Number of input parameters is incorrect!\n')
    err=1;
end

if err==0
    fid = fopen(filename,'wt');
    no_obws = length(locations);
    fprintf(fid,'Offshore breakwaters\n');
    fprintf(fid,'%1.0f\n',no_obws);
    for ii=1:no_obws
        fprintf(fid,'   Xw1      Yw1       Xw2       Yw2\n');
        fprintf(fid,' %9.2f %9.2f %9.2f %9.2f\n',locations{ii}(1),locations{ii}(2),locations{ii}(3),locations{ii}(4));
        if ~isempty(localrays{ii})
            fprintf(fid,'   ''LOCAL''\n');
            fprintf(fid,'   NUMBER OF TRANSPORT POINTS\n');
            fprintf(fid,'      %2.0f\n',size(localrays{ii},1));
            fprintf(fid,'      Xw        Yw        .RAY\n');
            for jj=1:size(localrays{ii},1);
                fprintf(fid,'      %9.2f  %9.2f  %s\n',localrays{ii}{jj,1},localrays{ii}{jj,2},localrays{ii}{jj,3});
            end
        end
        fprintf(fid,'''END''\n');
    end
    fclose(fid);
end
