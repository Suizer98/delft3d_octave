function [handles,ok]=muppet_newSession(handles,filename)

% Clear structure
handles.nrdatasets=0;
handles.datasets=[];

handles.nrfigures=0;
handles.figures=[];

handles.activedataset=1;
handles.activefigure=1;
handles.activesubplot=1;
handles.activedatasetinsubplot=1;

[handles,ok]=muppet_readSessionFile(handles,filename,0);

if ~ok
    return
end

% Import data
if handles.nrdatasets>0
    [handles,ok]=muppet_importDatasets(handles);
end
