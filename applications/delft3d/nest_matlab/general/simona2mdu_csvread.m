function [csv] = simona2mdu_csvread(filename,varargin)
%
% simona2mdu_csvread: reads comma seperated value file, also strings are returned
%                     empty lines are skipped
%                     optionally, comment lines are ignored
%                     csv = simona2mdu_csvread('test.csv','skiplines','%*')
%                     reads csv file, returns cell array csv, lines starting with a % or * are ignored
%

opt.skiplines = '';
opt.delimiter = ',';
opt.convert   = true;
opt = setproperty(opt,varargin);

irow = 0;
fid = fopen(filename);

while ~feof(fid)
    %
    % Read line from the csv file
    %
    line = strtrim(fgetl(fid));
    if ~isempty(line) && ~ismember(line(1),opt.skiplines)
        irow = irow + 1;
        %
        % Find comma's and quotes within the string
        %
        index_quote = strfind(line,'"');

        index_comma = [];
        for i_del = 1: length(opt.delimiter);
            index_comma = [index_comma strfind(line,opt.delimiter(i_del))];
        end
        index_comma = sort(index_comma);

        if ~isempty(index_quote)
            %
            % remove comma's between quotes (belong with a string)
            %
            for i_quote = 1:2:length(index_quote)
                for i_comma = 1: length(index_comma)
                    if index_comma(i_comma) > index_quote(i_quote) && ...
                       index_comma(i_comma) < index_quote(i_quote + 1)
                       index_comma(i_comma) = NaN;
                    end
                end
            end
            index_comma = index_comma(~isnan(index_comma));
        end

        %
        % Define cells (in between remaining comm's)
        %

        index_comma = [0 index_comma length(line) + 1];

        %
        % Fill output cell
        %
        for icol = 1:length(index_comma) - 1
            csv{irow,icol} = line(index_comma(icol) + 1:index_comma(icol + 1) - 1);
            if opt.convert
                if ~isempty(str2num((csv{irow,icol})))
                    csv{irow,icol} = str2num(csv{irow,icol});
                else
                    csv{irow,icol} = simona2mdu_replacechar(csv{irow,icol},'"',' ');
                end
            end
        end
    end
 end

fclose (fid);
