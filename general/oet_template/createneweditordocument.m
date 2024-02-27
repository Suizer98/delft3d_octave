function createneweditordocument(str)
%CREATENEWEDITORDOCUMENT  Creates a new document in the matlab editor.
%
%   This function creates a new document in the matlab editor with the
%   string as specified in the input.
%
%   Syntax:
%   createneweditordocument(str)
%
%   Input:
%   str       = (string) Body of the new document
%
%   Example 
%   createneweditordocument('function test()');
%
%   See also oetnewfun oetnewtest oetnewclass

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltares.nl	
%
%       Rotterdamseweg 185
%       2629 HD Delft
%       P.O. 177
%       2600 MH Delft
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 24 Nov 2010
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: createneweditordocument.m 4352 2011-03-25 14:31:07Z geer $
% $Date: 2011-03-25 22:31:07 +0800 (Fri, 25 Mar 2011) $
% $Author: geer $
% $Revision: 4352 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/oet_template/createneweditordocument.m $
% $Keywords: $

%% Check input
if nargin == 0
    str = '';
end

%% Check version and open document
if ~exist('verLessThan','file') || verLessThan('matlab', '7.11')
    com.mathworks.mlservices.MLEditorServices.newDocument(str)
else
    document = com.mathworks.mlservices.MLEditorServices.getEditorApplication.newEditor(str);
    document.smartIndentContents;
end