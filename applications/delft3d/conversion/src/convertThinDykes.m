%%% Clear screen and ignore warnings

fclose all;
clc;
warning off all;


%%% STANDARD GUI CHECK ON DIRECTORIES

convertGuiDirectoriesCheck;


%%% GUI CHECKS

% Check if the 2D weir file name has been specified (Delft3D)
filewei     = get(handles.edit36,'String');
filewei     = deblank2(filewei);
if ~isempty(filewei);
    filewei = [pathin,'\',filewei];
    if exist(filewei,'file')==0;
        if exist('wb'); close(wb); end;
        errordlg('The specified 2D weir file does not exist.','Error');
        set(handles.edit37,'String','');
        break;
    end
else
    if exist('wb'); close(wb); end;
    errordlg('The 2D weir file name has not been specified.','Error');
    set(handles.edit37,'String','');
    break;
end

% Check if the 2D weir file name has been specified (D-Flow FM)
weifile     = get(handles.edit37,'String');
if isempty(weifile);
    errordlg('The 2D weir polyline file name has not been specified.','Error');
    break;
end
if length(weifile) > 8;
    if strcmp(weifile(end-7:end),'_tdk.pli') == 0;
        if exist('wb'); close(wb); end;
        errordlg('The 2D weir polyline file name has an improper extension.','Error');
        break;
    end
end

% Put the output directory name in the filenames
weifile     = [pathout,'\',weifile];


%%% ACTUAL CONVERSION OF THE GRID

d3d2dflowfm_weirs_xyz(filegrd,filewei,weifile);