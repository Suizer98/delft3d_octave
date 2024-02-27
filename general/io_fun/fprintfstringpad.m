function varargout = fprintfstringpad(fid, totallength, string, varargin)
%FPRINTFSTRINGPAD   print string to file with precise length
%
% FPRINTFSTRINGPAD(fid, totallength, string, padcharacter <optional>)
% writes a string to file and to pads stringlength with spaces, or with 
% optional extra character.
%
% If the string is longer than totallength, the string is truncated.
%
% An optional output can be added for errorhandling
% iostat = fprintfstringpad(...), where iostat=1 when succesfull
% and iostat=-1 when an error occurred.
%
%See also: FPRINTF, PAD

%   --------------------------------------------------------------------
%   Copyright (C) 2004 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@citg.tudelft.nl	
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

% $Id: fprintfstringpad.m 5308 2011-10-06 08:54:16Z verhage $
% $Date: 2011-10-06 16:54:16 +0800 (Thu, 06 Oct 2011) $
% $Author: verhage $
% $Revision: 5308 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/io_fun/fprintfstringpad.m $
% $Keywords$

iostat=0;
try 
   if nargin ==4
      padcharacter = varargin{1};
   else
      padcharacter = ' ';
   end
   
   for j=1:totallength
      if j > length(string)
         fprintf(fid,'%1c',padcharacter);
      else
         fprintf(fid,'%1c',string(j));
      end
   end
catch
   % error
   iostat=-1;
end

if nargout==1
   varargout = {iostat};
end

%% EOF