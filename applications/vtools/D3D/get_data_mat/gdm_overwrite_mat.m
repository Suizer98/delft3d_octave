%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18086 $
%$Date: 2022-06-01 16:12:31 +0800 (Wed, 01 Jun 2022) $
%$Author: chavarri $
%$Id: gdm_overwrite_mat.m 18086 2022-06-01 08:12:31Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_overwrite_mat.m $
%
%

function [ret,flg_loc]=gdm_overwrite_mat(fid_log,flg_loc,fpath_mat,varargin)

%% PARSE

if isfield(flg_loc,'overwrite')==0
    flg_loc.overwrite=0;
end

if numel(varargin)>0
    if isfield(flg_loc,varargin{1,1})
        flg_loc.overwrite=[flg_loc.overwrite,flg_loc.(varargin{1,1})];
    end
end

%% CALC

ret=0;

if exist(fpath_mat,'file')==2
    messageOut(fid_log,'Mat-file already exist.')
    if ~any(flg_loc.overwrite)
        messageOut(fid_log,'Not overwriting mat-file.')
        ret=1;
        return
    end
    messageOut(fid_log,'Overwriting mat-file.')
else
    messageOut(fid_log,'Mat-file does not exist. Reading.')
end

end %function