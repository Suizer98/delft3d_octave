function handles = ddb_coordConvertDelft3DFLOW(handles)
%DDB_COORDCONVERTDELFT3DFLOW  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_coordConvertDelft3DFLOW(handles)
%
%   Input:
%   handles =
%
%   Output:
%   handles =
%
%   Example
%   ddb_coordConvertDelft3DFLOW
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
ddb_plotDelft3DFLOW(handles,'delete');

if handles.ConvertModelData
    NewSystem=handles.screenParameters.CoordinateSystem;
    OldSystem=handles.screenParameters.OldCoordinateSystem;
    
    for id=1:handles.GUIData.nrFlowDomains
        
        if ~isempty(handles.model.delft3dflow.domain(id).grdFile)
            
            %% Grid
            [filename, pathname, filterindex] = uiputfile('*.grd',['Select grid file for domain ' handles.model.delft3dflow.domain(id).runid],handles.model.delft3dflow.domain(id).grdFile);
            if pathname~=0
                curdir=[lower(cd) '\'];
                if ~strcmpi(curdir,pathname)
                    filename=[pathname filename];
                end
            else
                filename=handles.model.delft3dflow.domain(id).grdFile;
            end
            
            x=handles.Model(handles.activeModel.Nr).Input(id).gridX;
            y=handles.Model(handles.activeModel.Nr).Input(id).gridY;
            [x,y]=ddb_coordConvert(x,y,OldSystem,NewSystem);
            handles.Model(handles.ActiveModel.Nr).Input(id).gridX=x;
            handles.Model(handles.ActiveModel.Nr).Input(id).gridY=y;
            
            handles.model.delft3dflow.domain(id).grdFile=filename;
            encfile=[filename(1:end-3) 'enc'];
            if ~strcmpi(handles.model.delft3dflow.domain(id).encFile,encfile)
                copyfile(handles.model.delft3dflow.domain(id).encFile,encfile);
            end
            handles.model.delft3dflow.domain(id).encFile=encfile;
            
            if strcmpi(handles.screenParameters.CoordinateSystem.Type,'geographic')
                coord='Spherical';
            else
                coord='Cartesian';
            end
            ddb_wlgrid('write','FileName',filename,'X',x,'Y',y,'CoordinateSystem',coord);
            
            %% Open boundaries
            for ib=1:handles.model.delft3dflow.domain(id).nrOpenBoundaries
                [xb,yb,zb]=ddb_getBoundaryCoordinates(handles,id,ib);
                handles.model.delft3dflow.domain(id).openBoundaries(ib).x=xb;
                handles.model.delft3dflow.domain(id).openBoundaries(ib).y=yb;
            end
            
        end
    end
    ddb_plotDelft3DFLOW(handles,'plot');
else
    handles=ddb_initializeDelft3DFLOW(handles);
end

