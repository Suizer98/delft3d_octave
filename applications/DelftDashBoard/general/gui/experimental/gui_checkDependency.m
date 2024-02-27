function ok=gui_checkDependency(dependency,element)

ok=1;

if ~isempty(dependency.checkfor)
    switch lower(dependency.checkfor)
        case{'any'}
            ok=0;
            for k=1:length(dependency.check)
                val=gui_getValue(element,dependency.check(k).check.variable);
                if ischar(val)
                    % String
                    switch dependency.check(k).check.operator
                        case{'eq'}
                            if strcmpi(val,dependency.check(k).check.value)
                                ok=1;
                            end
                        case{'ne'}
                            if ~strcmpi(val,dependency.check(k).check.value)
                                ok=1;
                            end
                    end
                else
                    % Numeric
                    v=str2double(dependency.check(k).check.value);
                    switch dependency.check(k).check.operator
                        case{'eq'}
                            if isnan(v)
                                if isnan(val)
                                    ok=1;
                                end
                            else
                                if val==v
                                    ok=1;
                                end
                            end
                        case{'ne'}
                            if isnan(v)
                                if ~isnan(val)
                                    ok=1;
                                end
                            else
                                if val~=v
                                    ok=1;
                                end
                            end
                        case{'lt'}
                            if val<v
                                ok=1;
                            end
                        case{'gt'}
                            if val>v
                                ok=1;
                            end
                        case{'le'}
                            if val<=v
                                ok=1;
                            end
                        case{'ge'}
                            if val>=v
                                ok=1;
                            end
                    end
                end
            end
            
        case{'all'}
            ok=1;
            for k=1:length(dependency.check)
                val=gui_getValue(element,dependency.check(k).check.variable);
                if isempty(val)
                    if strcmpi(dependency.check(k).check.value,'isempty')
                        if strcmpi(dependency.check(k).check.operator,'eq')
                            ok=1;
                        else
                            ok=0;
                        end
                    end
                elseif ischar(val)
                    % String
                    switch dependency.check(k).check.operator
                        case{'eq'}
                            if ~strcmpi(val,dependency.check(k).check.value)
                                ok=0;
                            end
                        case{'ne'}
                            if isempty(val)
                                if strcmpi(dependency.check(k).check.value,'isempty')
                                    ok=0;
                                end
                            else
                                if strcmpi(val,dependency.check(k).check.value)
                                    ok=0;
                                end
                            end
                    end
                else
                    % Numeric
                    v=str2double(dependency.check(k).check.value);
                    switch dependency.check(k).check.operator
                        case{'eq'}
                            if isnan(v)
                                if ~isnan(val)
                                    ok=0;
                                end
                            else
                                if val~=v
                                    ok=0;
                                end
                            end
                        case{'ne'}
                            if isnan(v)
                                if isnan(val)
                                    ok=0;
                                end
                            else
                                if val==v
                                    ok=0;
                                end
                            end
                        case{'lt'}
                            if val>=v
                                ok=0;
                            end
                        case{'gt'}
                            if val<=v
                                ok=0;
                            end
                        case{'le'}
                            if val>v
                                ok=0;
                            end
                        case{'ge'}
                            if val<v
                                ok=0;
                            end
                    end
                end
            end
            
        case{'none'}
            ok=1;
            for k=1:length(dependency.check)
                
                val=gui_getValue(element,dependency.check(k).check.variable);
                if ischar(val)
                    % String
                    switch dependency.check(k).check.operator
                        case{'eq'}
                            if strcmpi(val,dependency.check(k).check.value)
                                ok=0;
                            end
                        case{'ne'}
                            if ~strcmpi(val,dependency.check(k).check.value)
                                ok=0;
                            end
                    end
                else
                    % Numeric
                    v=str2double(dependency.check(k).check.value);
                    switch dependency.check(k).check.operator
                        case{'eq'}
                            if val==v
                                ok=0;
                            end
                        case{'ne'}
                            if val~=v
                                ok=0;
                            end
                        case{'lt'}
                            if val<v
                                ok=0;
                            end
                        case{'gt'}
                            if val>v
                                ok=0;
                            end
                        case{'le'}
                            if val<=v
                                ok=0;
                            end
                        case{'ge'}
                            if val>=v
                                ok=0;
                            end
                    end
                end
            end
    end
end