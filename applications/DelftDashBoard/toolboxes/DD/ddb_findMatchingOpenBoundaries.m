function bnd1 = ddb_findMatchingOpenBoundaries(bnd0, grid1, grid2)
%DDB_FINDMATCHINGOPENBOUNDARIES  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   bnd1 = ddb_findMatchingOpenBoundaries(bnd0, grid1, grid2)
%
%   Input:
%   bnd0  =
%   grid1 =
%   grid2 =
%
%   Output:
%   bnd1  =
%
%   Example
%   ddb_findMatchingOpenBoundaries
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 01 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: ddb_findMatchingOpenBoundaries.m 5557 2011-12-01 16:25:56Z boer_we $
% $Date: 2011-12-02 00:25:56 +0800 (Fri, 02 Dec 2011) $
% $Author: boer_we $
% $Revision: 5557 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/DD/ddb_findMatchingOpenBoundaries.m $
% $Keywords: $

%%
if grid1.i2(1)>grid1.i1(1)
    opt='ver';
else
    opt='hor';
end

if strcmpi(opt,'ver')
    % Switch i and j
    grid1tmp=grid1;
    grid2tmp=grid2;
    grid1tmp.i1=grid1.j1;
    grid1tmp.j1=grid1.i1;
    grid1tmp.i2=grid1.j2;
    grid1tmp.j2=grid1.i2;
    grid2tmp.i1=grid2.j1;
    grid2tmp.j1=grid2.i1;
    grid2tmp.i2=grid2.j2;
    grid2tmp.j2=grid2.i2;
    grid1=grid1tmp;
    grid2=grid2tmp;
end

%% Now find matching points
% Bottom of first grid, top of second grid

used=zeros(size(grid1.i1));
grid1.used=used;
used=zeros(size(grid2.i1));
grid2.used=used;

% First assuming that first resolution of first grid is equal or lower than
% resolution of second grid
[bnd,grid1,grid2]=findMatches(grid1,grid2);

if ~isempty(bnd)
    if strcmpi(opt,'ver')
        % Switch i and j
        bndtmp=bnd;
        for k=1:length(bnd)
            bndtmp(k).i1a=bnd(k).j1a;
            bndtmp(k).i1b=bnd(k).j1b;
            bndtmp(k).j1a=bnd(k).i1a;
            bndtmp(k).j1b=bnd(k).i1b;
            bndtmp(k).i2a=bnd(k).j2a;
            bndtmp(k).i2b=bnd(k).j2b;
            bndtmp(k).j2a=bnd(k).i2a;
            bndtmp(k).j2b=bnd(k).i2b;
            bndtmp(k).x=bnd(k).x;
            bndtmp(k).y=bnd(k).y;
        end
        bnd=bndtmp;
    end
end

% Add new boundaries to original array
bnd1=bnd0;
nb=length(bnd1);
for i=1:length(bnd)
    bnd1(nb+i).i1a=bnd(i).j1a;
    bnd1(nb+i).i1b=bnd(i).j1b;
    bnd1(nb+i).j1a=bnd(i).i1a;
    bnd1(nb+i).j1b=bnd(i).i1b;
    bnd1(nb+i).i2a=bnd(i).j2a;
    bnd1(nb+i).i2b=bnd(i).j2b;
    bnd1(nb+i).j2a=bnd(i).i2a;
    bnd1(nb+i).j2b=bnd(i).i2b;
    bnd1(nb+i).x=bnd(i).x;
    bnd1(nb+i).y=bnd(i).y;
end

% Now the other way around
[bnd,grid2,grid1]=findMatches(grid2,grid1);

if ~isempty(bnd)
    if strcmpi(opt,'ver')
        % Switch i and j
        bndtmp=bnd;
        for k=1:length(bnd)
            bndtmp(k).i1a=bnd(k).j1a;
            bndtmp(k).i1b=bnd(k).j1b;
            bndtmp(k).j1a=bnd(k).i1a;
            bndtmp(k).j1b=bnd(k).i1b;
            bndtmp(k).i2a=bnd(k).j2a;
            bndtmp(k).i2b=bnd(k).j2b;
            bndtmp(k).j2a=bnd(k).i2a;
            bndtmp(k).j2b=bnd(k).i2b;
            bndtmp(k).x=bnd(k).x;
            bndtmp(k).y=bnd(k).y;
        end
        bnd=bndtmp;
    else
        bndtmp=bnd;
        for k=1:length(bnd)
            bndtmp(k).i1a=bnd(k).j2a;
            bndtmp(k).i1b=bnd(k).j2b;
            bndtmp(k).j1a=bnd(k).i2a;
            bndtmp(k).j1b=bnd(k).i2b;
            bndtmp(k).i2a=bnd(k).j1a;
            bndtmp(k).i2b=bnd(k).j1b;
            bndtmp(k).j2a=bnd(k).i1a;
            bndtmp(k).j2b=bnd(k).i1b;
            bndtmp(k).x=bnd(k).x;
            bndtmp(k).y=bnd(k).y;
        end
        bnd=bndtmp;
    end
