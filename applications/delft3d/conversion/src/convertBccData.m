%%% Clear screen and ignore warnings

fclose all;
clc;
warning off all;


%%% STANDARD GUI CHECK ON DIRECTORIES

convertGuiDirectoriesCheck;


%%% GUI CHECKS

% Check if the bcc file name has been specified (Delft3D)
filebcc     = get(handles.edit14,'String');
filebcc     = deblank2(filebcc);
if ~isempty(filebcc);
    filebcc = [pathin,'\',filebcc];
    if exist(filebcc,'file')==0;
        if exist('wb'); close(wb); end;
        errordlg('The specified bcc file does not exist.','Error');
        break;
    end
else
    if exist('wb'); close(wb); end;
    errordlg('The bcc file name has not been specified.','Error');
    break;
end

% Catch the polyline names for the boundary conditions
readpli     = get(handles.listbox1,'String');


%%% ACTUAL CONVERSION OF THE BCC DATA

% Get the salinity and temperature pli's
clear filepli;
i_pli_sal       = 0;
i_pli_tem       = 0;
for i=1:length(readpli);
    pli     = readpli{i};
    if strcmpi(pli(end-7:end),'_sal.pli') == 1;
        i_pli_sal          = i_pli_sal + 1;
        filepli_sal{i_pli_sal} = [pathout filesep readpli{i}];
    elseif strcmpi(pli(end-7:end),'_tem.pli') == 1;
        i_pli_tem          = i_pli_tem + 1;
        filepli_tem{i_pli_tem} = [pathout filesep readpli{i}];        
    end
end

% Use general conversion routine (also works for harmonic and timeseries)
allfiles_sal    = [];
allfiles_sal    = d3d2dflowfm_convertbc(filebcc,filepli_sal,pathout,'Salinity',true,'Series',true);

allfiles_tem    = [];
allfiles_tem    = d3d2dflowfm_convertbc(filebcc,filepli_tem,pathout,'Temperature',true,'Series',true);

allfiles = [allfiles_sal allfiles_tem];

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
set(handles.listbox5,'String',names);