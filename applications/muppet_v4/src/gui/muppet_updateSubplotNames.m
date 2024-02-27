function handles=muppet_updateSubplotNames(handles)
handles.subplotnames={''};
for id=1:handles.figures(handles.activefigure).figure.nrsubplots
    handles.subplotnames{id}=handles.figures(handles.activefigure).figure.subplots(id).subplot.name;
end