end

% Add new boundaries to original array
nb=length(bnd1);
for i=1:length(bnd)
    bnd1(nb+i).i1a=bnd(i).j1a;
    bnd1(nb+i).i1b=bnd(i).j1b;
    bnd1(nb+i).j1a=bnd(i).i1a;
    bnd1(nb+i).j1b=bnd(i).i1b;
    bnd1(nb+i).i2a=bnd(i).j2a;
    bnd1(nb+i).i2b=bnd(i).j2b;
    bnd1(nb+i).j2a=bnd(i).i2a;
    bnd1(nb+i).j2b=bnd(i).i2b;
    bnd1(nb+i).x=bnd(i).x;
    bnd1(nb+i).y=bnd(i).y;
end

%%
function [bnd,grid1,grid2]=findMatches(grid1,grid2)

bnd=[];
k=0;

for i=1:length(grid1.i1)
    
    % Check if this section has not already been used
    if ~grid1.used(i)
        
        xx1a=grid1.x1(i); % One point
        yy1a=grid1.y1(i); % One point
        xx1b=grid1.x2(i); % One point
        yy1b=grid1.y2(i); % One point
        
        x2a=grid2.x1; % Vector
        y2a=grid2.y1; % Vector
        x2b=grid2.x2; % Vector
        y2b=grid2.y2; % Vector
        
        % Compute distance between start point in first grid and all start
        % points in second grid
        dst=sqrt((x2a-xx1a).^2+(y2a-yy1a).^2);
        ia=find(dst==min(dst));
        if dst(ia)<0.1
            % Matching start point found!
            % Now find matching end point
            
            dst=sqrt((x2b-xx1b).^2+(y2b-yy1b).^2);
            ib=find(dst==min(dst));
            if dst(ib)<0.1
                % Matching end point found as well!
                % Now check if second grid has open boundaries in ALL
                % intermediate points
                i1a=grid1.i1(i);
                i1b=grid1.i2(i);
                j1a=grid1.j1(i);
                j1b=grid1.j2(i);
                i2a=grid2.i1(ia);
                i2b=grid2.i2(ib);
                j2a=grid2.j1(ia);
                j2b=grid2.j2(ib);
                if i2a==i2b
                    % Well, at least their on the same horizontal line
                    ifound=1;
                    % Check if intermediate cells are there and not
                    % already used
                    for j=j2a+1:j2b
                        iii=find(grid2.j2==j & grid2.i2==i2a, 1);
                        if isempty(iii)
                            % Intermediate cell missing, this is not a match
                            break
                        elseif grid2.used(iii)
                            % Already used
                            break
                        end
                    end
                    if ifound
                        % We have a match!
                        k=k+1;
                        
                        bnd(k).i1a=i1a;
                        bnd(k).i1b=i1b;
                        bnd(k).j1a=j1a;
                        bnd(k).j1b=j1b;
                        
                        bnd(k).i2a=i2a;
                        bnd(k).i2b=i2b;
                        bnd(k).j2a=j2a;
                        bnd(k).j2b=j2b;
                        
                        % Set used values
                        % of first grid ...
                        grid1.used(i)=1;
                        % and the second grid
                        np=1;
                        bnd(k).x(1)=grid2.x1(ia);
                        bnd(k).y(1)=grid2.y1(ia);
                        for j=j2a+1:j2b
                            iii= grid2.j2==j & grid2.i2==i2a;
                            grid2.used(iii)=1;
                            np=np+1;
                            bnd(k).x(np)=grid2.x2(iii);
                            bnd(k).y(np)=grid2.y2(iii);
                        end
                    end
                end
            end
            
        end
    end
end





