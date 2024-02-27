function URL = SVNgetURL(varargin)
%SVN_GETURL  One line description goes here.
%
%   Only works if a subversion command line client has been installed.
%
%   Syntax:
%   URL = SVNgetURL(varargin)
%
%   Input:
%   varargin = WorkingCopy (directory)
%
%   Output:
%   URL         =
%
%   Example
%   URL = SVNgetURL(oetroot)
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

% Created: 19 Feb 2009 (obtained from svn.haxx.se, author: Sven Probst)
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id: SVNgetURL.m 10069 2014-01-24 16:33:01Z heijer $
% $Date: 2014-01-25 00:33:01 +0800 (Sat, 25 Jan 2014) $
% $Author: heijer $
% $Revision: 10069 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/SVN_fun/SVNgetURL.m $
% $Keywords:

%%
% default return value
URL = []; %#ok<NASGU>
WorkingCopy = cd;
if nargin > 0
    WorkingCopy = varargin{1};
end

% call subversion with the given parameter string to get a list of all
% properties
ParamStr = sprintf('info "%s"', WorkingCopy);
svnMsg = SVNCall(ParamStr);

URL_Idx = strncmp('URL:',svnMsg, 4);
if isempty(URL_Idx)
    error('SVN:versioningProblem', '%s',...
        ['Problem using version control system - no URL found:' 10 ...
            ' ' [svnMsg{:}]])
end
URL = svnMsg{URL_Idx}(6:end); 