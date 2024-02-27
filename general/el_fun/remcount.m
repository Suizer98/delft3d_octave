function remcount = remcount(x,y)
%REMCOUNT  Remainder after division
%
% remcount = remcount(x,y)
%
% remcount = rem(x-1,y)+1;
%
% Useful together with divcount to determine
% position in a rectangular grid,.
%
%  Example where x=1:12, y=3
%
%  x         1  2  3  4  5  6  7  8  9 10 11 12
%
%  rem       1  2  0  1  2  0  1  2  0  1  2  0
%
%  mod       1  2  0  1  2  0  1  2  0  1  2  0
%  remcount  1  2  3  1  2  3  1  2  3  1  2  3
%
%  div       0  0  1  1  1  2  2  2  3  3  3  4
%  divcount  1  1  1  2  2  2  3  3  3  4  4  4 
%
%  Similar to use of [i,j]=ind2sub([y inf],x)
%
%  i         1  2  3  1  2  3  1  2  3  1  2  3 ~ remcount
%  j         1  1  1  2  2  2  3  3  3  4  4  4 ~ divcount
%
% SEE ALSO: REM, MOD, DIV, DIVCOUNT, IND2SUB

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
%   --------------------------------------------------------------------

remcount = rem(x-1,y)+1;

