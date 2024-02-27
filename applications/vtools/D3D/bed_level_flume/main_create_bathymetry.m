%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16769 $
%$Date: 2020-11-05 18:40:08 +0800 (Thu, 05 Nov 2020) $
%$Author: chavarri $
%$Id: main_create_bathymetry.m 16769 2020-11-05 10:40:08Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/bed_level_flume/main_create_bathymetry.m $
%

%% PREAMBLE

clear
close all

%% INPUT

flg.write=1; 
flg.plot=1;
flg.output_type=2; %1=D3D dep-file; 2=modify nc file

% BEGIN DEBUG
% profile on
% END DEBUG

%all distances are in meters
%a length is a distance in the streamwise direction
%a width is a distance in the transverse direction

%flume geometry
L_flume=36; %length of the flume
B_flume=5; %width of the flume
% s_flume=1e-3; %slope of the flume
s_flume=0; %slope of the flume

%floodplain geometry
B_floodplane=1; %width of the floodplain
h_floodplane=0.3; %increase in elevation of the floodplane

%groyne field geometry
h_groyne_field=0.1; %height of the groyne field at the point where the transverse sloping faces intersect [m]
s_n1_groyne_field=atan(1/25); %angle of the crest of the groyne field (positive if down when going from the floodplain to the main channel) [rad]
% s_n1_groyne_field=0; %angle of the crest of the groyne field (positive if down when going from the floodplain to the main channel) [rad]
s_n2_groyne_field=atan(1/3); %angle of the side face of the groyne field (continuation of the crest until main channel) (positive if down when going from the floodplain to the main channel) [rad]
    
%groyn geometry
L_between_groynes=6; %distance from the upstream end of one groyn to the upstream end of the next groynes [m]
L_groyn=(0.66-0.06)/0.11*0.21; %distance from the upstream end of a groyn to the downstream end of the same groyn [m]
B_groyn=2; %width of a groyn
% B_groyn=2.5; %width of a groyn
h_groyn=0.11+h_groyne_field; %increase in elevation of a groyn
s_us_groyn=atan(11/30); %angle of the upstream face of a groyn (positive always) [rad]
L_top_groyn=0.06; %distance from the upstream end of the crest of a groyn to the dowsntream end of the crest of the same groyn [m]
s_n1_groyn=atan(1/100); %angle of the crest of the groyn (positive if down when going from the floodplain to the main channel) [rad]
s_n2_groyn=atan(1/3); %angle of the side face of the groyn (continuation of the crest until main channel) (positive if down when going from the floodplain to the main channel) [rad]
L_to_downstream_end=35; %position after which no groyn is added [m]
% L_to_first_groyn=-(L_groyn-L_top_groyn)/2; %distance from the upstream end to the upstream part of the first groyn [m]
L_to_first_groyn=40; %distance from the upstream end to the upstream part of the first groyn [m]

%numerical discretization (flg.output_type=1 and plotting)
dx=0.2;
dy=0.2;
% dx=0.03;
% dy=0.04;
% dx=0.01;
% dy=0.01;
    %whole flume
% x0=0;
% xf=L_flume;
% y0=0;
% yf=B_flume;
x0=dx/2;
xf=L_flume-dx/2;
y0=dy/2;
yf=B_flume-dy/2;
    %one groyn
% x0=L_to_first_groyn;
% xf=L_to_first_groyn+L_groyn;
% y0=B_floodplane;
% yf=B_floodplane+B_groyn;

%path to NC (flg.output_type=2)
path_grd='c:\Users\chavarri\temporal\201030_groynes_lab_exp\00_input_files\01_grd\180x25_net.nc';
path_grd_new='c:\Users\chavarri\temporal\201030_groynes_lab_exp\00_input_files\01_grd\180x25_2_net.nc';

%% CALC

geom=v2struct(L_flume,B_flume,s_flume,B_floodplane,h_floodplane,L_to_first_groyn,L_between_groynes,L_groyn,B_groyn,h_groyn,s_us_groyn,L_top_groyn,s_n1_groyn,s_n2_groyn,L_to_downstream_end,s_n1_groyne_field,s_n2_groyne_field,h_groyne_field);

switch flg.output_type
    case 1
        %corners
        x_v=x0:dx:xf;
        y_v=y0:dy:yf;

        nx=numel(x_v);
        ny=numel(y_v);

        [x_m,y_m]=meshgrid(x_v,y_v);
        x_m=x_m';
        y_m=y_m';
        
        %preallocate
        z_m=NaN(nx,ny);
        for kx=1:nx
            for ky=1:ny
                z_m(kx,ky)=add_geom(geom,x_m(kx,ky),y_m(kx,ky));
            end %ky
        end %ky
        
        %write
        if flg.write

            z_m_wr=[-999*ones(nx,1),-z_m,-999*ones(nx,1)];
            z_m_wr=[-999*ones(1,ny+2);z_m_wr;-999*ones(1,ny+2)];
            fID=fopen('dep_gf0_s1em3.dep','w');
            str_wrt_1=repmat('%0.7E ',1,size(z_m_wr,1));
            str_wrt=sprintf('%s \n',str_wrt_1);

            for ky=1:size(z_m_wr,2)
                fprintf(fID,str_wrt,z_m_wr(:,ky));
            end %ky

            fclose(fID);

        end
    case 2
        % grd_info=ncinfo(path_grd);
        
        copyfile(path_grd,path_grd_new);
        
        mesh2d_node_x=ncread(path_grd,'mesh2d_node_x');
        mesh2d_node_y=ncread(path_grd,'mesh2d_node_y');
        
        %preallocate
        mesh2d_node_z=NaN(size(mesh2d_node_x));
        ne=numel(mesh2d_node_x);
        for ke=1:ne
            mesh2d_node_z(ke)=add_geom(geom,mesh2d_node_x(ke),mesh2d_node_y(ke));
        end %ky
        
        %write
        if flg.write
            ncwrite(path_grd_new,'mesh2d_node_z',mesh2d_node_z);
        end
        
        %for plotting
        %ad-hoc knowing how the grid looks like
        nx=L_flume/dx;
        ny=B_flume/dy;
        
        x_m=reshape(mesh2d_node_x,ny+1,nx+1)';
        y_m=reshape(mesh2d_node_y,ny+1,nx+1)';
        z_m=reshape(mesh2d_node_z,ny+1,nx+1)';
end

% BEGIN DEBUG
% profile off
% profile viewer
% END DEBUG

%% PLOT full flume

if 1
    
figure
hold on
surf(x_m,y_m,z_m,'edgecolor','none')
han.cbar=colorbar;
han.cbar.Label.String='elevation [m]';
xlabel('streamwise coordinate [m]')
ylabel('transversal coordinate [m]')
% axis equal

end

%% PLOT 1 groyn

if 0
    
figure
hold on
surf(x_m,y_m,z_m,'edgecolor','none')
colorbar
% xlim([0,0.1])
xlim([11,13])
% ylim([1,3.2])
view([-180,0])
% axis equal

end

%% NICE PLOTS

if flg.plot
    
fig_full_flume(x_m,y_m,z_m,[0,L_flume],[0,B_flume],[0,h_floodplane],[150,30],1)
fig_full_flume(x_m,y_m,z_m,[L_to_first_groyn+L_between_groynes-0.1,L_to_first_groyn+L_between_groynes+L_groyn+0.1],[B_floodplane,B_floodplane+B_groyn],[0,h_floodplane],[150,30],2)
fig_full_flume(x_m,y_m,z_m,[0,L_flume],[0,B_flume],[0,h_floodplane],[90,0],3)
    
end