%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18282 $
%$Date: 2022-08-05 22:25:39 +0800 (Fri, 05 Aug 2022) $
%$Author: chavarri $
%$Id: gdm_read_data_map.m 18282 2022-08-05 14:25:39Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_read_data_map.m $
%
%

function data=gdm_read_data_map(fdir_mat,fpath_map,varname,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'tim',[]);
addOptional(parin,'var_idx',[]);
addOptional(parin,'layer',[]);
addOptional(parin,'do_load',1);
addOptional(parin,'tol_t',5/60/24);
addOptional(parin,'idx_branch',[]);

parse(parin,varargin{:});

time_dnum=parin.Results.tim;
var_idx=parin.Results.var_idx;
layer=parin.Results.layer;
do_load=parin.Results.do_load;
tol_t=parin.Results.tol_t;
idx_branch=parin.Results.idx_branch;

%% CALC

% varname=D3D_var_derived2raw(varname); %I don't think I need it...
[ismor,is1d]=D3D_is(fpath_map);
[var_str,varname]=D3D_var_num2str(varname,'is1d',is1d,'ismor',ismor);
fpath_sal=mat_tmp_name(fdir_mat,var_str,'tim',time_dnum,'var_idx',var_idx);

if exist(fpath_sal,'file')==2
    if do_load
        messageOut(NaN,sprintf('Loading mat-file with raw data: %s',fpath_sal));
        load(fpath_sal,'data')
    else
        messageOut(NaN,sprintf('Mat-file with raw data exists: %s',fpath_sal));
        data=NaN;
    end
else
    messageOut(NaN,sprintf('Reading raw data for variable: %s',var_str));
    if isempty(idx_branch) %2D
        if ischar(varname)
            data=gdm_read_data_map_char(fpath_map,varname,'tim',time_dnum,'tol_t',tol_t);
        else
            data=gdm_read_data_map_num(fpath_map,varname,'tim',time_dnum);
        end
    else %1D
        [~,~,~,~,~,idx_tim]=D3D_time_dnum(fpath_map,time_dnum,'fdir_mat',fdir_mat);
        val=gdm_read_data_map_1D(fpath_map,varname,idx_branch,idx_tim);
        data.val=val;
    end
    save_check(fpath_sal,'data');
end

%% layer

if ~isempty(layer)
    %maybe better to search for [layer] in the ones coming from EHY?
   data.val=data.val(:,:,layer);
end

end %function