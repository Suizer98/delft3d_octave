%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18069 $
%$Date: 2022-05-21 00:31:37 +0800 (Sat, 21 May 2022) $
%$Author: chavarri $
%$Id: D3D_dep_u.m 18069 2022-05-20 16:31:37Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_dep_u.m $
%
%generate depths in rectangular grid 

%INPUT:
%   -
%
%OUTPUT:
%   -
%
%ATTENTION:
%   -
%

function D3D_dep_u(simdef)
%% RENAME

file_name=simdef.file.dep;

% dx=simdef.grd.dx;
% dy=simdef.grd.dy;
% nx=simdef.grd.M;
% N=simdef.grd.N;

B=simdef.grd.B;
etab=simdef.ini.etab;
etab0_type=simdef.ini.etab0_type;

%other
% ncy=N; %number of cells in y direction (N in RFGRID) [-]
% d0=etab; %depth (in D3D) at the downstream end (at x=L, where the water level is set)

%varying slope flag
% if numel(slope)>1; flg_vars=
%% CALCULATIONS

%data=[
%x0  y0  etab|_(0,0)
%x0  y1  etab|_(1,1)
%...
%]

%XYcen
fpath_netmap=fullfile(pwd,'tmpgrd_net.nc');
D3D_grd2map(simdef.file.grd,'fpath_map',fpath_netmap);
gridInfo=EHY_getGridInfo(fpath_netmap,{'XYcen','XYcor'});
delete(fpath_netmap);

Xtot=[gridInfo.Xcen;gridInfo.Xcor];
Ytot=[gridInfo.Ycen;gridInfo.Ycor];

switch etab0_type %type of initial bed elevation: 1=sloping bed; 2=constant bed elevation
    case 1
        slope=simdef.ini.s; %slope (defined positive downwards)
        L=simdef.grd.L;
%         depths=[0,0,etab+slope*L;0,B,etab+slope*L;L,0,etab;L,B,etab];

        %using grid
        depths=etab+slope*(L-Xtot);
    case 2
%         large_number=1e4;
%         depths=[-large_number,-large_number,etab;-large_number,large_number,etab;large_number,-large_number,etab;large_number,large_number,etab];
        depths=etab.*ones(size(Xtot));
    case 3
        depths=simdef.ini.xyz;
end

%% add noise
% noise=zeros(ny,nx);
rng(0)
switch simdef.ini.etab_noise
    case 0
        noise=zeros(size(depths));
%         noise=zeros(ny,nx);
%     case 1 %random noise
%         noise_amp=simdef.ini.noise_amp;
%         noise(1:end-3,3:end-1)=noise_amp.*(rand(ny-3,nx-3)-0.5);
    case 2 %sinusoidal
        %noise
        noise_amp=simdef.ini.noise_amp;
        noise_Lb=simdef.ini.noise_Lb;
        
        %variation in cross-direction
        if ~any(gridInfo.Ycen-gridInfo.Ycen(1)) %1D, you actually want no variation in transverse direction
            Ay=1;
        else
            Ay=sin(pi*(Ytot-B/2)./B);
        end
        
        %total noise
        noise=noise_amp*Ay.*cos(2*pi*Xtot/noise_Lb-pi/2);
        
%         %% BEGIN DEBUG
%         figure
%         hold on
%         scatter3(Xtot,Ytot,noise,10,noise,'filled')
%         view([0,0])
%         xlim([550,650])
        % END DEBUG
%     case 3 %random noise including at x=0
%         noise_amp=simdef.ini.noise_amp;
% %         noise(1:end-3,2:end-1)=noise_amp.*(rand(ny-3,nx-2)-0.5);
%         noise(1:end-3,1:end)=noise_amp.*(rand(ny-3,nx)-0.5);
    case 5        
        mu=simdef.ini.noise_x0;
        etab_max=simdef.ini.noise_amp;
        sig=simdef.ini.noise_Lb;
        
        x=Xtot;
        noise=etab_max.*exp(-(x-mu).^2/sig^2);
    case 6
        %2D gaussian
    otherwise
        error('sorry... not implemented!')
end

depths=depths+noise;

matwrite=[Xtot,Ytot,depths];

%% WRITE
  
write_2DMatrix(file_name,matwrite,'check_existing',false);
