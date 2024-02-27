%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: D3D_grd_sing.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_grd_sing.m $
%

function D3D_grd_sing(simdef)

%% RENAME

dire_sim=simdef.D3D.dire_sim;

% L=simdef.grd.L;
B=simdef.grd.B;
ds=simdef.grd.dx;
dn=simdef.grd.dy;

mmax=simdef.grd.M-1;
nmax=simdef.grd.N-1;
% mmax=round(lambda_num*lambda/ds);
% nmax=floor(B/dn*2);

teta_0=simdef.grd.teta_0; % [rad] maximum angle
lambda=simdef.grd.lambda; % [m] wave length
lambda_num=simdef.grd.lambda_num; % [-] number of wave lengths

%% GENERATE GRID

scal=0; %.1834;
s=(0:ds:lambda*lambda_num+ds)-scal;

enc=[];

phi=teta_0*sin(2*pi*s/lambda);
x(1)=0;
y(1)=0;
for j=1:length(s)-1
    x(j+1)=x(j)+ds*cos(phi(j));
    y(j+1)=y(j)+dn*sin(phi(j));
end

grd=d3dspline2grid(x,y,B,mmax,nmax);

%% SAVE

file_name=fullfile(dire_sim,'grd.grd');
try
   ok=wlgrid('write',file_name,grd.X,grd.Y,enc);
catch
   error('Function wlgrid could not be accessed')
end

%% PLOT

% figure 
% hold on
% 
% % plot(x,y)
% % plot(x,y,'r.');
% % axis equal;
% 
% d3dplotgrid(grd);
% 
% 
% xlabel('x-coordinate (m)')
% ylabel('y-coordinate (m)')
% % print('-dpng','Ashida.png')
