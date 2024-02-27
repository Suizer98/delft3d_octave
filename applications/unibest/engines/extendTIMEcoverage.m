function RAYdata=extendTIMEcoverage(RAYdata,NR,datenumstartDATASET,datenumstartMODEL)
% extends a RAYdata or SCOdata structure with 3 hourly wave or transport information (with time in hours starting from 0)
% can be used both for RAYdata and SCOdata!

    %datenumstartDATASET=datenum(2011,01,01);
    %datenumstartMODEL=datenum(2011,08,01);
    if nargin<2
        NR = 2;
    end
    if nargin<4
        datenumstartDATASET=0;
        datenumstartMODEL=0;
    end

    % EXTENT TIME COVERAGE BY USING SAME TIME-SERIES MULTIPLE TIMES
    fieldnms = fields(RAYdata);
    
    if isfield(RAYdata,'time')
        if ~isempty(RAYdata.time)  
            % TIMESERIES CLIMATE
            time0=RAYdata.time;

            %% make sure that a the new period starts at the rigth date after the previous 
            idt1=find((time0)/24/365 >= (time0(end)/24/365-floor(time0(end)/24/365)),1);
            idt2=length(time0);
            for kk=1:length(fieldnms)
                if strcmpi(fieldnms{kk},'time')
                    DT = diff(RAYdata.time);
                    DT = [DT(1);DT(:)];
                    DT2 = DT;
                    for gg=1:NR-1
                        DT2 = [DT2; DT(idt1:idt2)];
                    end
                    %DT2 = repmat(DT, [NR 1]);
                    RAYdata.time = [cumsum(DT2)-DT2(1)];
                elseif ~strcmpi(fieldnms{kk},'name') && ~strcmpi(fieldnms{kk},'path') && ~strcmpi(fieldnms{kk},'info') && ~strcmpi(fieldnms{kk},'hass') && length(RAYdata.(fieldnms{kk}))==length(time0)
                    RAYdata.(fieldnms{kk})=RAYdata.(fieldnms{kk})(:);
                    for gg=1:NR-1
                        RAYdata.(fieldnms{kk}) = [RAYdata.(fieldnms{kk}); RAYdata.(fieldnms{kk})(idt1:idt2)];
                    end
                end
            end
            
            %% remove periode from 1 jan 2011 till 1 august 2011 (LT timeseries actually started too early in january 2011)
            nt=length(RAYdata.time);
            idt0 = (datenumstartMODEL-datenumstartDATASET)*24/3+1;     % IDT=1697;
           
            for kk=1:length(fieldnms)
                if length(RAYdata.(fieldnms{kk}))==nt
                    RAYdata.(fieldnms{kk})=RAYdata.(fieldnms{kk})(idt0:end);
                end
                if strcmpi(fieldnms{kk},'time')
                    RAYdata.(fieldnms{kk})=RAYdata.(fieldnms{kk})-RAYdata.(fieldnms{kk})(1);
                end
            end
            
        end
    else
        % STATIC CLIMATE
    end
end
