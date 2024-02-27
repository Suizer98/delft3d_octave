%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18303 $
%$Date: 2022-08-15 22:11:52 +0800 (Mon, 15 Aug 2022) $
%$Author: chavarri $
%$Id: twoD_study.m 18303 2022-08-15 14:11:52Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/ECT/twoD_study.m $
%

function [eig_r,eig_i,kwx_v,kwy_v,m_in,eigenvector,eigenvalue,M,eigenvectorL,eigen_R]=twoD_study(ECT_matrices,in_2D)

v2struct(ECT_matrices);

%% INPUT

if isfield(in_2D,'lims_lw')==0
    in_2D.lims_lw=[0.01,200];
end
np=250;
if isfield(in_2D,'kwx_v')==0
    in_2D.kwx_v=(10.^(linspace(log10(2*pi/in_2D.lims_lw(2)),log10(2*pi/in_2D.lims_lw(1)),np)));
end
if isfield(in_2D,'kwy_v')==0
    in_2D.kwy_v=in_2D.kwx_v;
end
if isfield(in_2D,'qs_anl')==0
    in_2D.qs_anl=0;
end
if isfield(in_2D,'pert_anl')==0
    in_2D.pert_anl=1; %0=NO; 1=full; 2=no friction; 3=no friction & no diffusion; 
end

if isfield(in_2D,'flg_disp')==0
    in_2D.flg_disp=1;
end

v2struct(in_2D)

%%
% m_in=combvec(kwx_v,kwy_v)';
m_in=allcomb(kwx_v,kwy_v);

lwx_v=2*pi./kwx_v;
lwy_v=2*pi./kwy_v;

np1=numel(kwx_v);
np2=numel(kwy_v);
        
% [Ax_1,Ay_1,Dx_1,Dy_1,B_1,C_1]=rename_matrices(flg,ECT_matrices,alpha_pmm);

%% CALC

%for both
nc=size(m_in,1);

ne=size(Ax,1);
eig_r=NaN(nc,ne);
eig_i=NaN(nc,ne);

kwx_vi=m_in(:,1);
kwy_vi=m_in(:,2);

%qs
if qs_anl==1
syms lambda
O=sym(zeros(ne,ne));
    switch flg.anl
        case 6
            O(4,4)=lambda;
            O(5,5)=lambda;
            eig_r_qs=NaN(nc,2);
            eig_i_qs=NaN(nc,2);            
        case {9,10} %secondary flow and Exner fall in the fourth row in both cases
            O(4,4)=lambda;
            eig_r_qs=NaN(nc,1);
            eig_i_qs=NaN(nc,1);
    end
    
% syms lambda
% O=sym(zeros(ne,ne));
% O(5,5)=lambda;
% eig_r_qs=NaN(nc,1);
% eig_c_qs=NaN(nc,1);

%SW-nsf-H
% O(5,5)=lambda;


% syms lambda
% O=sym(eye(ne,ne)).*lambda;
% O(5,5)=0;
% eig_r_qs=NaN(nc,4);
% eig_c_qs=NaN(nc,4);
end

% parfor_progress(nc);
% parfor kc=1:nc
for kc=1:nc
    kwx=kwx_vi(kc);
    kwy=kwy_vi(kc);
 
    [M,eigenvector,eigenvalue,eigenvectorL,eigen_R]=ECT_M(pert_anl,kwx,kwy,Dx,Dy,C,Ax,Ay,B,M_pmm);
    
