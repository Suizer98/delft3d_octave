%
% Save Data to a NETCDF format file. Variable inputs and outputs.
% Order of the inputs is very sensitive.
%
% INPUT 1: output filename
% Next Inputs : Dimensions - input triples:
% '-dim',<dimension name>,<integer -- length of dimension>
%
% Next Inputs: Global Variables - input triples:
% '-global',<global variable name>,<global variable value>
%
% Next Inputs: Variables -- input quintuples:
% <variable name> , <precision -- float,double,short,char> ,
%        <Units> , {cell array of dimensions} , <data>
%
% A future goal with this is to have more attributes optional for each
% variable, but for now this is sufficient.
%
% written by David Sitton, QinetiQ North America
% 3/2009
%
%
%

function save_to_netcdf(filename,varargin)

n_arg = nargin-1;

clobber_flag = 'NC_WRITE'; % overwrite (default) or append to netcdf file
title_str    = 'NETCDF File for TOFU'; % title for header
author_str   = 'David Sitton'; % author's name (current default is me)

if isempty(regexp(filename,'\.nc$','once'))
    filename=[filename,'.nc']; % add the .nc extension to the filename
end

n_dims=0;
n_global=0;

dim_names = {};
dim_sizes = [];
arg_cnt=1;
% parse the inputs while the first character is a '-' (indicating a flag)
while arg_cnt <= n_arg && ~isempty(regexp(varargin{arg_cnt},'^-','once'))
    
    next_arg = varargin{arg_cnt};
    switch next_arg
        case {'-clobber'}
            clobber_flag = 'NC_WRITE';
            
        case {'-noclobber'}
            clobber_flag = 'NC_NOCLOBBER';
            
        case {'-define','-append'}
            clobber_flag = 'append';
            
        case '-title'
            if arg_cnt < n_arg
                arg_cnt=arg_cnt+1;
                title_str = varargin{arg_cnt};
            else
                error('Input error: Missing Title');
            end
            
        case '-author'
            if arg_cnt < n_arg
                arg_cnt=arg_cnt+1;
                author_str = varargin{arg_cnt};
            else
                error('Input error: Missing Author''s Name');
            end
            
        case '-dim'
            if arg_cnt < n_arg-1
                %%% add another dimension name to the header
                n_dims = n_dims + 1;
                
                arg_cnt=arg_cnt+1;
                dim_names{n_dims} = varargin{arg_cnt};
                arg_cnt=arg_cnt+1;
                dim_sizes(n_dims) = varargin{arg_cnt};
                
                
            else
                error('Input error: Missing Author''s Name');
            end
            
        case '-global'
            if arg_cnt < n_arg-1
                %%% add another dimension name to the header
                n_global = n_global + 1;
                
                arg_cnt=arg_cnt+1;
                global_names{n_global} = varargin{arg_cnt};
                arg_cnt=arg_cnt+1;
                global_values(n_global).value = varargin{arg_cnt};
                
            else
                error('Input error: Missing Author''s Name');
            end
            
    end
    
    arg_cnt=arg_cnt+1;
    
end



% remaining data must come in 5's (var name, format type, units,{dimension names},data,)
% if n_arg == arg_cnt || rem(n_arg - arg_cnt+1,5)
%     error('Input Error: Output Variables must appear as ''variable name'',''format type'',''units'',{dimension names},DATA.')
% end
switch clobber_flag
    case 'append'
        %disp('appending')
        f=netcdf.open(filename,'NC_WRITE');
        netcdf.reDef(f);
    otherwise
        %disp('creating')
        f=netcdf.create(filename,clobber_flag);
end
% try
netcdf.putAtt(f,netcdf.getConstant('GLOBAL'),'title',title_str);
netcdf.putAtt(f,netcdf.getConstant('GLOBAL'),'author',author_str);
netcdf.putAtt(f,netcdf.getConstant('GLOBAL'),'date',now);

for cnt_dim = 1:n_global
    
    
    fprintf('Global Name: %s\n',global_names{cnt_dim});
    netcdf.putAtt(f,netcdf.getConstant('GLOBAL'),global_names{cnt_dim},...
        global_values(cnt_dim).value);
end

%dim_hndl=zeros(n_dims,1);
% add dimensions to header:
for cnt_dim = 1:n_dims
    %disp(dim_names{cnt_dim})
    netcdf.defDim(f,dim_names{cnt_dim},dim_sizes(cnt_dim));
end
% take out of define mode
netcdf.endDef(f);

[total_dims,~,~,~] = netcdf.inq(f);
dim_names = cell(total_dims,1);
for cnt_dim = 1:total_dims
    %disp(dim_names{cnt_dim})
    %dim_hndl(cnt_dim)=netcdf.getDimension(f,cnt_dim);
    dim_names{cnt_dim}=netcdf.inqDim(f,cnt_dim-1);
    
