function hydrus1d_write_input(varargin)

OPT = struct( ...
    'path', pwd, ...
    'description', '');

OPT = setproperty(OPT, varargin);

%% write description file

fid = fopen(fullfile(OPT.path, 'DESCRIPT.TXT'),'w');
fprintf(fid, '%s\n', 'Pcp_File_Version=1');
fclose(fid);

%% write project file

hydrus1d_write_projectfile('path', OPT.path);

%% write selector file

hydrus1d_write_selectorfile('path', OPT.path);

%% write profile file

hydrus1d_write_profilefile('path', OPT.path);

%% write atmosphere file

hydrus1d_write_atmospherefile('path', OPT.path);