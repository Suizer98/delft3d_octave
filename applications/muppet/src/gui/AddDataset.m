function [handles,NewDataset]=AddDataset(handles)

cd(handles.FilePath);

filtername=handles.FilterIndex;

filetypes = defineFileTypes;

nf=size(filetypes,1);
for i=1:nf
    filternames{i}=filetypes{i,1};
end
          
filterindex0=strmatch(filtername,filternames,'exact');

if filterindex0==1
    for i=1:nf
        ftype{i}=filetypes{i,1};
        ffun{i}=filetypes{i,2};
        filterspec{i,1}=filetypes{i,3};
        filterspec{i,2}=filetypes{i,4};
    end
else
    ftype{1}=filetypes{filterindex0,1};
    ffun{1}=filetypes{filterindex0,2};
    filterspec{1,1}=filetypes{filterindex0,3};
    filterspec{1,2}=filetypes{filterindex0,4};
    k=1;
    for i=1:nf
        if ~strcmpi(filetypes{i,1},filetypes{filterindex0,1})
            k=k+1;
            ftype{k}=filetypes{i,1};
            ffun{k}=filetypes{i,2};
            filterspec{k,1}=filetypes{i,3};
            filterspec{k,2}=filetypes{i,4};
        end
    end
end

[filename, pathname, filterindex] = uigetfile(filterspec);

NewDataset=0;

if pathname~=0
    fnc=str2func(['AddDataset' ffun{filterindex}]);
    handles.FilterIndex=ftype{filterindex};
    nr0=handles.NrAvailableDatasets;
    [handles.DataProperties,handles.NrAvailableDatasets]=feval(fnc,'DataProperties',handles.DataProperties,'PathName',pathname,'FileName',filename,'Nr',handles.NrAvailableDatasets);
    if handles.NrAvailableDatasets>nr0
        NewDataset=1;
        for inew=nr0+1:handles.NrAvailableDatasets
            handles.DataProperties(inew).TimeZone=0;
            handles.DataProperties(inew).coordinateSystem.name='unknown';
            handles.DataProperties(inew).coordinateSystem.type='projected';
        end
    end
    handles.FilePath=pathname;
end

cd(handles.CurrentPath);

