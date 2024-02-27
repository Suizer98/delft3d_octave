%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18293 $
%$Date: 2022-08-11 00:25:55 +0800 (Thu, 11 Aug 2022) $
%$Author: chavarri $
%$Id: gdm_read_data_map_ls.m 18293 2022-08-10 16:25:55Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_read_data_map_ls.m $
%
%

function data=gdm_read_data_map_ls(fdir_mat,fpath_map,varname,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'tim',[]);
% addOptional(parin,'layer',[]);
addOptional(parin,'tol_t',5/60/24);
addOptional(parin,'pli','');
% addOptional(parin,'dchar','');
addOptional(parin,'overwrite',false);

parse(parin,varargin{:});

time_dnum=parin.Results.tim;
tol_t=parin.Results.tol_t;
pli=parin.Results.pli;
overwrite=parin.Results.overwrite;
% dchar=parin.Results.dchar;

[~,pliname,~]=fileparts(pli);
pliname=strrep(pliname,' ','_');

%%

var_str=varname;
fpath_sal=mat_tmp_name(fdir_mat,var_str,'tim',time_dnum,'pli',pliname);
if exist(fpath_sal,'file')==2 ~=overwrite
    messageOut(NaN,sprintf('Loading mat-file with raw data: %s',fpath_sal));
    load(fpath_sal,'data')
else
    messageOut(NaN,sprintf('Reading raw data for variable: %s',var_str));
    [data,data.gridInfo]=EHY_getMapModelData(fpath_map,'varName',var_str,'t0',time_dnum,'tend',time_dnum,'mergePartitions',1,'disp',0,'pliFile',pli,'tol_t',tol_t);
    save_check(fpath_sal,'data');
end

end %function