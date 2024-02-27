function s1 = deblankstart(s)
%DEBLANKSTART Remove leading blanks.
%   deblankstart(S) removes leading blanks from string S.
%
%   Based on DEBLANK of The MathWorks, Inc.
%
% See also: DEBLANK, STRTRIM

%   --------------------------------------------------------------------
%   Copyright (C) 2006 Delft University of Technology
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

% $Id: deblankstart.m 496 2009-06-04 15:47:01Z boer_g $
% $Date: 2009-06-04 23:47:01 +0800 (Thu, 04 Jun 2009) $
% $Author: boer_g $
% $Revision: 496 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/string_fun/deblankstart.m $
% $Keywords$

   if ~isempty(s) & ~isstr(s)
       warning('Input must be a string.')
   end
   
   if isempty(s)
       s1 = s([]);
   else
     % remove leading blanks
     [r,c] = find(s ~= ' ' & s ~= 0);
     if isempty(c)
       s1 = s([]);
     else
       s1 = s(:,min(c):end);
     end
   end

%% EOF
