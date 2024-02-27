%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: D3D_mini_frc_u.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_mini_frc_u.m $
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


function D3D_mini_frc_u(simdef)
%% RENAME

dire_sim=simdef.D3D.dire_sim; 

L=simdef.grd.L;
B=simdef.grd.B;

dx=simdef.grd.dx;
dy=simdef.grd.dy;

ThTrLyr=simdef.mor.ThTrLyr;
ThUnLyr=simdef.mor.ThUnLyr;
subs_frac=simdef.ini.subs_frac;
total_ThUnLyr=simdef.mor.total_ThUnLyr;
actlay_frac=simdef.ini.actlay_frac;

switch simdef.ini.actlay_frac_type
    case 2
        actlay_patch_x=simdef.ini.actlay_patch_x;
        actlay_patch_y=simdef.ini.actlay_patch_y;
        actlay_frac=simdef.ini.actlay_frac;
        actlay_patch_frac=simdef.ini.actlay_patch_frac;
end
switch simdef.ini.subs_type
    case 2
        subs_patch_frac=simdef.ini.subs_patch_frac;
        patch_x=simdef.ini.subs_patch_x; %x coordinate of the upper corners of the patch [m] [double(1,2)]
        patch_releta=simdef.ini.subs_patch_releta; %substrate depth of the upper corners of the patch [m] [double(1,1)]   
        eta_rel=[0,ThTrLyr:ThUnLyr:total_ThUnLyr];
        [~,eta_int_idx]=min(abs(eta_rel-patch_releta));
end
    
%other
MxNULyr=round(total_ThUnLyr/ThUnLyr); %number of underlayers
nf=numel(simdef.sed.dk);
nef=nf-1; %effective number of fractions (total-1)
if nef==0
    nef=1;
end
ntl=MxNULyr+2; %number of total layers (active layer + substrate + large last layer)

%% CALC

%% active layer
kl=1;

%first constant value
frc=NaN(4,3,nf);
% switch simdef.ini.actlay_frac_type
%     case 1
        actlay_frac=reshape(actlay_frac,nef,1); %reshape to avoid input issues
        for kf=1:nef
            frc(:,3,kf)=actlay_frac(kf);
        end
        frc(:,3,end)=1-sum(actlay_frac);
%     case 2
        
% end
% frc(:,1:2,:)=repmat([0,0;0,B;L,0;L,B],1,1,nf);
frc(:,1:2,:)=repmat([-dx,-dy;-dx,B+dy;L+dx,-dy;L+dx,B+dy],1,1,nf);

%add patch in active layer if requested
if simdef.ini.actlay_frac_type==2
%     if kl>=eta_int_idx
        frc_2=NaN(16,3,nf);
        frc_2(1:4,:,:)=frc;
        for kf=1:nef
            frc_2(5 ,:,kf)=[actlay_patch_x(1)-0.001,actlay_patch_y(1),actlay_frac(kf)];
            frc_2(6 ,:,kf)=[actlay_patch_x(1)-0.001,actlay_patch_y(2),actlay_frac(kf)];
            frc_2(7 ,:,kf)=[actlay_patch_x(1)+0.001,actlay_patch_y(1),actlay_patch_frac(kf)];
            frc_2(8 ,:,kf)=[actlay_patch_x(1)+0.001,actlay_patch_y(2),actlay_patch_frac(kf)];
            frc_2(9 ,:,kf)=[actlay_patch_x(2)-0.001,actlay_patch_y(1),actlay_patch_frac(kf)];
            frc_2(10,:,kf)=[actlay_patch_x(2)-0.001,actlay_patch_y(2),actlay_patch_frac(kf)];
            frc_2(11,:,kf)=[actlay_patch_x(2)+0.001,actlay_patch_y(1),actlay_frac(kf)];
            frc_2(12,:,kf)=[actlay_patch_x(2)+0.001,actlay_patch_y(2),actlay_frac(kf)];
            frc_2(13,:,kf)=[actlay_patch_x(1)+0.001,actlay_patch_y(1)-0.001,actlay_frac(kf)];
            frc_2(14,:,kf)=[actlay_patch_x(1)+0.001,actlay_patch_y(2)+0.001,actlay_frac(kf)];
            frc_2(15,:,kf)=[actlay_patch_x(2)-0.001,actlay_patch_y(1)-0.001,actlay_frac(kf)];
            frc_2(16,:,kf)=[actlay_patch_x(2)-0.001,actlay_patch_y(2)+0.001,actlay_frac(kf)];
        end
        frc_2(:,3,end)=1-sum(frc_2(:,3,1:end-1),3);
        frc_2(:,1:2,end)=frc_2(:,1:2,1);
        frc=frc_2;
%     end
end

%write active layer
for kf=1:nef+1
    mat2w=frc(:,:,kf); %matrix to write
    fname_frc=sprintf('%s_%02d_%s_%02d.xyz','lyr',kl,'frc',kf);
    file_name=fullfile(dire_sim,fname_frc);  
    write_2DMatrix(file_name,mat2w,size(mat2w,2),size(mat2w,1));
end
    
%% substrate
for kl=2:ntl
    frc=NaN(4,3,nf);
    %all with constant value
    for kf=1:nef
        frc(:,3,kf)=subs_frac(kf);
    end
    frc(:,3,end)=1-sum(subs_frac);
