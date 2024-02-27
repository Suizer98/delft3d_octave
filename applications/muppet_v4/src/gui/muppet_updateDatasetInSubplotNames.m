function handles=muppet_updateDatasetInSubplotNames(handles)
handles.datasetinsubplotnames={''};
if handles.figures(handles.activefigure).figure.nrsubplots>0
    for id=1:handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.nrdatasets
        handles.datasetinsubplotnames{id}=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.datasets(id).dataset.name;
    end
end
