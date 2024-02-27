function varargout = fgetl_key_val(fid_or_rec,varargin);
%FGETL_KEY_VAL  read <keyword,value> pair from file/string that is no comment file
%
% [keyword,value] = fgetl_key_val(fid,commentchar);
% [keyword,value] = fgetl_key_val(fid,commentchar,allow_empty_lines);
% [keyword,value] = fgetl_key_val(fid,commentchar,allow_empty_lines,remove_spaces_at_start);
%
% By default allow_empty_lines is false
% so all lines with only linefeeds are skipped
%
% At end of file '' is returned.
%
% [keyword,value,rec  ]= fgetl_key_val(); returns remainder of line after value
% [keyword,value,rec,n]= fgetl_key_val(); returns number of read lines n.
%
% Example:
% [keyword,value] = fgetl_key_val(fid) % to read following line in file: "Parameter=H10"
% [keyword,value] = fgetl_key_val('Parameter=H10')
%
% See also: FGETL, ISCOMMENTLINE, FGETL_NO_COMMENT_LINE

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
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% $Id: fgetl_key_val.m 8896 2013-07-08 13:08:25Z ivo.pasmans.x $
% $Date: 2013-07-08 21:08:25 +0800 (Mon, 08 Jul 2013) $
% $Author: ivo.pasmans.x $
% $Revision: 8896 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/io_fun/fgetl_key_val.m $
% $Keywords$

   commentchar = '';
   if nargin > 1
      commentchar = varargin{1};
      nextarg = 2;
   else
      nextarg = 1;
   end

   if isnumeric(fid_or_rec)
   rec                = fgetl_no_comment_line(fid_or_rec,commentchar);
   else
   rec                = fid_or_rec;
   end
   
   
   if isempty(rec) | rec==-1
      keyword=[]; 
      value=[]; 
      rec=[]; 
   else
      
   index_equal_sign   = strfind(rec,'=');

   index_comment_sign = strfind(rec,commentchar,varargin{nextarg:end});
   if isempty(index_comment_sign)
      index_comment_sign = length(rec)+1;
   end
   
   keyword = strtrim(rec(                    1:index_equal_sign-1));
   value   = strtrim(rec(index_equal_sign+1   :index_comment_sign(1)-1));
   rec     =         rec(index_comment_sign(1):end);

   %[keyword,rec] = strtok(rec)
   %[issign ,rec] = strtok(rec)
   %[value  ,rec] = strtok(rec)
   end
    
    if nargout==2
       varargout = {keyword,value};
    elseif nargout==3
       varargout = {keyword,value,rec};
    elseif nargout==4
       varargout = {keyword,value,rec};
    end
    
%% EOF