%%% Clear screen and ignore warnings

fclose all;
clc;
warning off all;


%%% STANDARD GUI CHECK ON DIRECTORIES

convertGuiDirectoriesCheck;


%%% GUI CHECKS

% In case of conversion of all stuff
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

    % Check if the mdu file name has been specified (D-Flow FM)
    mdufile     = get(handles.edit4,'String');
    if isempty(mdufile);
        if exist('wb'); close(wb); end;
        errordlg('The D-Flow FM master definition file name has not been specified.','Error');
%         break;
    end
    if length(mdufile) > 4;
        if strcmp(mdufile(end-3:end),'.mdu') == 0;
            if exist('wb'); close(wb); end;
            errordlg('The D-Flow FM master definition file name has an improper extension.','Error');
%             break;
        end
    end

    % Put the output directory name in the filenames
    mdufile     = [pathout,'\',mdufile];
    bndname     = mdufile(1:end-4);

    % If not: set simple name
else
    bndname     = [pathout,'\boundary'];
end

% Check if the bnd file name has been specified (Delft3D)
filebnd     = get(handles.edit9,'String');
filebnd     = deblank2(filebnd);
if ~isempty(filebnd);
    filebnd = [pathin,'\',filebnd];
    if exist(filebnd,'file')==0;
        if exist('wb'); close(wb); end;
        errordlg('The specified boundary file does not exist.','Error');
%         break;
    end
else
    if exist('wb'); close(wb); end;
    errordlg('The boundary file name has not been specified.','Error');
%     break;
end


%%% ACTUAL CONVERSION OF THE BOUNDARY LOCATIONS

plis        = d3d2dflowfm_bnd2pli(filegrd,filebnd,bndname,'Salinity',false);


%%% CHECK FOR SALINITY

% In case of conversion of all stuff
if convertallstuff == 1;

    % Read file
    mdfcontents           = delft3d_io_mdf('read',filemdf);
    mdfkeywds             = mdfcontents.keywords;

    % Read the mdf file (only to check if salinity is included)
    if isfield(mdfkeywds,'sub1') == 1;
        finds             = find(mdfkeywds.sub1 == 'S');
        if isempty(finds);
            salinity      = false;
        else
            salinity      = true;
        end
    else
        salinity          = false;
    end

    % If not: set salinity to true anyway
else
    salinity          = true;
end

% Build plis
if salinity == true;
    plissal           = d3d2dflowfm_bnd2pli(filegrd,filebnd,bndname,'Salinity',true);
end

%%% CHECK FOR TEMPERATURE

% In case of conversion of all stuff
if convertallstuff == 1;

    % Read file
    mdfcontents           = delft3d_io_mdf('read',filemdf);
    mdfkeywds             = mdfcontents.keywords;

    % Read the mdf file (only to check if salinity is included)
    if isfield(mdfkeywds,'sub1') == 1;
        finds             = find(mdfkeywds.sub1 == 'T');
        if isempty(finds);
            temperature      = false;
        else
            temperature      = true;
        end
    else
        temperature          = false;
    end

    % If not: set temperature to true anyway
else
    temperature          = true;
end

% Build plis
if temperature == true;
    plistem           = d3d2dflowfm_bnd2pli(filegrd,filebnd,bndname,'Temperature',true);
end



%%% PUT PLI-FILES IN LISTBOX

if salinity == true && temperature == false;
    set(handles.listbox1,'String',[plis plissal]);
elseif salinity == true && temperature == true;
    set(handles.listbox1,'String',[plis plissal plistem]);
elseif salinity == false && temperature == true;
    set(handles.listbox1,'String',[plis plistem]);
else
    set(handles.listbox1,'String', plis         );
end
