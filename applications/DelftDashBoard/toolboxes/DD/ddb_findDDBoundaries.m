function ddbound = ddb_findDDBoundaries(ddbound, x1, y1, x2, y2, runid1, runid2)
%DDB_FINDDDBOUNDARIES  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddbound = ddb_findDDBoundaries(ddbound, x1, y1, x2, y2, runid1, runid2)
%
%   Input:
%   ddbound =
%   x1      =
%   y1      =
%   x2      =
%   y2      =
%   runid1  =
%   runid2  =
%
%   Output:
%   ddbound =
%
%   Example
%   ddb_findDDBoundaries
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

% $Id: ddb_findDDBoundaries.m 5557 2011-12-01 16:25:56Z boer_we $
% $Date: 2011-12-02 00:25:56 +0800 (Fri, 02 Dec 2011) $
% $Author: boer_we $
% $Revision: 5557 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/DD/ddb_findDDBoundaries.m $
% $Keywords: $

%%
% This function finds DD boundaries for 2 grids and returns a ddb
% structure ddbound. ddbound can be empty (i.e. ddbound=[]). This function
% assumes that the grid comes in according to the Delft3D convention (i.e.
% x(m,n) and NOT x(n,m) as in meshgrid).

%% Find potential boundary sections
top1=findBoundarySections(x1,y1,'top');
bottom1=findBoundarySections(x1,y1,'bottom');
left1=findBoundarySections(x1,y1,'left');
right1=findBoundarySections(x1,y1,'right');

top2=findBoundarySections(x2,y2,'top');
bottom2=findBoundarySections(x2,y2,'bottom');
left2=findBoundarySections(x2,y2,'left');
right2=findBoundarySections(x2,y2,'right');

%% Find matching sections
ddbound=ddb_findMatchingOpenBoundaries(ddbound,top1,bottom2,runid1,runid2);
ddbound=ddb_findMatchingOpenBoundaries(ddbound,top2,bottom1,runid2,runid1);
ddbound=ddb_findMatchingOpenBoundaries(ddbound,right1,left2,runid1,runid2);
ddbound=ddb_findMatchingOpenBoundaries(ddbound,right2,left1,runid2,runid1);

%%
function s=findBoundarySections(x,y,opt)
% This function finds all grid cells that are potential DD boundaries
% It assumes that the grid comes in according to the Delft3D convention (i.e.
% x(m,n) and NOT x(n,m) like meshgrid). It checks for horizontal (along m lines) boundaries.
% Therefore x and y need to be transposed in case of left and right boundaries.

switch lower(opt)
    case{'left','right'}
        x=x';
        y=y';
    case{'top','bottom'}
end

s=[];
ii1=[];
jj1=[];
ii2=[];
jj2=[];
xx1=[];
yy1=[];
xx2=[];
yy2=[];

nx=size(x,1);
ny=size(x,2);

k=0;
switch lower(opt)
    case{'bottom','left'}
        for i=2:nx
            for j=1:ny
                % Check if both corner points are active
                if ~isnan(x(i,j)) && ~isnan(x(i-1,j))
                    % Check if both corner points below are active, if so :
                    % skip
                    ibnd=0;
                    if j==1
                        % This is the bottom row
                        ibnd=1;
                    elseif isnan(x(i,j-1)) || isnan(x(i-1,j-1))
                        % One of the corner points below is inactive
                        ibnd=1;
                    end
                    if ibnd
                        % This IS a boundary
                        k=k+1;
                        ii1(k)=i-1;
                        jj1(k)=j;
                        ii2(k)=i;
                        jj2(k)=j;
                        xx1(k)=x(ii1(k),jj1(k));
                        yy1(k)=y(ii1(k),jj1(k));
                        xx2(k)=x(ii2(k),jj2(k));
                        yy2(k)=y(ii2(k),jj2(k));
                    end
                end
            end
        end
    case{'top','right'}
        for i=2:nx
            for j=1:ny
                % Check if both corner points are active
                if ~isnan(x(i,j)) && ~isnan(x(i-1,j))
                    % Check if both corner points below are active, if so :
                    % skip
                    ibnd=0;
                    if j==ny
                        % This is the top row
                        ibnd=1;
                    elseif isnan(x(i,j+1)) || isnan(x(i-1,j+1))
                        % One of the corner points above is inactive
                        ibnd=1;
                    end
                    if ibnd
                        % This IS a boundary
                        k=k+1;
                        ii1(k)=i-1;
                        jj1(k)=j;
                        ii2(k)=i;
                        jj2(k)=j;
                        xx1(k)=x(ii1(k),jj1(k));
                        yy1(k)=y(ii1(k),jj1(k));
                        xx2(k)=x(ii2(k),jj2(k));
                        yy2(k)=y(ii2(k),jj2(k));
                    end
                end
            end
        end
