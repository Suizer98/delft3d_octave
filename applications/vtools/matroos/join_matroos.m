%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17443 $
%$Date: 2021-08-03 03:26:28 +0800 (Tue, 03 Aug 2021) $
%$Author: chavarri $
%$Id: join_matroos.m 17443 2021-08-02 19:26:28Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/matroos/join_matroos.m $
%
%joins files downloaded separately
%
%TO DO:
%   -possibility of joining everything in one folder

function join_matroos(path_dir_out,tim_0,tim_f,dt,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'str_file','knmi_h11_v72_%s_%s');

parse(parin,varargin{:})

str_file=parin.Results.str_file;

%% CALC

% path_all=matroos_file_name(str_file,kt,tim_v,path_dir_out);
fname_all=sprintf(str_file,datestr(tim_0,'yyyymmddHHMM'),datestr(tim_f,'yyyymmddHHMM'));
fname_all_ext=sprintf('%s.nc',fname_all);
path_all=fullfile(path_dir_out,fname_all_ext);

tim_v=tim_0:dt:tim_f;
nt=numel(tim_v)-1;

%create file for all
%   It needs to be the first one, as it uses the time reference
kt=1;
path_loc=matroos_file_name(str_file,kt,tim_v,path_dir_out);
copyfile(path_loc,path_all)

%vars
nci=ncinfo(path_loc);
var_names_all={nci.Variables.Name};
idx_all=1:1:numel(var_names_all);
[~,bol]=find_str_in_cell(var_names_all,{'x','y','time'});
var_names_join=var_names_all(~bol);
idx_join=idx_all(~bol);

%location of time dimension
nvars=numel(var_names_join);
dim_tim=NaN(nvars,1);
inds=cell(nvars,1);
for kvar=1:nvars
    dim_tim(kvar)=find_str_in_cell({nci.Variables(idx_join(kvar)).Dimensions.Name},{'time'});
    dim_num=numel(nci.Variables(idx_join(kvar)).Dimensions);
    inds{kvar}=cell(dim_num,1);
    for kdim=1:dim_num
        inds{kvar}{kdim}=1:1:nci.Variables(idx_join(kvar)).Dimensions(kdim).Length;
    end
end

%create vars
[tim_all,tim_units]=NC_read_time(path_loc,[1,Inf]);
var_all=cell(nvars,1);
for kvar=1:nvars
    var_all{kvar}=ncread(path_loc,var_names_join{kvar});
end
    
for kt=2:nt-1
    path_loc=matroos_file_name(str_file,kt,tim_v,path_dir_out);
    tim_loc=NC_read_time(path_loc,[1,Inf]);
    tim_all=cat(1,tim_all,tim_loc);
    for kvar=1:nvars
        var_loc=ncread(path_loc,var_names_join{kvar});
        var_all{kvar}=cat(dim_tim(kvar),var_all{kvar},var_loc);
    end
    fprintf('joining data %4.2f %% \n',kt/(nt-1)*100)
end

%cut time
[tim_u,idx_u]=unique(tim_all);
var_all_u=cell(nvars,1);
for kvar=1:nvars
    inds_u=inds{kvar};
    inds_u{dim_tim(kvar)}=idx_u;
    var_all_u{kvar}=var_all{kvar}(inds_u{:});
end

%write
var_original=ncread(path_all,'time');
switch tim_units
    case 'hours'
        tim_u_write=hours(tim_u-tim_u(1));
    otherwise
        error('add')
end
ncwrite_class(path_all,'time',var_original,tim_u_write)
for kvar=1:nvars
    var_original=ncread(path_all,var_names_join{kvar});
    ncwrite_class(path_all,var_names_join{kvar},var_original,var_all_u{kvar})
end
messageOut(NaN,sprintf('File created: %s',path_all))

end %join_matroos

%%
%% FUNCTIONS
%%

function path_loc=matroos_file_name(str_file,kt,tim_v,path_dir_out)

fname_loc=sprintf(str_file,datestr(tim_v(kt),'yyyymmddHHMM'),datestr(tim_v(kt+1),'yyyymmddHHMM'));
fname_loc_ext=sprintf('%s.nc',fname_loc);
path_loc=fullfile(path_dir_out,fname_loc_ext);
if exist(path_loc,'file')~=2
    error('file does not exist: %s',path_loc)
end

end %matroos_file_name