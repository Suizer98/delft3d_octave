%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18455 $
%$Date: 2022-10-17 13:25:35 +0800 (Mon, 17 Oct 2022) $
%$Author: chavarri $
%$Id: gdm_read_plot_along_rkm.m 18455 2022-10-17 05:25:35Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_read_plot_along_rkm.m $
%
%

function in_p=gdm_read_plot_along_rkm(in_p,flg_loc)

if flg_loc.do_rkm_disp
    fid=fopen(flg_loc.fpath_rkm_disp,'r');
    rkm_file=textscan(fid,'%f %f %s %f','headerlines',1,'delimiter',',');
    fclose(fid);
    rkm_file{1,3}=cellfun(@(X)strrep(X,'_','\_'),rkm_file{1,3},'UniformOutput',false);
    in_p.rkm=rkm_file;
end

end %function