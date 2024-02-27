function muppet_selectDataset

handles=getHandles;
if handles.nrdatasets>0
    if isempty(handles.activedataset)
        handles.activedataset=1;
    end
    idtype=muppet_findIndex(handles.datatype,'datatype','name',handles.datasets(handles.activedataset).dataset.type);
    [pathname,filename,ext]=fileparts(handles.datasets(handles.activedataset).dataset.filename);
    currentpath=pwd;
    if ~strcmpi(currentpath,pathname)
        if isempty(pathname)
            filename=[filename ext];
        else
            filename=[pathname filesep filename ext];
        end
    else
        filename=[filename ext];
    end
    txt1=['Name : ' handles.datasets(handles.activedataset).dataset.name];
    txt2=['File: ' filename];
    txt3=['Type : ' handles.datatype(idtype).datatype.longname];
    if isempty(handles.datasets(handles.activedataset).dataset.time)
        txt4='';
    else
        txt4=['Time : ' datestr(handles.datasets(handles.activedataset).dataset.time)];
    end
    txt5='';
else
    txt1='';
    txt2='';
    txt3='';
    txt4='';
    txt5='';
end
handles.datasettext1=txt1;
handles.datasettext2=txt2;
handles.datasettext3=txt3;
handles.datasettext4=txt4;
handles.datasettext5=txt5;
setHandles(handles);
