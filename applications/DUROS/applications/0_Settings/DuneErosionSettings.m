function varargout = DuneErosionSettings(varargin)
%DUNEEROSIONSETTINGS manages general settings of the dune erosion routines 
%
% This function retrieves provides and stores general settings of the dune
% erosion calculations
%
% syntax:
% [paramsout] = DuneErosionSettings(paramsinreq)
% [paramsout] = DuneErosionSettings('get',paramsinreq)
% DuneErosionSettings('set',paramnames,paramvals,...)
% DuneErosionSettings('load',filename)
% DuneErosionSettings('load', DESettingsstructure)
% DuneErosionSettings('save',filename)
% DuneErosionSettings('default')
%
% input:
% paramsinreq = names of the parameters that have to be retrieved. This can
%       be either a cell array of characters, or individual characters.
% paramnames  = names of the parameters that have to be stored. This can be 
%       specified in the form of a cell array representing different 
%       parameters. In this case also the values have to be specified in a 
%       cell array. Parameters can also be specified using string 
%       combinations of paramnames and paramvals.
% paramvals   = either a cell array of multiple strings in combination with
%       a cell array or multiple strings specifying the parameter names.
%       (see also paramnames)
% filename    = The name of the settings file that has to be saved or
%       loaded. This parameter is optional. Omitting filename will result
%       in a popup window asking the user where to load / save the file.
%
% output:
% paramsout = Requested settings (parameters) in the order specified in the
%       input (paramsinreq).
%
% example:
%       g = DuneErosionSettings('g')
%
%       g = 
%
%           9.8100
%
%       DuneErosionSettings('set','g',10);
%       new_g = DuneErosionSettings('g')
%
%       new_g =
%
%          10
%
% See also persistent getDuneErosion_VTV2006
%

%--------------------------------------------------------------------------
% Copyright (c) Deltares 2008 FOR INTERNAL USE ONLY
% Version: Version 1.0, April 2008 (Version 1.0, April 2008)
% By: <Pieter van Geer (email: pieter.vangeer@deltares.nl)>
%--------------------------------------------------------------------------

persistent DESettings
%{ 
get DESettings struct
%}
if isempty(DESettings)
    DESettings = loadDESettings('default');
end

%{
Deal with input argument
%}

call = varargin{1};
if ischar(call)
    switch call
        case 'get'
            varargout = getDESettings(DESettings,varargin{2:end});
        case 'set'
            DESettings = setDESettings(DESettings, varargin{2:end});
            varargout = {DESettings};
        case 'load'
            DESettings = loadDESettings(varargin{2:end});
            varargout = {DESettings};
            if isempty(DESettings)
                return
            end
        case 'save'
            saveDESettings(DESettings,varargin{2:end});
            varargout = {true};
        case 'default'
            DESettings = defaultDESettings;
            DESfieldnames = fieldnames(DESettings);
            cntr = 0;
            for itypes = 1:length(DESfieldnames)
                DESsubfieldnames = fieldnames(DESettings.(DESfieldnames{itypes}));
                for ifields = 1:length(DESsubfieldnames)
                    cntr = cntr+1;
                    varargin{2*cntr-1} = DESsubfieldnames{ifields};
                    varargin{2*cntr}   = DuneErosionSettings(DESsubfieldnames{ifields});
                end
            end
            DESettings = setDESettings(DESettings, varargin{:});
            varargout = {DESettings};
        case 'all'
            varargout = {DESettings};
        otherwise % get settings (default)
            varargout = getDESettings(DESettings,varargin{:});
    end
end

end % DuneErosionSettings

%% subfunction getDESettings

function outp = getDESettings(DESettings, varargin)

outp = cell(size(varargin));
if iscell(varargin{1}) && length(varargin)==1
    reqvars = varargin{1};
else
    reqvars = varargin;
end
for iinp = 1:length(reqvars)
    inprequest = reqvars{iinp};
    DESfieldnames = fieldnames(DESettings);
    varfound = false;
    for itypes = 1:length(DESfieldnames)
        if any(strcmpi(fieldnames(DESettings.(DESfieldnames{itypes})),inprequest));
            outp{iinp} = DESettings.(DESfieldnames{itypes}).(inprequest);
            varfound = true;
            break
        end
    end
    if ~varfound
        display(['Variable named "' inprequest '" is not found. An empty double is returned']);
        outp{iinp} = [];
    end
