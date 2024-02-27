%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18107 $
%$Date: 2022-06-05 23:19:09 +0800 (Sun, 05 Jun 2022) $
%$Author: chavarri $
%$Id: gdm_read_data_his.m 18107 2022-06-05 15:19:09Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_read_data_his.m $
%
%

function data=gdm_read_data_his(fdir_mat,fpath_his,varname,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'tim',[]);
addOptional(parin,'tim2',[]);
addOptional(parin,'layer',[]);
addOptional(parin,'station','');
% addOptional(parin,'tol_t',5/60/24);

parse(parin,varargin{:});

tim=parin.Results.tim;
tim2=parin.Results.tim2;
layer=parin.Results.layer;
station=parin.Results.station;
% tol_t=parin.Results.tol_t;

%% READ
    
var_str=D3D_var_num2str(varname);

if ~isempty(layer)
    fpath_mat=mat_tmp_name(fdir_mat,var_str,'station',station,'layer',layer,'tim',tim,'tim2',tim2);
else
    fpath_mat=mat_tmp_name(fdir_mat,var_str,'station',station,'tim',tim,'tim2',tim2);
end
if exist(fpath_mat,'file')==2
    messageOut(NaN,sprintf('Loading mat-file with raw data: %s',fpath_mat));
    load(fpath_mat,'data')
else
    messageOut(NaN,sprintf('Reading raw data for variable: %s',var_str));
    OPT.varName=var_str;
    OPT.layer=layer;
    OPT.t0=tim;
    OPT.tend=tim2;

    data=EHY_getmodeldata(fpath_his,station,'dfm',OPT);
    save_check(fpath_mat,'data');
end

end %function
