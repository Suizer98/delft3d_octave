function handles = ddb_readAttributeFiles(handles, id)
%DDB_READATTRIBUTEFILES  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_readAttributeFiles(handles, id)
%
%   Input:
%   handles =
%   id      =
%
%   Output:
%   handles =
%
%   Example
%   ddb_readAttributeFiles
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
if ~isempty(handles.model.delft3dflow.domain(id).grdFile)
    [x,y,enc]=ddb_wlgrid('read',[handles.model.delft3dflow.domain(id).grdFile]);
    handles.model.delft3dflow.domain(id).gridX=x;
    handles.model.delft3dflow.domain(id).gridY=y;
    [handles.model.delft3dflow.domain(id).gridXZ,handles.model.delft3dflow.domain(id).gridYZ]=getXZYZ(x,y);
    handles.model.delft3dflow.domain(id).kcs=determineKCS(handles.model.delft3dflow.domain(id).gridX,handles.model.delft3dflow.domain(id).gridY);
    if ~isempty(handles.model.delft3dflow.domain(id).encFile)
        mn=ddb_enclosure('read',[handles.model.delft3dflow.domain(id).encFile]);
        [handles.model.delft3dflow.domain(id).gridX,handles.model.delft3dflow.domain(id).gridY]=ddb_enclosure('apply',mn,handles.model.delft3dflow.domain(id).gridX,handles.model.delft3dflow.domain(id).gridY);
    end
    nans=zeros(size(handles.model.delft3dflow.domain(id).gridX));
    nans(nans==0)=NaN;
    handles.model.delft3dflow.domain(id).depth=nans;
    handles.model.delft3dflow.domain(id).depthZ=nans;
end
if ~isempty(handles.model.delft3dflow.domain(id).depFile)
    mmax=handles.model.delft3dflow.domain(id).MMax;
    nmax=handles.model.delft3dflow.domain(id).NMax;
    dp=ddb_wldep('read',handles.model.delft3dflow.domain(id).depFile,[mmax nmax]);
    dp(dp==-999)=NaN;
    handles.model.delft3dflow.domain(id).depth=-dp(1:end-1,1:end-1);
    handles.model.delft3dflow.domain(id).depthZ=getDepthZ(handles.model.delft3dflow.domain(id).depth,handles.model.delft3dflow.domain(id).dpsOpt);
end
if ~isempty(handles.model.delft3dflow.domain(id).bndFile)
    handles=ddb_readBndFile(handles,id);
    handles=ddb_sortBoundaries(handles,id);
end

% ddb_initialize Tracers and Sediment
for i=1:handles.model.delft3dflow.domain(id).nrTracers
    handles=ddb_initializeTracer(handles,id,i);
end

% Initialize sediment
if handles.model.delft3dflow.domain(id).sediments.include
    handles=ddb_readSedFile(handles,id);
    handles=ddb_readMorFile(handles,id);
end

if ~isempty(handles.model.delft3dflow.domain(id).bcaFile)
    if exist(handles.model.delft3dflow.domain(id).bcaFile,'file')
        handles=ddb_readBcaFile(handles,id);
    else
        handles.model.delft3dflow.domain(id).bcaFile='';        
        ddb_giveWarning('text',['Bca file ' handles.model.delft3dflow.domain(id).bcaFile ' not found! Input was skipped!']);
    end
end
if ~isempty(handles.model.delft3dflow.domain(id).corFile)
    if exist(handles.model.delft3dflow.domain(id).corFile,'file')
        handles=ddb_readCorFile(handles,id);
    else
        handles.model.delft3dflow.domain(id).corFile='';        
        ddb_giveWarning('text',['Cor file ' handles.model.delft3dflow.domain(id).corFile ' not found! Input was skipped!']);
    end
end
if ~isempty(handles.model.delft3dflow.domain(id).bctFile)
    try
        % Don't read bct file
%        handles=ddb_readBctFile(handles,id);
    end
end
if ~isempty(handles.model.delft3dflow.domain(id).bchFile)
    handles=ddb_readBchFile(handles,id);
end
if ~isempty(handles.model.delft3dflow.domain(id).bcqFile)
    handles=ReadBcqFile(handles,id);
end
if ~isempty(handles.model.delft3dflow.domain(id).bccFile)
    try
        % Don't read bct file
%        handles=ddb_readBccFile(handles,id);
    end
end
if ~isempty(handles.model.delft3dflow.domain(id).obsFile)
    handles=ddb_readObsFile(handles,id);
end
if ~isempty(handles.model.delft3dflow.domain(id).crsFile)
    handles=ddb_readCrsFile(handles,id);
end
if ~isempty(handles.model.delft3dflow.domain(id).droFile)
    handles=ddb_readDroFile(handles,id);
end
if ~isempty(handles.model.delft3dflow.domain(id).dryFile)
    handles=ddb_readDryFile(handles,id);
end
if ~isempty(handles.model.delft3dflow.domain(id).thdFile)
    handles=ddb_readThdFile(handles,id);
end
if ~isempty(handles.model.delft3dflow.domain(id).wndFile)
    handles=ddb_readWndFile(handles,id);
end
if ~isempty(handles.model.delft3dflow.domain(id).srcFile)
    handles=ddb_readSrcFile(handles,id);
    if ~isempty(handles.model.delft3dflow.domain(id).disFile)
        handles=ddb_readDisFile(handles,id);
    end
end


