%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17854 $
%$Date: 2022-03-25 14:31:11 +0800 (Fri, 25 Mar 2022) $
%$Author: chavarri $
%$Id: D3D_check_results_available.m 17854 2022-03-25 06:31:11Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_check_results_available.m $
%
%Check if all results files are available

function [fpath_missing,kpart_missing]=D3D_check_results_available(fdir_sim,npart)

simdef.D3D.dire_sim=fdir_sim;
simdef=D3D_simpath(simdef,'break',0);

%map
kmiss=0;
fpath_missing={};
kpart_missing=[];
for kpart=1:npart
    fpath_map=fullfile(simdef.file.output,sprintf('%s_%04d_map.nc',simdef.file.runid,kpart-1));
    if exist(fpath_map,'file')~=2
        kmiss=kmiss+1;
        fpath_missing{kmiss}=fpath_map;
        kpart_missing=cat(1,kpart_missing,kpart-1);
    end
end %kpart

if isempty(fpath_missing)
    fprintf('All files are available \n')
else
    fprintf('You are missing files! \n')
end

end %function
