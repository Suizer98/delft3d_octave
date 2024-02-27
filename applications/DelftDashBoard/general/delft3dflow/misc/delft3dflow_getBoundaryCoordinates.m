function [xb yb zb alphau alphav side orientation] = delft3dflow_getBoundaryCoordinates(openBoundary, x, y, depthZ, kcs, varargin)
%DELFT3DFLOW_GETBOUNDARYCOORDINATES  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   [xb yb zb alphau alphav side orientation] = delft3dflow_getBoundaryCoordinates(openBoundary, x, y, depthZ, kcs, varargin)
%
%   Input:
%   openBoundary =
%   x            =
%   y            =
%   depthZ       =
%   kcs          =
%   varargin     =
%
%   Output:
%   xb           =
%   yb           =
%   zb           =
%   alphau       =
%   alphav       =
%   side         =
%   orientation  =
%
%   Example
%   delft3dflow_getBoundaryCoordinates
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
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: delft3dflow_getBoundaryCoordinates.m 13260 2017-04-13 12:37:27Z nederhof $
% $Date: 2017-04-13 20:37:27 +0800 (Thu, 13 Apr 2017) $
% $Author: nederhof $
% $Revision: 13260 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/delft3dflow/misc/delft3dflow_getBoundaryCoordinates.m $
% $Keywords: $

%%
cs='projected';
for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'coordinatesystem','cs','coordsys'}
                % Coordiate system type (projected or geographic)
                cs=lower(varargin{i+1});
        end
    end
end

mmax=size(x,1);
nmax=size(x,2);

M1=openBoundary.M1;
N1=openBoundary.N1;
M2=openBoundary.M2;
N2=openBoundary.N2;

% Check
if (N1>1 && kcs(M1,N1-1)==1 && kcs(M1,N1)==0) && (N2>1 && kcs(M2,N2-1)==1 && kcs(M2,N2)==0)
    % top
    if M2>=M1
        m1=M1-1;
        m2=M2;
        dm=1;
        orientation='positive';
    else
        m1=M1;
        m2=M2-1;
        dm=-1;
        orientation='negative';
    end
    n1=N1-1;
    n2=n1;
    dn=1;
    zb(1)=depthZ(M1,N1-1);
    zb(2)=depthZ(M2,N1-1);
    side='top';
elseif (N1<nmax && kcs(M1,N1+1)==1 && kcs(M1,N1)==0) && (N2<nmax && kcs(M2,N2+1)==1 && kcs(M2,N2)==0)
    % bottom
    if M2>=M1
        m1=M1-1;
        m2=M2;
        dm=1;
        orientation='positive';
    else
        m1=M1;
        m2=M2-1;
        dm=-1;
        orientation='negative';
    end
    n1=N1;
    n2=n1;
    dn=1;
    zb(1)=depthZ(M1,N1+1);
    zb(2)=depthZ(M2,N1+1);
    side='bottom';
elseif (M1>1 && kcs(M1-1,N1)==1 && kcs(M1,N1)==0) && (M2>1 && kcs(M2-1,N2)==1 && kcs(M2,N2)==0)
    % right
    if N2>=N1
        n1=N1-1;
        n2=N2;
        dn=1;
        orientation='positive';
    else
        n1=N1;
        n2=N2-1;
        dn=-1;
        orientation='negative';
    end
    m1=M1-1;
    m2=m1;
    dm=1;
    zb(1)=depthZ(M1-1,N1);
    zb(2)=depthZ(M2-1,N2);
    side='right';
elseif (M1<mmax && kcs(M1+1,N1)==1 && kcs(M1,N1)==0) && (M2<mmax && kcs(M2+1,N2)==1 && kcs(M2,N2)==0)
    % left
    if N2>=N1
        n1=N1-1;
        n2=N2;
        dn=1;
        orientation='positive';
    else
        n1=N1;
        n2=N2-1;
        dn=-1;
        orientation='negative';
    end
    m1=M1;
    m2=m1;
    dm=1;
    zb(1)=depthZ(M1+1,N1);
    zb(2)=depthZ(M2+1,N2);
    side='left';
% Test
else
    % right
    if N2>=N1
        n1=N1-1;
        n2=N2;
        dn=1;
        orientation='positive';
    else
        n1=N1;
        n2=N2-1;
        dn=-1;
        orientation='negative';
    end
    m1=M1-1;
    m2=m1;
    dm=1;
    zb(1)=depthZ(M1-1,N1);
    zb(2)=depthZ(M2-1,N2);
    side='right';
end

xb=x(m1:dm:m2,n1:dn:n2);
yb=y(m1:dm:m2,n1:dn:n2);

% Find rotation
% End A
dx=xb(2)-xb(1);
dy=yb(2)-yb(1);
switch lower(cs)
    case{'geographic','spherical','geo','latlon'}
        dx=dx*cos(0.5*pi*(yb(1)+yb(2))/180);
end
if strcmpi(orientation,'negative')
    dx=dx*-1;
    dy=dy*-1;
end
switch lower(side)
    case{'left','right'}
        % u-point
        alphau(1)=atan2(dy,dx)-0.5*pi;
        alphav(1)=atan2(dy,dx);
    case{'bottom','top'}
        % v-point
        alphau(1)=atan2(dy,dx)+0.5*pi;
        alphav(1)=atan2(dy,dx);
end

% End B

dx=xb(end)-xb(end-1);
dy=yb(end)-yb(end-1);
switch lower(cs)
    case{'geographic','spherical','geo','latlon'}
        dx=dx*cos(0.5*pi*(yb(1)+yb(2))/180);
end
if strcmpi(orientation,'negative')
    dx=dx*-1;
    dy=dy*-1;
end
switch lower(side)
    case{'left','right'}
        % u-point
        alphau(2)=atan2(dy,dx)-0.5*pi;
        alphav(2)=atan2(dy,dx);
    case{'bottom','top'}
        % v-point
        alphau(2)=atan2(dy,dx)+0.5*pi;
        alphav(2)=atan2(dy,dx);
end
