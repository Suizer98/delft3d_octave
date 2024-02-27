function [Info] = read_sobeknc (dir_or_filename)

% Read all data from all the sobeknc files in a directory or just a single file 

if isdir(dir_or_filename)
    %% Get all filenames
    D                 = dir2(dir_or_filename,'file_incl', '\.nc$');
    files             = find(~[D.isdir]);
    full_file_names   = strcat({D(files).pathname}, {D(files).name})';
    
    for i_file = 1: length(full_file_names)
        [~,name,~] = fileparts(full_file_names{i_file});
        position = strfind(name,'-');
        short_file_name{i_file} = simona2mdu_replacechar(name(1:position(1)-1),' ','_');
        short_file_name{i_file} = simona2mdu_replacechar(short_file_name{i_file},'(','');
        short_file_name{i_file} = simona2mdu_replacechar(short_file_name{i_file},')','');
        Info.(short_file_name{i_file}) = read_sobeknc_file(full_file_names{i_file});
    end
else
    Info = read_sobeknc_file_new(dir_or_filename);
end

end

function Info = read_sobeknc_file_new(file_name)

%% Read a single Sobek3 nc file and put everthing in a structure
general    = nc_info(file_name);
names      = {general.Dataset.Name};

for i_name = 1: length(names)
    Info.(names{i_name}) = ncread(file_name,names{i_name});
    
end

end