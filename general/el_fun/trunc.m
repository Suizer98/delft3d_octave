function y = trunc(x,varargin)
%TRUNC   rounds/floors/ceils/truncs a real to a specified number of decimals
%
% trunc(x) rounds x to nearest integer 
% (0 digits behind the decimal seperator).
%
% trunc(x,n_digits) rounds x to the number of digits 
% (n_digits) digits behind the decimal seperator.
% (default n_digits= 0). When n_digits < 0, n_digits 
% significant digits left of the decimal seperator are set to 0.
%
% trunc(x,n_digits,method) uses method for rounding:
% 'ceil', 'floor', 'fix', 'round'. (default method = 'round')
%
% method: y = round(10^n_digits*x)/10^n_digits;
%
% Examples: (format long e)
%
% trunc(111.111,-3) = 0; warning from trunc(..): too many digits removed: 999 => 0!!
% trunc(111.111,-2) = 100
% trunc(111.111,-1) = 110
% trunc(111.111,0)  = 111
% trunc(111.111,1)  = 111.1
% trunc(111.111,2)  = 111.11
% trunc(111.111,3)  = 111.111
% trunc(111.111,4)  = 111.111
%
% trunc(7.7777,2,'round') = 7.78
% trunc(7.7777,2,'floor') = 7.77
%
%See also: ROUND, ROUNDOFF

%   --------------------------------------------------------------------
%   Copyright (C) 2005 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl	
%
%       Fluid Mechanics Section
%       Faculty of Civil Engineering and Geosciences
%       PO Box 5048
%       2600 GA Delft
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

if nargin>1
   number_of_digits = varargin{1};
else   
   number_of_digits = 0;
end

if nargin>2
   method = varargin{2};
else   
   method = 'round';
end

fac = 10^number_of_digits;

if     strcmp(method,'round')

   y = round((fac.*x))./fac;

elseif strcmp(method,'floor')

   y = floor((fac.*x))./fac;

elseif strcmp(method,'ceil')

   y = ceil((fac.*x))./fac;

elseif strcmp(method,'fix')

   y = fix((fac.*x))./fac;

end   

if abs(x*fac) < 1
   disp(['warning from trunc(..): too many digits removed: ',num2str(x),' => 0 !!'])
   y = 0;
end

%% EOF