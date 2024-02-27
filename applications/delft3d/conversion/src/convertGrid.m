%%% Clear screen and ignore warnings

fclose all;
clc;
warning off all;


%%% STANDARD GUI CHECK ON DIRECTORIES

convertGuiDirectoriesCheck;


%%% GUI CHECKS

% In case of conversion of all stuff
dpsopt      = 1;
if convertallstuff == 1;

    % Check if the mdf file name has been specified (Delft3D)
    filemdf     = get(handles.edit3,'String');
    filemdf     = deblank2(filemdf);
    if ~isempty(filemdf);
        filemdf = [pathin,'\',filemdf];
        if exist(filemdf,'file')==0;
            if exist('wb'); close(wb); end;
            errordlg('The specified mdf file does not exist.','Error');
%             break;
        end
    else
        if exist('wb'); close(wb); end;
        errordlg('The mdf file name has not been specified.','Error');
%         break;
    end

    % Check type of bathymetry data
    mdfcontents = delft3d_io_mdf('read',filemdf);
    mdfkeywds   = mdfcontents.keywords;
    dpsopt      = 1;
    if isfield(mdfkeywds,'dpsopt') == 1;
        if strcmpi(mdfkeywds.dpsopt,'DP');
            dpsopt       = 0;
        end
    end
    
end

% Check if the input is correct
if ~isempty(filedep);
    filedep = [pathin,'\',filedep];
    if exist(filedep,'file')==0;
        if exist('wb'); close(wb); end;
        errordlg('The specified dep-file does not exist in the specified input directory.','Error');
%         break;
    end
end

% Check if the netcdf file name has been specified
filenetcdf  = get(handles.edit8,'String');
if isempty(filenetcdf);
    if exist('wb'); close(wb); end;
    errordlg('The netcdf file name has not been specified.','Error');
%     break;
end
if length(filenetcdf) > 7;
    if strcmp(filenetcdf(end-6:end),'_net.nc') == 0;
        if exist('wb'); close(wb); end;
        errordlg('The netcdf file name has an improper extension.','Error');
%         break;
    end
end

% Check if the bedlevel sample file has been specified
filebedsam  = get(handles.edit30,'String');
if isempty(filebedsam);
    if exist('wb'); close(wb); end;
    errordlg('The bedlevel sample file name has not been specified.','Error');
%     break;
end
if length(filebedsam) > 8;
    if strcmp(filebedsam(end-7:end),'_bed.xyz') == 0;
        if exist('wb'); close(wb); end;
        errordlg('The bedlevel sample file name has an improper extension.','Error');
%         break;
    end
end

% Put the output directory name in the filenames
filenetcdf  = [pathout,'\',filenetcdf];
filebedsam  = [pathout,'\',filebedsam];


%%% ACTUAL CONVERSION OF THE GRID

if ~isempty(fileenc);
    d3d2dflowfm_grd2net(filegrd,''     ,filedep,filenetcdf,filebedsam);
else
    d3d2dflowfm_grd2net(filegrd,fileenc,filedep,filenetcdf,filebedsam);
end
fclose all;
clc;


%%% GIVE WARNING IN CASE OF NON-MATCHING BATHYMETRY DATAPOINTS
if dpsopt == 0;
    warndlg('Important: bed level definition in Delft3D is not compliant with bed level definition in D-Flow FM (dpsopt = DP).','Warning');
end
