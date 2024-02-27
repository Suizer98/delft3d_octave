function string = simona2mdu_replacechar(string,char_org,char_replace)

% Replaces single character in a string or cell array of strings
%

if iscell(string)
    %
    % Cell array of strings
    %
    for icel = 1: length(string)
        index = strfind(string{icel},char_org);
        while ~isempty(index)
            string{icel} = [string{icel}(1:index(1) - 1) char_replace string{icel}(index(1) + length(char_org):end)];
            index = strfind(string{icel},char_org);
        end
        string{icel} = strtrim(string{icel});
    end
else
    %
    % Single string
    %
    index = strfind(string,char_org);
    while ~isempty(index)
        string = [string(1:index(1) - 1) char_replace string(index(1) + length(char_org):end)];
        index = strfind(string,char_org);
    end
    string = strtrim(string);
end
