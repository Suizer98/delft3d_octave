function handles=muppet_updateDatasetNames(handles)
handles.datasetnames={''};
for id=1:handles.nrdatasets
    handles.datasetnames{id}=handles.datasets(id).dataset.name;
end
