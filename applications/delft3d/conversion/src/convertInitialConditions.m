%%% Clear screen and ignore warnings

fclose all;
clc;
warning off all;


%%% STANDARD GUI CHECK ON DIRECTORIES

convertGuiDirectoriesCheck;


%%% GUI CHECKS

% Check if the initial conditions file name has been specified (Delft3D)
fileini     = get(handles.edit21,'String');
fileini     = deblank2(fileini);
if ~isempty(fileini);
    fileini = [pathin,'\',fileini];
    if exist(fileini,'file')==0;
        if exist('wb'); close(wb); end;
        errordlg('The specified initial conditions file does not exist.','Error');
        set(handles.edit28,'String','');
        break;
    end
else
    if exist('wb'); close(wb); end;
    errordlg('The initial conditions file name has not been specified.','Error');
    set(handles.edit28,'String','');
    break;
end

% Check if the viscosity file name has been specified (D-Flow FM)
inifile     = get(handles.edit28,'String');
if isempty(inifile);
    if exist('wb'); close(wb); end;
    errordlg('The initial conditions sample file name has not been specified.','Error');
    break;
end
if length(inifile) > 8;
    if strcmp(inifile(end-7:end),'_ini.xyz') == 0;
        if exist('wb'); close(wb); end;
        errordlg('The initial conditions sample file name has an improper extension.','Error');
        break;
    end
end

% Put the output directory name in the filenames
inifile     = [pathout,'\',inifile];


%%% ACTUAL CONVERSION OF THE GRID

d3d2dflowfm_initial_xyz(filegrd,fileini,inifile);