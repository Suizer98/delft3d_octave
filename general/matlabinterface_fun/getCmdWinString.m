function CmdWinTXT = getCmdWinString(varargin)
%GETCMDWINSTRING  gets the contents of the command window.
%
%   This function uses undocumented java objects to retrieve the content of
%   the matlab command window.
%
%   Syntax:
%   CmdWinTXT = getCmdWinString;
%
%   Output:
%   CmdWinTXT = A cell containing all lines that were in the command window
%               at the time this function was run. This includes the matlab
%               ">>" signs. A call to cellfun for replacing the ">>" with ""
%               will remove these. This method can also be used to remove
%               empty lines or strtrim the lines.
%
%   Example
%   getCmdWinString
%
%   See also cellfun strtrim strrep

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

% Created: 14 Apr 2009
% Created with Matlab version: 7.6.0.324 (R2008a)

% $Id: getCmdWinString.m 362 2009-04-14 14:02:55Z geer $
% $Date: 2009-04-14 22:02:55 +0800 (Tue, 14 Apr 2009) $
% $Author: geer $
% $Revision: 362 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/matlabinterface_fun/getCmdWinString.m $
% $Keywords: $

%% Get the java handle of the command window parts
MWlisteners = com.mathworks.mde.cmdwin.CmdWinDocument.getInstance.getDocumentListeners;

for i=1:length(MWlisteners)
    if strcmp(class(MWlisteners(i)),'javax.swing.JTextArea$AccessibleJTextArea')
        % this is the handle to the text area
        MWCmdText = MWlisteners(i);
        break
    end
end

%% Retrieve the java object that contains the text
MWAccessibleText = MWCmdText.getAccessibleText;
    
%% Retrieve all text from the object
% query the number of characters that are in the text object
NumberOfCharacters = MWAccessibleText.getCharCount;

% retrieve the javax.swing.JText object with all characters and convert to
% matlab char
CmdWinTXT = char(MWAccessibleText.getTextRange(1,NumberOfCharacters));

% strread the char to distinguish the lines
CmdWinTXT = strread(CmdWinTXT','%s','delimiter',char(10));
