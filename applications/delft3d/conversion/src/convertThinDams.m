%%% Clear screen and ignore warnings

fclose all;
clc;
warning off all;


%%% STANDARD GUI CHECK ON DIRECTORIES

convertGuiDirectoriesCheck;


%%% GUI CHECKS

% Check if the dry points file name has been specified (Delft3D)
filedry     = get(handles.edit19,'String');
filedry     = deblank2(filedry);
jadry       = 1;
if ~isempty(filedry);
    filedry = [pathin,'\',filedry];
    if exist(filedry,'file')==0;
        if exist('wb'); close(wb); end;
        errordlg('The specified dry points file does not exist.','Error');
        set(handles.edit27,'String','');
        break;
    end
else
    jadry = 0;
end

% Check if the thin dams file name has been specified (Delft3D)
filethd     = get(handles.edit20,'String');
filethd     = deblank2(filethd);
jathd       = 1;
if ~isempty(filethd);
    filethd = [pathin,'\',filethd];
    if exist(filethd,'file')==0;
        if exist('wb'); close(wb); end;
        errordlg('The specified thin dams file does not exist.','Error');
        set(handles.edit27,'String','');
        break;
    end
else
    jathd = 0;
end

% Check if either the dry-file and/or the thd-file has been assigned as input
if jadry == 1 | jathd == 1;
    
    % Check if the thin dams file name has been specified (D-Flow FM)
    thdfile     = get(handles.edit27,'String');
    if isempty(thdfile);
        if exist('wb'); close(wb); end;
        errordlg('The thin dams file name has not been specified.','Error');
        break;
    end
    if length(thdfile) > 8;
        if strcmp(thdfile(end-7:end),'_thd.pli') == 0;
            if exist('wb'); close(wb); end;
            errordlg('The thin dams file name has an improper extension.','Error');
            break;
        end
    end
    
    % Put the output directory name in the filenames
    thdfile     = [pathout,'\',thdfile];
    
    
    %%% ACTUAL CONVERSION OF THE GRID
    
    d3d2dflowfm_thd_xyz(filegrd,filedry,filethd,thdfile);
end