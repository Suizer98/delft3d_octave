function handles = muppet_getDirectories(handles)
%MUPPET_GETDIRECTORIES
%
%   Defines handles.muppetdir, handles.xmldir and handles.settingsdir
%
%   Syntax:
%   [handles ok] = muppet_getDirectories(handles)

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: muppet_getDirectories.m 13219 2017-03-24 11:47:39Z ormondt $
% $Date: 2017-03-24 19:47:39 +0800 (Fri, 24 Mar 2017) $
% $Author: ormondt $
% $Revision: 13219 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/muppet_v4/src/initialize/muppet_getDirectories.m $
% $Keywords: $

%% Find Muppet directories

% Find muppet path
if isdeployed
    [status, result] = system('path');
    exedir = char(regexpi(result, 'Path=(.*?);', 'tokens', 'once'));
    handles.muppetdir=[fileparts(exedir) filesep];
%     handles.xmldir=[ctfroot filesep 'xml' filesep];
%     handles.xmlguidir=[ctfroot filesep 'xml' filesep 'gui' filesep];
else
    % Muppet.ini file must sit in the same directory as muppet.m (or muppet4.m)
    mppath=fileparts(which('muppet4'));
    if exist([mppath filesep 'muppet.ini'],'file')
        fid=fopen([mppath filesep 'muppet.ini'],'r');
        pth = fgetl(fid);
        fclose(fid);
        if ~strcmpi(pth(end),filesep)
            pth=[pth filesep];
        end
        handles.muppetdir=pth;
    else
        % No muppet.ini, use muppet directory in code repository
        handles.muppetdir=[fileparts(mppath) filesep];
    end
%     handles.xmldir=[mppath filesep 'xml' filesep];
%     handles.xmlguidir=[mppath filesep 'xml' filesep 'gui' filesep];
end

handles.settingsdir=[handles.muppetdir 'settings' filesep];
handles.xmldir=[handles.settingsdir 'xml' filesep];
handles.xmlguidir=[handles.settingsdir 'xml' filesep 'gui' filesep];
