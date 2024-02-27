function value = simona2mdf_fieldandvalue(struct,string)

% simona2mdf_fieldandvalue : determines wheteher a field exists and if it has a value


%
% Decompose string
%

if ~isempty(string)
    fieldnames = textscan(string,'%s','delimiter','.');
else
    fieldnames = '';
    end

if isempty(fieldnames)
    
    %
    % Lowest level
    %

    try
        if ~isempty(struct)
            value = true;
        else
            value = false;
        end
        return
    catch
        value = false;
        return
    end
else
    
    %
    % Go deeper
    %

    index = strfind(string,'.');
    if isempty(index)
        name   = string;
        string = '';
        if ~isfield(struct,name)
            value = false;
            return
        end
    else
        if isfield(struct,string(1:index(1) - 1))
            name   = string(1:index(1) - 1);
            string = string(index(1) + 1:end);
        else
            value = false;
            return
        end
    end
    
    value = simona2mdf_fieldandvalue(struct.(name),string);
end
    
    
    
