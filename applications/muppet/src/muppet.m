function muppet(varargin)

% Muppet v3.22
% Compile with: mcc -m -B sgl muppet.m

handles.MuppetVersion='3.26';

% Turn off annoying warning messages
warning('off','all');

% Find muppet path
if isdeployed
    [status, result] = system('path');
    exeDir = char(regexpi(result, 'Path=(.*?);', 'tokens', 'once'));
    handles.MuppetPath=[fileparts(exeDir) filesep];
else
    pth = fileparts(mfilename('fullpath'));
    pth = [pth filesep '..' filesep];
    handles.MuppetPath=pth;
end

if nargin==0

    %% Start GUI
    GUI_Muppet('Version',handles.MuppetVersion,handles.MuppetPath);

else

    %% Make invisible figure
    handles.SessionName=varargin{1};
    mpt=figure('Visible','off','Position',[0 0 0.2 0.2]);
    set(mpt,'Name','Muppet','NumberTitle','off');
    
    %% Read defaults
    handles=ReadDefaults(handles);
    handles.ColorMaps=ImportColorMaps(handles.MuppetPath);
    handles.DefaultColors=ReadDefaultColors(handles.MuppetPath);
    handles.Frames=ReadFrames(handles.MuppetPath);

    %% Read session file
    handles=ReadSessionFile(handles,handles.SessionName);

    %% Import datasets
    handles.DataProperties=mp_importDatasets(handles.DataProperties,handles.NrAvailableDatasets);

    %% Combine datasets
    [handles.DataProperties,handles.NrAvailableDatasets,handles.CombinedDatasetProperties]=mp_combineDatasets(handles.DataProperties, ...
        handles.NrAvailableDatasets,handles.CombinedDatasetProperties,handles.NrCombinedDatasets);

    guidata(mpt,handles);

    if nargin==1
        % Make figure
        for ifig=1:handles.NrFigures
            ExportFigure(handles,ifig,'export');
        end
    else

        % Make animation
        AnimationSettings=ReadAnimationSettings(varargin{2});
        MakeAnimation(FigureProperties,SubplotProperties,PlotOptions,DataProperties,CombinedDatasetProperties, ...
            ColorMaps,DefaultColors,Frames,AnimationSettings,NrAvailableDatasets,NrCombinedDatasets,1);

    end

    close(findobj('Name','Muppet'));

end

