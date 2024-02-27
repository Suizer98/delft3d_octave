function stru_out=D3D_read_polys(fname,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'ver',2)

parse(parin,varargin{:})

ver=parin.Results.ver;

%%

tek=tekal('read',fname,'loaddata');

if ver==1
    stru_out.name={tek.Field.Name};
    stru_out.val={tek.Field.Data};
elseif ver==2
    stru_out=struct('name',{tek.Field.Name},'xy',{tek.Field.Data});
else 
    error('Unknonw version')
end

                
end %function