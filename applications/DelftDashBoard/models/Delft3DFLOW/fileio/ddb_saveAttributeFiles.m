function handles = ddb_saveAttributeFiles(handles, id, opt)
%DDB_SAVEATTRIBUTEFILES  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_saveAttributeFiles(handles, id, opt)
%
%   Input:
%   handles =
%   id      =
%   opt     =
%
%   Output:
%   handles =
%
%   Example
%   ddb_saveAttributeFiles
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
sall=0;
if strcmpi(opt,'saveallas')
    sall=1;
end

runid=handles.model.delft3dflow.domain(id).runid;

if handles.model.delft3dflow.domain(id).nrOpenBoundaries>0
    
    handles=ddb_sortBoundaries(handles,id);
    
    if isempty(handles.model.delft3dflow.domain(id).bndFile) || sall
        [filename, pathname, filterindex] = uiputfile('*.bnd', ['Select Boundary Definitions File - domain ' runid],'');
        curdir=[lower(cd) '\'];
        if ~strcmpi(curdir,pathname)
            filename=[pathname filename];
        end
        handles.model.delft3dflow.domain(id).bndFile=filename;
    end
    ddb_saveBndFile(handles.model.delft3dflow.domain(id).openBoundaries,handles.model.delft3dflow.domain(id).bndFile);
    
    handles=ddb_countOpenBoundaries(handles,id);
    
    if handles.model.delft3dflow.domain(id).nrAstro>0
        if isempty(handles.model.delft3dflow.domain(id).bcaFile) || sall
            [filename, pathname, filterindex] = uiputfile('*.bca', ['Select Astronomic Conditions File - domain ' runid],'');
            curdir=[lower(cd) '\'];
            if ~strcmpi(curdir,pathname)
                filename=[pathname filename];
            end
            handles.model.delft3dflow.domain(id).bcaFile=filename;
        end
        ddb_saveBcaFile(handles,id);
    end
    
    if handles.model.delft3dflow.domain(id).nrCor>0
        if isempty(handles.model.delft3dflow.domain(id).corFile) || sall
            [filename, pathname, filterindex] = uiputfile('*.cor', ['Select Astronomic Corrections File - domain ' runid],'');
            curdir=[lower(cd) '\'];
            if ~strcmpi(curdir,pathname)
                filename=[pathname filename];
            end
            handles.model.delft3dflow.domain(id).corFile=filename;
        end
        ddb_saveCorFile(handles,id);
    end
    
    if handles.model.delft3dflow.domain(id).nrHarmo>0
        if isempty(handles.model.delft3dflow.domain(id).bchFile) || sall
            [filename, pathname, filterindex] = uiputfile('*.bch', ['Select Harmonic Conditions File - domain ' runid],'');
            curdir=[lower(cd) '\'];
            if ~strcmpi(curdir,pathname)
                filename=[pathname filename];
            end
            handles.model.delft3dflow.domain(id).bchFile=filename;
        end
        ddb_saveBchFile(handles,id);
    end
    
    if handles.model.delft3dflow.domain(id).nrTime>0
        if isempty(handles.model.delft3dflow.domain(id).bctFile) || sall
            [filename, pathname, filterindex] = uiputfile('*.bct', ['Select Time Series Conditions File - domain ' runid],'');
            curdir=[lower(cd) '\'];
            if ~strcmpi(curdir,pathname)
                filename=[pathname filename];
            end
            handles.model.delft3dflow.domain(id).bctFile=filename;
        end
        if handles.model.delft3dflow.domain(id).bctChanged
            ddb_saveBctFile(handles,id);
            handles.model.delft3dflow.domain(id).bctChanged=0;
        end
    end
    
    incconst=handles.model.delft3dflow.domain(id).salinity.include || handles.model.delft3dflow.domain(id).temperature.include || ...
        handles.model.delft3dflow.domain(id).sediments.include || handles.model.delft3dflow.domain(id).tracers;
    if incconst
        if isempty(handles.model.delft3dflow.domain(id).bccFile) || sall
            [filename, pathname, filterindex] = uiputfile('*.bcc', ['Select Transport Conditions File - domain ' runid],'');
            curdir=[lower(cd) '\'];
            if ~strcmpi(curdir,pathname)
                filename=[pathname filename];
            end
            handles.model.delft3dflow.domain(id).bccFile=filename;
        end
        if handles.model.delft3dflow.domain(id).bccChanged
            ddb_saveBccFile(handles,id);
            handles.model.delft3dflow.domain(id).bccChanged=0;
        end
    end
    
end

if handles.model.delft3dflow.domain(id).nrObservationPoints>0
    if isempty(handles.model.delft3dflow.domain(id).obsFile) || sall
        [filename, pathname, filterindex] = uiputfile('*.obs', ['Select Observation Points File - domain ' runid],'');
        curdir=[lower(cd) '\'];
        if ~strcmpi(curdir,pathname)
            filename=[pathname filename];
        end
        handles.model.delft3dflow.domain(id).obsFile=filename;
    end
    ddb_saveObsFile(handles,id);
end

if handles.model.delft3dflow.domain(id).nrCrossSections>0
    if isempty(handles.model.delft3dflow.domain(id).crsFile) || sall
        [filename, pathname, filterindex] = uiputfile('*.crs', ['Select Cross Sections File - domain ' runid],'');
        curdir=[lower(cd) '\'];
        if ~strcmpi(curdir,pathname)
            filename=[pathname filename];
        end
        handles.model.delft3dflow.domain(id).crsFile=filename;
    end
    ddb_saveCrsFile(handles,id);
end

if handles.model.delft3dflow.domain(id).nrDryPoints>0
    if isempty(handles.model.delft3dflow.domain(id).dryFile) || sall
        [filename, pathname, filterindex] = uiputfile('*.dry', ['Select Dry Points File - domain ' runid],'');
        curdir=[lower(cd) '\'];
        if ~strcmpi(curdir,pathname)
            filename=[pathname filename];
        end
        handles.model.delft3dflow.domain(id).dryFile=filename;
    end
    ddb_saveDryFile(handles,id);
end

if handles.model.delft3dflow.domain(id).nrThinDams>0
    if isempty(handles.model.delft3dflow.domain(id).thdFile) || sall
        [filename, pathname, filterindex] = uiputfile('*.thd', ['Select Thin Dams File - domain ' runid],'');
        curdir=[lower(cd) '\'];
        if ~strcmpi(curdir,pathname)
            filename=[pathname filename];
        end
        handles.model.delft3dflow.domain(id).thdFile=filename;
    end
    ddb_saveThdFile(handles,id);
end

if handles.model.delft3dflow.domain(id).nrWeirs2D>0
    if isempty(handles.model.delft3dflow.domain(id).w2dFile) || sall
        [filename, pathname, filterindex] = uiputfile('*.2dw', ['Select 2D Weirs File - domain ' runid],'');
        curdir=[lower(cd) '\'];
        if ~strcmpi(curdir,pathname)
            filename=[pathname filename];
        end
        handles.model.delft3dflow.domain(id).w2dFile=filename;
    end
    ddb_save2DWFile(handles,id);
end

if handles.model.delft3dflow.domain(id).nrDrogues>0
    if isempty(handles.model.delft3dflow.domain(id).droFile) || sall
        [filename, pathname, filterindex] = uiputfile('*.dro', ['Select Drogues File - domain ' runid],'');
        curdir=[lower(cd) '\'];
        if ~strcmpi(curdir,pathname)
            filename=[pathname filename];
        end
        handles.model.delft3dflow.domain(id).droFile=filename;
    end
    ddb_saveDroFile(handles,id);
end

if handles.model.delft3dflow.domain(id).nrDischarges>0
    
    if isempty(handles.model.delft3dflow.domain(id).srcFile) || sall
        [filename, pathname, filterindex] = uiputfile('*.src', ['Select Discharge Locations File - domain ' runid],'');
        curdir=[lower(cd) '\'];
        if ~strcmpi(curdir,pathname)
            filename=[pathname filename];
        end
        handles.model.delft3dflow.domain(id).srcFile=filename;
    end
    ddb_saveSrcFile(handles,id);
    
    if isempty(handles.model.delft3dflow.domain(id).disFile) || sall
        [filename, pathname, filterindex] = uiputfile('*.dis', ['Select Discharge File - domain ' runid],'');
        curdir=[lower(cd) '\'];
        if ~strcmpi(curdir,pathname)
            filename=[pathname filename];
        end
        handles.model.delft3dflow.domain(id).disFile=filename;
    end
    ddb_saveDisFile(handles,id);
end

if handles.model.delft3dflow.domain(id).nrSediments>0 && handles.model.delft3dflow.domain(id).sediments.include
    
    if isempty(handles.model.delft3dflow.domain(id).sedFile) || sall
        [filename, pathname, filterindex] = uiputfile('*.sed', ['Select Sediments File - domain ' runid],'');
        curdir=[lower(cd) '\'];
        if ~strcmpi(curdir,pathname)
            filename=[pathname filename];
        end
        handles.model.delft3dflow.domain(id).sedFile=filename;
    end
    ddb_saveSedFile(handles,id);
    
    if isempty(handles.model.delft3dflow.domain(id).morFile) || sall
        [filename, pathname, filterindex] = uiputfile('*.mor', ['Select Morphology File - domain ' runid],'');
        curdir=[lower(cd) '\'];
        if ~strcmpi(curdir,pathname)
            filename=[pathname filename];
        end
        handles.model.delft3dflow.domain(id).morFile=filename;
    end
    ddb_saveMorFile(handles,id);
end

if handles.model.delft3dflow.domain(id).wind
    if strcmpi(handles.model.delft3dflow.domain(id).windType,'uniform')
        if isempty(handles.model.delft3dflow.domain(id).wndFile)
            [filename, pathname, filterindex] = uiputfile('*.wnd', ['Select Wind File - domain ' runid],'');
            if pathname~=0
                curdir=[lower(cd) '\'];
                if ~strcmpi(curdir,pathname)
                    filename=[pathname filename];
                end
            else
                filename=[];
            end
            if ~isempty(filename)
                handles.model.delft3dflow.domain(id).wndFile=filename;
            end
        end
        if ~isempty(handles.model.delft3dflow.domain(id).wndFile)
            ddb_saveWndFile(handles,id)
        end
    end
end

