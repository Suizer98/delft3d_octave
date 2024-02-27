%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: generate_paths_delft3d_4rijn2017v1.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/convert_d3d_fm/generate_paths_delft3d_4rijn2017v1.m $
%

function paths=generate_paths_delft3d_4rijn2017v1

%% INPUT

paths_folder_in='C:\Users\chavarri\OneDrive - Stichting Deltares\all\projects\02_runs\D3D\runs\Rhine_bifurcation\00\delft3d_4-rijn-2017-v1\';

domains={'br0';'br2';'pk2';'wl2a'};

paths_folder_out='c:\Users\chavarri\Downloads\tmp_out\';

%create output directory
mkdir(paths_folder_out)
fprintf('output directory is %s \n',paths_folder_out)

nl=5; %number of substrate layers (br2 has 5, so all of them have 5)
nf=10; %number of frc files

%% in paths

nd=numel(domains);

%loop on domains
for kd=1:nd
    
    %paths to mdf
    if strcmp(domains{kd,1},'br0')
        paths_mdf_in{kd,1}=fullfile(paths_folder_in,'source',sprintf('%s.mdf',domains{kd,1}));
    else
        paths_mdf_in{kd,1}='';
    end
    
    %paths to grd and enc
    paths_grd_in{kd,1}=fullfile(paths_folder_in,'source',sprintf('%s.grd',domains{kd,1}));
    paths_enc_in{kd,1}=fullfile(paths_folder_in,'source',sprintf('%s.enc',domains{kd,1}));
    
    %paths to dep
    if strcmp(domains{kd,1},'br2')
        paths_dep_in{kd,1}=fullfile(paths_folder_in,'source',sprintf('%s_suppletie_30.dep',domains{kd,1}));
    else
        paths_dep_in{kd,1}=fullfile(paths_folder_in,'source',sprintf('%s_na_mor_inspeel.dep',domains{kd,1}));
    end
    
    %paths to bct
    if strcmp(domains{kd,1},'br2')
        paths_bct_in{kd,1}='';
    else
        paths_bct_in{kd,1}=fullfile(paths_folder_in,'q_dependent',sprintf('%sQ2250.bct',domains{kd,1}));
    end
    
    %paths to bnd
    if strcmp(domains{kd,1},'br2')
        paths_bnd_in{kd,1}='';
    else
        paths_bnd_in{kd,1}=fullfile(paths_folder_in,'source',sprintf('%s.bnd',domains{kd,1}));
    end
    
    %paths to mor
    if strcmp(domains{kd,1},'br0')
        paths_mor_in{kd,1}=fullfile(paths_folder_in,'q_dependent',sprintf('%sQ2250.mor',domains{kd,1}));
    else
        paths_mor_in{kd,1}='';
    end
    
    %paths to bcm
    if strcmp(domains{kd,1},'br0')
        paths_bcm_in{kd,1}=fullfile(paths_folder_in,'source',sprintf('%s.bcm',domains{kd,1}));
    else
        paths_bcm_in{kd,1}='';
    end
    
    %paths to thd
    paths_thd_in{kd,1}=fullfile(paths_folder_in,'source',sprintf('%s.thd',domains{kd,1}));
        
    %paths to wr
    paths_wr_in{kd,1}=fullfile(paths_folder_in,'source',sprintf('%s.wr',domains{kd,1}));
    
    %paths to aru
    if strcmp(domains{kd,1},'br2')
        paths_aru_in{kd,1}=fullfile(paths_folder_in,'source',sprintf('%s_spijk.aru',domains{kd,1}));
    else
        paths_aru_in{kd,1}=fullfile(paths_folder_in,'source',sprintf('%s.aru',domains{kd,1}));
    end
    
    %paths to arv
    if strcmp(domains{kd,1},'br2')
        paths_arv_in{kd,1}=fullfile(paths_folder_in,'source',sprintf('%s_spijk.arv',domains{kd,1}));
    else
        paths_arv_in{kd,1}=fullfile(paths_folder_in,'source',sprintf('%s.arv',domains{kd,1}));
    end
    
    %paths to dune height
    paths_dhe_in{kd,1}=fullfile(paths_folder_in,'source',sprintf('duneheight%s.dep',domains{kd,1}));
    
    %loop on layers
    for kl=1:nl
        
        %paths to thk
        if kl==1
            if strcmp(domains{kd,1},'br2')
                paths_thk_in{kd,kl}=fullfile(paths_folder_in,'sed','br2_suppletie_30.thk');
            else
                paths_thk_in{kd,kl}=''; %we will set it equal to 0
            end
        else
            paths_thk_in{kd,kl}=fullfile(paths_folder_in,'sed',sprintf('%s_lyr%02d.thk',domains{kd,1},kl-1));
        end %kl==1
        
        %loop on fractions
        for kf=1:nf
            
            %paths to frc
            if kl==1
                paths_frc_in{kd,kl,kf}=''; %value set in morlyr
            else
