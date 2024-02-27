%%% Clear screen and ignore warnings

fclose all;
clc;
warning off all;


%%% STANDARD GUI CHECK ON DIRECTORIES

convertGuiDirectoriesCheck;


%%% FOLLOW THE SEQUENCE

% Check if the session is initialized
mdufile     = get(handles.edit4,'String');
filegrd     = get(handles.edit5,'String');
if isempty(mdufile) & isempty(filegrd);
    errordlg('The sessions has not been initialized. First press ''Initialize''.','Error');
    break;
end

% Remove waitbar if it exists
if exist('wb'); close(wb); end;
istep       =  1;
numsteps    = 18;

% Convert the grid
wb          = waitbar(istep/numsteps,'Converting the grid ...');
istep       = istep + 1;
convertGrid;

% Generate the pli-files
waitbar(istep/numsteps,wb,'Generating the boundary polylines ...');
istep       = istep + 1;
filebnd     = get(handles.edit9,'String');
filebnd     = deblank2(filebnd);
if ~isempty(filebnd);
    filebnd = [pathin,'\',filebnd];
    if exist(filebnd,'file')~=0;
        convertBoundaryLocations;
    end
end

% Set template of the ext-file
waitbar(istep/numsteps,wb,'Setting the template for the ext file ...');
istep       = istep + 1;
convertExtForcing;

% Check if bct-file is present; if yes, then convert the data
waitbar(istep/numsteps,wb,'Converting the timeseries boundary data ...');
istep       = istep + 1;
filebct     = get(handles.edit11,'String');
filebct     = deblank2(filebct);
if ~isempty(filebct);
    filebct = [pathin,'\',filebct];
    if exist(filebct,'file')~=0;
        convertBctData;
    end
end

% Check if bca-file is present; if yes, then convert the data
waitbar(istep/numsteps,wb,'Converting the astronomic boundary data ...');
istep       = istep + 1;
filebca     = get(handles.edit12,'String');
filebca     = deblank2(filebca);
if ~isempty(filebca);
    filebca = [pathin,'\',filebca];
    if exist(filebca,'file')~=0;
        convertBcaData;
    end
end

% Check if bch-file is present; if yes, then convert the data
waitbar(istep/numsteps,wb,'Converting the harmonic boundary data ...');
istep       = istep + 1;
filebch     = get(handles.edit13,'String');
filebch     = deblank2(filebch);
if ~isempty(filebch);
    filebch = [pathin,'\',filebch];
    if exist(filebch,'file')~=0;
        convertBchData;
    end
end

% Check if bcc-file is present; if yes, then convert the data
waitbar(istep/numsteps,wb,'Converting the salinity boundary data ...');
istep       = istep + 1;
filebcc     = get(handles.edit14,'String');
filebcc     = deblank2(filebcc);
if ~isempty(filebcc);
    filebcc = [pathin,'\',filebcc];
    if exist(filebcc,'file')~=0;
        convertBccData;
    end
end

% Check if wnd-file is present; if yes, then convert the data
waitbar(istep/numsteps,wb,'Converting the unimagdir wind ...');
istep       = istep + 1;
filewnd     = get(handles.edit32,'String');
filewnd     = deblank2(filewnd);
if ~isempty(filewnd);
    filewnd = [pathin,'\',filewnd];
    if exist(filewnd,'file')~=0;
        convertUnimagdir;
    else
        set(handles.edit33,'String','');
    end
end

% Check if spw-file is present; if yes, then convert the data
waitbar(istep/numsteps,wb,'Converting the spiderweb wind ...');
istep       = istep + 1;
filespw     = get(handles.edit34,'String');
filespw     = deblank2(filespw);
if ~isempty(filespw);
    filespw = [pathin,'\',filespw];
    if exist(filespw,'file')~=0;
        convertSpiderweb;
    else
        set(handles.edit35,'String','');
    end
end

% Check if obs-file is present; if yes, then convert the data
waitbar(istep/numsteps,wb,'Converting the observation points ...');
istep       = istep + 1;
fileobs     = get(handles.edit15,'String');
fileobs     = deblank2(fileobs);
if ~isempty(fileobs);
    fileobs = [pathin,'\',fileobs];
    if exist(fileobs,'file')~=0;
        convertObservationPoints;
    else
        set(handles.edit22,'String','');
    end
end

% Check if crs-file is present; if yes, then convert the data
waitbar(istep/numsteps,wb,'Converting the cross sections ...');
istep       = istep + 1;
filecrs     = get(handles.edit16,'String');
filecrs     = deblank2(filecrs);
if ~isempty(filecrs);
    filecrs = [pathin,'\',filecrs];
    if exist(filecrs,'file')~=0;
        convertCrossSections;
    else
        set(handles.edit31,'String','');
    end
end

% Check if rgh-file is present; if yes, then convert the data
waitbar(istep/numsteps,wb,'Converting the spatial friction data ...');
istep       = istep + 1;
filergh     = get(handles.edit17,'String');
filergh     = deblank2(filergh);
if ~isempty(filergh);
    filergh = [pathin,'\',filergh];
    if exist(filergh,'file')~=0;
        convertRoughness;
    else
        set(handles.edit24,'String','');
    end
end

% Check if edy-file is present; if yes, then convert the data
waitbar(istep/numsteps,wb,'Converting the spatial viscosity data ...');
istep       = istep + 1;
fileedy     = get(handles.edit18,'String');
fileedy     = deblank2(fileedy);
if ~isempty(fileedy);
    fileedy = [pathin,'\',fileedy];
    if exist(fileedy,'file')~=0;
        convertViscosity;
    else
        set(handles.edit25,'String','');
    end
end

% Check if ini-file is present; if yes, then convert the data
waitbar(istep/numsteps,wb,'Converting the initial waterlevels ...');
istep       = istep + 1;
fileini     = get(handles.edit21,'String');
fileini     = deblank2(fileini);
if ~isempty(fileini);
    fileini = [pathin,'\',fileini];
    if exist(fileini,'file')~=0;
        convertInitialConditions;
    else
        set(handles.edit28,'String','');
    end
end

% Check if dry-file or thd-file is present; if yes, then convert the data
waitbar(istep/numsteps,wb,'Converting the dry points and/or thin dams ...');
istep       = istep + 1;
filedry     = get(handles.edit19,'String');
filedry     = deblank2(filedry);
nodry       = 0;
nothd       = 0;
if isempty(filedry);
    nodry   = 1;
end
filethd     = get(handles.edit20,'String');
filethd     = deblank2(filethd);
if isempty(filethd);
    nothd   = 1;
end
if nodry == 0 | nothd == 0;
    filedry = [pathin,'\',filedry];
    filethd = [pathin,'\',filethd];
    if exist(filedry,'file')~=0 | exist(filethd,'file')~=0;
        convertThinDams;
    else
        set(handles.edit27,'String','');
    end
end
if nodry == 1 & nothd == 1;
    set(handles.edit27 ,'String','');
end

% Check if 2dw-file is present; if yes, then convert the data
waitbar(istep/numsteps,wb,'Converting the 2D weir data ...');
istep       = istep + 1;
file2dw     = get(handles.edit36,'String');
file2dw     = deblank2(file2dw);
if ~isempty(file2dw);
    file2dw = [pathin,'\',file2dw];
    if exist(file2dw,'file')~=0;
        convertThinDykes;
    else
        set(handles.edit37,'String','');
    end
end

% Finalize ext-file
waitbar(istep/numsteps,wb,'Finalizing the ext file ...');
istep       = istep + 1;
convertExtForcingFin;

% Finalize mdu-file
waitbar(istep/numsteps,wb,'Finalizing the mdu file ...');
istep       = istep + 1;
convertMasterFile;
close(wb);

% Finished!
msgbox('Conversion finished!','Message');