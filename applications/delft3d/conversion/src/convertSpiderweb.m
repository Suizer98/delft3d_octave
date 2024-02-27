%%% Clear screen and ignore warnings

fclose all;
clc;
warning off all;


%%% STANDARD GUI CHECK ON DIRECTORIES

convertGuiDirectoriesCheck;


%%% GUI CHECKS

% Check if the spiderweb file name has been specified (Delft3D)
filespw     = get(handles.edit34,'String');
filespw     = deblank2(filespw);
if ~isempty(filespw);
    spwfile = filespw;
    spwfile = [pathout,'\',spwfile];   % Put the output directory name in the filenames
    filespw = [pathin,'\',filespw];
    if exist(filespw,'file')==0;
        if exist('wb'); close(wb); end;
        errordlg('The specified spiderweb wind file does not exist.','Error');
        set(handles.edit35,'String','');
        break;
    end
else
    if exist('wb'); close(wb); end;
    errordlg('The spiderweb wind file name has not been specified.','Error');
    set(handles.edit35,'String','');
    break;
end


%%% ACTUAL CONVERSION OF THE GRID

copyfile(filespw, spwfile)