%                 if kf==1 %'none'
%                     paths_frc_in{kd,kl,kf}=fullfile(paths_folder_in,'sed',sprintf('%s_none.frc',domains{kd,1}));
%                 else
                    paths_frc_in{kd,kl,kf}=fullfile(paths_folder_in,'sed',sprintf('%s_lyr%02d_frac%02d.frc',domains{kd,1},kl-1,kf));
%                 end %kf==1
            end %kl==1
        end %kf
    end %kl
end %kd


%% out paths

%mdu
paths_mdu_out=fullfile(paths_folder_out,'bifurcation.mdu');

%dep
paths_dep_out=fullfile(paths_folder_out,'dep.xyz');

%bc
paths_bct_out=fullfile(paths_folder_out,'bc.bc');

%mor
paths_mor_out=fullfile(paths_folder_out,'mor.mor');

%bcm
paths_bcm_out=fullfile(paths_folder_out,'bcm.bcm');

%thd
paths_thd_out=fullfile(paths_folder_out,'thd.pli');

%wr - tdk
paths_tdk_out=fullfile(paths_folder_out,'tdk.pli');

%arl
paths_arl_out=fullfile(paths_folder_out,'arl.arl');

%dune height
paths_dhe_out=fullfile(paths_folder_out,'dhe.xyz');

for kl=1:nl
    
    %thk
    paths_thk_out{1,kl}=fullfile(paths_folder_out,sprintf('lyr_%02d.xyz',kl));
    
    %frc
    for kf=1:nf
        paths_frc_out{1,kl,kf}=fullfile(paths_folder_out,sprintf('lyr_%02d_frac_%02d.xyz',kl,kf));
    end
end


%% out structure

paths.paths_mdf_in=paths_mdf_in;
paths.paths_grd_in=paths_grd_in;
paths.paths_enc_in=paths_enc_in;
paths.paths_bnd_in=paths_bnd_in;
paths.paths_dep_in=paths_dep_in;
paths.paths_thk_in=paths_thk_in;
paths.paths_frc_in=paths_frc_in;
paths.paths_bct_in=paths_bct_in;
paths.paths_mor_in=paths_mor_in;
paths.paths_bcm_in=paths_bcm_in;
paths.paths_thd_in=paths_thd_in;
paths.paths_wr_in=paths_wr_in;
paths.paths_aru_in=paths_aru_in;
paths.paths_arv_in=paths_arv_in;
paths.paths_dhe_in=paths_dhe_in;

paths.paths_folder_out=paths_folder_out;

paths.paths_mdu_out=paths_mdu_out;
paths.paths_dep_out=paths_dep_out;
paths.paths_thk_out=paths_thk_out;
paths.paths_frc_out=paths_frc_out;
paths.paths_bct_out=paths_bct_out;
paths.paths_mor_out=paths_mor_out;
paths.paths_bcm_out=paths_bcm_out;
paths.paths_thd_out=paths_thd_out;
paths.paths_tdk_out=paths_tdk_out;
paths.paths_arl_out=paths_arl_out;
paths.paths_dhe_out=paths_dhe_out;

