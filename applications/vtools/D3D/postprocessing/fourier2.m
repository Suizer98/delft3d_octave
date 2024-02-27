%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: fourier2.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/postprocessing/fourier2.m $
%
function fourier2(flg,file,out_read)


%% RENAME

x_m=out_read.XZ(2:end-1,:);
y_m=out_read.YZ(2:end-1,:);
z_m=out_read.z(2:end-1,:);

nx=size(x_m,2);
ny=size(x_m,1);

%better to take it from input
dx=x_m(1,2)-x_m(1,1);
dy=y_m(2,1)-y_m(1,1);

%% STANDARD

f_z=fft2(z_m);
f_zr=abs(f_z);

f_x=(0:1:nx-1)/dx/nx;
f_y=(0:1:ny-1)'/dy/ny;
f_xm=repmat(f_x,ny,1);
f_ym=repmat(f_y,1,nx);

w_x=0:1:nx-1;
w_y=(0:1:ny-1)';
w_xm=repmat(w_x,ny,1);
w_ym=repmat(w_y,1,nx);

%% shift
f_z_sh=fftshift(f_z);
f_zr_sh=abs(f_z_sh);
f_x_sh=(-nx/2:1:nx/2-1)/dx/nx;
f_y_sh=(-ny/2:1:ny/2-1)'/dy/ny;
f_x_sh_m=repmat(f_x_sh,ny,1);
f_y_sh_m=repmat(f_y_sh,1,nx);

%% NO DISCONTINUITY
x_m2=repmat([-fliplr(x_m),x_m],2,1);
y_m2=repmat([-flipud(y_m);y_m],1,2);
z_m2=[flipud(z_m),flipud(z_m);z_m,z_m];

%Fourier
f_z2=fft2(z_m2);
f_zr2=abs(f_z2);

f_x2=(0:1:2*nx-1)/dx/(2*nx)/2;
f_y2=(0:1:2*ny-1)'/dy/(2*ny)/2;
f_xm2=repmat(f_x2,ny,1);
f_ym2=repmat(f_y2,1,nx);

w_x2=(0:1:2*nx-1)/2;
w_y2=(0:1:2*ny-1)'/2;
w_xm2=repmat(w_x2,2*ny,1);
w_ym2=repmat(w_y2,1,2*nx);

%shift
f_z_sh2=fftshift(f_z2);
f_zr_sh2=abs(f_z_sh2);
f_x_sh2=(-2*nx/2:1:2*nx/2-1)/dx/(2*nx);
f_y_sh2=(-2*ny/2:1:2*ny/2-1)'/dy/(2*ny);
f_x_sh_m2=repmat(f_x_sh2,2*ny,1);
f_y_sh_m2=repmat(f_y_sh2,1,2*nx);

%%
%% PLOT
%%

%frequency
flg.which_tf=1;
in_plot.XZ=f_x_sh_m2;
in_plot.YZ=f_y_sh_m2;
in_plot.z=f_zr_sh2;
in_plot.time_r=out_read.time_r;

if 0
flg.which_s=1;
D3D_figure_fourier2(flg,file,in_plot)
end

if 0
flg.which_s=3;
flg.lims.x=[0,0.02]; %x limit in [m]
flg.lims.y=[0,0.1]; %y limit in [m]
D3D_figure_fourier2(flg,file,in_plot)
end

%full and log-log
if 0
flg.which_s=3;
% flg.lims.x=[0,0.05]; %x limit in [m]
% flg.lims.y=[0,0.1]; %y limit in [m]
flg.lims.z=[1,1e5]; %z limit in [m]
flg.XScale='log';
flg.YScale='log';
flg.ZScale='log';
D3D_figure_fourier2(flg,file,in_plot)
end

if 1
flg.which_s=3;
flg.lims.x=[0,0.05]; %x limit in [m]
flg.lims.y=[0,0.25]; %y limit in [m]
flg.lims.z=[1,1e5]; %z limit in [m]
% flg.XScale='log';
% flg.YScale='log';
flg.ZScale='log';
D3D_figure_fourier2(flg,file,in_plot)
end


%mode
flg.which_tf=2;
in_plot.XZ=w_xm2;
in_plot.YZ=w_ym2;
in_plot.z=f_zr2;
in_plot.time_r=out_read.time_r;

if 0
flg.which_s=1;
flg=rmfield(flg,'lims');
% flg.lims.x=[0,200]; %x limit in [m]
% flg.lims.y=[0,400]; %y limit in [m]
D3D_figure_fourier2(flg,file,in_plot)
end

if 0
flg.which_s=3;
flg.lims.x=[0,20]; %x limit in [m]
flg.lims.y=[0,5]; %y limit in [m]
D3D_figure_fourier2(flg,file,in_plot)
end

%%
if 0
%% original
figure
surf(x_m,y_m,z_m)
xlabel('streamwise direction [m]')
ylabel('transverse direction [m]')
%% harmonics
figure
scatter3(reshape(w_xm,[],1),reshape(w_ym,[],1),reshape(f_zr,[],1))
xlabel('streamwise harmonic')
ylabel('transversal harmonic')
xlim([0,12])
ylim([0,5])
view([-90,0])
view([0,0])
%% frequencies
figure
scatter3(reshape(f_xm,[],1),reshape(f_ym,[],1),reshape(f_zr,[],1))
xlabel('streamwise frequency [1/m]')
ylabel('transversal frequency [1/m]')
xlim([0,0.01])
% ylim([0,5])
view([-90,0])
view([0,0])
%% frequencies shift
figure
scatter3(reshape(f_x_sh_m,[],1),reshape(f_y_sh_m,[],1),reshape(f_zr_sh,[],1))
xlabel('streamwise frequency [1/m]')
ylabel('transversal frequency [1/m]')
xlim([0,0.02])
ylim([0,0.1])
view([-90,0])
view([0,0])

%%
%% modified
%%

%% surf
figure
surf(x_m2,y_m2,z_m2)
xlabel('streamwise direction [m]')
ylabel('transverse direction [m]')
%% harmonics
figure
scatter3(reshape(w_xm2,[],1),reshape(w_ym2,[],1),reshape(f_zr2,[],1))
xlabel('streamwise harmonic')
ylabel('transversal harmonic')
xlim([0,12])
ylim([0,5])
view([-90,0])
view([0,0])
%% frequencies
figure
scatter3(reshape(f_xm2,[],1),reshape(f_ym2,[],1),reshape(f_zr2,[],1))
xlabel('streamwise frequency [1/m]')
ylabel('transversal frequency [1/m]')
% xlim([0,12])
% ylim([0,5])
view([-90,0])
view([0,0])
%% frequencies shift
figure
scatter3(reshape(f_x_sh_m2,[],1),reshape(f_y_sh_m2,[],1),reshape(f_zr_sh2,[],1),'filled')
xlabel('streamwise frequency [1/m]')
ylabel('transversal frequency [1/m]')
xlim([0,0.02])
ylim([0,0.05])
view([-90,0])
print(gcf,'fs_x.eps','-depsc2')
view([0,0])

end
end %function