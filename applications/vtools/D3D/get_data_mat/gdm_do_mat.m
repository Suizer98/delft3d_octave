%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18069 $
%$Date: 2022-05-21 00:31:37 +0800 (Sat, 21 May 2022) $
%$Author: chavarri $
%$Id: gdm_do_mat.m 18069 2022-05-20 16:31:37Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_do_mat.m $
%
%

function ret=gdm_do_mat(fid_log,flg_loc,tag,varargin)

%% PARSE

if isfield(flg_loc,'do')==0
    flg_loc.do=1;
end

if numel(varargin)>0
    if isfield(flg_loc,varargin{1,1})
        flg_loc.do=[flg_loc.do,flg_loc.(varargin{1,1})];
    end
end

%% CALC

ret=0;

if ~all(flg_loc.do)
    messageOut(fid_log,sprintf('Not doing ''%s''',tag));
    ret=1;
    return
end
messageOut(fid_log,sprintf('Start ''%s''',tag));

end %function