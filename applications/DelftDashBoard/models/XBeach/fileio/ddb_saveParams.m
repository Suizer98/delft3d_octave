function ddb_saveParams(handles,ndomain)

%% This function saves the structure from DDB 
% Makes use of xb_read_input and xb_save_input
handles = getHandles;

%% Get XBeach structure
xbeach_ddb = handles.model.xbeach.domain(ndomain);
xbeach_writing = xs_set('');

%% Check which variables are different than default?
xbeach_empty = ddb_initializeXBeachInput([],1,'empty');
xbeach_empty = xbeach_empty.model.xbeach.domain;
names = fieldnames(xbeach_empty);

count = 1; varchanged = [];
varchanged{1} = 'tst';
for ii = 1:length(names);
    nametesting = names{ii};
    try
        if isnumeric(xbeach_empty.(nametesting))
            if xbeach_ddb.(nametesting) == xbeach_empty.(nametesting);
            else
            varchanged{count} = nametesting;
            count = count +1;
            end
        else
            if strcmp(xbeach_ddb.(nametesting), xbeach_empty.(nametesting))
            else
                varchanged{count} = nametesting;
                count = count +1;
            end
        end
    end
end

for ii = 1:count-1
    nametesting = varchanged{ii};
    xbeach_writing.data(ii).name = nametesting;
    xbeach_writing.data(ii).value = xbeach_ddb.(nametesting);
end

%% Always write these variables
% -> make sure no double!
varsneeded = {'alfa', 'xori', 'yori', 'front', 'back', 'depfile', 'xfile', 'yfile', 'thetamin' ,'thetamax', 'dtheta', 'CFL', 'bedfriction', 'instat', 'outputformat' ,'tintm','tintg', 'tstart', 'tstop', 'globalvars', 'meanvars', 'morfac'};
for ii = 1:length(varsneeded)
    nametesting = varsneeded{ii};

    try
    if sum(strcmp(varchanged, nametesting))>0
    else
        xbeach_writing.data(count).name = nametesting;
        xbeach_writing.data(count).value = xbeach_ddb.(nametesting);
        count = count+1;
    end
    end
end

%% Make sure tides are correct
for jj = 1:length(xbeach_writing.data)
    vars{jj} = xbeach_writing.data(jj).name;
end
ids =find((strcmp(vars, 'zs0file'))>0);
if isempty(ids);
    ids = length(xbeach_writing.data)+1;
else
end
try
zs0file = xbeach_writing.data(ids).value;
xbeach_writing.data(ids).value = [];
xbeach_writing.data(ids).value = xbeach_ddb.zs0file_info.name;
catch
end

%% Also have vegetation
for jj = 1:length(xbeach_writing.data)
    vars{jj} = xbeach_writing.data(jj).name;
end
ids =find((strcmp(vars, 'veggiefile'))>0);
if isempty(ids);
    ids = length(xbeach_writing.data)+1;
else
end
try
tst = xbeach_ddb.veggiefile;
xbeach_writing.data(ids).value = [];
xbeach_writing.data(ids).name =     'veggiefile';
xbeach_writing.data(ids).value =    xbeach_ddb.veggiefile;
catch
end

for jj = 1:length(xbeach_writing.data)
    vars{jj} = xbeach_writing.data(jj).name;
end
ids =find((strcmp(vars, 'veggiemapfile'))>0);
if isempty(ids);
    ids = length(xbeach_writing.data)+1;
else
end
try
tst = xbeach_ddb.veggiemapfile;
xbeach_writing.data(ids).value = [];
xbeach_writing.data(ids).name       = 'veggiemapfile';
xbeach_writing.data(ids).value      = xbeach_ddb.veggiemapfile;
catch
end

%% Always delete
varsdelete = {'runid', 'attname', 'ParamsFile'};
for ii = 1:length(varsdelete)
    nametesting = varsdelete{ii};
    for jj = 1:length(xbeach_writing.data)
        vars{jj} = xbeach_writing.data(jj).name;
    end
    ids =find((strcmp(vars, nametesting))>0);
    xbeach_writing.data(ids) = [];
end

%% Check is every cell 'full'
ndatathings = length(length(xbeach_writing.data));
for jj = 1:ndatathings
    if isempty(xbeach_writing.data(jj).value)
        iddel = jj;
    end
    try
    if ~isempty(iddel)
    xbeach_writing.data(iddel) = [];
    end
    end
    ndatathings = length(length(xbeach_writing.data));
end

%% Check grid type
gridform = xs_get(xbeach_writing, 'gridform');
if strfind(gridform, 'delft3d')
    xbeach_writing = xs_del(xbeach_writing, 'xfile');
    xbeach_writing = xs_del(xbeach_writing, 'yfile');
end

%% Writing
pathname = handles.model.xbeach.domain(ndomain).pwd;
cd(pathname);xb_write_params('params.txt', xbeach_writing);

%% Write batch file
fname = '_run_XBeach.bat';
fileID = fopen(fname,'wt');
fprintf(fileID,'call ');
fprintf(fileID,'%s',handles.model.xbeach.exedir);
fprintf(fileID,'xbeach.exe');
fclose(fileID);
fclose('all');

