function handles = ddb_readToolboxXML(handles, name)
%DDB_READTOOLBOXXML  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_readToolboxXML(handles, j)
%
%   Input:
%   handles =
%   j       =
%
%   Output:
%   handles =
%
%   Example
%   ddb_readToolboxXML
%
%   See also

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

% $Id: ddb_readToolboxXML.m 11760 2015-03-03 10:16:26Z ormondt $
% $Date: 2015-03-03 18:16:26 +0800 (Tue, 03 Mar 2015) $
% $Author: ormondt $
% $Revision: 11760 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/main/initialize/ddb_readToolboxXML.m $
% $Keywords: $

%%

fname=['toolbox.' handles.toolbox.(name).name '.xml'];

xmldir=handles.toolbox.(name).xmlDir;

handles.toolbox.(name).useXML=0;

handles.toolbox.(name).enable=0;

if exist([xmldir fname],'file')>0
    
    handles.toolbox.(name).useXML=1;
    
%    xml=gui_readXMLfile(fname,xmldir,'variableprefix',['toolbox.' name]);
    xml=gui_readXMLfile(fname,xmldir);
    
    handles.toolbox.(name).longName=xml.longname;
    handles.toolbox.(name).enable=xml.enable;
    
    handles.toolbox.(name).formodel=[];
    
    if isfield(xml,'formodel')
        if iscell(xml.formodel)
            for ii=1:length(xml.formodel)
                handles.toolbox.(name).formodel{ii}=xml.formodel(ii).formodel;
            end
        else
            handles.toolbox.(name).formodel{1}=xml.formodel;
        end
    end
    handles.toolbox.(name).GUI.element=xml.element;
else
    disp([xmldir fname ' not found!']);
end

