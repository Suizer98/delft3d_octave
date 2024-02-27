%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18397 $
%$Date: 2022-09-29 23:07:34 +0800 (Thu, 29 Sep 2022) $
%$Author: chavarri $
%$Id: gdm_order_dimensions.m 18397 2022-09-29 15:07:34Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_order_dimensions.m $
%
%dimension 1 of <data.val> must be faces.

function data=gdm_order_dimensions(fid_log,data)

if isfield(data,'dimensions') %read from EHY
    str_sim_c=strrep(data.dimensions,'[','');
    str_sim_c=strrep(str_sim_c,']','');
    tok=regexp(str_sim_c,',','split');
    idx_f=find_str_in_cell(tok,{'mesh2d_nFaces'});
    dim=1:1:numel(tok);
    dimnF=dim;
    dimnF(dimnF==idx_f)=[];
    if ~isempty(dimnF) 
        data.val=permute(data.val,[idx_f,dimnF]);
        %reconstruct dimensions vector
        str_order=tok([idx_f,dimnF]);
        str_aux=sprintf('%s,',str_order{:});
        str_aux=sprintf('[%s]',str_aux);
        str_aux=strrep(str_aux,',]',']');
        data.dimensions=str_aux;
    else
        %there is only <mesh2d_nFaces>
    end
else
    size_val=size(data.val);
    if size_val(1)==1 && size_val(2)>1
        data.val=data.val';
        messageOut(fid_log,'It seems faces are not in first dimension. I am permuting the vector.')
    end
end


end %function