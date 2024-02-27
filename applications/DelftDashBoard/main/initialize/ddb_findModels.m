function ddb_findModels
%DDB_FINDMODELS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_findModels
%
%   Input:

%
%
%
%
%   Example
%   ddb_findModels
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

if isdeployed
    dr=[ctfroot filesep 'models']; % Changed back MvO (2017-4-20)
    
    dr=[ctfroot filesep 'DelftDashBoa' filesep 'ddbsettings' filesep 'models']; % Changed back MvO (2017-4-20)
    
%     [status, result] = system('path');
%     exeDir = char(regexpi(result, 'Path=(.*?);', 'tokens', 'once'));
%     dr = [fileparts(exeDir) filesep 'ddbsettings' filesep 'models']; % by Bart Grasmeijer    
else
    ddb_root = fileparts(which('delftdashboard.ini'));
    dr=[ddb_root filesep 'models'];
end

k=0;
%% Standard models
flist=dir(dr);
for i=1:length(flist)
    if flist(i).isdir
        switch lower(flist(i).name)
            case{'.','..','.svn'}
            otherwise
                if isdeployed
                    % xml file in settings dir
                    xmlfile=[handles.settingsDir filesep 'models' filesep flist(i).name filesep 'xml' filesep 'model.'  lower(flist(i).name) '.xml'];
                else
                    % xml file in model code dir
                    xmlfile=[dr filesep flist(i).name filesep 'xml' filesep 'model.' lower(flist(i).name) '.xml'];
                end
                if exist(xmlfile,'file')
                    xml=xml2struct(xmlfile,'structuretype','short');
                    if strcmpi(flist(i).name,'none')
                        k=k+1;
                        name{k}=flist(i).name;
                        tp{k}='standard';
                    else
                        switch lower(xml.enable)
                            case{'1','y','yes'}
                                k=k+1;
                                name{k}=flist(i).name;
                                tp{k}='standard';
                        end
                    end
                end
        end
    end
end

%% Additional models
dr2=handles.additionalModelsDir;
if ~isempty(dr2)
    addpath(genpath(dr2));
    flist=dir(dr2);
    for i=1:length(flist)
        if flist(i).isdir
            switch lower(flist(i).name)
                case{'.','..','.svn'}
                otherwise
                    if isdeployed
                        % xml file in settings dir
                        xmlfile=[handles.settingsDir filesep 'models' filesep flist(i).name filesep 'xml' filesep 'model.'  lower(flist(i).name) '.xml'];
                    else
                        % xml file in model code dir
                        xmlfile=[dr2 filesep flist(i).name filesep 'xml' filesep 'model.' lower(flist(i).name) '.xml'];
                    end
                    if exist(xmlfile,'file')
                        xml=xml2struct(xmlfile,'structuretype','short');
                        switch lower(xml.enable)
                            case{'1','y','yes'}
                                k=k+1;
                                name{k}=flist(i).name;
                                tp{k}='additional';
                        end
                    end
            end
        end
    end
end

if ~strcmpi(handles.configuration.include_models{1},'all')
    % Only use toolboxes included in xml file
    name0=name;
    tp0=tp;
    name=[];
    tp=[];
    k=0;
    names=handles.configuration.include_models;
    for j=1:length(name0)
        if ~isempty(strmatch(lower(name0{j}),lower(names)))
            k=k+1;
            name{k}=name0{j};
            tp{k}  =tp0{j};
        end
    end
else
    % All models included, set Delft3D-FLOW as the first model
    name0=name;
    tp0=tp;
    name=[];
    tp=[];
    name{1}='Delft3DFLOW';
    tp{1}='standard';
    n=1;
    for k=1:length(name0)
        if ~strcmpi(name0{k},'delft3dflow')
            n=n+1;
            name{n}=name0{k};
            tp{n}  =tp0{k};
        end        
    end
end

nt=length(name);
for i=1:nt
    nm=lower(name{i});
    handles.model.(nm).name=nm;
    handles.model.(nm).longName=name{i};
    handles.model.(nm).iniFcn=str2func(['ddb_initialize' name{i}]);
    handles.model.(nm).plotFcn=str2func(['ddb_plot' name{i}]);
    handles.model.(nm).saveFcn=str2func(['ddb_save' name{i}]);
    handles.model.(nm).openFcn=str2func(['ddb_open' name{i}]);
    handles.model.(nm).clrFcn=str2func(['ddb_clear' name{i}]);
    handles.model.(nm).coordConvertFcn=str2func(['ddb_coordConvert' name{i}]);
    handles.model.(nm).GUI=[];
    if isdeployed
        handles.model.(nm).dir=[dr filesep name{i} filesep];
        handles.model.(nm).xmlDir=[handles.settingsDir filesep 'models' filesep name{i} filesep 'xml' filesep];
    else
        handles.model.(nm).xmlDir=[dr filesep name{i} filesep 'xml' filesep];
        % From Matlab
        if strcmpi(tp{i},'standard')
            handles.model.(nm).dir=[dr filesep name{i} filesep];
            handles.model.(nm).xmlDir=[handles.model.(nm).dir 'xml' filesep];
        else
            handles.model.(nm).dir=[dr2 filesep name{i} filesep];
            handles.model.(nm).xmlDir=[handles.model.(nm).dir 'xml' filesep];
        end
    end
end

% Read xml files
models=fieldnames(handles.model);
for i=1:length(models)
    handles=ddb_readModelXML(handles,models{i});
end

%if ~strcmpi(handles.configuration.include_models{1},'all')
    handles.activeModel.name=lower(name{1});
    handles.activeModel.nr=1;
% else
%     handles.activeModel.name='delft3dflow';
%     handles.activeModel.nr=1;
% end

setHandles(handles);

