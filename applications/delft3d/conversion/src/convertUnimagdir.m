%%% Clear screen and ignore warnings

fclose all;
clc;
warning off all;


%%% STANDARD GUI CHECK ON DIRECTORIES

convertGuiDirectoriesCheck;


%%% GUI CHECKS

% Check if the unimagdir file name has been specified (Delft3D)
filewnd     = get(handles.edit32,'String');
filewnd     = deblank2(filewnd);
if ~isempty(filewnd);
    wndfile = filewnd;
    wndfile = [pathout,'\',wndfile];   % Put the output directory name in the filenames
    filewnd = [pathin,'\',filewnd];
    if exist(filewnd,'file')==0;
        if exist('wb'); close(wb); end;
        errordlg('The specified unimagdir wind file does not exist.','Error');
        set(handles.edit33,'String','');
        break;
    end
else
    if exist('wb'); close(wb); end;
    errordlg('The unimagdir wind file name has not been specified.','Error');
    set(handles.edit33,'String','');
    break;
end


%%% ACTUAL CONVERSION OF THE GRID

copyfile(filewnd, wndfile)