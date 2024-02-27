%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17342 $
%$Date: 2021-06-11 13:36:03 +0800 (Fri, 11 Jun 2021) $
%$Author: chavarri $
%$Id: D3D_write_sim_folder.m 17342 2021-06-11 05:36:03Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_write_sim_folder.m $
%
%writes files from a reference folder
%
%INPUT:
%   -
%
%OUTPUT:
%   -

function D3D_write_sim_folder(path_sim_out,path_file,mdf)

nfs=size(path_file,1);

for kfs=1:nfs

    path_file_in=path_file{kfs,1};
    path_file_out=fullfile(path_sim_out,path_file{kfs,2});

    [~,~,ext]=fileparts(path_file_in);
    switch ext
        case {'.mdf','.mdu'}
            D3D_io_input('write',path_file_out,mdf);
        otherwise
            copyfile(path_file_in,path_file_out);
    end

end %kfs