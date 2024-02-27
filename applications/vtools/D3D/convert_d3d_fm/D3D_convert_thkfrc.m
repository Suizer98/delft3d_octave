%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: D3D_convert_thkfrc.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/convert_d3d_fm/D3D_convert_thkfrc.m $
%

function D3D_convert_thkfrc(paths_grd_in,paths_enc_in,paths_thk_in,paths_frc_in,paths_thk_out,paths_frc_out)

%% CALC

nl=size(paths_thk_in,2);
nf=size(paths_frc_in,3);

%loop on thk
for kl=1:nl
    
    %thk files
    paths_int_in=paths_thk_in(:,kl);
    paths_int_out=paths_thk_out{1,kl};
    

    D3D_convert_mn2xyz(paths_grd_in,paths_enc_in,paths_int_in,paths_int_out)

    %loop on frc
    for kf=1:nf
        
        %frc files
        paths_int_in=paths_frc_in(:,kl,kf);
        paths_int_out=paths_frc_out{1,kl,kf};

        %function
        D3D_convert_mn2xyz(paths_grd_in,paths_enc_in,paths_int_in,paths_int_out)

        fprintf('done fraction %d/%d of layer %d/%d \n',kf,nf,kl,nl)
    end %kl
end %kl





