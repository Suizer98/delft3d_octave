function [b z n converged] = find_zero_poly(un, b, z, varargin)
%FIND_ZERO_POLY  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = find_zero_poly(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   find_zero_poly
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl	
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
% Created: 25 Aug 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: find_zero_poly.m 6097 2012-05-01 10:25:31Z hoonhout $
% $Date: 2012-05-01 18:25:31 +0800 (Tue, 01 May 2012) $
% $Author: hoonhout $
% $Revision: 6097 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/engines/DirectionalSampling/LineSearch/find_zero_poly.m $
% $Keywords: $
%% settings

OPT = struct(...
    'zFunction',        '',                 ...
    'epsZ',             1e-2,               ...     % precision in stop criterium
    'maxiter',          50,                 ...     % maximum number of iterations
    'maxretry',         3,                  ...     % maximum number of iterations before retry
    'maxorder',         3                   ...     % maximum order of polynom in line search
);

OPT = setproperty(OPT, varargin{:});

%% search zero

converged = true;

n = 0;
l = length(z);

while abs(z(end))>OPT.epsZ || length(z) == l
    n   = n+1;
    p   = polyfit(z,b,min([length(b)-1 OPT.maxorder]));
    b   = [b polyval(p,0)];
    z   = [z feval(OPT.zFunction, un, b(end))];

    if length(z)<=OPT.maxretry
        bl  = b(end-1);
        while ~isfinite(z(end))
            n   = n+1;
            b   = [b(1:end-1) mean([bl b(end)])];
            z   = [z(1:end-1) feval(OPT.zFunction, un, b(end))];

            if length(z)>OPT.maxiter+1
                break;
            end
        end
    end

    b = real(b);
    z = real(z);
    
    if ~isfinite(z(end)) || length(z)>OPT.maxiter+1
        converged = false;
        break;
    end
end

b = b(l+1:end);
z = z(l+1:end);
