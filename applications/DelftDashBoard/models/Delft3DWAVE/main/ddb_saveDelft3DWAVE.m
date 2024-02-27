function ddb_saveDelft3DWAVE(opt)

handles=getHandles;

switch lower(opt)
    case{'save'}
        ddb_saveMDW(handles);
    case{'saveas'}
        [filename, pathname, ~] = uiputfile('*.mdw', 'Select MDW File','');
        if pathname~=0
            curdir=[lower(cd) '\'];
            if ~strcmpi(curdir,pathname)
                filename=[pathname filename];
            end
            ii=strfind(filename,'.mdw');
            handles.model.delft3dwave.domain.runid=filename(1:ii-1);
            handles.model.delft3dwave.domain.mdwfile=filename;
            ddb_saveMDW(handles);
        end
    case{'saveall'}
        handles=ddb_Delft3DWAVE_saveAttributeFiles(handles,'saveall');
        ddb_saveMDW(handles);
    case{'saveallas'}
        [filename, pathname, ~] = uiputfile('*.mdw', 'Select MDW File','');
        if pathname~=0
            curdir=[lower(cd) '\'];
            if ~strcmpi(curdir,pathname)
                filename=[pathname filename];
            end
            ii=strfind(filename,'.mdw');
            handles.model.delft3dwave.domain.runid=filename(1:ii-1);
            handles.model.delft3dwave.domain.mdwfile=filename;
            ddb_saveMDW(handles);
        end
        ddb_Delft3DWAVE_saveAttributeFiles(handles,'saveallas');
end

ddb_Delft3DWAVE_checkInput(handles);

setHandles(handles);
