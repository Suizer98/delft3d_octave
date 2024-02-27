% Check if the directories have been set
pathin      = get(handles.edit1,'String');
pathout     = get(handles.edit2,'String');
if isempty(pathin);
    errordlg('The input directory has not been assigned','Error');
%     break;
end
if isempty(pathout);
    errordlg('The output directory has not been assigned','Error');
%     break;
end
if exist(pathin,'dir')==0;
    errordlg('The input directory does not exist.','Error');
%     break;
end
if exist(pathout,'dir')==0;
    errordlg('The output directory does not exist.','Error');
%     break;
end

% Check if the edit boxes are filled
filegrd     = get(handles.edit5,'String');
fileenc     = get(handles.edit6,'String');
filedep     = get(handles.edit7,'String');

% Check if the files specified in the edit boxes do exist
if ~isempty(filegrd);
    filegrd = [pathin,'\',filegrd];
    if exist(filegrd,'file')==0;
        if exist('wb'); close(wb); end;
        errordlg('The specified grd-file does not exist in the specified input directory.','Error');
%         break;
    end
end
if ~isempty(fileenc);
    fileenc = [pathin,'\',fileenc];
    if exist(fileenc,'file')==0;
        if exist('wb'); close(wb); end;
        errordlg('The specified enc-file does not exist in the specified input directory.','Error');
%         break;
    end
end