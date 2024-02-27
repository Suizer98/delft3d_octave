function varargout = fgetl_no_comment_line(fid,commentchar,varargin);
%FGETL_NO_COMMENT_LINE  Reads next line that is no comment file from file
%
% string = fgetl_no_comment_line(fid,commentchar);
% string = fgetl_no_comment_line(fid,commentchar,allow_empty_lines);
% string = fgetl_no_comment_line(fid,commentchar,allow_empty_lines,remove_spaces_at_start);
%
% By default allow_empty_lines is false
% so all lines with only linefeeds are skipped
%
% At end of file -1 is returned, just like fgetl.
%
% [string,n]= fgetl_no_comment_line(); returns number of read lines.
%
% See also: FGETL, ISCOMMENTLINE

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

% $Id: fgetl_no_comment_line.m 7794 2012-12-06 12:06:03Z boer_g $
% $Date: 2012-12-06 20:06:03 +0800 (Thu, 06 Dec 2012) $
% $Author: boer_g $
% $Revision: 7794 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/io_fun/fgetl_no_comment_line.m $
% $Keywords$

if nargin>2
   allow_empty_lines = varargin{1};
else
   allow_empty_lines = false;
end

if nargin>3
   remove_spaces_at_start = varargin{2};
else
   remove_spaces_at_start = true;
end

    n = 0;
    
    while 1
    
       rec = fgetl(fid);
       if rec==-1
          break
       else
          if remove_spaces_at_start
             rec = deblankstart(rec);
          end
          
          %disp(rec)
          %disp([ ~isempty(rec)   allow_empty_lines])
          
          n   = n+1;
          if (~isempty(rec) | allow_empty_lines)
          
             % ~isempty(rec) | allow_empty_lines 0 1: 1 emtpy string, allowed
             % ~isempty(rec) | allow_empty_lines 0 0: 0 emtpy string, but not allowed
             % ~isempty(rec) | allow_empty_lines 1 1: 1 full string   which is always allowed
             % ~isempty(rec) | allow_empty_lines 1 0: 1 full string   which is always allowed
          
             if ~iscommentline(rec,commentchar,remove_spaces_at_start)
            
             break
             end
          end
       end % if rec==-1
    end   
    
    if nargout==1
       varargout = {rec};
    elseif nargout==2
       varargout = {rec,n};
    end
    
%% EOF    
    