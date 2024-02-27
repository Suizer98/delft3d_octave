function deletefile(varargin)
%DELETEFILE   vectorized version of delete file
%
%    deletefile(one_file,<other_files,<other_files,<...>>>)
%
% where any other_files can be a char or a cellstr (collection of other_files)
%
%See also: delete, copyfile, !

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares for Building with Nature
%       Gerben J. de Boer
%
%       gerben.deboer@Deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: deletefile.m 6841 2012-07-10 10:23:54Z boer_g $
% $Date: 2012-07-10 18:23:54 +0800 (Tue, 10 Jul 2012) $
% $Author: boer_g $
% $Revision: 6841 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/io_fun/deletefile.m $
% $Keywords: $

% 1st part is same code as KML2kmz

%% gather all files

   if        ischar(varargin{1})
   kml_file       = varargin{1};
   elseif iscellstr(varargin{1})
   kml_file       = varargin{1}{1};
   end
   
   all_files = {};
   for i=1:nargin
      if                 ischar(varargin{i})
      all_files = {all_files{:} varargin{i}};
      elseif          iscellstr(varargin{i})
      all_files = {all_files{:} varargin{i}{:}};
      else
      error('only cellstr or char allowed')
      end
   end

%% remove redundancies

   all_files = unique(all_files);

%% go

   for i=1:length(all_files)
      delete(all_files{i})
   end

