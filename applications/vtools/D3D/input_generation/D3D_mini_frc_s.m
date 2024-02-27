%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17062 $
%$Date: 2021-02-12 20:47:20 +0800 (Fri, 12 Feb 2021) $
%$Author: chavarri $
%$Id: D3D_mini_frc_s.m 17062 2021-02-12 12:47:20Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_mini_frc_s.m $
%
%generate fractions of active and substrate layers

%INPUT:
%   -simdef.D3D.dire_sim = full path to the output folder [string] e.g. 'd:\victorchavarri\SURFdrive\projects\ellipticity\D3D\runs\1D\998'
%
%OUTPUT:
%   -
%
%ATTENTION:
%   -patch is very specific for simulations with flow to the right


function frc=D3D_mini_frc_s(simdef)
%% RENAME

dire_sim=simdef.D3D.dire_sim; 

dx=simdef.grd.dx;
nx=simdef.grd.M;
N=simdef.grd.N;
L=simdef.grd.L;

ThTrLyr=simdef.mor.ThTrLyr;
ThUnLyr=simdef.mor.ThUnLyr;
subs_frac=simdef.ini.subs_frac;
subs_patch_frac=simdef.ini.subs_patch_frac;
total_ThUnLyr=simdef.mor.total_ThUnLyr;
actlay_frac=simdef.ini.actlay_frac;

switch simdef.ini.subs_type
    case {2,3}
        patch_x=simdef.ini.subs_patch_x; %x coordinate of the upper corners of the patch [m] [double(1,2)]
        patch_releta=simdef.ini.subs_patch_releta; %substrate depth of the upper corners of the patch [m] [double(1,1)]     
end
    
%other
ncy=N; %number of cells in y direction (N in RFGRID) [-]
MxNULyr=round(total_ThUnLyr/ThUnLyr); %number of underlayers
nef=numel(simdef.sed.dk)-1; %effective number of fractions (total-1)
ny=ncy+2; %number of depths points in y direction
ntl=MxNULyr+2; %number of total layers (active layer + substrate + large last layer)

%% CALCULATIONS

frc=NaN(ny,nx,ntl,nef+1); %initial fractions with dummy values

%active layer
switch simdef.ini.actlay_frac_type
    case 1
        actlay_frac=reshape(actlay_frac,nef,1); %reshape to avoid input issues
        for kf=1:nef
            frc(:,:,1,kf)=actlay_frac(kf);
        end
        frc(:,:,1,end)=1-sum(actlay_frac);
end

%substrate
switch simdef.ini.subs_type
    case {2,3}
        %all with constant value
        for kl=2:ntl
            for kf=1:nef
                frc(:,:,kl,kf)=subs_frac(kf);
            end
            frc(:,:,kl,end)=1-sum(subs_frac);
        end
        
        %identify patch coordinates
        xedge=-dx/2:dx:L-dx/2;
        [~,x0_idx]=min(abs(xedge-patch_x(1)));
        [~,xf_idx]=min(abs(xedge-patch_x(2)));
        eta_rel=[0,ThTrLyr:ThUnLyr:total_ThUnLyr];
        [~,eta_int_idx]=min(abs(eta_rel-patch_releta));
        for kx=x0_idx+1:xf_idx+1
            for kl=eta_int_idx:ntl
                for kf=1:nef
                    frc(:,kx,kl,kf)=subs_patch_frac(kf);
                end %kf
                frc(:,kx,kl,end)=1-sum(subs_patch_frac);
            end %kl    
        end %kx
    otherwise
        error('Check simdef.ini.subs_type')
end

%% WRITE

for kl=1:ntl
    for kf=1:nef+1
        fname_frc=sprintf('%s_%02d_%s_%02d.frc','lyr',kl,'frc',kf);
        file_name=fullfile(dire_sim,fname_frc);  
        write_2DMatrix(file_name,frc(:,:,kl,kf),nx,ny)
    end
end

end %function

%% 
%% FUNCTIONS
%%

function write_2DMatrix(file_name,matrix,nx,ny)

    %check if the file already exists
if exist(file_name,'file')
    error('You are trying to overwrite a file!')
end

fileID_out=fopen(file_name,'w');
write_str_x=strcat(repmat('%0.7E ',1,nx),'\n'); %string to write in x

for ky=1:ny
    fprintf(fileID_out,write_str_x,matrix(ky,:));
end

fclose(fileID_out);

end %function
