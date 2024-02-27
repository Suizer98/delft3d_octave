function varargout = poly_op(varargin)
%POLY_OP  Returns the union or the overlapping region of 2 polygons.
%
%    [xr,yr] = poly_op(x1,y1,x2,y2,'union')
%
% returns a clockwise oriented polygon which is the union of two polygons
% (x1,y1) and (x2,y2) and is simply connected (i.e. no donuts, sorry).
%
%    [xr,yr] = poly_op(x1,y1,x2,y2,'overlap')
%
% returns a clockwise oriented polygon which is the area which the two
% polygons have in common.
%
%    [xr,yr] = poly_op(x1,y1,x2,y2,'overlap','disp',1)
%
% returns the polygon and plots it as well
%
% To do in future: deal with overlapping line segments,
%                  error handling, incorrect polygons, etc
%
%
% See also: polyintersect, poly_isclockwise, dflowfm.intersect_lines,
%           convhull
%
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Willem Ottevanger
%
%       willem.ottevanger@deltares.nl
%
%       Deltares
%       Rotterdamseweg 185
%       2629 HD Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   --------------------------------------------------------------------

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 18 Oct 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: poly_op.m 17793 2022-02-25 12:52:07Z l.w.m.roest.x $
% $Date: 2022-02-25 20:52:07 +0800 (Fri, 25 Feb 2022) $
% $Author: l.w.m.roest.x $
% $Revision: 17793 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/poly_fun/poly_op.m $
% $Keywords: $

%%
%% Set defaults for keywords
%% ----------------------

%OPT.debug = 0;
OPT.disp  = 0;

%% Return defaults
%% ----------------------

if nargin==0
    varargout = {OPT};
    return
elseif nargin == 4;
    x1 = varargin{1};
    y1 = varargin{2};
    x2 = varargin{3};
    y2 = varargin{4};
    choice = 'union';
else
    x1 = varargin{1};
    y1 = varargin{2};
    x2 = varargin{3};
    y2 = varargin{4};
    choice = varargin{5};
end
overlaptrue = 0;
if strcmp('overlap',choice)
    overlaptrue = 1;
end


%% Cycle keywords in input argument list to overwrite default values.
%% Align code lines as much as possible to allow for block editing in textpad.
%% Only start <keyword,value> pairs after the REQUIRED arguments.
%% ----------------------
%
iargin    = 6;
while iargin<=nargin,
    if      ischar(varargin{iargin}),
        switch lower(varargin{iargin})
            %        case 'debug'     ;iargin=iargin+1;OPT.debug    = varargin{iargin};
            case 'disp'      ;iargin=iargin+1;OPT.disp     = varargin{iargin};
            otherwise
                error(sprintf('Invalid string argument: %s.',varargin{iargin}));
        end
    end;
    iargin=iargin+1;
end;

%% code

% check for overlapping begin and end point.
if (x1(1)==x1(end) & y1(1)==y1(end))
    x1(end) = [];
    y1(end) = [];
end
if (x2(1)==x2(end) & y2(1)==y2(end))
    x2(end) = [];
    y2(end) = [];
end

N1 = length(x1);
N2 = length(x2);

% make both polygons clockwise oriented
if (~poly_isclockwise(x1,y1));
    x1 = x1(N1:-1:1);
    y1 = y1(N1:-1:1);
end
if (~poly_isclockwise(x2,y2));
    x2 = x2(N2:-1:1);
    y2 = y2(N2:-1:1);
end

x1=x1(:);
x2=x2(:);
y1=y1(:);
y2=y2(:);

N1 = length(x1);
N2 = length(x2);

in1 = inpolygon(x1,y1,x2,y2);
in2 = inpolygon(x2,y2,x1,y1);

A.x1 = x1;
A.x2 = circshift(x1,1);
A.y1 = y1;
A.y2 = circshift(y1,1);
B.x1 = x2;
B.x2 = circshift(x2,1);
B.y1 = y2;
B.y2 = circshift(y2,1);
A.out = 0*x1;
B.out = 0*x2;
A.idxB = 0*x1;
B.idxA = 0*x2;

C = dflowfm.intersect_lines(A,B);

P.x = [];
P.y = [];
pointsused1 = 0;
pointsused2 = 0;

if N1 >= N2;
    [val,idx] = sort(C.idxA);
else
    [val,idx] = sort(C.idxB);
end

varnams= fieldnames(C);
for j=1:length(varnams)
    var=varnams{j};
    if length(C.(var)) == length(idx);
        C.(var) = C.(var)(idx);
    end
end

for k = 1:C.n;
    P.x = [P.x; C.x(k)];
    P.y = [P.y; C.y(k)];
%     hold off;
%     plot(x1,y1,'b.-',x2,y2,'g.-');
%     hold on;
%     plot(P.x,P.y,'r-')
%     plot(P.x,P.y,'ro')
    if (in1(C.idxA(k)) == overlaptrue & pointsused1 < N1);
        x1t = circshift(x1,-C.idxA(k)+1);
        y1t = circshift(y1,-C.idxA(k)+1);
        in1t= circshift(in1,-C.idxA(k)+1);
        idx1 = find(in1t== ~overlaptrue);
        if length(idx1>0)
            x1t = x1t(1:idx1(1)-1);
            y1t = y1t(1:idx1(1)-1);
%        else
%           x1t = [];
%           y1t = [];
        end
        pointsused1 = pointsused1 + length(x1t);
        P.x = [P.x; x1t];
        P.y = [P.y; y1t];
    elseif (in2(C.idxB(k)) == overlaptrue & pointsused2 < N2);
        x2t = circshift(x2,-C.idxB(k)+1);
        y2t = circshift(y2,-C.idxB(k)+1);
        in2t= circshift(in2,-C.idxB(k)+1);
        idx2 = find(in2t== ~overlaptrue);
        if length(idx2>0)
            x2t = x2t(1:idx2(1)-1);
            y2t = y2t(1:idx2(1)-1);
%        else
%           x2t = [];
%           y2t = [];
        end
        pointsused2 = pointsused2 + length(x2t);
        P.x = [P.x; x2t];
        P.y = [P.y; y2t];
    end
end

if overlaptrue
    if sum(in1) == N1;
        %Deal with special case first polygon lies in the second
        P.x = x1;
        P.y = y1;
    elseif sum(in2) == N2;
        %Deal with special case second polygon lies in the first
        P.x = x2;
        P.y = y2;
    elseif sum(in1)+sum(in2) == 0;
        %Deal polygons are completely disconnected
        P.x = [];
        P.y = [];
    end
end

if OPT.disp == 1;
    plot([x1;x1(1)],[y1;y1(1)],[x2;x2(1)],[y2;y2(1)],P.x,P.y,'r.-')
elseif OPT.disp == 2;
    plot([x1],[y1],[x2],[y2],P.x,P.y,'r.-')
end

if nargout==2
    varargout = {P.x,P.y};
end