%     switch pert_anl
%         case 1 %full
%             M=Dx*kwx^2*1i+Dy*kwy^2*1i+C*kwx*kwy*1i+Ax*kwx+Ay*kwy-B*1i; 
%         case 2 %no friction
%             M=Dx*kwx^2*1i+Dy*kwy^2*1i+C*kwx*kwy*1i+Ax*kwx+Ay*kwy; 
%         case 3 %no friction no diffusion
%             M=Ax*kwx+Ay*kwy; 
%         case 4 %full PMM
%             M=inv(M_pmm)*Dx*kwx^2*1i+inv(M_pmm)*Dy*kwy^2*1i+inv(M_pmm)*C*kwx*kwy*1i+inv(M_pmm)*Ax*kwx+inv(M_pmm)*Ay*kwy-inv(M_pmm)*B*1i; 
% %             M=Dx_1*kwx^2*1i+Dy_1*kwy^2*1i+C_1*kwx*kwy*1i+inv(M_pmm)*Ax_1*kwx+inv(M_pmm)*Ay_1*kwy-inv(M_pmm)*B_1*1i; 
%         case 5 %no friction PMM
%             M=inv(M_pmm)*Dx*kwx^2*1i+inv(M_pmm)*Dy*kwy^2*1i+inv(M_pmm)*C*kwx*kwy*1i+inv(M_pmm)*Ax*kwx+inv(M_pmm)*Ay*kwy; 
%         case 6 %no friction no diffusion PMM
%             M=inv(M_pmm)*Ax*kwx+inv(M_pmm)*Ay*kwy; 
%         otherwise
%             error('implement')
%     end
%     
% %     eigen_R=eig(M);
%     [eigenvector,eigenvalue,eigenvectorL]=eig(M);
%     eigen_R=diag(eigenvalue);
    eig_r(kc,:)=real(eigen_R); 
    eig_i(kc,:)=imag(eigen_R);
    
    %qs
    switch qs_anl
        case 1 %quasi-steady sediment transport
            det_m=det(O-M);
            det_m_vpa=vpa(det_m);
            eigen_qs=solve(det_m_vpa,lambda);
            eig_r_qs(kc,:)=real(eigen_qs); 
            eig_i_qs(kc,:)=imag(eigen_qs);
    end
    
%     parfor_progress
if flg_disp
fprintf('2D done %5.1f %% \n',kc/nc*100)
end
end
% parfor_progress(0)

%%
%% MOVE TO OTHER PLACE
%%

if 0
%% POST CALC


    %%  growth rate
eig_i(eig_i==0)=NaN;
max_gr=max(eig_i,[],2,'omitnan');

%positive growth rate
gr_p=max_gr>0;
max_grp=NaN(nc,1);
max_grp(gr_p)=max_gr(gr_p);

%matrix form
[xm_k,ym_k]=meshgrid(kwx_v,kwy_v);
[xm_l,ym_l]=meshgrid(lwx_v,lwy_v);
max_gr_m=reshape(max_gr,np1,np2)';
max_grp_m=reshape(max_grp,np1,np2)';
% min_cl_m=reshape(min_cl,np,np)';

%qs
if qs_anl==1
eig_i_qs(eig_i_qs==0)=NaN;
max_gr_qs=max(eig_i_qs,[],2,'omitnan');

max_gr_qs_m=reshape(max_gr_qs,np1,np2)';
end

    %% celerity
%take the celerity of the eigenvalues related to exner-hirano that we identify as the smallest
[m_s,p_s]=sort(abs(eig_r),2);
eig_r_morph=NaN(size(eig_r,1),ne-3);
for kc=1:nc
    eig_r_morph(kc,:)=eig_r(kc,p_s(kc,1:ne-3));
end

%matrix form
max_cl_m=NaN(np1,np2,ne-3);
for ke=1:ne-3
    max_cl_m(:,:,ke)=reshape(eig_r_morph(:,ke),np1,np2)'./xm_k;
end

%% PLOT
ncmap=10000;
cmap1=brewermap(ncmap,'RdYlGn');
% cmap2=brewermap(ncmap,'Greens');
% cmap2=cmap2(ncmap*0.1:end,:);
% cmap=[flipud(cmap1(1:ncmap/2-ncmap*0.05,:));flipud(cmap1(ncmap/2+ncmap*0.05:end,:))];
cmap=flipud([flipud(cmap1(1:ncmap/2-ncmap*0.05,:));0,0,0;flipud(cmap1(ncmap/2+ncmap*0.05+1:end,:))]);
clim_l=max(abs(min(max_gr)),abs(max(max_gr)));
clim_f=[-clim_l,clim_l];

end

%%

% fig_twoD

%% REAL K
    %% scatter
if 0
figure
scatter(m_in(:,1),m_in(:,2),10,max_gr,'filled')
set(gcf,'colormap',cmap1)
han.cbar=colorbar;
han.cbar.Label.String='growth rate [1/s]';
xlabel('k_{wx} [rad/m]')
ylabel('k_{wy} [rad/m]')
end

    %% surf
