function dec = rgb2dec(rgb)
%RGB2DEC   converts matlab colorspec to decimal color notation
%
% function that converts matlab colorspec to decimal color notation
%
% Decimal color notation is obtained by:
%
%   dec = red + green*256 + blue*256^2;
%
% in which red, green and blue are the rgb values that represent red green
% and blue colors (number between 0 and 255).
%
% syntax:
%   dec = rgb2dec(rgb)
%
% input:
%   rgb     -   matlab colorspec (either a matlab color string like 'y' or
%               'yellow' or an rgb representation of the form [R G B] (Nx3)
%               in which R, G and B are the relative (0-1) values of the
%               red(R), green(G) and blue(B) contributions to a color.
%
% output:
%   dec     -   decimal notation of the input.
%
% See also: STR2RGB rgb2hexadecimal

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltares.nl	
%
%       Rotterdamseweg 185
%       2629 HD Delft
%       P.O. 177
%       2600 MH Delft
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 30 Jun 2009
% Created with Matlab version: 7.6.0.324 (R2008a)

% $Id: rgb2dec.m 596 2009-06-30 12:47:52Z geer $
% $Date: 2009-06-30 20:47:52 +0800 (Tue, 30 Jun 2009) $
% $Author: geer $
% $Revision: 596 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/color_fun/rgb2dec.m $
% $Keywords: $

%% convert input to double
if ischar(rgb) % convert from matlab string to rgb
    rgb = str2rgb(rgb);
end

%% check if input is rgbcolor
if size(rgb,2)~=3 || any(rgb<0 | rgb>1)
    error('rgb2dec:NoRGB','Input must be a matlab colorspec');
end

%% convert rgb from relative to absolute
rgb = 255*rgb;

%% calculate decimal notation
dec = rgb(:,1) + rgb(:,2).*256 + rgb(:,3).*256^2;
