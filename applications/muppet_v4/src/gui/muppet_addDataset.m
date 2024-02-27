function handles=muppet_addDataset(handles,dataset)

dataset=feval(dataset.callback,'import',dataset);

nrd=handles.nrdatasets+1;
handles.nrdatasets=nrd;

handles.datasetnames{nrd}=dataset.name;

handles.activedataset=nrd;
handles.datasets(nrd).dataset=dataset;
