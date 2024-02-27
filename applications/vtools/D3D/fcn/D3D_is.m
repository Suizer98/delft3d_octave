%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18286 $
%$Date: 2022-08-09 19:35:55 +0800 (Tue, 09 Aug 2022) $
%$Author: chavarri $
%$Id: D3D_is.m 18286 2022-08-09 11:35:55Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_is.m $
%
%

function [ismor,is1d,str_network1d,issus]=D3D_is(nc_map)

[~,~,ext]=fileparts(nc_map);

if strcmp(ext,'.nc') %FM
    nci=ncinfo(nc_map);

    %ismor
    idx=find_str_in_cell({nci.Variables.Name},{'mesh2d_mor_bl','mesh1d_mor_bl'});
    ismor=1;
    if any(isnan(idx))
        ismor=0;
    end
    
    %is suspended load
    idx=find_str_in_cell({nci.Variables.Name},{'cross_section_suspended_sediment_transport','mesh2d_sscx'});
    issus=1;
    if any(isnan(idx))
        issus=0;
    end

    %is 1D simulation
    idx=find_str_in_cell({nci.Variables.Name},{'mesh2d_node_x'});
    is1d=0;
    if any(isnan(idx))
        is1d=1;
    end
    idx=find_str_in_cell({nci.Variables.Name},{'network1d_geom_x'});
    if isnan(idx)
        str_network1d='network';
    else
        str_network1d='network1d';
    end

elseif strcmp(ext,'.dat')
    NFStruct=vs_use(nc_map,'quiet');
    ismor=1;
    is1d=0;
    str_network1d='';
    issus=NaN; %add!
    if isnan(find_str_in_cell({NFStruct.GrpDat.Name},{'map-infsed-serie'}))
        ismor=0;
    end

end
