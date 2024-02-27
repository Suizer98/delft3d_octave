function booleans = strmatcb(varargin)
%STRMATCHB   Find possible matches for string.
%
%   Same as STRMATCH, but returns boolean matrix instead of indices.
%   This allows for easy combining with numeric selections as:
%   find(strmatchb('OBAMA',P.names) | P.number==44) where P.number 
%   and P.names are database entries of the same length.
%
%   B = STRMATCHB(STR, STRARRAY) looks through the rows of the character
%   array or cell array of strings STRARRAY to find strings that begin
%   with the string contained in STR, and returns the matching row indices. 
%   Any trailing space characters in STR or STRARRAY are ignored when 
%   matching. STRMATCHB is fastest when STRARRAY is a character array. 
%
%   B = STRMATCHB(STR, STRARRAY, 'exact') compares STR with each row of
%   STRARRAY, looking for an exact match of the entire strings. Any 
%   trailing space characters in STR or STRARRAY are ignored when matching.
%
%   Examples
%     b = strmatchb('max',strvcat('max','minimax','maximum'))
%   returns b = [1 0 1] since rows 1 and 3 begin with 'max', and
%     b = strmatchb('max',strvcat('max','minimax','maximum'),'exact')
%   returns b = [1 0 0], since only row 1 matches 'max' exactly.
%   
%   See also STRMATCH, STRFIND, STRVCAT, STRCMP, STRNCMP, REGEXP.

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Delft University of Technology
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
%   USA or 
%   http://www.gnu.org/licenses/licenses.html,
%   http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% $Id: strmatchb.m 7223 2012-09-11 13:03:52Z boer_g $
% $Date: 2012-09-11 21:03:52 +0800 (Tue, 11 Sep 2012) $
% $Author: boer_g $
% $Revision: 7223 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/string_fun/strmatchb.m $
% $Keywords$

indices = strmatch(varargin{:});

booleans = repmat(false,1,length(varargin{2}));

booleans(indices) = true;

%% EOF