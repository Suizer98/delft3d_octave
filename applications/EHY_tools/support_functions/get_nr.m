function nr = get_nr(cell_str,str)

%% Simple, might be more elegant methods but at least it always works

nr = [];
for i_cell = 1: length(cell_str)
    if strcmpi(cell_str{i_cell}, str)
        nr = i_cell;
        break
    end
end
