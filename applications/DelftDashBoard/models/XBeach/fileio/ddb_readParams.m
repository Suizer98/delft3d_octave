function handles=ddb_readParams(handles,filename,ad)

xbs = xb_read_input(filename);


% Fix for D3D grids
nx = xs_get(xbs, 'nx'); ny = xs_get(xbs, 'ny');
gridform = xs_get(xbs, 'gridform');
if strfind(gridform, 'delft3d')
    xbs = xs_set(xbs, 'nx', ny-1);
    xbs = xs_set(xbs, 'ny', nx-1);
end

% Place in DDB
for is = 1:length(xbs.data)
    if isnumeric(xbs.data(is).value)
        ddb_xbmi.(xbs.data(is).name) = xbs.data(is).value;
    elseif ischar(xbs.data(is).value)
        ddb_xbmi.(xbs.data(is).name) = xbs.data(is).value;
    elseif isstruct(xbs.data(is).value)
        [pathstr,fname,ext] = fileparts(xbs.data(is).value.file);
        ddb_xbmi.(xbs.data(is).name) = [fname ext]; % get name of file 
    end
end

% Replace default values with model input
fieldNames = fieldnames(ddb_xbmi);
for i = 1:size(fieldNames,1)
    handles.model.xbeach.domain(ad).(fieldNames{i}) = ddb_xbmi.(fieldNames{i});
end

% Save variables
namesxb = [];
for ii = 1:length(xbs.data)
    namesxb{ii} = xbs.data(ii).name;
end

% Always needed
varsneeded = {'meanvars', 'globalvars'};
for ii = 1:length(varsneeded)
    nametesting = varsneeded{ii};
    ids =find((strcmp(namesxb, nametesting))>0);
    handles.model.xbeach.domain(ad).(varsneeded{ii}) = xbs.data(ids).value;
end

% Change path
index = findstr(filename, '\');    
handles.model.xbeach.domain(ad).pwd=filename(1:(index(end)-1));
handles.model.xbeach.domain(ad).params_file=filename;
disp('Params red successfully')
