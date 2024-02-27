function writeMDA_old(mda_filename, reference_line, varargin)
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
%       bas.huisman@deltares.nl	
%
%   Copyright (C) 2014 Deltares
%       Freek Scheel
%       freek.scheel@deltares.nl	
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

% $Id: writeMDA_old.m 10584 2014-04-22 09:02:24Z scheel $
% $Date: 2014-04-22 17:02:24 +0800 (Tue, 22 Apr 2014) $
% $Author: scheel $
% $Revision: 10584 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/unibest/fileio/writeMDA_old.m $
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
baselineFine=[baselineFine(2:end-1,:); baseline(end,:)];
% baselineFine=baselineFine(2:end-1,:);

% loop through points of coastline and find for each point the nearest point of the baseline
tel = 1;
for ii=1:length(coast)
    dist=sqrt((baselineFine(:,1)-coast(ii,1)).^2+(baselineFine(:,2)-coast(ii,2)).^2);
    [Y(ii),id(ii)]=min(dist);
    baselineNew(ii,:)=baselineFine(id(ii),:);
    
    thrdist = 5;           % make sure the distance between reference points is at least 'thrdist' meters
    if ii>1
        if (sqrt(((baselineNew(ii,1)-baselineNew(ii-1,1)).^2)+((baselineNew(ii,2)-baselineNew(ii-1,2)).^2)))<thrdist
            id_baseline(ii,1) = tel;
        else
            tel = tel+1;
            id_baseline(ii,1) = tel;
        end
    else
        id_baseline(ii,1) = tel;
    end
end

%% thin out baselineNew
baselineNew2 = [];
for jj=1:max(id_baseline)
    ID1 = find(id_baseline==jj);
    [dum1,ID2]= min(Y(ID1));
    ID3 = ID1(ID2(1));
    baselineNew2(jj,:) = baselineNew(ID3(1),:);
    Y2(jj) = Y(ID3(1));
    
%     % If you want to inspect what is happening:
%     if jj == 1
%         fig = figure; set(fig,'visible','off'); hold on; axis equal; grid on; box on;
%     end
%         plot(baselineNew2(jj,1),baselineNew2(jj,2),'r+');
%         plot(coast(ID1,1),coast(ID1,2),'b');
%         plot([coast(ID3,1) baselineNew2(jj,1)],[coast(ID3,2) baselineNew2(jj,2)],'k');
%     if jj == max(id_baseline)
%         set(fig,'visible','on');
%         1; % SET YOUR BREAKPOINT HERE! (FILE WILL ONLY BE WRITTEN UPON CONTINUE)
%     end
    
    if min(unique(diff(id)))<0
        if jj == 1
            fig = figure; set(fig,'visible','off'); hold on; axis equal; grid on; box on;
        end
            plot(baselineNew2(jj,1),baselineNew2(jj,2),'r+');
            plot(coast(ID1,1),coast(ID1,2),'b');
            plot([coast(ID3,1) baselineNew2(jj,1)],[coast(ID3,2) baselineNew2(jj,2)],'k');
        if jj == max(id_baseline)
            set(fig,'visible','on');
            error(['It appears that the specified coastline triggers basepoints to be used multiple times, please check the figure to identify these points (multi-black lines from red basepoints), please change the coastline accordingly!']);
        end
    end
end

%% flip the coastline if it is defined in wrong direction
dist1 = (baseline(1,1)-baselineNew2(1,1)).^2+(baseline(1,2)-baselineNew2(1,2)).^2;
dist2 = (baseline(1,1)-baselineNew2(end,1)).^2+(baseline(1,2)-baselineNew2(end,2)).^2;
if dist2<dist1
    baselineNew2 = flipud(baselineNew2);
    Y2 = flipud(Y2(:));
end

%specify minimal number of comp. points between two supporting points of baseline
N=[0; ceil(diff(pathdistance(baselineNew2(:,1),baselineNew2(:,2)))/resolution)];
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
fprintf(fid,'%13.1f   %13.1f %11.0f%11.0f%11.0f\n',[baselineNew2 Y2(:) N Ray]');
fclose(fid);