end

end % getDESettings

%% subfunction setDESettings

function DESettings = setDESettings(DESettings, varargin)

[inpprops, inpvars] = parseinp(varargin);
DESfieldnames = fieldnames(DESettings);
for iinp = 1:length(inpprops)
    inpfound = false;
    for itypes = 1:length(DESfieldnames)
        if ~isempty(fieldnames(DESettings.(DESfieldnames{itypes}))) && any(strcmp(fieldnames(DESettings.(DESfieldnames{itypes})),inpprops{iinp}));
            inpfound = true;
            currentvar = DuneErosionSettings('get', (inpprops{iinp})); % current value of the variable
            VariableChanges = ~isequal(currentvar, inpvars{iinp});
            if VariableChanges
                if ischar(inpvars{iinp})
                    variablevaluestring = inpvars{iinp};
                elseif isnumeric(inpvars{iinp})
                    variablevaluestring = num2str(inpvars{iinp});
                elseif iscell(inpvars{iinp})
                    variablevaluestring = 'cell array'; %TODO: use var2evalstr to display the cell content
                elseif islogical(inpvars{iinp})
                    if inpvars{iinp}
                        variablevaluestring = 'true';
                    else
                        variablevaluestring = 'false';
                    end
                elseif isa(inpvars{iinp},'function_handle')
                    variablevaluestring = ['@',char(inpvars{iinp})];
                end
                DESettings.(DESfieldnames{itypes}).(inpprops{iinp}) = inpvars{iinp};
                writemessage(50, ['Variable "' inpprops{iinp} '" is set to "' variablevaluestring '".']);
            end
            break
        end
    end
    if ~inpfound
        DESettings.Other.(inpprops{iinp}) = inpvars{iinp};
        display(['Specified variable is not recognised. A new variable named "' inpprops{iinp} '" is saved.']);
    end
end

end % setDESettings

%% subfunction loadDESettings

function DESettings = loadDESettings(varargin)

DESettings = [];
if isempty(varargin)
    [FileName,PathName] = uigetfile({'*.mat','Settings file (*.mat)' ; '*.*','All files'},'Select DuneErosion settings file');
    if ischar(FileName)
        load([PathName, FileName]);
    else
        DESettings = [];
        return
    end
else
    if strcmp(varargin{1},'default')
        DESettings = defaultDESettings;
    elseif isstruct(varargin{1})
        DESettings = varargin{1};
    else
        try
            load(varargin{1});
        catch
            display(['Settings could not be loaded from location "' varargin{1} '". Please check filename.']);
            return
        end
    end
end

end % loadDESettings

%% subfunction saveDESettings

function saveDESettings(DESettings,varargin) %#ok<INUSL>

if isempty(varargin)
    [FileName,PathName] = uiputfile({'*.mat','Settings file (*.mat)' ; '*.*','All files'},'Select DuneErosion settings file');
    if ischar(FileName)
        [pathstr, name, ext] = fileparts([PathName FileName]);
        if ~strcmp(ext,'.mat')
            display(['Specified format (' ext ') not correct. Specify a ".mat" file instead.']);
            return
        end
        save([PathName, FileName],'DESettings');
    else
        return
    end
else
    [pathstr, name, ext] = fileparts(varargin{1});
    if isempty(pathstr)
        pathstr = cd;
        % TODO found general system dir to save / load
    end
    if isempty(ext)
        ext = '.mat';
    end
    if ~strcmp(ext,'.mat')
        display(['Specified format (' ext ') not correct. Specify a ".mat" file instead.']);
        return
    end
    save([pathstr, filesep, name, ext],'DESettings');
end
end % saveDESettings

%% sub function parseinp

function [inpprops, inpvars] = parseinp(inp)

if length(inp)==2 && iscell(inp{1})
    inpprops = inp{1};
    inpvars = inp{2};
else
    if length(inp)/2 ~= round(length(inp)/2)
        error('Number of specified parameters does not match the number of parameter values. Please try specifying again.');
    end
    inpprops = inp(1:2:end);
    inpvars = inp(2:2:end);
end

end % parseinp