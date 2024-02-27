%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17251 $
%$Date: 2021-05-03 22:39:50 +0800 (Mon, 03 May 2021) $
%$Author: chavarri $
%$Id: rename_matrices.m 17251 2021-05-03 14:39:50Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/ECT/rename_matrices.m $
%

function [Ax_1,Ay_1,Dx_1,Dy_1,B_1,C_1,M_pmm]=rename_matrices(flg,alpha_pmm,A,A_qs,D_qs,Ax,Ay,Dx,Dy,B,C,Ax_sf,Ay_sf,Dx_sf,Dy_sf,B_sf,C_sf,Ax_SW,Ay_SW,Dx_SW,Dy_SW, B_SW, C_SW,Ax_SW_sf,Ay_SW_sf,Dx_SW_sf,Dy_SW_sf, B_SW_sf, C_SW_sf,Ax_SWE,Ay_SWE,Dx_SWE,Dy_SWE, B_SWE, C_SWE,Ax_SWE_sf,Ay_SWE_sf,Dx_SWE_sf,Dy_SWE_sf, B_SWE_sf, C_SWE_sf,A_ED,K_ED,B_ED,Ax_d,Ay_d,Dx_d,Dy_d, B_d, C_d);

% function [Ax_1,Ay_1,Dx_1,Dy_1,B_1,C_1,M_pmm]=rename_matrices(flg,ECT_matrices,alpha_pmm)
% v2struct(ECT_matrices)

if numel(flg.anl)>1
    error('flg.anl~=1')
end

%% rename matrix
switch flg.anl
    case 1 
        Ax_1=A;
        
        Dx_1=zeros(size(Ax_1));
        Ay_1=zeros(size(Ax_1));
        Dy_1=zeros(size(Ax_1));
        B_1 =zeros(size(Ax_1));
        C_1 =zeros(size(Ax_1));   
    case 2
        Ax_1=A_qs;
        Dx_1=D_qs;
        
        Ay_1=zeros(size(Ax_1));
        Dy_1=zeros(size(Ax_1));
        B_1 =zeros(size(Ax_1));
        C_1 =zeros(size(Ax_1));
    case 6
        Ax_1=Ax;
        Ay_1=Ay;
        Dx_1=Dx;
        Dy_1=Dy;
        B_1 = B;
        C_1 = C;
    case 7
        Ax_1=Ax_sf;
        Ay_1=Ay_sf;
        Dx_1=Dx_sf;
        Dy_1=Dy_sf;
        B_1 = B_sf;
        C_1 = C_sf;
    case 8
        Ax_1=Ax_SW;
        Ay_1=Ay_SW;
        Dx_1=Dx_SW;
        Dy_1=Dy_SW;
        B_1 = B_SW;
        C_1 = C_SW;
    case 9
        Ax_1=Ax_SW_sf;
        Ay_1=Ay_SW_sf;
        Dx_1=Dx_SW_sf;
        Dy_1=Dy_SW_sf;
        B_1 = B_SW_sf;
        C_1 = C_SW_sf;
    case 10
        Ax_1=Ax_SWE;
        Ay_1=Ay_SWE;
        Dx_1=Dx_SWE;
        Dy_1=Dy_SWE;
        B_1 = B_SWE;
        C_1 = C_SWE;
    case 11
        Ax_1=Ax_SWE_sf;
        Ay_1=Ay_SWE_sf;
        Dx_1=Dx_SWE_sf;
        Dy_1=Dy_SWE_sf;
        B_1 = B_SWE_sf;
        C_1 = C_SWE_sf;
    case 12
        Ax_1=A_ED;
        Dx_1=K_ED;
        B_1=B_ED;
    case 14
        Ax_1=Ax_d;
        Ay_1=Ay_d;
        Dx_1=Dx_d;
        Dy_1=Dy_d;
        B_1 = B_d;
        C_1 = C_d;
end

%% PMM

    
M_pmm=diag(ones(1,size(Ax_1,1)),0);
switch flg.anl
    case 2
        M_pmm(2:end,2:end)=diag(alpha_pmm.*ones(1,size(Ax_1,1)-1),0);
    case {6,14}
        M_pmm(5:end,5:end)=diag(alpha_pmm.*ones(1,size(Ax_1,1)-4),0);
end
