%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17937 $
%$Date: 2022-04-05 19:43:41 +0800 (Tue, 05 Apr 2022) $
%$Author: chavarri $
%$Id: D3D_modify_mdu.m 17937 2022-04-05 11:43:41Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_modify_mdu.m $
%

function mdf_loc=D3D_modify_mdu(mdf,input_m_mdf_ksim,path_sim_loc)
    
mdf_loc=mdf;
mdf_loc=D3D_modify_input_structure(mdf_loc,input_m_mdf_ksim);

%special case of grid change->copy to simulation folder
if isfield(input_m_mdf_ksim,'NetFile')
    [~,fname_grd,fext_grd]=fileparts(input_m_mdf_ksim.NetFile);
    fnameext_grd=sprintf('%s%s',fname_grd,fext_grd);
    fpath_grd=fullfile(path_sim_loc,fnameext_grd);
    sts=copyfile_check(input_m_mdf_ksim.NetFile,fpath_grd);
    if ~sts
%         fclose(fid_win);
%         fclose(fid_lin);
        error('I cannot find the grid to be copied: %s',input_m_mdf_ksim.NetFile)
    end
    mdf_loc.geometry.NetFile=fnameext_grd;
end

end %function