end

switch lower(opt)
    case{'left','right'}
        s.i1=jj1;
        s.i2=jj2;
        s.j1=ii1;
        s.j2=ii2;
    case{'top','bottom'}
        s.i1=ii1;
        s.i2=ii2;
        s.j1=jj1;
        s.j2=jj2;
end

s.x1=xx1;
s.x2=xx2;
s.y1=yy1;
s.y2=yy2;

%%
function bndind=ddb_findMatchingOpenBoundaries(bndind,grid1,grid2,runid1,runid2)

nddb=length(bndind);

if grid1.i2(1)>grid1.i1(1)
    opt='hor';
else
    opt='ver';
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
% And paste them together
bnd=pasteDDsections(bnd);

if ~isempty(bnd)
    if strcmpi(opt,'hor')
        for k=1:length(bnd)
            nddb=nddb+1;
            bndind(nddb).runid1=runid1;
            bndind(nddb).runid2=runid2;
            bndind(nddb).m1a=bnd(k).i1a;
            bndind(nddb).m1b=bnd(k).i1b;
            bndind(nddb).n1a=bnd(k).j1a;
            bndind(nddb).n1b=bnd(k).j1b;
            bndind(nddb).m2a=bnd(k).i2a;
            bndind(nddb).m2b=bnd(k).i2b;
            bndind(nddb).n2a=bnd(k).j2a;
            bndind(nddb).n2b=bnd(k).j2b;
            bndind(nddb).x=bnd(k).x;
            bndind(nddb).y=bnd(k).y;
        end
    else
        % Switch i and j
        for k=1:length(bnd)
            nddb=nddb+1;
            bndind(nddb).runid1=runid1;
            bndind(nddb).runid2=runid2;
            bndind(nddb).m1a=bnd(k).j1a;
            bndind(nddb).m1b=bnd(k).j1b;
            bndind(nddb).n1a=bnd(k).i1a;
            bndind(nddb).n1b=bnd(k).i1b;
            bndind(nddb).m2a=bnd(k).j2a;
            bndind(nddb).m2b=bnd(k).j2b;
            bndind(nddb).n2a=bnd(k).i2a;
            bndind(nddb).n2b=bnd(k).i2b;
            bndind(nddb).x=bnd(k).x;
            bndind(nddb).y=bnd(k).y;
        end
    end
end

% Now the other way around (first grid is fine than second grid)
[bnd,grid2,grid1]=findMatches(grid2,grid1);
% And paste them together
bnd=pasteDDsections(bnd);

if ~isempty(bnd)
    if strcmpi(opt,'hor')
        for k=1:length(bnd)
            nddb=nddb+1;
            bndind(nddb).runid1=runid1;
            bndind(nddb).runid2=runid2;
            bndind(nddb).m1a=bnd(k).i2a;
            bndind(nddb).m1b=bnd(k).i2b;
            bndind(nddb).n1a=bnd(k).j2a;
            bndind(nddb).n1b=bnd(k).j2b;
            bndind(nddb).m2a=bnd(k).i1a;
            bndind(nddb).m2b=bnd(k).i1b;
            bndind(nddb).n2a=bnd(k).j1a;
            bndind(nddb).n2b=bnd(k).j1b;
            bndind(nddb).x=bnd(k).x;
            bndind(nddb).y=bnd(k).y;
        end
    else
        % Switch i and j
        for k=1:length(bnd)
            nddb=nddb+1;
            bndind(nddb).runid1=runid1;
            bndind(nddb).runid2=runid2;
            bndind(nddb).m1a=bnd(k).j2a;
            bndind(nddb).m1b=bnd(k).j2b;
            bndind(nddb).n1a=bnd(k).i2a;
            bndind(nddb).n1b=bnd(k).i2b;
            bndind(nddb).m2a=bnd(k).j1a;
            bndind(nddb).m2b=bnd(k).j1b;
            bndind(nddb).n2a=bnd(k).i1a;
            bndind(nddb).n2b=bnd(k).i1b;
            bndind(nddb).x=bnd(k).x;
            bndind(nddb).y=bnd(k).y;
        end
    end
