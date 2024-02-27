%%% Clear screen and ignore warnings

fclose all;
clc;
warning off all;


%%% STANDARD GUI CHECK ON DIRECTORIES

convertGuiDirectoriesCheck;


%%% GUI CHECKS

% Check if the viscosity file name has been specified (Delft3D)
fileedy     = get(handles.edit18,'String');
fileedy     = deblank2(fileedy);
if ~isempty(fileedy);
    fileedy = [pathin,'\',fileedy];
    if exist(fileedy,'file')==0;
        if exist('wb'); close(wb); end;
        errordlg('The specified eddy viscosity file does not exist.','Error');
        set(handles.edit25,'String','');
        break;
    end
else
    if exist('wb'); close(wb); end;
    errordlg('The eddy viscosity file name has not been specified.','Error');
    set(handles.edit25,'String','');
    break;
end

% Check if the viscosity file name has been specified (D-Flow FM)
edyfile     = get(handles.edit25,'String');
if isempty(edyfile);
    errordlg('The eddy viscosity sample file name has not been specified.','Error');
    break;
end
if length(edyfile) > 8;
    if strcmp(edyfile(end-7:end),'_edy.xyz') == 0;
        if exist('wb'); close(wb); end;
        errordlg('The eddy viscosity sample file name has an improper extension.','Error');
        break;
    end
end

% Put the output directory name in the filenames
edyfile     = [pathout,'\',edyfile];


%%% ACTUAL CONVERSION OF THE GRID

d3d2dflowfm_viscosity_xyz(filegrd,fileedy,edyfile);