function varargout = SVNcreatelog(varargin)
%SVNCREATELOG  create log with status and revision numbers of svn directories
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = SVNcreatelog(varargin)
%
%   Input:
%   varargin  = directory (default is current directory)
%
%   Output:
%   varargout = string
%
%   Example
%   SVNcreatelog
%
%   See also 

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       C.(Kees) den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
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

% Created: 20 Feb 2009
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id: SVNcreatelog.m 10131 2014-02-04 16:27:26Z heijer $
% $Date: 2014-02-05 00:27:26 +0800 (Wed, 05 Feb 2014) $
% $Author: heijer $
% $Revision: 10131 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/SVN_fun/SVNcreatelog.m $
% $Keywords:

%%
if nargin > 0
    ReferencePath = varargin{1};
    if exist(ReferencePath, 'dir') && strcmp(ReferencePath(end), filesep) ||...
            exist(ReferencePath, 'file') == 2
        % make sure that ReferencePath is a directory (not a file) not
        % ending with a filesep
        ReferencePath = fileparts(ReferencePath);
    end
else
    ReferencePath = cd;
end

[svnErr, svnstatusMsg] = system(['svn status "' ReferencePath '"']);
isSVNdir = isempty(strfind(svnstatusMsg, 'is not a working copy'));

%%
if ~isSVNdir
    % check sub directories
    dirs = dir(ReferencePath);
    dirs = {dirs([dirs.isdir]).name};
    id = ~(strcmp(dirs, '.') | strcmp(dirs, '..'));
    dirs = dirs(id);
else
    dirs = {''};
end

str = sprintf('%s\n', datestr(now));
for i = 1:length(dirs)
    [svnErr, svnstatusMsg] = system(['svn status "' fullfile(ReferencePath, dirs{i}) '"']);
    [svnErr, svnversionMsg] = system(['svnversion "' fullfile(ReferencePath, dirs{i}) '"']);
    if isempty(strfind(svnstatusMsg, 'is not a working copy'))
        str = sprintf('%s\n', str, '%%', fullfile(ReferencePath, dirs{i}), svnversionMsg, svnstatusMsg);
    end
end

varargout = {str};