function filename = simona2mdf_rmpath(fullnames)

% rmpath : removes path from file name

if iscell(fullnames)
    for i_str = 1: length(fullnames)
       [~,name,ext]     = fileparts(fullnames{i_str});
       filename{i_str}  = [name ext];
    end
elseif ischar(fullnames)
    [~,name,ext]     = fileparts(fullnames);
    filename         = [name ext];
end
