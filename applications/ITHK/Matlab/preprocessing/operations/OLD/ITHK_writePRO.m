function [err_message] = ITHK_writePRO(x1,y1,z_dynamicboundary, filename , varargin)
%write PRO : Writes a unibest profile file (also computes location of shoreline, dynamic boundary and grid settings)
%
%   Syntax:
%     function crossdist = ITHK_writePRO(x1,y1,z_dynamicboundary, filename, reference_level, dx)
% 
%   Input:
%     X                    [1xN] vector with x coordinates
%     Y                    [1xN] vector with y coordinates
%     z_dynamicboundary    depth at which dynamic boudnary is defined
%     filename             string with filename
%     reference_level      (optional) reference level (default = 0)
%     dx                   (optional) spatial grid of discretisation in x-direction (default at 200 grid-points)
% 
%   Output:
%     .pro files
%
%   Example:
%     [err_message] = ITHK_writePRO(x1,y1,z_dynamicboundary, filename)
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

% $Id: ITHK_writePRO.m 6382 2012-06-12 16:00:17Z boer_we $
% $Date: 2012-06-13 00:00:17 +0800 (Wed, 13 Jun 2012) $
% $Author: boer_we $
% $Revision: 6382 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ITHK/Matlab/preprocessing/operations/OLD/ITHK_writePRO.m $
% $Keywords: $


%------------Read input data----------------
%-------------------------------------------
if nargin>5
    reference_level   = varargin{1};
    dx                = varargin{2};
elseif nargin>4
    reference_level   = varargin{1};
    dx=ceil((max(x1)-min(x1))/200);    
else
    reference_level   = 0;
    dx=ceil((max(x1)-min(x1))/200);
end

if size(x1,2)>size(x1,1)
    x1=x1';
end
if size(y1,2)>size(y1,1)
    y1=y1';
end
err_message='';

%------------Analyse profile----------------
%-------------------------------------------
% determine location of MSL-shoreline -> Define x-location of shoreline as x=0
xoffset = find0crossing(x1,y1);
x1 = x1 - xoffset;
% define coast landwards
xdiep = x1(find(y1==max(y1)));
xland = x1(find(y1==min(y1)));
if xland>xdiep
    x1=flipud(x1);
    y1=flipud(y1);
end
% determine location of dynamic boundary
if z_dynamicboundary>max(y1)
    z_dynamicboundary=max(y1)-0.00001;
    fprintf([' ! dynamic boundary reset to ',num2str(z_dynamicboundary,'%2.1f'),'m\n'])
    fprintf([' ! (depth of samples smaller than provided depth of dynamic boundary)\n'])
    err_message=[' ! dynamic boundary reset to ',num2str(z_dynamicboundary,'%2.1f'),'m'];
end
xdynbound = find0crossing(x1,y1,z_dynamicboundary);


%-----------Write data to file--------------
%-------------------------------------------
fid = fopen(filename,'wt');
fprintf(fid,'-1                 (Code X-Direction: +1/-1  Landwards/Seawards)\n');
fprintf(fid,'%3.0f                (reference X-point coastline)\n',0);
fprintf(fid,'%3.0f                (X-point dynamic boundary)\n',xdynbound(1));
fprintf(fid,'%3.0f                (X-point trunction transpor_CFSt)\n',xdynbound(1));
fprintf(fid,'-1                 (Code Z-Direction; +1/-1 Bottom-Level/Depth)\n');
fprintf(fid,'%3.0f                 (Reference level)\n',reference_level);
fprintf(fid,' 2                 (Number of points for Dx)\n');
fprintf(fid,'         X DX\n');
fprintf(fid,'%5.1f  %5.1f\n',[min(x1) dx]);
fprintf(fid,'%5.1f  %5.1f\n',[max(x1) dx]);
fprintf(fid,'%3.0f                 (Number of points for Profile)\n',length(x1));
fprintf(fid,'         X         Depth   (In any order)\n');
fprintf(fid,'%5.1f  %5.1f\n',[x1 y1]');
fclose(fid);