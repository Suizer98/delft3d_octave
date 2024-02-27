%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18316 $
%$Date: 2022-08-19 15:13:26 +0800 (Fri, 19 Aug 2022) $
%$Author: chavarri $
%$Id: call_ECT.m 18316 2022-08-19 07:13:26Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/ECT/call_ECT.m $
%
%call to Ellipticity Check Tool
%

function [ECT_matrices,sed_trans]=call_ECT(ECT_input)

%% PARSE

if isfield(ECT_input.flg,'read')==0
    ECT_input.flg.read=1;
end

if isfield(ECT_input.flg,'check_input')==0
    ECT_input.flg.check_input=0;
end

if isfield(ECT_input.flg,'friction_closure')==0
    ECT_input.flg.friction_closure=1;
end
if ECT_input.flg.friction_closure==2
    error('I think that the matrices should change! it is not only to convert the value to Chezy')
end

if isfield(ECT_input.flg,'derivatives')==0
    ECT_input.flg.derivatives=1;
end

if isfield(ECT_input.flg,'particle_activity')==0
    ECT_input.flg.particle_activity=0;
end

if isfield(ECT_input.flg,'cp')==0
    ECT_input.flg.cp=0;
end

if isfield(ECT_input.flg,'extra')==0
    ECT_input.flg.extra=0;
end

if isfield(ECT_input.flg,'pmm')==0
    ECT_input.flg.pmm=0;
end

if isfield(ECT_input.flg,'vp')==0
    ECT_input.flg.vp=1; %compute particle velocity: 0=NO, 1=YES
end

if isfield(ECT_input.flg,'E')==0
    ECT_input.flg.E=1; %compute entrainment-deposition formulation: 0=NO, 1=YES
end

if isfield(ECT_input.flg,'calib_s')==0
    ECT_input.flg.calib_s=1; 
end

if isfield(ECT_input,'u_b')==0
    ECT_input.u_b=NaN; 
end

if isfield(ECT_input,'v')==0
    ECT_input.v=0;
end

v2struct(ECT_input)

%%

I=0;
beta_c=1.0; %0=no secondary flow; 1=secondary flow without calibration !! it is used also in the linear source term

Gammak=NaN(size(gsd));
% der=1e-8;

%% Sediment Transport

cnt.g=9.81;
cnt.rho_s=2650;
cnt.rho_w=1000;
cnt.p=0.4; %in ECT sedtrnas uses this porosity
cnt.k=0.41;

cnt.R=(cnt.rho_s-cnt.rho_w)/cnt.rho_w;

Mak=Fa1.*La;

[qbk,Qbk,thetak,qbk_st,Wk_st,u_st,xik,Qbk_st,Ek,Ek_st,Ek_g,Dk,Dk_st,Dk_g,vpk,vpk_st,Gammak_eq,Dm]=sediment_transport(flg,cnt,h,u*h,Cf,La,Mak,gsd,sedTrans,hiding,1,E_param,vp_param,Gammak);
qbk_no_pores=qbk.*(1-cnt.p);
% [~,~,~,~,~,~,~,~,~,~,~,~,~,~,vpk_hdh,~,~,~]=sediment_transport(flg,cnt,h+der,u*h,Cf,La,Mak,gsd,sedTrans,hiding,1,E_param,vp_param,Gammak);

%d(vpk)/d(h) ; %double [1,1]
% vpk_h=vpk;
% dvpk_dh=(vpk_hdh-vpk_h)/der; 

% Fr=u/sqrt(cnt.g*h);
% cf_p=1/(6+2.5*log(h/(2.5*gsd(1))))^2

Gammak=Gammak_eq;
alpha_pmm=NaN;
% Gammak=[0,0]; 
% [qbk,Qbk,thetak,qbk_st,Wk_st,u_st,xik,Qbk_st,Ek,Ek_st,Ek_g,Dk,Dk_st,Dk_g,vpk,vpk_st,Gammak_eq,Dm]=sediment_transport(flg,cnt,repmat(h,1,numel(gsd)),repmat(u*h,1,numel(gsd)),repmat(Cf,1,numel(gsd)),repmat(La,1,numel(gsd)),Mak,gsd,sedTrans,hiding,1,E_param,vp_param,Gammak);

%% NODE STATE

if any(flg.anl==1) || any(flg.anl==2) || any(flg.anl==3) || any(flg.anl==4) || any(flg.anl==5) || any(flg.anl==12)
nodeState=[u,h,Cf,La,Fa1,1-sum(Fa1),Fi1,1-sum(Fi1)]; %1D    
    if any(flg.anl==12)
        nodeState=[u,h,Cf,La,Fa1,1-sum(Fa1),Fi1,1-sum(Fi1),Gammak]; %1D 
    end
