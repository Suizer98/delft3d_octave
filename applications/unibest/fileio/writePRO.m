function [err_message] = writePRO(x1,y1,z_dynamicboundary, filename , varargin)
%write PRO : Writes a unibest profile file (also computes location of shoreline, dynamic boundary and grid settings)
%
%   Syntax:
%     function crossdist = writePRO(x1,y1,z_dynamicboundary, filename, <reference_level>, <dx>, <x_dir>)
% 
%   Input:
%     X                    [1xN] vector with x coordinates
%     Y                    [1xN] vector with y coordinates
%     z_dynamicboundary    depth at which dynamic boudnary is defined
%     filename             string with filename
%     <reference_level>    (optional) reference level (default = 0)
%     <dx>                 (optional) spatial grid of discretisation in x-direction (default at 200 grid-points)
%     <x_dir>              (optional) switch for X-direction convention: either 1 (LandWards) or -1 (SeaWards)
% 
%   Output:
%     .pro files
%
%   Example:
%     [err_message] = writePRO(x1,y1,z_dynamicboundary, filename)
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

% $Id: writePRO.m 13439 2017-07-04 19:37:19Z huism_b $
% $Date: 2017-07-05 03:37:19 +0800 (Wed, 05 Jul 2017) $
% $Author: huism_b $
% $Revision: 13439 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/unibest/fileio/writePRO.m $
% $Keywords: $


%------------Read input data----------------
%-------------------------------------------
x_dir=1;
z_truncate=[];
if nargin>=8
    z_truncate=varargin{4};
end
if nargin>=7
    x_dir=varargin{3};
    try
        if x_dir ~= 1 && x_dir ~= -1
            error('Unknown <x_dir> input, please use eather 1 (default) or -1');
        end
    catch
        error('Unknown format for <x_dir> input');
    end
end
if nargin>=6
    reference_level   = varargin{1};
    dx                = varargin{2};
elseif nargin>=5
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
%x1 = x1 - max(xoffset);
try
x1 = x1 - min(xoffset); 
end

% define coast landwards
xdiep = x1(find(y1==max(y1),1));
xland = x1(find(y1==min(y1),1));
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
if isempty(z_truncate)
    z_truncate=z_dynamicboundary;
end
xdynbound = find0crossing(x1,y1,z_dynamicboundary);   
xtruncate = find0crossing(x1,y1,z_truncate); 
if isempty(xdynbound)
xdynbound = x1(find(abs(y1-z_dynamicboundary)==min(abs(y1-z_dynamicboundary)),1));
end
if isempty(xtruncate);
xtruncate = x1(find(abs(y1-z_truncate)==min(abs(y1-z_truncate)),1));
end
if x_dir==0
    xdynbound = max(xdynbound);
    xtruncate = min(xtruncate);
    xtruncate = min(xdynbound,xtruncate);
elseif x_dir==1
    xdynbound = min(xdynbound);
    xtruncate = max(xtruncate);
    xtruncate = max(xdynbound,xtruncate);
end

if x_dir==1
    x1=flipud(x1);
    y1=flipud(y1);
    %x1=x1;
    %xdynbound=-xdynbound;
end

%-----------Write data to file--------------
%-------------------------------------------
fid = fopen(filename,'wt');
if x_dir==0
    fprintf(fid,'-1                 (Code X-Direction: +1/-1  Landwards/Seawards)\n');
elseif x_dir==1
    fprintf(fid,' 1                 (Code X-Direction: +1/-1  Landwards/Seawards)\n');
    xdynbound = max(min(x1),xdynbound);
end

%fprintf(fid,'1                 (Code X-Direction: +1/-1  Landwards/Seawards)\n');
fprintf(fid,'%3.0f                (reference X-point coastline)\n',0);
fprintf(fid,'%5.2f                (X-point dynamic boundary)\n',xdynbound(1));
fprintf(fid,'%5.2f                (X-point trunction transpor_CFSt)\n',xtruncate(1));
fprintf(fid,'-1                 (Code Z-Direction; +1/-1 Bottom-Level/Depth)\n');
fprintf(fid,'%3.0f                 (Reference level)\n',reference_level);
fprintf(fid,' 2                 (Number of points for Dx)\n');
fprintf(fid,'         X DX\n');
fprintf(fid,'%5.1f  %5.1f\n',[min(x1) dx]);
fprintf(fid,'%5.1f  %5.1f\n',[max(x1) dx]);
fprintf(fid,'%3.0f                 (Number of points for Profile)\n',length(x1));
fprintf(fid,'         X         Depth   (In any order)\n');
fprintf(fid,'%5.2f  %5.3f\n',[x1 y1]'); % with cm (cross-shore) and mm (depth) accuracy
fclose(fid);