function [y, errors] = interp1_log(Vx, Vy, x)
% interp1_log: Linear interpolation between the log of x-values
%
%   Linear interpolation between the log of the given x-values. Extrapolation
%   based on the second most outer values is done in case a value outside the
%   supplied range is requested.
%
%   BASED ON FUNCTION WRITTEN BY J.BECKERS WL | DELFT HYDRAULICS 23-03-2007
%
%   Syntax:
%   [y, errors] = interp1_log(Vx, Vy, x)
%
%   Input:
%   Vx          = array with x-values
%   Vy          = array with y-values
%   x           = requested x-value
%
%   Output:
%   y           = interpolated y-value
%   errors      = error number
%
%   Example
%   [y, errors] = interp1_log(Vx, Vy, x)
%
%   See also interp1

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       B.M. (Bas) Hoonhout
%
%       Bas.Hoonhout@Deltares.nl	
%
%       Deltares
%       P.O. Box 177 
%       2600 MH Delft 
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
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% Created: 29 juli 2009
% Created with Matlab version: 7.5.0.342 (R2007b)

% $Id: interp1_log.m 4584 2011-05-23 10:13:14Z hoonhout $
% $Date: 2011-05-23 18:13:14 +0800 (Mon, 23 May 2011) $
% $Author: hoonhout $
% $Revision: 4584 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/general/interp1_log.m $

%% initialize

y = NaN;
errors = 0;

% check input if required
[Vx, Vy, errors] = check_input(Vx, Vy);
if errors > 5
    return
end

if x <= 0
    errors = 10;
    return
end

%% determine ranges

% check if x is larger than first value in Vx 
if(x > Vx(1))
    disp('Warning: trying to interpolate to a value larger than Vx range, try extrapolation')
    
    i1 = 1;
    i2 = 2;
    errors = 1; % unreliable but not fatal
else

    % find the first element in Vx smaller than x (-log is larger)
    Vix = find(Vx < x);
    
    if(isempty(Vix))
        disp('Warning: trying to interpolate to a value smaller than Vx range, try extrapolation')
        
        i2 = length(Vx);
        i1 = i2-1;
        errors = 1; % unreliable result but not a fatal error
    else
        % interpolation between i1 and i2
        i2 = Vix(1);
        i1 = i2-1;
    end    
end

% take -log 
if Vx(i1) > 0 && Vx(i2) > 0 
    logx1 = -log(Vx(i1));
    logx2 = -log(Vx(i2));
    logx = -log(x);
elseif Vx(i1) > 0 
    y = Vy(i1);
    errors = 1;
    return
elseif Vx(i2) > 0 
    y = Vy(i2);
    errors = 1;
    return
else
    errors = 10;
    return
end

if logx1 == logx2 
    y = Vy(i2);
    return
end

y1 = Vy(i1);
y2 = Vy(i2);

%% interpolate
y = y1 + ((logx - logx1) / (logx2 - logx1)) * (y2 - y1);

%% function check input
function [Vx, Vy, errors] = check_input(Vx, Vy)

errors = 0;

% make proper vectors
Vx = reshape(Vx, length(Vx), 1);
Vy = reshape(Vy, length(Vy), 1);

if length(Vx) ~= length(Vy) 
    disp('Fatal error: dimensions of x,y vectors do not agree')
    errors = errors + 10;
    return
elseif length(Vx) < 2
    disp('Fatal error: length of x,y vectors must be at least 2')
    errors = errors + 10;
    return
end   

% check for negative and zero elements
if find(Vx<0) 
    disp('Error: there are negative elements in x vector')
    errors = errors + 1;
end

% check sorting
if -Vx ~= sort(-Vx) 
    disp('Error: x vector is not sorted in descending order, try to restore')
    errors = errors + 1;
    
    A = sortrows([-Vx,Vy]);
    Vx=-A(:,1);
    Vy=A(:,2);
end

if Vy ~= sort(Vy) 
    disp('Error: y vector is not sorted in ascending order, try to restore')
    errors = errors + 1;

    A = sortrows([Vy,Vx]);
    Vy=A(:,1);
    Vx=A(:,2);
end

% remove zeros in x and corresponding y values
if find(Vx==0) 
    disp('Warning: there are zeros in x vector, will be removed')
    
    nonzeros = max(2, nnz(Vx));
    Vx=Vx(1:nonzeros);
    Vy=Vy(1:nonzeros);
end
