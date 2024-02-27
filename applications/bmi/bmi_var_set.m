function values = bmi_var_set(bmidll, var_name, values)
% allocate exactly MAXSTRLEN : 1024 chars
type_name = [repmat(' ', [1,1024])];
[name, type_name] = calllib(bmidll, 'get_var_type', var_name, type_name);

rank_ = 0;
[name, rank_] = calllib(bmidll, 'get_var_rank', var_name, rank_);
% Shape is always zero long
shape = zeros(6,1);
[name, shape] = calllib(bmidll, 'get_var_shape', var_name, shape);
% Matlab inconvenience (vector==matrix....)
if (rank_ == 1) 
    shape = [shape(rank_),1];
else
    shape = shape(1:rank_);
end
% Ensure a row vector
shape = shape(:)';
switch type_name
    case 'int'
        values = int32(values);
    case 'float'
        values = single(values);
    case 'double'
        values = double(values);
end
% Dynamicly create the function name, only int, float and double supported
functionname = sprintf('set_%dd_%s', rank_, type_name);
[name, values] = calllib(bmidll, functionname, var_name, values);
end