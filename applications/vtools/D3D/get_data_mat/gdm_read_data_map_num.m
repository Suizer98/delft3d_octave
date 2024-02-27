%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18154 $
%$Date: 2022-06-14 11:40:14 +0800 (Tue, 14 Jun 2022) $
%$Author: chavarri $
%$Id: gdm_read_data_map_num.m 18154 2022-06-14 03:40:14Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_read_data_map_num.m $
%
%

function data=gdm_read_data_map_num(fpath_map,varname,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'tim',[]);
% addOptional(parin,'layer',[]);

parse(parin,varargin{:});

time_dnum_obj=parin.Results.tim;
% layer=parin.Results.layer;

%% CALC

ismor=D3D_is(fpath_map);

[time_r,time_mor_r,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime]=D3D_results_time(fpath_map,ismor,[1,Inf]);
[diff_tim,in.kt]=min(abs(time_dnum-time_dnum_obj));
if diff_tim>5/60/24
    error('The time differs by more than 5 min')
end

simdef.D3D.structure=2;
simdef.file.map=fpath_map;
simdef.flg.get_EHY=1;
simdef.flg.get_cord=0;
simdef.flg.which_p=2; 
simdef.flg.which_v=varname;

if isempty(time_dnum)
    error('provide time')
else
    out=D3D_read(simdef,in);
end

if numel(size(out.z))>2
    %not strong enough do this:
%                 if isfield(data_var,'dimensions')
%                     str_sim_c=strrep(data_var.dimensions,'[','');
%                     str_sim_c=strrep(str_sim_c,']','');
%                     tok=regexp(str_sim_c,',','split');
%                     idx_f=find_str_in_cell(tok,{'mesh2d_nFaces'});
%                     dim=1:1:numel(tok);
%                     dimnF=dim;
%                     dimnF(dimnF==idx_f)=[];
%                     data_var.val=permute(data_var.val,[idx_f,dimnF]);
%                 end
    data.val=squeeze(out.z)'; %[faces,else]
else
    data.val=out.z; %[faces,else]
%     data.val=out.z'; %[faces,else]
end

end %function