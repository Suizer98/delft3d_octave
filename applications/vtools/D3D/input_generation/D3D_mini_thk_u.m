%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: D3D_mini_thk_u.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_mini_thk_u.m $
%
%generate thickness of active and substrate layers

%INPUT:
%   -simdef.D3D.dire_sim = full path to the output folder [string] e.g. 'd:\victorchavarri\SURFdrive\projects\ellipticity\D3D\runs\1D\998'
%
%OUTPUT:
%   -
%
%ATTENTION:
%   -


function D3D_mini_thk_u(simdef)

%% RENAME

dire_sim=simdef.D3D.dire_sim; 

L=simdef.grd.L;
B=simdef.grd.B;

ThTrLyr=simdef.mor.ThTrLyr;
ThUnLyr=simdef.mor.ThUnLyr;
total_ThUnLyr=simdef.mor.total_ThUnLyr;

%other
MxNULyr=round(total_ThUnLyr/ThUnLyr); %number of underlayers
ntl=MxNULyr+2; %number of total layers (active layer + substrate + large last layer)

%% CALCULATIONS

thk=NaN(4,3,ntl); %initial thickness with dummy values

thk(:,1:2,:)=repmat([0,0;0,B;L,0;L,B],1,1,ntl);

%active layer
thk(:,3,1)=ThTrLyr;

%substrate
thk(:,3,2:end-1)=ThUnLyr;

%last layer
thk(:,3,end)=ThUnLyr*10;

%% WRITE

for kl=1:ntl
    mat2w=thk(:,:,kl); %matrix to write
    fname_thk=sprintf('%s_%02d.xyz','lyr',kl);
    file_name=fullfile(dire_sim,fname_thk);
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
% ThTrLyr=simdef.mor.ThTrLyr;
% ThUnLyr=simdef.mor.ThUnLyr;
% total_ThUnLyr=simdef.mor.total_ThUnLyr;
% 
% %other
% MxNULyr=round(total_ThUnLyr/ThUnLyr); %number of underlayers
% ntl=MxNULyr+2; %number of total layers (active layer + substrate + large last layer)
% 
% %% CALCULATIONS
% 
% thk=NaN(ny,nx+2,ntl); %initial thickness with dummy values
%     %+2 accounts for the fact that we need to provide values at open
%     %boundaries (at x=cte). We copy first and last values.
% 
% %active layer
% thk(:,:,1)=ThTrLyr;
% 
% %substrate
% thk(:,:,2:end-1)=ThUnLyr;
% 
% %last layer
% thk(:,:,end)=ThUnLyr*10;
% 
% %% CONECTIVITY MATRIX
% 
% topo_faces=D3D_topo_faces_rec(nx+2,ny);
% 
% %% WRITE
% 
% for kl=1:ntl
%     mat2w=thk(:,:,kl); %matrix to write
%     vec2w=mat2w(topo_faces(:)); %vector to write
%     fname_thk=sprintf('%s_%02d.thk','lyr',kl);
%     file_name=fullfile(dire_sim,fname_thk);  
%     write_2DMatrix(file_name,vec2w,1,(nx+2)*ny);
% end
% 
% end %function
