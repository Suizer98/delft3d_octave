function [svnMsg varargout] = SVNCall(ParamStr)
%SVN_CALL  One line description goes here.
%
%   Only works if a subversion command line client has been installed.
%
%   Syntax:
%   [svnMsg varargout] = SVNCall(ParamStr)
%
%   Input:
%   ParamStr  =
%
%   Output:
%   svnMsg    =
%   varargout =
%
%   Example
%   SVNCall
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

% $Id: SVNCall.m 10070 2014-01-24 22:01:27Z heijer $
% $Date: 2014-01-25 06:01:27 +0800 (Sat, 25 Jan 2014) $
% $Author: heijer $
% $Revision: 10070 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/SVN_fun/SVNCall.m $
% $Keywords:

%%
% History: 2005-11-30 created
% 2005-12-12 callStr changed to make SVN return values
% independent from localization

Msg = struct([]);
% call subversion with the given parameter string
%callStr=sprintf('svn %s',ParamStr);
callStr = sprintf('set LC_MESSAGES=en_En&&svn %s',ParamStr);
[svnErr, svnMsg] = system(callStr);

% create cellstring with one row per line
% svnMsg = strread(svnMsg,'%s',...
%     'delimiter', '\n',...
%     'whitespace', '');
% check for an error reported by the operating system
if svnErr~=0
    % an error is reported
    if strmatch('''svn', svnMsg) == 1
        Msg = struct(...
            'identifier', 'SVN:installationProblem',...
            'message', ['Problem using version control system:' 10 ...
                        ' Subversion could not be executed!']);
    else
        Msg = struct(...
            'identifier', 'SVN:versioningProblem',...
            'message', ['Problem using version control system:' 10 ...
                        cell2str(svnMsg,' ')]);
    end
elseif ~isempty(svnMsg)
    if strmatch('svn:', svnMsg) == 1
        Msg = struct(...
            'identifier', 'SVN:versioningProblem',...
            'message', ['Problem using version control system:' 10 ...
                        cell2str(svnMsg,' ')]);
    end
end

if nargout>1
    varargout = {Msg};
else
    error(Msg);
end

%%
function s = cell2str(cstr, indent)
% define linebreak
NewLine = char(10);

if iscellstr(cstr)
    % add indent and linebreak to each cell element
    h = strcat({indent}, cstr, {NewLine});
    % convert to char array
    s = [h{:}];
    % remove last NewLine
    s = s(1:(end-length(NewLine)));
else
    s = cstr;
end 