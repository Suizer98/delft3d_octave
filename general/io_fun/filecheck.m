function varargout = filecheck(file_name,varargin)
%FILECHECK   Check whether file exists and aborts with message as speficied
%
%    FILECHECK(file_name)
%    FILECHECK(file_name,mode)
%
% [FILEexists]     = FILECHECK(file_name)
% [FILEexists,mode]= FILECHECK(file_name,mode)
%
% where FILEexists is 1 if the file exists and
% where mode can be 
%
%  'o' = overwrite (default when file does NOT exist)
%  'c' = cancel     leads to error when no output arguments
%  'p' = prompt    (default when file does exist, after which o/c can be chosen)
%
%See also: EXIST

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

% $Id: filecheck.m 2986 2010-08-25 09:57:52Z geer $
% $Date: 2010-08-25 17:57:52 +0800 (Wed, 25 Aug 2010) $
% $Author: geer $
% $Revision: 2986 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/io_fun/filecheck.m $
% $Keywords$

   if nargin>1
      overwrite = varargin{1};
   else
      overwrite = 'p';
   end
   
   tmp = dir(file_name);
   
   if ~length(tmp)==0
      
      FILEexists = 1;
      
      if strcmp(overwrite,'p')
         disp(['File ',file_name,' alreay exists. '])
         overwrite = input(['Overwrite/cancel ? (o/c): '],'s');
         % for some reason input in Matlab R14 SP3 removes slashes
         % overwrite = input(['File ',file_name,' alreay exists. Overwrite/cancel ? (o/c)'],'s');
         while isempty(strfind('oac',overwrite))
             overwrite = input(['Overwrite/cancel ? (o/c): '],'s');
         end
      end
      
      if strcmpi(overwrite,'o')
         disp (['File ',file_name,' overwritten as it alreay exists.'])
      end      
      
      if strcmpi(overwrite,'c')
         if nargout==0
            error(['File ',file_name,' not saved as it alreay exists.'])
         else
            disp(['File ',file_name,' not saved as it alreay exists.'])
         end
      end        
      
   else
      FILEexists = 0;
      overwrite  = 'o'; % create
   end
   
   if nargout==1
      varargout = {FILEexists};
   elseif nargout==2
      varargout = {FILEexists,overwrite};
   end
   
%% EOF   