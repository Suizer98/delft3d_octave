function [MDAdata]=readMDA(MDAfilename)
%read MDA : Reads UNIBEST MDA-files
%   
%   Syntax:
%     function [MDAdata]=readMDA(MDAfilename)
%   
%   Input:
%     MDAfilename    string with filename of MDA
%   
%   Output:
%     MDAdata        struct with contents of mda file
%                    .X           : X-coordinate of reference line [m]
%                    .Y           : Y-coordinate of reference line [m]
%                    .Y1          : Offset of coastline from reference line [m]
%                    .nrgridcells : Number of grid cells in-between current 
%                                   and previous reference line point
%                    .nr          : Index of reference line point
%                    .Y2          : Offset of coastline from reference line on 
%                                   the right side of a coastline point [m]
%                    .Xi          : X-coordinate of reference line (for every grid cell) [m]
%                    .Yi          : Y-coordinate of reference line (for every grid cell) [m]
%                    .Yi1         : Offset of coastline from reference line for every grid cell [m]
%                    .Xcoast      : X-coordinate of coastline [m]
%                    .Ycoast      : Y-coordinate of coastline [m]
%                    .ANGLEcoast  : coastline orientation of the reference line
%                                   (normal to coast in seaward direction) [°N] 
%                                   Note that this is not the angle of the coastline,
%                                   but the angle of the reference line!!!
%                    .QpointsX    : X-coordinates of transport points on reference line
%                    .QpointsY    : Y-coordinates of transport points on reference line
%   
%   Example:
%     x = [1:10:1000]';
%     y = x.^1.2;
%     writeMDA('test.mda', [x,y]);
%     [MDAdata]=readMDA('test.mda');
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

% $Id: readMDA.m 18215 2022-06-29 14:18:46Z vermeer $
% $Date: 2022-06-29 22:18:46 +0800 (Wed, 29 Jun 2022) $
% $Author: vermeer $
% $Revision: 18215 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/unibest/fileio/readMDA.m $
% $Keywords: $


%-----------read data from file--------------
%-------------------------------------------
fid=fopen(MDAfilename,'rt');
line1 = fgetl(fid);
line2 = fgetl(fid);
numberoflines = str2num(line2);
line3 = fgetl(fid);

for nn=1:numberoflines
    line = fgetl(fid);
    [MDAdata.X(nn,1),MDAdata.Y(nn,1),MDAdata.Y1(nn,1),MDAdata.nrgridcells(nn,1),MDAdata.nr(nn,1)] = strread(line,'%f %f %f %f %f','delimiter',' ');
    if MDAdata.nrgridcells(nn)<0
        line = fgetl(fid);
        if ~isfield(MDAdata,'Y2')
            MDAdata.Y2=nan(numberoflines,1);
        end
        MDAdata.Y2(nn)=str2num(line);
    end
end
if ~isfield(MDAdata,'Y2')
    MDAdata.Y2=nan(numberoflines,1);
end
fclose(fid);

%% Interpolate reference line
dist = distXY(MDAdata.X(:),MDAdata.Y(:));
dist2 = dist(1);
for ii=2:length(MDAdata.nrgridcells)
    igr = MDAdata.nrgridcells(ii);
    dx2 = (dist(ii)-dist(ii-1))/igr.*[1:igr]';
    dist2=[dist2;dist(ii-1)+dx2];
end
    
MDAdata.Xi=interp1(dist,MDAdata.X,dist2,'spline');
MDAdata.Yi=interp1(dist,MDAdata.Y,dist2,'spline');
MDAdata.Y1i=interp1(dist,MDAdata.Y1,dist2,'spline');
MDAdata.Xci = (MDAdata.Xi(1:end-1)+MDAdata.Xi(2:end))/2;
MDAdata.Yci = (MDAdata.Yi(1:end-1)+MDAdata.Yi(2:end))/2;
MDAdata.Y1ci = (MDAdata.Y1i(1:end-1)+MDAdata.Y1i(2:end))/2;

%% compute coastline
dx = diff(MDAdata.Xi);dx=[dx(1);(dx(2:end)+dx(1:end-1))/2;dx(end)];
dy = diff(MDAdata.Yi);dy=[dy(1);(dy(2:end)+dy(1:end-1))/2;dy(end)];
dxc = diff(MDAdata.Xci);dxc=[dxc(1);(dxc(2:end)+dxc(1:end-1))/2;dxc(end)];
dyc = diff(MDAdata.Yci);dyc=[dyc(1);(dyc(2:end)+dyc(1:end-1))/2;dyc(end)];

MDAdata.Xtransp = MDAdata.Xi + MDAdata.Y1i.*-dy.*(dx.^2+dy.^2).^-0.5;
MDAdata.Ytransp = MDAdata.Yi + MDAdata.Y1i.*dx.*(dx.^2+dy.^2).^-0.5;
MDAdata.Xcoast = MDAdata.Xci + MDAdata.Y1ci.*-dyc.*(dxc.^2+dyc.^2).^-0.5;
MDAdata.Ycoast = MDAdata.Yci + MDAdata.Y1ci.*dxc.*(dxc.^2+dyc.^2).^-0.5;

%% compute coastline orientation of the reference line (normal to coast in seaward direction) [°N] 
%  Note that this is not the angle of the coastline, but the angle of the reference line!!!
MDAdata.ANGLEreferenceline = mod(atan2(-dy,dx)*180/pi,360);
MDAdata.ANGLEcoast = mod(atan2(-dyc,dxc)*180/pi,360);

% %% Q-points
% MDAdata.QpointsX = (MDAdata.Xi(2:end)+MDAdata.Xi(1:end-1))/2;
% MDAdata.QpointsY = (MDAdata.Yi(2:end)+MDAdata.Yi(1:end-1))/2;
% MDAdata.QpointsX = [2*MDAdata.QpointsX(1)-MDAdata.QpointsX(2);MDAdata.QpointsX;2*MDAdata.QpointsX(end)-MDAdata.QpointsX(end-1)];
% MDAdata.QpointsY = [2*MDAdata.QpointsY(1)-MDAdata.QpointsY(2);MDAdata.QpointsY;2*MDAdata.QpointsY(end)-MDAdata.QpointsY(end-1)];
