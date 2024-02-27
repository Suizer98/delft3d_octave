%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18107 $
%$Date: 2022-06-05 23:19:09 +0800 (Sun, 05 Jun 2022) $
%$Author: chavarri $
%$Id: gdm_station_layer.m 18107 2022-06-05 15:19:09Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_station_layer.m $
%
%

function layer=gdm_station_layer(flg_loc,gridInfo,fpath_his,stations)
    
if isnan(flg_loc.layer)
    layer=gridInfo.no_layers;
elseif isinf(flg_loc.layer)
    data_sal=EHY_getmodeldata(fpath_his,stations,'dfm','varName','sal','layer',[],'t',1);
    layer=find(~isnan(data_sal.val),1,'first');
else
    layer=flg_loc.layer;
end

end %function