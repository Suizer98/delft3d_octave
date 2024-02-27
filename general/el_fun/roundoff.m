function Xround = roundoff(X, n, varargin)
%ROUNDOFF   routine rounds number to predefined number of decimal digits
%
%   Please be aware of floating point behaviour like:
%      roundoff(1.4,1) == 1.4 = false
%      14/10           == 1.4 = true
%
%   This routine returns a rounded number to a specified number of decimal
%   digits
%
%   Syntax:
%   Xround = roundoff(X, n, varargin)
%
%   Input:
%   X        = number, or matrix of numbers, to be rounded
%   n        = number of decimal digits to be rounded to (can also be
%              negative)
%   varargin = optional mode: either 'round' (default), 'ceil', 'floor' or
%               'fix'
%              optional 4th argument 'multiple': by this option, X can be
%              rounded to multiples of n
%
%   Output:
%   Xround   = rounded X, same size as X
%
%   Example
%               roundoff(5.8652, 2)
%               ans =
%                   5.8700
%
%               roundoff(5.8652, 2, 'floor')
%               ans =
%                   5.8600
%
%               roundoff(5.8652, 0)
%               ans =
%                   6
%
%               roundoff(5.8652, -1)
%               ans =
%                   10
%
%   See also round floor ceil fix

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Kees den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
%       The Netherlands
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

% Created: 07 May 2009
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id: roundoff.m 5691 2012-01-11 15:46:47Z tda.x $
% $Date: 2012-01-11 23:46:47 +0800 (Wed, 11 Jan 2012) $
% $Author: tda.x $
% $Revision: 5691 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/el_fun/roundoff.m $
% $Keywords: $

%% check input
if nargin == 1
    getdefaults('n', 0, true);
elseif nargin == 0
    error('ROUNDOFF:NotEnoughInputs','At least input argument "X" must be specified')
end



%% check varargin
mode = @round;
if ~isempty(varargin)
    mode = varargin{1};
    if ~ismember(char(mode), {'round' 'ceil' 'floor' 'fix'})
        error(sprintf('Invalid mode: "%s"', char(mode)))
    end
    
    % for backward compatibility, change 'normal' to 'round'
    if strcmp(char(mode), 'normal')
        warning(sprintf('Mode "%s" changed to "%s".', mode, 'round'))
        mode = @round;
    end
end


if length(varargin) == 2 && strcmpi(varargin{2}, 'multiple')
    % optionally, X can be rounded to multiples of n
    multiple = n;
else
    if round(n) ~= n
        error('ROUNDOFF:IntegerReq','Input "n" must be an integer')
    end
    % by default, n represents the number of decimal digits where X must be
    % rounded to
    multiple = 10.^-n;
end

Xround = feval(mode, X ./ multiple) .* multiple;