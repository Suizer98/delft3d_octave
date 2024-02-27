function s = ddb_findBoundarySections(x, y, opt)
%DDB_FINDBOUNDARYSECTIONS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   s = ddb_findBoundarySections(x, y, opt)
%
%   Input:
%   x   =
%   y   =
%   opt =
%
%   Output:
%   s   =
%
%   Example
%   ddb_findBoundarySections
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

% $Id: ddb_findBoundarySections.m 5557 2011-12-01 16:25:56Z boer_we $
% $Date: 2011-12-02 00:25:56 +0800 (Fri, 02 Dec 2011) $
% $Author: boer_we $
% $Revision: 5557 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/DD/ddb_findBoundarySections.m $
% $Keywords: $

%% This function finds all grid cells that are potential open (or DD) boundaries

switch lower(opt)
    case{'left','right'}
    case{'top','bottom'}
        x=x';
        y=y';
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
        s.i1=ii1;
        s.i2=ii2;
        s.j1=jj1;
        s.j2=jj2;
    case{'top','bottom'}
        s.i1=jj1;
        s.i2=jj2;
        s.j1=ii1;
        s.j2=ii2;
end

s.x1=xx1;
s.x2=xx2;
s.y1=yy1;
s.y2=yy2;


