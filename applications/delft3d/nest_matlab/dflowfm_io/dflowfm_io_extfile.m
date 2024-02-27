function varargout=dflowfm_io_extfile(cmd,fname,varargin)

%  DFLOWFM_IO_extfile: write D-Flow FM external forcing file
%% Switch read/write

switch lower(cmd)

    case 'read'
        fprintf('Reading file %s \n',fname)
        OPT.strip = false;
        OPT       = setproperty(OPT,varargin);
        i_forcing = 0;
        type      = 'old';

        try
            % New Format
            fprintf('Trying new format \n')
            fprintf('Start reading info \n')
            Info           = inifile('open',fname);
            fprintf('End reading info \n')

            %% Cycle over the Chapters
            ListOfChapters = inifile('chapters',Info);
            if isempty(Info.Data{1,1}) throw(MException()); end    % then we have an old ext file, go to catch
            for i_chapter = 1: length(ListOfChapters)
                i_forcing = i_forcing + 1;
                i_val     = 0;
                ext_force(i_forcing).Chapter = ListOfChapters{i_chapter};

                %% Cycle over the keywords within a chapter
                ListOfKeywords=inifile('keywords',Info,i_chapter);
                for i_key = 1: length(ListOfKeywords)

                    %% Keyword/value (not a series)
                    if ~isempty(ListOfKeywords{i_key})
                        ext_force(i_forcing).Keyword.Name {i_key}  = ListOfKeywords{i_key};
                        ext_force(i_forcing).Keyword.Value{i_key} = inifile('get',Info,i_chapter,i_key);

                        %% remove comments (if requested)
                        if OPT.strip
                            index = strfind(ext_force(i_forcing).Keyword.Value{i_key},'#');
                            if ~isempty(index)
                                ext_force(i_forcing).Keyword.Value{i_key} = ext_force(i_forcing).Keyword.Value{i_key}(1:index(1) - 1);
                            end
                        end

                        %% Convert 2 number if possible (exception for timeseries since that is a native matlab function)
                        if isstr(ext_force(i_forcing).Keyword.Value{i_key}) && ~strcmp(ext_force(i_forcing).Keyword.Value{i_key},'timeseries')
                            if ~isempty(str2num(ext_force(i_forcing).Keyword.Value{i_key}))
                                % Convert string 2 number
                                ext_force(i_forcing).Keyword.Value{i_key}= str2num(ext_force(i_forcing).Keyword.Value{i_key});
                            else
                                % String
                                ext_force(i_forcing).Keyword.Value{i_key} = strtrim(ext_force(i_forcing).Keyword.Value{i_key});
                            end
                        end
                    else
                        %% The series (put in cell array to allow for Astronomical foring, M2, S2 etc.
                        i_val = i_val + 1;
                        tmp   = inifile('get',Info,i_chapter,i_key);
                        if ~isstr(tmp)
                            for i_col = 1: length(tmp)
                                ext_force(i_forcing).values{i_val,i_col} =  tmp(i_col);
                            end
                        else
                            index =   d3d2dflowfm_decomposestr(tmp);
                            for i_val2 = 1: length(index) - 1;
                                ext_force(i_forcing).values{i_val,i_val2} = strtrim(tmp(index(i_val2):index(i_val2 + 1) - 1));
                                if ~isempty(str2num(ext_force(i_forcing).values{i_val,i_val2}))
                                    ext_force(i_forcing).values{i_val,i_val2} = str2num(ext_force(i_forcing).values{i_val,i_val2});
                                end
                            end
                        end
                    end
                    
                end
                fprintf('Reading Chapter %4.2f %% \n',i_chapter/length(ListOfChapters)*100)
            end
            type = 'ini';

        catch
            %% Old Format

            fid     = fopen(fname  );
            line = strtrim(fgetl(fid));
            while ~feof(fid)
                if ~isempty(line) && ~(line(1) == '*') && ~(line(1)== '[')
                    if ~isempty(strfind(lower(line),'quantity'))
                        i_forcing = i_forcing + 1;
                        index = strfind(line,'=');
                        ext_force(i_forcing).quantity = strtrim(line(index(1) + 1:end));
                    else
                        index = strfind(line,'=');
                        if ~isempty(str2num(line(index(1) + 1: end)))
                            ext_force(i_forcing).(strtrim(lower(line(1:index(1) - 1)))) = str2num(line(index(1) + 1:end));
                        else
                            ext_force(i_forcing).(strtrim(lower(line(1:index(1) - 1)))) = strtrim(line(index(1) + 1:end));
                        end
                    end
                end
                line = strtrim(fgetl(fid));
            end

            fclose (fid);
        end
        varargout{1} = ext_force;
        varargout{2} = type;

    case 'write'
        OPT.Filcomments = '' ;
        OPT.ext_force   = [] ;
        OPT.type        = 'old';
        OPT.first       = true;
        OPT = setproperty(OPT,varargin);

        if strcmp(OPT.type,'old')
            % Old format
            % Comment lines
            if ~isempty(OPT.Filcomments)
                fid      = fopen(fname,'w+');
                comments = simona2mdu_csvread(OPT.Filcomments);
                for i_com = 1: length(comments)
                    fprintf(fid,'%s \n',comments{i_com});
                end
                fclose (fid);
            end

            if ~isempty(OPT.ext_force)
                fid = fopen(fname,'a');
                fseek(fid,0,'eof');
                for i_force = 1: length(OPT.ext_force)
                    names = fieldnames(OPT.ext_force(i_force));
                    for i_name = 1: length(names)
                        if ~isempty(OPT.ext_force(i_force).(names{i_name}))
                            fprintf(fid,'%-24s =%-12s \n', upper(names{i_name}),num2str(OPT.ext_force(i_force).(names{i_name})));
                            % Keywords are (FY) case sensitive!
                            % fprintf(fid,'%-24s =%-12s \n', names{i_name},num2str(OPT.ext_force(i_force).(names{i_name})));
                        end
                    end
                    fprintf(fid,' \n');
                end
                fclose(fid);
            end
        else
            % New format (writing through function inifile does not work
            % conveniently for series so write directly)
            if OPT.first fid = fopen(fname,'w+'); else; fid = fopen(fname,'a'); end

            ext_force = OPT.ext_force;
            no_force  = length(ext_force);
            for i_force = 1: no_force
                Chapter  = ext_force(i_force).Chapter;
                Keyword  = ext_force(i_force).Keyword.Name;
                Value    = ext_force(i_force).Keyword.Value;

                fprintf(fid,'[%s]\n',ext_force(i_force).Chapter);
                for i_key = 1: length(Keyword)
                    if strcmpi(Keyword{i_key},'offset')
                        fprintf (fid,'%-20s = %s\n',Keyword{i_key},num2str(Value{i_key}));
                    else
                        fprintf (fid,'%-20s = %s\n',Keyword{i_key},Value{i_key});
                    end
                end

                if isfield(ext_force(i_force),'values')
                    Value = ext_force(i_force).values;
                    no_row = size(Value,1);
                    no_col = size(Value,2);

                    if iscell(Value(1,1))
                        format = ['%8s ' repmat('%12.6f ',1,no_col - 1)];
                    elseif isinteger(Value(1,1))
                        format = ['%8i ' repmat('%12.6f ',1,no_col - 1)];
                    else
                        format = repmat('%12.6f ',1,no_col);
                    end

                    for i_row = 1: no_row
                        fprintf(fid,[format '\n'],string(Value(i_row,:)));
                    end

                end
            end
            fclose(fid);
        end
end

