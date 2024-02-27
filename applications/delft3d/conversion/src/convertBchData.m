%%% Clear screen and ignore warnings

fclose all;
clc;
warning off all;


%%% STANDARD GUI CHECK ON DIRECTORIES

convertGuiDirectoriesCheck;


%%% GUI CHECKS

% Check if the bca file name has been specified (Delft3D)
filebch     = get(handles.edit13,'String');
filebch     = deblank2(filebch);
if ~isempty(filebch);
    filebch = [pathin,'\',filebch];
    if exist(filebch,'file')==0;
        if exist('wb'); close(wb); end;
        errordlg('The specified bch file does not exist.','Error');
        break;
    end
else
    if exist('wb'); close(wb); end;
    errordlg('The bch file name has not been specified.','Error');
    break;
end

% Catch the polyline names for the boundary conditions
readpli     = get(handles.listbox1,'String');


%%% ACTUAL CONVERSION OF THE BCH DATA

% Filter the salinity-plis out
clear filepli;
i_pli       = 0;
for i=1:length(readpli);
    pli     = readpli{i};
    if strcmpi(pli(end-7:end),'_sal.pli');
        continue
    else
        i_pli          = i_pli + 1;
        filepli{i_pli} = [pathout filesep readpli{i}];
    end
end

% Use general conversion routine (also works for harmonic and timeseries)
allfiles    = [];
allfiles    = d3d2dflowfm_convertbc(filebch,filepli,pathout,'Harmonic',true);

% Fill listbox with cmp files
i_file      = 0;
if ~isempty(allfiles);
    for i = 1: length(allfiles);
        if ~isempty(allfiles{i});
            i_file              = i_file + 1;
            alltimfiles{i_file} = allfiles{i};
            [~,names{i_file},~] = fileparts(alltimfiles{i_file});
        end
    end
end
set(handles.listbox4,'String',names);