function start_of_PATHSTR = first_subdir(fullfilename,varargin)
%FIRST_SUBDIR   Returns first subdirectory names from filename
%
% returns first subdirectory names from filename
%
% subdir = first_subdir(file) 
% (n  > 0): subdir = first_subdir(file,n) returns first n subdirectories
% (n <= 0): subdir = first_subdir(file,n) returns all subdirectories except last n
%
% Example
% subdir = first_subdir(file,0)   gives full path
% subdir = first_subdir(file,1)   gives drive (e.g. d:\)
% subdir = first_subdir(file,-1)  removes last subdirectory from path
%
% See also: FILEPARTS, filepathstr, filename, filenameext, last_subdir

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
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% $Id: first_subdir.m 5018 2011-08-09 15:35:33Z boer_g $
% $Date: 2011-08-09 23:35:33 +0800 (Tue, 09 Aug 2011) $
% $Author: boer_g $
% $Revision: 5018 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/io_fun/first_subdir.m $
% $Keywords$

   %% Make sure traling directory end with a slash
   
   if isdir(fullfilename) & ~strcmp(fullfilename(end),filesep)
      fullfilename = [fullfilename filesep];
   end

%% Chop directory into parts

   [PATHSTR,NAME,EXT] = fileparts(fullfilename);
   
   PATHSTR            = path2os(PATHSTR);

   slash_positions    = findstr(PATHSTR,filesep);
   slash_positions    = [slash_positions length(fullfilename)-1];
   
   if nargin==2
      nsubdir = varargin{1};
   else
      nsubdir = 1;
   end

   if abs(nsubdir) > (length(slash_positions));
      nsubdir = sign(nsubdir).*length(slash_positions);
      disp(['Warning: n truncated to : ',num2str(nsubdir)]);
   end
   
%% Gather relevant directory parts
   
   if sign(nsubdir) > 0
   start_of_PATHSTR  = PATHSTR(1:1+slash_positions(nsubdir)-1);
   else
   start_of_PATHSTR  = PATHSTR(1:slash_positions(length(slash_positions) + nsubdir));
   end

%% EOF