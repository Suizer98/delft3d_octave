function id=muppet_findIndex(s,varargin)

id=[];

ninp=length(varargin);


switch ninp
    case 2       
        subfield1=varargin{1};
        var=varargin{2};
        if isempty(var)
            return
        end
        for ii=1:length(s)
            if isfield(s(ii),subfield1)
                if ischar(var)
                    if strcmpi(s(ii).(subfield1),var)
                        id=ii;
                        break;
                    end
                else
                    if s(ii).(subfield1)==var
                        id=ii;
                        break;
                    end
                end
            end
        end        
    case 3
        subfield1=varargin{1};
        subfield2=varargin{2};
        var=varargin{3};
        if isempty(var)
            return
        end
        for ii=1:length(s)
            if isfield(s(ii).(subfield1),subfield2)
                if ischar(var)
                    if strcmpi(s(ii).(subfield1).(subfield2),var)
                        id=ii;
                        break;
                    end
                else
                    if s(ii).(subfield1).(subfield2)==var
                        id=ii;
                        break;
                    end
                end
            end
        end
    case 4
        subfield1=varargin{1};
        subfield2=varargin{2};
        subfield3=varargin{3};
        var=varargin{4};
        if isempty(var)
            return
        end
        for ii=1:length(s)
            if isfield(s(ii).(subfield1),subfield2)
                if isfield(s(ii).(subfield1).(subfield2),subfield3)
                    if ischar(var)
                        if strcmpi(s(ii).(subfield1).(subfield2).(subfield3),var)
                            id=ii;
                            break;
                        end
                    else
                        if s(ii).(subfield1).(subfield2).(subfield3)==var
                            id=ii;
                            break;
                        end
                    end
                end
            end
        end
end