if 0
figure
surf(xm_k,ym_k,max_gr_m)
set(gcf,'colormap',cmap1)
han.cbar=colorbar;
han.cbar.Label.String='growth rate [1/s]';
xlabel('k_{wx} [rad/m]')
ylabel('k_{wy} [rad/m]')
% xlim([0,20]);
% xlim([0,20]);
end

    %% surf only growth
if 0
figure
surf(xm_k,ym_k,max_grp_m)
set(gcf,'colormap',cmap1)
han.cbar=colorbar;
han.cbar.Label.String='growth rate [1/s]';
xlabel('k_{wx} [rad/m]')
ylabel('k_{wy} [rad/m]')
% xlim([0,20]);
% xlim([0,20]);
end

    %% contour
if 0
figure
contourf(xm_k,ym_k,max_gr_m,'showtext','on')
title('growth rate [1/s]')
xlabel('k_{wx} [rad/m]')
ylabel('k_{wy} [rad/m]')
colormap(gca,cmap);
caxis(gca,clim_f*1e-1);
colorbar
end
    %% scatter 2 colors
if 0
figure
hold on
scatter(m_in(max_gr>0,1),m_in(max_gr>0,2),10,'g','filled')
scatter(m_in(max_gr<0,1),m_in(max_gr<0,2),10,'r','filled')
xlim([min(kwx_v),max(kwx_v)])
ylim([min(kwy_v),max(kwy_v)])
xlabel('k_{wx} [rad/m]')
ylabel('k_{wy} [rad/m]')
end
%% REAL l
    %% contour
if 0
figure
contourf(xm_l,ym_l,max_gr_m,'showtext','on')
title('growth rate [1/s]')
xlabel('l_{x} [m]')
% ylabel('B [m]')
ylabel('l_{y} [m]')
colormap(gca,cmap);
caxis(gca,clim_f*0.8);
end
    %% scatter 2 colors
if 0
figure
hold on
scatter(2*pi./m_in(max_gr>0,1),2*pi./m_in(max_gr>0,2),10,'g','filled')
scatter(2*pi./m_in(max_gr<0,1),2*pi./m_in(max_gr<0,2),10,'r','filled')
xlim([min(lwx_v),max(lwx_v)])
ylim([min(lwy_v),max(lwy_v)])
xlabel('l_{wx} [m]')
ylabel('l_{wy} [m]')
end


%% IMAG k
    %% contour
if 0
figure
contour(xm_k,ym_k,min_cl_m,10.^(linspace(log10(1e-6),log10(1e-1),11)),'showtext','on')
title('angular frequency [1/s]')
xlabel('k_{wx} [rad/m]')
ylabel('k_{wy} [rad/m]')
end

    %% surf
if 0
figure
surf(xm_k,ym_k,min_cl_m)
% caxis([-10,10])
set(gcf,'colormap',cmap1)
han.cbar=colorbar;
han.cbar.Label.String='angular frequency [1/s]';
xlabel('k_{wx} [rad/m]')
ylabel('k_{wy} [rad/m]')
end

    %% scatter
if 0
figure
scatter(m_in(:,1),m_in(:,2),10,min_cl,'filled')
% caxis([-10,10])
set(gcf,'colormap',cmap1)
han.cbar=colorbar;
han.cbar.Label.String='angular frequency [1/s]';
xlabel('k_{wx} [rad/m]')
ylabel('k_{wy} [rad/m]')
end


%% Celerity
    %% contour
if 0
figure
contour(xm_k,ym_k,min_cl_m./xm_k,10.^(linspace(log10(1e-6),log10(1e-1),11)),'showtext','on')
title('phase speed x [m/s]')
xlabel('k_{wx} [rad/m]')
ylabel('k_{wy} [rad/m]')
end

    %% surf
if 0
figure
surf(xm_k,ym_k,min_cl_m./xm_k)
% caxis([-10,10])
set(gcf,'colormap',cmap1)
han.cbar=colorbar;
han.cbar.Label.String='phase speed x [m/s]';
xlabel('k_{wx} [rad/m]')
ylabel('k_{wy} [rad/m]')
end

    %% scatter
