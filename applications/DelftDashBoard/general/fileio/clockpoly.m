function rot=clockpoly(x,y)
%CLOCKPOLY Determine drawing direction of a simple polygon
%
%    Determines whether the point x,y of the polygon
%    have been specified in clockwise or counter-
%    clockwise direction.
%    Returns 1 for clockwise, -1 for counter-clockwise
%    and 0 for indeterminate.
%    If the direction is not defined (e.g. in case of a
%    polygon describing the shape 8) the routine gives a
%    random answer
%
%   Syntax:
%   rot = CLOCKPOLY(x,y)
%
%   See also INPOLYGON

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
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
% Created: 07 Sep 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
x=x(:);
y=y(:);
xc=mean(x);

xd=diff([x;x(1)]);
yd=diff([y;y(1)]);
x=x;
y=y;

mark=xd==0;
xd(mark)=NaN;
a=(xc-x)./xd;
mark2=a<0 | a>1;
yc=y+a.*yd;
yc(mark & xc~=x)=-inf; % parallel to x=xc -> not crossing -> remove
yc(mark2)=-inf; % crossing outside range -> remove
mark=mark & xc==x;
yc(mark)=y(mark)+max(0,yd(mark)); % on the line x=xc -> take maximum

ycm=max(yc); % highest crossing of x=xc somewhere between i and i+1
i=find(yc==ycm);

Rot=0;
if all(xd(i)>=0) & any(xd(i)>0) % going right
  Rot=1;
elseif all(xd(i)<=0) & any(xd(i)<0) % going left
  Rot=-1;
elseif any(xd(i)>0) & any(xd(i)<0) % going both left and right
  % indeterminate
else, % xd=0 % going straight up or down
  % indeterminate
end

if nargout==0
  switch Rot
  case -1
    fprintf('Counter-clockwise polygon\n');
  case 0
    fprintf('Indeterminate polygon\n');
  case 1
    fprintf('Clockwise polygon\n');
  end
else
  rot=Rot;
end