elseif (any(flg.anl==6) || any(flg.anl==7) || any(flg.anl==8) || any(flg.anl==9) || any(flg.anl==10) || any(flg.anl==11) || any(flg.anl==14))
nodeState=[u,v,h,Cf,La,Fa1,1-sum(Fa1),Fi1,1-sum(Fi1)]; %2D
end

%% ECT

         [eigen_all,elliptic,A,cp,Ribb,out,pmm,...
          eigen_all_qs,elliptic_qs,A_qs,D_qs,...
          eigen_all_dLa,elliptic_dLa,A_dLa,...
          eigen_all_ad,elliptic_ad,A_ad,...
          eigen_all_2Dx,eigen_all_2Dy,elliptic_2D,Ax,Ay,Dx,Dy,B,C,...
          eigen_all_2Dx_sf,eigen_all_2Dy_sf,elliptic_2D_sf,Ax_sf,Ay_sf,Dx_sf,Dy_sf,B_sf,C_sf,...
          eigen_all_SWx,eigen_all_SWy,elliptic_SW,Ax_SW,Ay_SW,Dx_SW,Dy_SW,B_SW,C_SW,...
          eigen_all_SWx_sf,eigen_all_SWy_sf,elliptic_SW_sf,Ax_SW_sf,Ay_SW_sf,Dx_SW_sf,Dy_SW_sf,B_SW_sf,C_SW_sf,...
          eigen_all_SWEx,eigen_all_SWEy,elliptic_SWE,Ax_SWE,Ay_SWE,Dx_SWE,Dy_SWE,B_SWE,C_SWE,...
          eigen_all_SWEx_sf,eigen_all_SWEy_sf,elliptic_SWE_sf,Ax_SWE_sf,Ay_SWE_sf,Dx_SWE_sf,Dy_SWE_sf,C_SWE_sf,B_SWE_sf,...
          A_ED,K_ED,B_ED,...
          eigen_all_Dm,elliptic_Dm,A_Dm,...
          eigen_all_2Dx_d,eigen_all_2Dy_d,elliptic_2D_d,Ax_d,Ay_d,Dx_d,Dy_d,B_d,C_d...
          ]=ECT(flg,'gsd',gsd,'nodeState',nodeState,'sedTrans',sedTrans,'hiding',hiding,'ad',u_b,'secflow',[I,1,beta_c,NaN,Dh],'twoD',NaN,'kappa',kappa,'E_param',E_param,'vp_param',vp_param,'gsk_param',gsk_param,'diff_mom',nu_mom,'diff_hir',diff_hir,'cnt',cnt);

%% RENAME

[Ax,Ay,Dx,Dy,B,C,M_pmm]=rename_matrices(flg,alpha_pmm,A,A_qs,D_qs,Ax,Ay,Dx,Dy,B,C,Ax_sf,Ay_sf,Dx_sf,Dy_sf,B_sf,C_sf,Ax_SW,Ay_SW,Dx_SW,Dy_SW, B_SW, C_SW,Ax_SW_sf,Ay_SW_sf,Dx_SW_sf,Dy_SW_sf, B_SW_sf, C_SW_sf,Ax_SWE,Ay_SWE,Dx_SWE,Dy_SWE, B_SWE, C_SWE,Ax_SWE_sf,Ay_SWE_sf,Dx_SWE_sf,Dy_SWE_sf, B_SWE_sf, C_SWE_sf,A_ED,K_ED,B_ED,Ax_d,Ay_d,Dx_d,Dy_d, B_d, C_d);

ECT_matrices=v2struct(Ax,Ay,Dx,Dy,B,C,M_pmm);
sed_trans=v2struct(qbk,Qbk,thetak,qbk_st,Wk_st,u_st,xik,Qbk_st,Ek,Ek_st,Ek_g,Dk,Dk_st,Dk_g,vpk,vpk_st,Gammak_eq,Dm,qbk_no_pores);

% ECT_elliptic=v2struct(elliptic,elliptic_qs,elliptic_dLa,elliptic_ad,elliptic_Dm);
% ECT_matrices=v2struct(A_qs,D_qs,Ax,Ay,Dx,Dy,B,C,Ax_sf,Ay_sf,Dx_sf,Dy_sf,B_sf,C_sf,Ax_SW,Ay_SW,Dx_SW,Dy_SW, B_SW, C_SW,Ax_SW_sf,Ay_SW_sf,Dx_SW_sf,Dy_SW_sf, B_SW_sf, C_SW_sf,Ax_SWE,Ay_SWE,Dx_SWE,Dy_SWE, B_SWE, C_SWE,Ax_SWE_sf,Ay_SWE_sf,Dx_SWE_sf,Dy_SWE_sf, B_SWE_sf, C_SWE_sf,A_ED,K_ED,B_ED,Ax_d,Ay_d,Dx_d,Dy_d, B_d, C_d);
% [Ax_1,Ay_1,Dx_1,Dy_1,B_1,C_1,M_pmm]=rename_matrices(flg,ECT_matrices,alpha_pmm);