end

%%
function [bnd,grid1,grid2]=findMatches(grid1,grid2)
% Finds matching cell sections in both domains
bnd=[];
k=0;

for ii=1:length(grid1.i1)
    
    % Check if this section has not already been used
    if ~grid1.used(ii)
        
        xx1a=grid1.x1(ii); % One point
        yy1a=grid1.y1(ii); % One point
        xx1b=grid1.x2(ii); % One point
        yy1b=grid1.y2(ii); % One point
        
        x2a=grid2.x1; % Vector
        y2a=grid2.y1; % Vector
        x2b=grid2.x2; % Vector
        y2b=grid2.y2; % Vector
        
        % Compute distance between start point in first grid and all start
        % points in second grid
        dst=sqrt((x2a-xx1a).^2+(y2a-yy1a).^2);
        ia=find(dst==min(dst)); % index of nearest point
        maxdist=0.1*sqrt((x2b(ia)-x2a(ia)).^2+(y2b(ia)-y2a(ia)).^2); % one tenth of length of nearest section
        maxdist=min(maxdist,0.1*(sqrt((xx1b-xx1a).^2+(yy1b-yy1a).^2)));
        if dst(ia)<maxdist
            % Matching start point found!
            % Now find matching end point
            dst=sqrt((x2b-xx1b).^2+(y2b-yy1b).^2);
            ib=find(dst==min(dst)); % index of nearest point
            maxdist=0.1*sqrt((x2b(ib)-x2a(ib)).^2+(y2b(ib)-y2a(ib)).^2); % one tenth of length of nearest section
            maxdist=min(maxdist,0.1*(sqrt((xx1b-xx1a).^2+(yy1b-yy1a).^2)));
            if dst(ib)<maxdist
                % Matching end point found as well!
                % Now check if second grid has open boundaries in ALL
                % intermediate points
                i1a=grid1.i1(ii);
                i1b=grid1.i2(ii);
                j1a=grid1.j1(ii);
                j1b=grid1.j2(ii);
                i2a=grid2.i1(ia);
                i2b=grid2.i2(ib);
                j2a=grid2.j1(ia);
                j2b=grid2.j2(ib);
                if j2a==j2b
                    % Well, at least their on the same horizontal line
                    ifound=1;
                    % Check if intermediate cells are there and not
                    % already used
                    for i=i2a+1:i2b
                        iii=find(grid2.i2==i & grid2.j2==j2a, 1);
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
                        grid1.used(ii)=1;
                        % and the second grid
                        np=1;
                        bnd(k).x(1)=grid2.x1(ia);
                        bnd(k).y(1)=grid2.y1(ia);
                        for i=i2a+1:i2b
                            iii= grid2.i2==i & grid2.j2==j2a;
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


%%
function bnd1=pasteDDsections(bnd0)
% Pastes all separate cell sections where possible
if isempty(bnd0)
    bnd1=[];
end
nb=0;
used=zeros(length(bnd0));
for i=1:length(bnd0)
    
    if ~used(i)
        
        used(i)=1;
        
        nb=nb+1;
        
        % Copy first segment
        bnd1(nb).i1a=bnd0(i).i1a;
        bnd1(nb).i1b=bnd0(i).i1b;
        bnd1(nb).j1a=bnd0(i).j1a;
        bnd1(nb).j1b=bnd0(i).j1b;
        bnd1(nb).i2a=bnd0(i).i2a;
        bnd1(nb).i2b=bnd0(i).i2b;
        bnd1(nb).j2a=bnd0(i).j2a;
        bnd1(nb).j2b=bnd0(i).j2b;
        bnd1(nb).x=bnd0(i).x;
        bnd1(nb).y=bnd0(i).y;
        
        for j=1:length(bnd0)
            if bnd0(j).i1b==bnd1(nb).i1b+1 && bnd0(j).j1b==bnd1(nb).j1b && ~used(j)
                % Found next section along boundary nb
                % Append to section nb
                used(j)=1;
                bnd1(nb).i1b=bnd0(j).i1b;
                bnd1(nb).i2b=bnd0(j).i2b;
                bnd1(nb).x=[bnd1(nb).x bnd0(j).x(2:end)];
                bnd1(nb).y=[bnd1(nb).y bnd0(j).y(2:end)];
            end
        end
    end
end

