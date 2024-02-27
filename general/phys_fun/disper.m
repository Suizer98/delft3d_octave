function k = disper(w, h, g)
%DISPER  Linear dispersion relation.
%
%   absolute error in k*h < 5.0e-16 for all k*h
%
%   Syntax:
%   k = disper(w, h, g)
%
%   Input:
%   w = 2*pi/T, were T is wave period
%   h = water depth
%   g = gravity constant
%
%   Output:
%   k = wave number
%
%   Example
%   k = disper(2*pi/5,5,9.81);

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 <COMPANY>
%       G. Klopman, Delft Hydraulics, 6 Dec 1994
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
% Created: 19 Nov 2010
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id: disper.m 3766 2010-12-29 15:59:16Z hoonhout $
% $Date: 2010-12-29 23:59:16 +0800 (Wed, 29 Dec 2010) $
% $Author: hoonhout $
% $Revision: 3766 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/phys_fun/disper.m $
% $Keywords: $

%%
if nargin < 3,
  g = 9.81;
end;

w2 = (w.^2) .* h ./ g;
q  = w2 ./ (1 - exp (-(w2.^(5/4)))) .^ (2/5);

for j=1:2,
  thq     = tanh(q);
  thq2    = 1 - thq.^2;
  a       = (1 - q .* thq) .* thq2;
  b       = thq + q .* thq2;
  c       = q .* thq - w2;
  arg     = (b.^2) - 4 .* a .* c;
  arg     = (-b + sqrt(arg)) ./ (2 * a);
  iq      = find (abs(a.*c) < 1.0e-8 * (b.^2));
  arg(iq) = - c(iq) ./ b(iq);
  q       = q + arg;
end;

k = sign(w) .* q ./ h;

ik    = isnan (k);
k(ik) = zeros(size(k(ik)));
