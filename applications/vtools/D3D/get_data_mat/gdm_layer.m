%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18455 $
%$Date: 2022-10-17 13:25:35 +0800 (Mon, 17 Oct 2022) $
%$Author: chavarri $
%$Id: gdm_layer.m 18455 2022-10-17 05:25:35Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_layer.m $
%
%

function layer=gdm_layer(flg_loc,no_layers,var_str)
        
if isfield(flg_loc,'layer')==0
    layer=[];
else
    if isnan(flg_loc.layer)
        layer=no_layers;
    else
        layer=flg_loc.layer;
    end
end

%remove the input if makes no sense. Otherwise the filename has the 'layer'.
switch var_str
    case {'clm2'}
        layer=[];
end

end %function