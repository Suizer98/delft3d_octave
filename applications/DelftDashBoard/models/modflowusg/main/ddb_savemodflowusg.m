function ddb_saveDelft3DFLOW(opt)
%DDB_SAVEDELFT3DFLOW  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_saveDelft3DFLOW(opt)
%
%   Input:
%   opt =
%
%
%
%
%   Example
%   ddb_saveDelft3DFLOW
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

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
handles=getHandles;

ddb_fixtimestepDelft3DFLOW(handles, ad); % Check input and output times

switch lower(opt)
    case{'save'}
        ddb_saveMDF(handles,ad);
    case{'saveas'}
        [filename, pathname, ~] = uiputfile('*.mdf', 'Select MDF File','');
        if pathname~=0
            curdir=[lower(cd) '\'];
            if ~strcmpi(curdir,pathname)
                filename=[pathname filename];
            end
            ii=strfind(filename,'.mdf');
            handles.model.delft3dflow.domain(ad).runid=filename(1:ii-1);
            handles.model.delft3dflow.domain(ad).mdfFile=filename;
            handles=ddb_saveMDF(handles,ad);
        end
    case{'saveall'}
        for i=1:handles.model.delft3dflow.nrDomains
            handles=ddb_saveAttributeFiles(handles,i,'saveall');
            handles=ddb_saveMDF(handles,i);
        end
    case{'saveallas'}
        [filename, pathname, ~] = uiputfile('*.mdf', 'Select MDF File','');
        if pathname~=0
            handles=ddb_saveAttributeFiles(handles,ad,'saveallas');
            curdir=[lower(cd) '\'];
            if ~strcmpi(curdir,pathname)
                filename=[pathname filename];
            end
            ii=strfind(filename,'.mdf');
            handles.model.delft3dflow.domain(ad).runid=filename(1:ii-1);
            handles.model.delft3dflow.domain(ad).mdfFile=filename;
            handles=ddb_saveMDF(handles,ad);
        end
    case{'savealldomains'}
        for i=1:handles.model.delft3dflow.nrDomains
            handles=ddb_saveAttributeFiles(handles,i,'saveall');
            handles=ddb_saveMDF(handles,i);
        end
end

setHandles(handles);

