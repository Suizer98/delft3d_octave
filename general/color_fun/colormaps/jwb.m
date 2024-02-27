function col=jwb(varargin)
%JWB Sets the colormap to 'jwb', which is jet, with a white band in the middle.
% JWB is a colormap based on JET, but with an adjustable white band in the 
% centre. Colors go from red and yellow via white to cyan and blue.
% Default there are 100 coloursteps, jwb(n) will give you n colours.
% The defaul white-space is 10%
%
% Syntax: col=jwb(n);
%         col=jwb(n,per);
%         colormap(jwb(n,per));
%
% Input:  n: number of colors [1 inf].
%         per: percentage of white (in colorbar) [+0 1]
%
% Output: col: nx3 matrix with rgb triplets.
%
% See also: colormap.

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2017 TU Delft
%       Bart Roest
%
%       l.w.m.roest@student.tudelft.nl
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
% Created: 22 Feb 2017
% Created with Matlab version: 8.6.0.267246 (R2015b)

% $Id: jwb.m 13857 2017-10-27 10:07:23Z l.w.m.roest.x $
% $Date: 2017-10-27 18:07:23 +0800 (Fri, 27 Oct 2017) $
% $Author: l.w.m.roest.x $
% $Revision: 13857 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/color_fun/colormaps/jwb.m $
% $Keywords: $

n=100;
per=0.1;
if length(varargin)==1;
    n=varargin{1};
elseif length(varargin)>=2;
    n=varargin{1};
    per=varargin{2};
end

if per==0;
    x=[0.000, 0.125, 0.450, 0.500, 0.550, 0.875, 1.000];
    r=[0.000, 0.000, 0.000, 1.000, 1.000, 1.000, 0.500];
    g=[0.000, 0.000, 1.000, 1.000, 1.000, 0.000, 0.000];
    b=[0.500, 1.000, 1.000, 1.000, 0.000, 0.000, 0.000];
else
    x=[0.000, 0.125-per*0.125, 0.450-per*0.450,  0.500-per*0.500, 0.500+per*0.500, 0.550+per*0.450, 0.875+per*0.125, 1.000];
    r=[0.000, 0.000          , 0.000          ,  1.000          , 1.000          , 1.000          , 1.000          , 0.500];
    g=[0.000, 0.000          , 1.000          ,  1.000          , 1.000          , 1.000          , 0.000          , 0.000];
    b=[0.500, 1.000          , 1.000          ,  1.000          , 1.000          , 0.000          , 0.000          , 0.000];
end

ri=interp1(x,r,linspace(0,1,n));
gi=interp1(x,g,linspace(0,1,n));
bi=interp1(x,b,linspace(0,1,n));
col=[ri' gi' bi'];
end
%EOF