function varargout = istype(in,typename)
%ISTYPE checks whether array elements are of certian type
%
% [bool,<status>] = istype(in,''typename'')
%
% implemented for typename are:
% * 'axes'
% * 'figure'
% * 'text'
% * all other typenames (matlab data types) are passed 
%   to isa(), that returns 0 for unknown types.
%
% See also: ISHANDLE, ISA

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
%   --------------------------------------------------------------------

% $Id: istype.m 9900 2013-12-19 09:31:45Z tda.x $
% $Date: 2013-12-19 17:31:45 +0800 (Thu, 19 Dec 2013) $
% $Author: tda.x $
% $Revision: 9900 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/io_fun/istype.m $
% $Keywords$

status = 1;

switch lower(typename)

case 'axes'

   %% initialize with subset where only handles are true
   out            = ishandle(in);
   handle_indices = find(out);
   for i=handle_indices
      out(i) = strcmp(get(in(i),'Type'),'axes');
   end

case 'figure'

   %% initialize with subset where only handles are true
   out            = ishandle(in);
   handle_indices = find(out);
   for i=handle_indices
      out(i) = strcmp(get(in(i),'Type'),'figure');
   end

case 'text'

   %% inilitiaze at false
   out            = isnan(in); 
   for i=1:length(out(:))
      out(i) = strcmp(get(in(i),'Type'),'text');
   end

otherwise

   %try
      % this never crashes, but simply returns 0 if unknown.
      out    = isa(in,typename); 
   %catch
   %   if nargout==1
   %      error  (['Unknown type: ',typename])
   %   elseif nargout==2
   %      warning(['Unknown type: ',typename])
   %      out    = [];
   %      status = -1;
   %   end
   %end

end

    if nargout<2
   varargout = {out};
elseif nargout==2
   varargout = {out,status};
else
   error('syntax: [bool,<status>] = istype(in,''typename'')')
end
