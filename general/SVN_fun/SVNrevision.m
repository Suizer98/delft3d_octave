function varargout = SVNrevision(varargin)
%SVNREVISION  get the subversion revision
%
%   Only works if a subversion command line client has been installed.
%
%   Syntax:
%   varargout = SVNrevision(varargin)
%
%   Input:
%   varargin  = path of the source code part of the working directory
%
%   Output:
%   varargout = vector with 1 or 2 elements representing the lowest and
%               highest revision of the referenced path 
%
%   Example
%   revision = SVNrevision(oetroot)
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

% $Id: SVNrevision.m 2107 2009-12-21 14:45:44Z boer_g $
% $Date: 2009-12-21 22:45:44 +0800 (Mon, 21 Dec 2009) $
% $Author: boer_g $
% $Revision: 2107 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/SVN_fun/SVNrevision.m $
% $Keywords:

%%
% set default return value
v = 0;
ReferencePath = cd;
if nargin > 0
    ReferencePath = varargin{1};
    if exist(ReferencePath, 'dir') && strcmp(ReferencePath(end), filesep) ||...
            exist(ReferencePath, 'file') == 2
        % make sure that ReferencePath is a directory (not a file) not
        % ending with a filesep
        ReferencePath = fileparts(ReferencePath);
    end
end

% call subversion to find out version control revision
[svnErr svnMsg] = system(['svnversion "' ReferencePath '"']);

% create cellstring with one row per line
svnMsg = strread(svnMsg, '%s',...
    'whitespace', char(10));
% check for an error reported by the operating system
if svnErr ~= 0
    % an error is reported
    if strmatch('''svnversion', svnMsg{1})==1
        warnMsgID = 'SVN:installationProblem';
        warnMsg = ['Problem using version control system:' 10 ...
            ' Subversion could not be executed!'];
    else
        warnMsgID = 'SVN:versioningProblem';
        warnMsg = ['Problem using version control system:' 10 ...
            ' ' [svnMsg{:}] ];
    end
else
    d1 = regexp(svnMsg{1}, '\d+|:', 'match');
    if isempty(d1)
        warnMsgID = 'SVN:versioningProblem';
        warnMsg = ['Problem using version control system:' 10 ...
            ' ' [svnMsg{:}] ];
    else
        v(1) = str2double(d1{1});
        if length(d1) == 3
            v(2) = str2double(d1{3});
        end
        if sum(cellfun('length',d1)) ~= length(svnMsg{1})
            warnMsgID = 'SVN:versioningProblem';
            warnMsg = ['Problem using version control system:' 10 ...
                ' Working directory is not up to date !'];
        else
            warnMsgID = [];
        end
    end
end

if ~isempty(warnMsgID)
   
    button = uigetpref('SVN_Interface','ContinueOnRevisionProblem',...
        'Version problem',...
        [warnMsg 10 'Continue anyway ?'],...
        {'Yes','No';'Yes','No'},...
        'DefaultButton','Yes');
    if strcmpi(button, 'Yes')
        warning(warnMsgID, '%s', warnMsg);
    else
        error(['User canceled -> ' warnMsg])
    end
end

varargout = {v};