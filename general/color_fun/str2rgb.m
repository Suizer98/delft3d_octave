function rgbVector = str2rgb(colorString)
%STR2RGB  Converts a string representation of a color to an RGB triple.
%
%   STR2RGB converts the string STR into a three-element row vector X 
%   (an RGB triple). STR can be one of three string representations of 
%   colors that MATLAB uses (see ColorSpec help): a full color name 
%   ('yellow'), a single character ('y'), or a string of numbers within 
%   the range of 0 and 1 ('[1 1 0]' or '1 1 0').
%
%   If the string STR does not represent a valid string representation of a
%   color, STR2RGB(STR) returns NaN.
%
%   NOTE: STR2RGB does not use eval.
%
%   Syntax:
%   rgbVector = str2rgb(colorString)
%
%   Input:
%   colorString = A valid matlab color string
%
%   Output:
%   rgbVector   = A 1x3 double specifying [R G B] in which R = Red Color
%                   intensity, G = Green color intensity and B = blue color
%                   intensity. rgbVector-values are normalized (0-1)
%
%   Example
%      str2rgb('yellow')        returns [1 1 0]
%      str2rgb('y')             returns [1 1 0]
%      str2rgb('[1 1 0]')       returns [1 1 0]
%      str2rgb('1 1 0')         returns [1 1 0]
%      str2rgb('[1; 1; 0]')     returns [1 1 0]
%      str2rgb('[0 0.5 0.91]')  returns [0 0.5000 0.9100]
%      str2rgb('purple')        returns NaN
%      str2rgb('[1 2]')         returns NaN
%
%   See also rgb2dec rgb2hexadecimal

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
%
%   This function is obtained from the matlab file exchange server and
%   written by:
%    Ken Eaton
%   Last modified: 4/2/08

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 30 Jun 2009
% Created with Matlab version: 7.6.0.324 (R2008a)

% $Id: str2rgb.m 596 2009-06-30 12:47:52Z geer $
% $Date: 2009-06-30 20:47:52 +0800 (Tue, 30 Jun 2009) $
% $Author: geer $
% $Revision: 596 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/color_fun/str2rgb.m $
% $Keywords: $

%% 
if (nargin == 0),
    error('str2rgb:notEnoughInputs','Not enough input arguments.');
  end
  if (~ischar(colorString)),
    error('str2rgb:badArgumentType',...
          'Input argument should be of type char.');
  end
  expression = {'^\s*yellow\s*$','^\s*magenta\s*$','^\s*cyan\s*$',...
                '^\s*red\s*$','^\s*green\s*$','^\s*blue\s*$',...
                '^\s*white\s*$','^\s*black\s*$','^\s*y\s*$','^\s*m\s*$',...
                '^\s*c\s*$','^\s*r\s*$','^\s*g\s*$','^\s*b\s*$',...
                '^\s*w\s*$','^\s*k\s*$','[\[\]\;\,]'};
  replace = {'[1 1 0]','[1 0 1]','[0 1 1]','[1 0 0]','[0 1 0]',...
             '[0 0 1]','[1 1 1]','[0 0 0]','[1 1 0]','[1 0 1]',...
             '[0 1 1]','[1 0 0]','[0 1 0]','[0 0 1]','[1 1 1]',...
             '[0 0 0]',' '};
  rgbVector = sscanf(regexprep(colorString,expression,replace),'%f').';
  if ((numel(rgbVector) ~= 3) || any((rgbVector < 0) | (rgbVector > 1))),
    rgbVector = nan;
  end

end
