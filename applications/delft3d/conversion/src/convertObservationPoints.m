%%% Clear screen and ignore warnings

fclose all;
clc;
warning off all;


%%% STANDARD GUI CHECK ON DIRECTORIES

convertGuiDirectoriesCheck;


%%% GUI CHECKS

% Check if the observation file name has been specified (Delft3D)
filesta     = get(handles.edit15,'String');
filesta     = deblank2(filesta);
if ~isempty(filesta);
    filesta = [pathin,'\',filesta];
    if exist(filesta,'file')==0;
        if exist('wb'); close(wb); end;
        errordlg('The specified observation points file does not exist.','Error');
        set(handles.edit22,'String','');
%         break;
    end
else
    if exist('wb'); close(wb); end;
    errordlg('The observation points file name has not been specified.','Error');
    set(handles.edit22,'String','');
%     break;
end

% Check if the observation file name has been specified (D-Flow FM)
obsfile     = get(handles.edit22,'String');
if isempty(obsfile);
    if exist('wb'); close(wb); end;
    errordlg('The observation points sample file name has not been specified.','Error');
%     break;
end
if length(obsfile) > 8;
    if strcmp(obsfile(end-7:end),'_obs.xyn') == 0;
        if exist('wb'); close(wb); end;
        errordlg('The observation points sample file name has an improper extension.','Error');
%         break;
    end
end

% Put the output directory name in the filenames
obsfile     = [pathout,'\',obsfile];


%%% ACTUAL CONVERSION OF THE GRID

d3d2dflowfm_obs_xy(filegrd,filesta,obsfile);
