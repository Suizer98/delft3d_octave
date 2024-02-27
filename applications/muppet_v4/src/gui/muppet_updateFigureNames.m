function handles=muppet_updateFigureNames(handles)
handles.figurenames={''};
for ii=1:handles.nrfigures
    handles.figurenames{ii}=handles.figures(ii).figure.name;
end
