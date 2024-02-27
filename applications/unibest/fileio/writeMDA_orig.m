function writeMDA(mda_filename, reference_line, varargin)
%write MDA : Writes a unibest mda-file (also computes cross-shore distance between reference line and shoreline)
%
%   Syntax:
%     function writeMDA(filename, reference_line, resolution, shoreline, dx)
% 
%   Input:
%     mda_filename        string with output filename of mda-file
%     reference_line      string with filename of polygon of reference line  OR  X,Y coordinates of ref.line [Nx2]
%     resolution          (optional) specify max. distance between two supporting points [m](default = 10 m)
%     shoreline           (optional) string with filename of polygon of shoreline (default : reference_line = shoreline)
%     dx                  (optional) resolution to cut up baseline (default = 0.05)
% 
%   Output:
%     .mda file
%
%   Example:
%     x = [1:10:1000]';
%     y = x.^1.2;
%     writeMDA('test.mda', [x,y]);
%     writeMDA('test.mda', [x,y], [x+20,y]);
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

% $Id: writeMDA.m 2849 2010-10-01 08:30:33Z huism_b $
% $Date: 2010-10-01 10:30:33 +0200 (vr, 01 okt 2010) $
% $Author: huism_b $
% $Revision: 2849 $
% $HeadURL: https://repos.deltares.nl/repos/mctools/trunk/matlab/applications/UNIBEST_CL/fileio/writeMDA.m $
% $Keywords: $

%---------------Initialise------------------
%-------------------------------------------
if nargin == 2
    resolution = 10;
    shoreline  = reference_line;
    dx         = 0.05;
elseif nargin == 3
    resolution = varargin{1};
    shoreline  = reference_line;
    dx         = 0.05;
elseif nargin == 4
    resolution = varargin{1};
    shoreline  = varargin{2};
    dx         = 0.05;
elseif nargin == 5
    resolution = varargin{1};
    shoreline  = varargin{2};
    dx         = varargin{3};
elseif nargin>5
    resolution = varargin{1};
    shoreline  = varargin{2};
    dx         = varargin{3};
end

%--------------Analyse data-----------------
%-------------------------------------------
% load baseline
if isstr(reference_line)
    baseline=landboundary('read',reference_line);
else
    baseline=reference_line;
end
% make it two colums
baseline=baseline(:,1:2);
% remove nans
baseline(find(isnan(baseline(:,1))),:)=[];

% load real coastline
%coast=flipud(landboundary('read','walcheren_RD.ldb'));
if isstr(shoreline)
    coast=landboundary('read',shoreline);
else
    coast=shoreline;
end
coast(find(isnan(coast(:,1))),:)=[];

% specify resolution to cut up baseline
% cut up baseline
baselineFine=add_equidist_points(dx,baseline);

% loop through points of coastline and find for each point the nearest point of the baseline
for ii=1:length(coast)
    dist=sqrt((baselineFine(:,1)-coast(ii,1)).^2+(baselineFine(:,2)-coast(ii,2)).^2);
    [Y(ii),id]=min(dist);
    baselineNew(ii,:)=baselineFine(id,:);
end

%specify minimal number of comp. points between two supporting points of baseline
N=[0; ceil(diff(pathdistance(baselineNew(:,1),baselineNew(:,2)))/resolution)];
N=min(99,N);
N(N==0)=1;N(1)=0;
Ray=[1:length(N)]';


%-----------Write data to file--------------
%-------------------------------------------
% print to mda-file
fid=fopen(mda_filename,'wt');
fprintf(fid,'%s\n',' BASISPOINTS');
fprintf(fid,'%4.0f\n',length(N));
fprintf(fid,'%s\n','     Xw             Yw             Y              N              Ray');
fprintf(fid,'%13.1f   %13.1f %11.0f%11.0f%11.0f\n',[baselineNew Y' N Ray]');
fclose(fid);
