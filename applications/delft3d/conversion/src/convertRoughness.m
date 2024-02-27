%%% Clear screen and ignore warnings

fclose all;
clc;
warning off all;


%%% STANDARD GUI CHECK ON DIRECTORIES

convertGuiDirectoriesCheck;


%%% GUI CHECKS

% Check if the roughness file name has been specified (Delft3D)
filergh     = get(handles.edit17,'String');
filergh     = deblank2(filergh);
if ~isempty(filergh);
    filergh = [pathin,'\',filergh];
    if exist(filergh,'file')==0;
        if exist('wb'); close(wb); end;
        errordlg('The specified roughness file does not exist.','Error');
        set(handles.edit24,'String','');
        break;
    end
else
    if exist('wb'); close(wb); end;
    errordlg('The roughness file name has not been specified.','Error');
    set(handles.edit24,'String','');
    break;
end

% Check if the roughness file name has been specified (D-Flow FM)
rghfile     = get(handles.edit24,'String');
if isempty(rghfile);
    if exist('wb'); close(wb); end;
    errordlg('The roughness sample file name has not been specified.','Error');
    break;
end
if length(rghfile) > 8;
    if strcmp(rghfile(end-7:end),'_rgh.xyz') == 0;
        if exist('wb'); close(wb); end;
        errordlg('The roughness sample file name has an improper extension.','Error');
        break;
    end
end

% Put the output directory name in the filenames
rghfile     = [pathout,'\',rghfile];


%%% ACTUAL CONVERSION OF THE GRID

d3d2dflowfm_friction_xyz(filegrd,filergh,rghfile);