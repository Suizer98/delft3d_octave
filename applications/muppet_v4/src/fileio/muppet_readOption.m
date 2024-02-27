function data=muppet_readOption(handles,data,info,keywords,values)

if isfield(info,'keyword')
    if isfield(info,'variable')
        varname=info.variable;
    else
        varname=info.name;
    end
    ikw=strmatch(info.keyword,keywords,'exact');
    if ~isempty(ikw)
        % Keyword found
        if ~isfield(info,'type')
            info.type='string';
        end
        valuestr=values{ikw};
        switch info.type
            case{'real','int'}
                val=str2num(valuestr);
            case{'date'}
                val=datenum(valuestr,'yyyymmdd');
            case{'datetime'}
                val=datenum(valuestr,'yyyymmdd HHMMSS');
            case{'time'}
                val=datenum(valuestr,'HHMMSS');
            case{'boolean'}
                switch lower(valuestr(1))
                    case{'y','1'}
                        val=1;
                    otherwise
                        val=0;
                end
            case{'indexstring'}
                val=indexstring('read',valuestr);
            case{'filename'}
                val=valuestr;
            otherwise
                val=valuestr;                
        end
        data.(varname)=val;
    end
end