if 0
figure
scatter(m_in(:,1),m_in(:,2),10,min_cl./m_in(:,1),'filled')
% caxis([-10,10])
set(gcf,'colormap',cmap1)
han.cbar=colorbar;
han.cbar.Label.String='phase speed x [m/s]';
xlabel('k_{wx} [rad/m]')
ylabel('k_{wy} [rad/m]')
end

%% %%
%% qs
%% %%

if 0
figure
contour(xm_k,ym_k,max_gr_qs_m,'showtext','on')
title('growth rate [1/s]')
xlabel('k_{wx} [rad/m]')
ylabel('k_{wy} [rad/m]')
end






%%
%%
%%
%%
if 0
figure
scatter(m_in_l(:,1),m_in_l(:,2),10,max_gr,'filled')
% caxis([-10,10])
set(gcf,'colormap',cmap1)
colorbar
xlabel('l_{wx} [rad/m]')
ylabel('l_{wy} [rad/m]')
end
%% l scatter 2 colors
if 0
figure
hold on
scatter(xm_l(max_grl_m>0),ym_l(max_grl_m>0),10,'g')
scatter(xm_l(max_grl_m<0),ym_l(max_grl_m<0),10,'r')
xlim([min(lwx_v),max(lwx_v)])
ylim([min(lwy_v),max(lwy_v)])
colorbar
xlabel('l_{wx} [m]')
ylabel('l_{wy} [m]')
end
%% k scatter 2 colors
if 0
figure
hold on
scatter(m_in(max_grl>0,1),m_in(max_grl>0,2),10,'g')
scatter(m_in(max_grl<0,1),m_in(max_grl<0,2),10,'r')
xlim([min(kwx_v),max(kwx_v)])
ylim([min(kwy_v),max(kwy_v)])
% colorbar
xlabel('k_{wx} [rad/m]')
ylabel('k_{wy} [rad/m]')
end
%% k surf 2 colors
if 0
figure
surf(xm_k,ym_k,max_grl_m,'edgecolor','none')
view([0,90])
caxis(clim)
set(gcf,'colormap',cmap)
xlim([min(kwx_v),max(kwx_v)])
ylim([min(kwy_v),max(kwy_v)])
colorbar
xlabel('k_{wx} [rad/m]')
ylabel('k_{wy} [rad/m]')
end
%% l
if 0
figure
surf(xm_l,ym_l,max_grl_m,'edgecolor','none')
view([0,90])
caxis(clim)
set(gcf,'colormap',cmap)
xlim([min(lwx_v),max(lwx_v)])
ylim([min(lwy_v),max(lwy_v)])
colorbar
xlabel('l_{wx} [m]')
ylabel('l_{wy} [m]')
end
%% k
if 0
figure
hold on
surf(xm_k,ym_k,max_grl_m_p,'edgecolor','none')
scatter3(kwx_max,kwy_max,max_max_grl,10,'r')
view([0,90])
% caxis(clim)
set(gcf,'colormap',cmap2)
xlim([min(kwx_v),max(kwx_v)])
ylim([min(kwy_v),max(kwy_v)])
colorbar
xlabel('k_{wx} [rad/m]')
ylabel('k_{wy} [rad/m]')
end
%%
if 0
figure
hold on
surf(xm_l,ym_l,max_grl_m_p,'edgecolor','none')
view([0,90])
% caxis(clim)
set(gcf,'colormap',cmap2)
xlim([min(lwx_v),max(lwx_v)])
ylim([min(lwy_v),max(lwy_v)])
colorbar
xlabel('l_{wx} [m]')
ylabel('l_{wy} [m]')

%%
figure
contour(xm_l,ym_l,max_grl_m_p,'showtext','on')
xlabel('l_{wx} [m]')
ylabel('l_{wy} [m]')
%%
figure
contour(xm_l,ym_l,max_grl_m_p_nsf,'showtext','on')
xlabel('l_{wx} [m]')
ylabel('l_{wy} [m]')
%%
figure
surf(xm_l,ym_l,max_grl_m_p_nsf,'edgecolor','none')
view([0,90])
% caxis(clim)
set(gcf,'colormap',cmap2)
xlim([min(lwx_v),max(lwx_v)])
ylim([min(lwy_v),max(lwy_v)])
colorbar
xlabel('l_{wx} [m]')
ylabel('l_{wy} [m]')
end
