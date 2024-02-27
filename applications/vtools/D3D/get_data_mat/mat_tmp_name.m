%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18282 $
%$Date: 2022-08-05 22:25:39 +0800 (Fri, 05 Aug 2022) $
%$Author: chavarri $
%$Id: mat_tmp_name.m 18282 2022-08-05 14:25:39Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/mat_tmp_name.m $
%
%

function fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'tim',[]);
addOptional(parin,'layer',[]);
addOptional(parin,'station','');
addOptional(parin,'pli','');
addOptional(parin,'pol','');
addOptional(parin,'iso','');
addOptional(parin,'var','');
addOptional(parin,'sb','');
addOptional(parin,'tim2',[]);
addOptional(parin,'stat','');
addOptional(parin,'var_idx','');
addOptional(parin,'sim_idx',''); %just to be able to pass all varargin
addOptional(parin,'branch',''); 

parse(parin,varargin{:});

time_dnum=parin.Results.tim;
layer=parin.Results.layer;
station=parin.Results.station;
pli=parin.Results.pli;
pol=parin.Results.pol;
iso=parin.Results.iso;
var=parin.Results.var;
sb=parin.Results.sb;
time_dnum_2=parin.Results.tim2;
stat=parin.Results.stat;
var_idx=parin.Results.var_idx;
branch=parin.Results.branch;

%%

% if isempty(time_dnum)
%     error('time missing')
% end

%% CALC

str_add='';

%time
if ~isempty(time_dnum)
    str_add=sprintf('%s%s',str_add,datestr(time_dnum,'yyyymmddHHMMSS'));
end

%time 2
if ~isempty(time_dnum_2)
    str_add=sprintf('%s-%s',str_add,datestr(time_dnum_2,'yyyymmddHHMMSS'));
end

%station
if ~isempty(station)
    str_add=sprintf('%s_%s',str_add,strrep(station,' ','_'));
end

%layer
if ~isempty(layer)
    str_add=sprintf('%s_layer_%04d',str_add,layer);
end

%pli
if ~isempty(pli)
    str_add=sprintf('%s_pli_%s',str_add,strrep(pli,' ',''));
end

%pol
if ~isempty(pol)
    str_add=sprintf('%s_pol_%s',str_add,strrep(pol,' ',''));
end

%iso
if ~isempty(iso)
    str_add=sprintf('%s_iso_%s',str_add,strrep(iso,' ',''));
end

%var
if ~isempty(var)
    str_add=sprintf('%s_var_%s',str_add,strrep(var,' ',''));
end

%stat
if ~isempty(stat)
    str_add=sprintf('%s_stat_%s',str_add,strrep(stat,' ',''));
end

%sb
if ~isempty(sb)
    str_add=sprintf('%s_sb_%s',str_add,strrep(sb,' ',''));
end

%var_idx
if ~isempty(var_idx)
    str_add=sprintf('%s_var_idx_%02d',str_add,var_idx);
end

%branch
if ~isempty(branch)
    str_add=sprintf('%s_branch_%s',str_add,branch);
end

%final
str_add=sprintf('%s_%s.mat',tag,str_add);
str_add=strrep(str_add,'__','_');
str_add=strrep(str_add,'_.mat','.mat');
if strcmp(str_add(1),'_')
    str_add(1)='';
end
fpath_mat_tmp=fullfile(fdir_mat,str_add);

end %function