end


% add header info for each variable:
var_cnt=arg_cnt-1;
while var_cnt < n_arg
    % for var_cnt = arg_cnt:5:n_arg
    % consider the next four input values:
    cur_var_name  = varargin{var_cnt+1};
    cur_var_fmt   = varargin{var_cnt+2};
    cur_var_units = varargin{var_cnt+3};
    cur_var_dims  = varargin{var_cnt+4};
    %cur_var_data = varargin{var_cnt+5}; % hold off on this variable
    cur_n_dims = length(cur_var_dims);
    cur_dim_idx = zeros(cur_n_dims,1);
    %disp(cur_var_name)
    for cnt_dims = 1:cur_n_dims
        cur_dim_idx(cnt_dims)=find(strcmp(cur_var_dims{cur_n_dims-cnt_dims+1},dim_names))-1;
    end
    
    % declare each variable here:
    %%% would be good here to check that the cur_var_name is a valid
    %%% variable name, but I'm not worrying about that now:
    switch lower(cur_var_fmt)
        case {'float','ncfloat','flt'}
            x_type = 'float';
            %f{cur_var_name} = ncfloat(cur_var_dims{:});
        case {'double','ncdouble','dbl'}
            x_type = 'double';
            %cur_nc_var = netcdf.defVar(f,cur_var_name,'double',cur_var_dims{:});
            %f{cur_var_name} = ncdouble(cur_var_dims{:});
        case {'short','ncshort','shrt'}
            x_type = 'short';
            %cur_nc_var = netcdf.defVar(f,cur_var_name,'short',cur_var_dims{:});
            %f{cur_var_name} = ncshort(cur_var_dims{:});
        case {'char','character','chr','string'}
            x_type = 'char';
            %cur_nc_var = netcdf.defVar(f,cur_var_name,'char',cur_var_dims{:});
            %f{cur_var_name} = ncstring(cur_var_dims{:});
            %fprintf(1,'%s\n',cur_var_name);
        case {'integer','int','int32','ncint'}
            x_type = 'int';
            %cur_nc_var = netcdf.defVar(f,cur_var_name,'int',cur_var_dims{:});
    end
    
    % put back into define mode
    netcdf.reDef(f);
    
    cur_nc_var = netcdf.defVar(f,cur_var_name,x_type,cur_dim_idx);
    
    %disp(cur_var_name)
    
    % take out of define mode
    netcdf.endDef(f);
    
    netcdf.putVar(f,cur_nc_var,varargin{var_cnt+5});
    
    netcdf.reDef(f);
    
    netcdf.putAtt(f,cur_nc_var,'units',cur_var_units);
    switch lower(cur_var_fmt)
        case {'float','ncfloat','flt'}
            netcdf.putAtt(f,cur_nc_var,'_FillValue',single(0));
        case {'double','ncdouble','dbl'}
            netcdf.putAtt(f,cur_nc_var,'_FillValue',double(0));
        case {'short','ncshort','shrt'}
            netcdf.putAtt(f,cur_nc_var,'_FillValue',int16(0));
        case {'integer','int','int32','ncint'}
            netcdf.putAtt(f,cur_nc_var,'_FillValue',int32(0));
    end
%     
    
    %f{cur_var_name}.units = cur_var_units;
    %f{cur_var_name}.FillValue = 0; % not sure what this does
    var_cnt=var_cnt+6;
    while var_cnt < n_arg && strcmpi(varargin{var_cnt},'-att')
        if strcmp(varargin{var_cnt+1},'_FillValue')
            switch lower(cur_var_fmt)
                case {'float','ncfloat','flt'}
                    netcdf.putAtt(f,cur_nc_var,varargin{var_cnt+1},single(varargin{var_cnt+2}));
                case {'double','ncdouble','dbl'}
                    netcdf.putAtt(f,cur_nc_var,varargin{var_cnt+1},double(varargin{var_cnt+2}));
                case {'short','ncshort','shrt'}
                    netcdf.putAtt(f,cur_nc_var,varargin{var_cnt+1},int16(varargin{var_cnt+2}));
                case {'integer','int','int32','ncint'}
                    netcdf.putAtt(f,cur_nc_var,varargin{var_cnt+1},int32(varargin{var_cnt+2}));
            end
            
        else
            netcdf.putAtt(f,cur_nc_var,varargin{var_cnt+1},varargin{var_cnt+2})
        end
        var_cnt=var_cnt+3;
    end
    netcdf.endDef(f);
    
end

% close the output to file (and push the data to file)
netcdf.close(f);
% catch ME
%     fprintf(2,'An error occurred writing %s\n',filename)
%     netcdf.close(f);
%     error()
% end

return