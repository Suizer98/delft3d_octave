function tmpfilename = gettmpfilename(varargin)
%GETTMPFILENAME   Gets temporary filename with specified pre- & postfix
%
% tmpfilename = GETTMPFILENAME
% tmpfilename = GETTMPFILENAME(directory)
% tmpfilename = GETTMPFILENAME(directory,prefix)
% tmpfilename = GETTMPFILENAME(directory,prefix,postfix)
%
% where by default
%
%    directory = getenv('TEMP');
%    prefix    = '~';
%    postfix = '.tmp';
%
% See also: FOPEN, DIR, EXIST, FILEPATHSTR, TEMPDIR, TEMPNAME

%   --------------------------------------------------------------------
%   Copyright (C) 2005-8 Delft University of Technology
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

% $Id: gettmpfilename.m 1875 2009-11-03 08:35:55Z boer_g $
% $Date: 2009-11-03 16:35:55 +0800 (Tue, 03 Nov 2009) $
% $Author: boer_g $
% $Revision: 1875 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/io_fun/gettmpfilename.m $
% $Keywords$

   directory = getenv('TEMP');
   prefix    = '~';
   extension = '.tmp';
   
   if nargin>0
      directory = char(varargin{1});
   end
   
   if nargin>1
      prefix    = char(varargin{2});
   end
   
   if nargin>2
      extension = char(varargin{3});
   end
   
   i=0;
   
   if ~isempty(directory)
      tmpfilename = [directory,filesep,prefix,num2str(i),extension];
   else
      tmpfilename = [prefix,num2str(i),extension];
   end
   
   while exist(tmpfilename,'file') 
   
      i=i+1;
      if ~isempty(directory)
         tmpfilename = [directory,filesep,prefix,num2str(i),extension];
      else
         tmpfilename = [prefix,num2str(i),extension];
      end
   
   end

%% EOF

 