function end_of_PATHSTR = last_subdir(fullfilename,varargin)
%LAST_SUBDIR   Returns last subdirectory names from filename
%
% returns last subdirectory name from filename
%
% subdir = last_subdir(file) 
% subdir = last_subdir(file,n) returns last n subdirectories
%                             (default: n=1 )
%
% See also: FILEPARTS, FILEPATHSTR, FILENAME, FILENAMEEXT, FIRST_SUBDIR

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

% $Id: last_subdir.m 3211 2010-10-29 16:22:01Z thijs@damsma.net $
% $Date: 2010-10-30 00:22:01 +0800 (Sat, 30 Oct 2010) $
% $Author: thijs@damsma.net $
% $Revision: 3211 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/io_fun/last_subdir.m $
% $Keywords$

   %% Make sure any trailing directories end with a filesep
   if exist(fullfilename)==7
   fullfilename = fullfile(fullfilename,filesep,'');
   end
   
   %% Remove any trailing file names 
   PATHSTR                  = fileparts(fullfilename);
   PATHSTR                  = path2os(PATHSTR);
   
   slash_positions          = findstr(PATHSTR,filesep);
   slash_positions          = [0 slash_positions];
   
   if nargin==2
      nsubdir = varargin{1};
   else
      nsubdir = 1;
   end
   
   if nsubdir > (length(slash_positions));
      nsubdir = length(slash_positions);
      disp(['Warning: n truncated to : ',num2str(nsubdir)])
   end
   
   end_of_PATHSTR  = PATHSTR(slash_positions(end-nsubdir+1)+1:end);

%% EOF