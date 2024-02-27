%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17062 $
%$Date: 2021-02-12 20:47:20 +0800 (Fri, 12 Feb 2021) $
%$Author: chavarri $
%$Id: D3D_mini.m 17062 2021-02-12 12:47:20Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_mini.m $
%
%morphological initial file creation

%INPUT:
%   -simdef.D3D.dire_sim = full path to the output folder [string] e.g. 'd:\victorchavarri\SURFdrive\projects\ellipticity\D3D\runs\1D\998'
%   -simdef.mor.ThTrLyr = active layer thickness [m] [double(1,1)] e.g. [0.05]
%   -simdef.mor.ThUnLyr = thickness of each underlayer [m] [double(1,1)] e.g. [0.05]
%   -simdef.mor.total_ThUnLyr = thickness of the entire bed [m] [double(1,1)] e.g. [1.5]
%   -simdef.ini.subs_frac = efective (total-1) number of fractions at the substrate [-] [double(nf-1)] e.g. [0.2,0.1]
%
%OUTPUT:
%   -a morphological .ini compatible with D3D is created in file_name

%150728->151104
%   -fractions at the active layer introduced

function D3D_mini(simdef)
%% RENAME

D3D_structure=simdef.D3D.structure;
nf=numel(simdef.sed.dk);

%% CALL

if nf>1
    if simdef.ini.subs_type==1 && simdef.ini.actlay_frac_type==1
        D3D_mini_const(simdef) %generate .ini
    else
        if D3D_structure==1
            D3D_mini_nconst_s(simdef) %generate .ini
            frc=D3D_mini_frc_s(simdef); %generate .frc
            D3D_mini_thk_s(simdef,frc) %generate .thk
        else
            D3D_mini_nconst_u(simdef) %generate .ini
            D3D_mini_thk_u(simdef) %generate .thk
            D3D_mini_frc_u(simdef) %generate .frc
        end
    end
end %nf

end %function