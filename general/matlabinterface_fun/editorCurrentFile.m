function [CurFile varargout] = editorCurrentFile
%EDITORCURRENTFILE  provides path to the current file in the matlab editor
%
%   This function uses undocumented matlab stuff to get the path of the
%   file that is currently open in the matlab editor. If more than one
%   files are open it takes the one that is selected).
%
%   Syntax:
%   [CurFile varargout] = EditorCurrentFile
%
%   Output:
%   CurFile   = The path to the current file (string)
%   varargout = java handle to the EditorViewContainer
%
%   Example
%   EditorCurrentFile
%
%   See also 

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltares.nl	
%
%       <ADDRESS>
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

% Created: 08 Apr 2009
% Created with Matlab version: 7.6.0.324 (R2008a)

% $Id: editorCurrentFile.m 902 2009-09-02 12:49:14Z geer $
% $Date: 2009-09-02 20:49:14 +0800 (Wed, 02 Sep 2009) $
% $Author: geer $
% $Revision: 902 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/matlabinterface_fun/editorCurrentFile.m $
% $Keywords: $

%% Start of function

% Define the handle for the set of java commands:
desktopHandle=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;

% Determine the last selected document in the editor:
lastDocument=desktopHandle.getLastDocumentSelectedInGroup('Editor');

% Strip off the '*' which indicates that it has been modified.
CurFile=strtok(char(desktopHandle.getTitle(lastDocument)),'*');

if nargout>1
    varargout{1}=lastDocument;
end

%% That's it....