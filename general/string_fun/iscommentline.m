function comment = iscommentline(rec,varargin)
%ISCOMMENTLINE  determines whether a 1D char array is a commentline
%
%   boolean = iscommentline(rec)
%   boolean = iscommentline(rec,commentchar)
%   boolean = iscommentline(rec,commentchar,remove_spaces_at_start)
%
%   by default commentchar = ';'
%   boolean false when rec = [];
%
%   * By default spaces at the beginning of the line are removed, 
%     spaces at the end are not removed. Set 
%     remove_spaces_at_start to true to use only the first 
%     chartacter to check whether is is a commentline.
%
%   * commentchar can contain multiple character values (like *, #, %)
%
%   * rec can be 2 2D char array, where the first dimension = line number, 
%     or a cell array
%
%
% See also: DEBLANK

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

% $Id: iscommentline.m 5019 2011-08-10 06:38:16Z boer_g $
% $Date: 2011-08-10 14:38:16 +0800 (Wed, 10 Aug 2011) $
% $Author: boer_g $
% $Revision: 5019 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/string_fun/iscommentline.m $
% $Keywords$

%% Input

   if nargin>1
      commentchars = varargin{1};
   else
      commentchars = ';';
   end
   
   if nargin>2
      remove_spaces_at_start = varargin{1};
   else
      remove_spaces_at_start = true;
   end
   
   if isempty(rec)
      comment = true;
   else
   
%% Make sure rec is always a cell array
      
      rec = cellstr(rec);
      
%% Pre allocate at false
      
      comment = repmat(false,[1 length(rec)]);
      
%% Scroll line numbers in cell array
%  and set to true when considered comment line
      
      for linenumber=1:length(rec)
      
         if remove_spaces_at_start
            currentrec = deblankstart(rec{linenumber});
         else
            currentrec = rec;
         end
      
         if ~isempty(currentrec)
            comment(linenumber) = false;
            for j=1:length(commentchars)
               if strcmp(currentrec(1),commentchars(j))
                  comment(linenumber) = true;
                  break
               end
            end
         end
      end
   end
   
%% EOF