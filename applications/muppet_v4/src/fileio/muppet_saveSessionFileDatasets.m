function muppet_saveSessionFileDatasets(handles,fid)

for id=1:handles.nrdatasets
    
    txt=['Dataset "' handles.datasets(id).dataset.name '"'];
    fprintf(fid,'%s \n',txt);
    
    ift=muppet_findIndex(handles.filetype,'filetype','name',handles.datasets(id).dataset.filetype);
    
    if ~isempty(ift)
        for ii=1:length(handles.filetype(ift).filetype.dataproperty)
            idp=muppet_findIndex(handles.dataproperty,'dataproperty','name',handles.filetype(ift).filetype.dataproperty(ii).dataproperty.name);
            if ~isempty(idp)
                muppet_writeOption(handles.dataproperty(idp).dataproperty,handles.datasets(id).dataset,fid,3,14);
            end
        end
    end
    
    txt='EndDataset';
    fprintf(fid,'%s \n',txt);
    fprintf(fid,'%s \n','');
    
end
