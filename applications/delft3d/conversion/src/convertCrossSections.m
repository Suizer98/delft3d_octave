%%% Clear screen and ignore warnings

fclose all;
clc;
warning off all;


%%% STANDARD GUI CHECK ON DIRECTORIES

convertGuiDirectoriesCheck;


%%% GUI CHECKS

% Check if the cross-sections file name has been specified (Delft3D)
filecrs     = get(handles.edit16,'String');
filecrs     = deblank2(filecrs);
if ~isempty(filecrs);
    filecrs = [pathin,'\',filecrs];
    if exist(filecrs,'file')==0;
        if exist('wb'); close(wb); end;
        errordlg('The specified cross-sections file does not exist.','Error');
        set(handles.edit31,'String','');
%         break;
    end
else
    if exist('wb'); close(wb); end;
    errordlg('The cross-sections file name has not been specified.','Error');
    set(handles.edit31,'String','');
%     break;
end

% Check if the cross-sections file name has been specified (D-Flow FM)
crsfile     = get(handles.edit31,'String');
if isempty(crsfile);
    if exist('wb'); close(wb); end;
    errordlg('The cross-sections polyline file name has not been specified.','Error');
%     break;
end
if length(crsfile) > 8;
    if strcmp(crsfile(end-7:end),'_crs.pli') == 0;
        if exist('wb'); close(wb); end;
        errordlg('The ocross-sections polyline file name has an improper extension.','Error');
%         break;
    end
end

% Put the output directory name in the filenames
crsfile     = [pathout,'\',crsfile];


%%% ACTUAL CONVERSION OF THE GRID

d3d2dflowfm_crs_xy (filegrd,filecrs,crsfile);