%     frc(:,1:2,:)=repmat([0,0;0,B;L,0;L,B],1,1,nf);
    frc(:,1:2,:)=repmat([-dx,-dy;-dx,B+dy;L+dx,-dy;L+dx,B+dy],1,1,nf);
    
    if simdef.ini.subs_type==2
        if kl>=eta_int_idx
            frc_2=NaN(12,3,nf);
            frc_2(1:4,:,:)=frc;
            for kf=1:nef
                frc_2(5 ,:,kf)=[patch_x(1)-0.001,0,subs_frac(kf)];
                frc_2(6 ,:,kf)=[patch_x(1)-0.001,B,subs_frac(kf)];
                frc_2(7 ,:,kf)=[patch_x(1)+0.001,0,subs_patch_frac(kf)];
                frc_2(8 ,:,kf)=[patch_x(1)+0.001,B,subs_patch_frac(kf)];
                frc_2(9 ,:,kf)=[patch_x(2)-0.001,0,subs_patch_frac(kf)];
                frc_2(10,:,kf)=[patch_x(2)-0.001,B,subs_patch_frac(kf)];
                frc_2(11,:,kf)=[patch_x(2)+0.001,0,subs_frac(kf)];
                frc_2(12,:,kf)=[patch_x(2)+0.001,B,subs_frac(kf)];
            end
            frc_2(:,3,end)=1-sum(frc_2(:,3,1:end-1),3);
            frc_2(:,1:2,end)=frc_2(:,1:2,1);
            frc=frc_2;
        end
    end
    for kf=1:nf
        mat2w=frc(:,:,kf); %matrix to write
        fname_frc=sprintf('%s_%02d_%s_%02d.xyz','lyr',kl,'frc',kf);
        file_name=fullfile(dire_sim,fname_frc);  
        write_2DMatrix(file_name,mat2w,size(mat2w,2),size(mat2w,1));
    end

end %function

% %% RENAME
% 
% dire_sim=simdef.D3D.dire_sim; 
% 
% %number of faces
% nx=simdef.grd.node_number_x;
% ny=simdef.grd.node_number_y;
% 
% dx=simdef.grd.dx;
% L=simdef.grd.L;
% 
% ThTrLyr=simdef.mor.ThTrLyr;
% ThUnLyr=simdef.mor.ThUnLyr;
% subs_frac=simdef.ini.subs_frac;
% subs_patch_frac=simdef.ini.subs_patch_frac;
% total_ThUnLyr=simdef.mor.total_ThUnLyr;
% actlay_frac=simdef.ini.actlay_frac;
% 
% switch simdef.ini.subs_type
%     case 2
%         patch_x=simdef.ini.subs_patch_x; %x coordinate of the upper corners of the patch [m] [double(1,2)]
%         patch_releta=simdef.ini.subs_patch_releta; %substrate depth of the upper corners of the patch [m] [double(1,1)]     
% end
%     
% %other
% MxNULyr=round(total_ThUnLyr/ThUnLyr); %number of underlayers
% nef=numel(simdef.sed.dk)-1; %effective number of fractions (total-1)
% ntl=MxNULyr+2; %number of total layers (active layer + substrate + large last layer)
% 
% %% CALCULATIONS
% 
% frc=NaN(ny,nx,ntl,nef+1); %initial fractions with dummy values
%     
% %active layer
% switch simdef.ini.actlay_frac_type
%     case 1
%         actlay_frac=reshape(actlay_frac,nef,1); %reshape to avoid input issues
%         for kf=1:nef
%             frc(:,:,1,kf)=actlay_frac(kf);
%         end
%         frc(:,:,1,end)=1-sum(actlay_frac);
% end
% 
% %substrate
% switch simdef.ini.subs_type
%     case 2
%         %all with constant value
%         for kl=2:ntl
%             for kf=1:nef
%                 frc(:,:,kl,kf)=subs_frac(kf);
%             end
%             frc(:,:,kl,end)=1-sum(subs_frac);
%         end
%         
%         %identify patch coordinates
%         xedge=-dx/2:dx:L-dx/2;
%         [~,x0_idx]=min(abs(xedge-patch_x(1)));
%         [~,xf_idx]=min(abs(xedge-patch_x(2)));
%         eta_rel=[0,ThTrLyr:ThUnLyr:total_ThUnLyr];
%         [~,eta_int_idx]=min(abs(eta_rel-patch_releta));
%         for kx=x0_idx+1:xf_idx+1
%             for kl=eta_int_idx:ntl
%                 for kf=1:nef
%                     frc(:,kx,kl,kf)=subs_patch_frac(kf);
%                 end %kf
%                 frc(:,kx,kl,end)=1-sum(subs_patch_frac);
%             end %kl    
%         end %kx
%         
% end
% 
% %% CONECTIVITY MATRIX
% 
% topo_faces=D3D_topo_faces_rec(nx,ny);
% 
% %% PADDING
% %I am not sure why this is needed, but it is! :D
% 
% frc_pad=NaN(ny,nx+2,ntl,nef+1); %initial fractions with dummy values
% frc_pad(:,1:end-2,:,:)=frc;
% frc_pad(:,end-1:end,:,:)=1/(nef+1);
% 
% topo_faces_pad=NaN(ny,nx+2);
% topo_faces_pad(:,1:end-2)=topo_faces;
% % topo_faces_pad(:,end-1:end)=1:1:ny;
% topo_faces_pad(:,end-1:end)=reshape((ny*nx)+1:1:(ny*nx)+2*ny,ny,2);
% 
% %% WRITE
% 
% for kl=1:ntl
%     for kf=1:nef+1
%         mat2w=frc_pad(:,:,kl,kf); %matrix to write
%         vec2w=mat2w(topo_faces_pad(:)); %vector to write
%         fname_frc=sprintf('%s_%02d_%s_%02d.frc','lyr',kl,'frc',kf);
%         file_name=fullfile(dire_sim,fname_frc);  
%         write_2DMatrix(file_name,vec2w,1,numel(vec2w));
%     end
% end
