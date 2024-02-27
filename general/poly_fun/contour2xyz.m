function varargout = contour2xyz(C);%,varargin)
%CONTOUR2XYZ Transforms contour matrix to xyz coordinates.
%
%   Transforms a contour matrix of size [2,n] to x,y,z coordinates.
%   C=[level1 x1 x2 ... level2 ...]
%     [number y1 y2 ... number ...];
%
%   Syntax:
%   varargout = contour2xyz(C);
%
%   Input: For <keyword,value> pairs call contour2xyz() without arguments.
%       C= contour matrix from contourc;
%
%   Output:
%       XYZ= [n,3] nan delimited matrix with x,y,z coordinates;
%     OR
%       x = vector of x-coordinates without nans;
%       y = vector of y-coordinates without nans;
%       z = vector of z-coordinates (contour levels) without nans;
%
%   Example:
%       C=contourc(peaks);
%       [x,y,z]=contour2xyz(C);
%       nanscatter(x,y,10,z);
%
%   See also: contour, contourc.

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2021 KU Leuven
%       Bart Roest
%
%       bart.roest@kuleuven.be
%       l.w.m.roest@tudelft.nl
%
%       Spoorwegstraat 12
%       8200 Bruges
%       Belgium
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
% Created: 19 Nov 2021
% Created with Matlab version: 9.9.0.1592791 (R2020b) Update 5

% $Id: contour2xyz.m 17793 2022-02-25 12:52:07Z l.w.m.roest.x $
% $Date: 2022-02-25 20:52:07 +0800 (Fri, 25 Feb 2022) $
% $Author: l.w.m.roest.x $
% $Revision: 17793 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/poly_fun/contour2xyz.m $
% $Keywords: $

%%
% OPT.keyword=value;
% % return defaults (aka introspection)
% if nargin==0;
%     varargout = {OPT};
%     return
% end
% % overwrite defaults with user arguments
% OPT = setproperty(OPT, varargin);

assert(size(C,1)==2,'C must be a matrix of size [2 n] obtained from contourc.');
%% code
C(3,:)=nan;
i=1;
while i<size(C,2);
    c=C(1,i); %contour level
    n=C(2,i); %number of elements
    C(3,i+1:i+n)=c; %patch level information
    C(:,i)=nan; %set to nan
    i=i+n+1;
end

%% output
if nargout==1;
    varargout={C};
else
    mask=~isnan(C(1,:));
    x=C(1,mask)';
    y=C(2,mask)';
    z=C(3,mask)';
    varargout={x,y,z};
end