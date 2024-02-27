%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: D3D_figure_2DV_z_u.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/postprocessing/D3D_figure_2DV_z_u.m $
%
%plot of 1D volume fraction 2

function D3D_figure_2DV_z_u(simdef,in)

%% RENAME in

flg=simdef.flg;

ucx_s 		=in.ucx_s;
ucy_s		=in.ucy_s;
ucz_s		=in.ucz_s;
uc_norm		=in.uc_norm;
x_face_s	=in.x_face_s;
y_face_s	=in.y_face_s;
z_face_s	=in.z_face_s;

time_r=in.time_r.*flg.plot_unitt;

np=numel(x_face_s);
nl=size(z_face_s,1);

% switch flg.elliptic
%     case 1
%         ell=in.eigen_ell_p;
%     case 2
%         ell=in.HIRCHK;
% end

% if isfield(in,'a')
%     lims=in.lims;
% end

if isfield(flg.prop,'fs')==0
    flg.prop.fs=12;
end
%% data rework

uc_lim=[min(uc_norm(:)),max(uc_norm(:))];

%limits
    %defaults
lims.x=[min(x_face_s),max(x_face_s)];
lims.y=[min(y_face_s),max(y_face_s)];
lims.z=[min(z_face_s(:)),max(z_face_s(:))];
% lims.f=uc_lim;
% lims.f=[min(ucz_s(:)),max(ucz_s(:))];
abs_max=max(abs(min(ucz_s(:))),abs(max(ucz_s(:))));
lims.f=[-abs_max,abs_max];


if isfield(flg,'lims')
    if isfield(flg.lims,'x')
        lims.x=flg.lims.x;
    end
    if isfield(flg.lims,'y')
        lims.y=flg.lims.y;
    end 
    if isfield(flg.lims,'z')
        lims.z=flg.lims.z;
    end
    if isfield(flg.lims,'f')
        lims.f=flg.lims.f;
    end
else
    
end

%% FIGURE

%figure input
prnt.filename=sprintf('vz_%010.0f',time_r./flg.plot_unitt); %time is already in the plotting unitsm here we recover [s]
prnt.size=[0,0,25.4,19.05]; %slide=[0,0,25.4,19.05]
npr=1; %number of plot rows
npc=1; %number of plot columns
marg.mt=2.0; %top margin [cm]
marg.mb=2.0; %bottom margin [cm]
marg.mr=4.5; %right margin [cm]
marg.ml=2.0; %left margin [cm]
marg.sh=1.0; %horizontal spacing [cm]
marg.sv=0.0; %vertical spacing [cm]

% prop.ms1=10; 
% prop.lw=1;
% prop.fs=12;
% prop.fn='Helvetica';
% prop.color=[... %>= matlab 2014b default
%  0.0000    0.4470    0.7410;... %blue
%  0.8500    0.3250    0.0980;... %red
%  0.9290    0.6940    0.1250;... %yellow
%  0.4940    0.1840    0.5560;... %purple
%  0.4660    0.6740    0.1880;... %green
%  0.3010    0.7450    0.9330;... %cyan
%  0.6350    0.0780    0.1840];   %brown
% prop.color=[... %<  matlab 2014b default
%  0.0000    0.0000    1.0000;... %blue
%  0.0000    0.5000    0.0000;... %green
%  1.0000    0.0000    0.0000;... %red
%  0.0000    0.7500    0.7500;... %cyan
%  0.7500    0.0000    0.7500;... %purple
%  0.7500    0.7500    0.0000;... %ocre
%  0.2500    0.2500    0.2500];   %grey
% set(groot,'defaultAxesColorOrder',prop.color)

%colorbar
cbar.sfig=[1,1]; 
cbar.displacement=[0.1,0,0,0]; 
cbar.location='eastoutside';
cbar.label='vertical velocity [m/s]';

%text
% aux.sfig=11;
% texti.(sprintf('sfig%d',aux.sfig)).pos=[0.015,0.5e-3;0.03,-0.5e-3;0.005,-1e-3];
% texti.(sprintf('sfig%d',aux.sfig)).tex={'1','2','a'};
% texti.(sprintf('sfig%d',aux.sfig)).clr={prop.color(1,:),prop.color(2,:),'k'};

%limits


% brewermap('demo')
% cmap=brewermap(3,'set1');
ncmap=100;
cmap=brewermap(ncmap,'RdYlBu');

%figure initialize
han.fig=figure('name',prnt.filename);
set(han.fig,'paperunits','centimeters','paperposition',prnt.size)
set(han.fig,'units','normalized','outerposition',[0,0,1,1])
[mt,mb,mr,ml,sh,sv]=pre_subaxis(han.fig,marg.mt,marg.mb,marg.mr,marg.ml,marg.sh,marg.sv);

%subplots initialize
han.sfig(1,1)=subaxis(npr,npc,1,1,1,1,'mt',mt,'mb',mb,'mr',mr,'ml',ml,'sv',sv,'sh',sh);

%properties
    %sub11
kpr=1; kpc=1;    
hold(han.sfig(kpr,kpc),'on')
han.sfig(kpr,kpc).Box='on';
if flg.equal_axis
axis(han.sfig(kpr,kpc),'equal')
end
% han.sfig(kpr,kpc).XLim=lims.x;
% han.sfig(kpr,kpc).YLim=lims.y;
% han.sfig(kpr,kpc).ZLim=lims.z;
% han.sfig(kpr,kpc).XLabel.String='streamwise position x-x_0 [m]';
% han.sfig(kpr,kpc).YLabel.String={'elevation [m]'};
% % han.sfig(kpr,kpc).XTickLabel='';
% % han.sfig(kpr,kpc).YTickLabel='';
% % han.sfig(kpr,kpc).XTick=[];  
% % han.sfig(kpr,kpc).YTick=[];  
% % han.sfig(kpr,kpc).XScale='log';
% % han.sfig(kpr,kpc).YScale='log';
% han.sfig(kpr,kpc).Title.String='c';
if flg.plot_unitx==1
    xlabel(han.sfig(kpr,kpc),'x position [m]');
else
    error('Hard-code the label')
end
ylabel(han.sfig(kpr,kpc),'y position [m]');
zlabel(han.sfig(kpr,kpc),'elevation [m]');
% xlim(han.sfig(kpr,kpc),lims.x)
% ylim(han.sfig(kpr,kpc),lims.y)
% zlim(han.sfig(kpr,kpc),lims.y)
switch flg.plot_unitt
    case 1
        title(han.sfig(kpr,kpc),sprintf('time [s] = %5.2f',time_r))
    case 1/3600 %conversion from s
        title(han.sfig(kpr,kpc),sprintf('time [h] = %5.2f',time_r))
    otherwise
        error('Hard-code the label')
    % title(han.sfig(kpr,kpc),sprintf('%d years',round(time/3600/24/365)))  
end
    
%plots
if flg.which_s==3 || flg.which_s==5
for kl=1:nl
    for kp=1:np
        switch flg.which_s 
            case 3
                scatter3(x_face_s(kp),y_face_s(kp),z_face_s(kl,kp),20,ucz_s(kl,kp),'filled')        
            case 5
                text(x_face_s(kp),y_face_s(kp),z_face_s(kl,kp),sprintf('%0.2e',ucz_s(kl,kp)))
        end        
    end
end
end

switch flg.which_s 
    case 1
%         x_all_v=reshape(repmat(x_face_s,nl,1),[],1);
%         y_all_v=reshape(repmat(y_face_s,nl,1),[],1);
%         z_all_v=reshape(       z_face_s      ,[],1);
%         tri=delaunay(x_all_v,y_all_v,z_all_v);
%         tri=delaunay(y_all_v,z_all_v);
%         trisurf(tri,x_face_s(kp),y_face_s(kp),z_face_s(kp),ucz_s(kl,kp));
        dist=sqrt((x_face_s-x_face_s(1)).^2+(y_face_s-y_face_s(1)).^2);
        dist_m=repmat(dist,nl,1);

        surf(dist_m,z_face_s,ucz_s,'edgecolor','none')
        ylabel('elevation [m]')
        xlabel('crosswise position [m]')
%         han.sfig(kpr,kpc).XLim=lims.y;
%         han.sfig(kpr,kpc).YLim=lims.z;
%         warning('this only works because x is constant.project points on a plane to generalize')
end

% switch flg.elliptic
%     case 1
%         han.el=scatter(XZ(2:end),repmat(lims.y(1),1,ncx),20,ell,'fill');
%             %for legend
%         han.leg(1)=scatter(-1000,-1000,20,'k','fill');
%         han.leg(2)=scatter(-1000,-1000,20,'m','fill');
%     case 2
% %         patch('Faces',faces','Vertices',[x_node,y_node,lims.z(1)*ones(size(y_node))],'FaceVertexCData',ell,'FaceColor','flat','EdgeColor','none')
%         idx_p=ell==0;
%         cmap_ell=repmat([1,0,0],size(faces,2),1); %all red
%         cmap_ell(idx_p,:)=repmat([0,1,0],sum(idx_p),1);
%         patch('Faces',faces','Vertices',[x_node,y_node,lims.z(1)*ones(size(y_node))],'FaceVertexCData',cmap_ell,'FaceColor','flat','EdgeColor','none')
% %         idx_p=ell==1;
% %         han.p1=scatter3(XZ(idx_p),YZ(idx_p),lims.z(1)*ones(size(XZ(idx_p))),10,'r');
%                     %for legend
%         han.leg(1)=scatter(-1000,-1000,20,'g','fill');
%         han.leg(2)=scatter(-1000,-1000,20,'r','fill');
% end

% han.surf1.EdgeColor='none';
% 
% light
% material dull
% han.surf1.FaceLighting='gouraud';

%water level
% han.wl=plot(XZ(2:end),S1,'color','b','linewidth',2);

%colormap
colormap(han.sfig(1,1),cmap);

%view
if isfield(flg,'view')
view(han.sfig(1,1),flg.view);
end

%caxis
caxis(han.sfig(1,1),lims.f+[-eps,+eps]); %eps it to avoid error when values are equal

%text
% aux.sfig=12; 
% text(texti.(sprintf('sfig%d',aux.sfig)).pos(1),texti.(sprintf('sfig%d',aux.sfig)).pos(2),texti.(sprintf('sfig%d',aux.sfig)).tex,'parent',han.(sprintf('sfig%d',aux.sfig)),'color',texti.(sprintf('sfig%d',aux.sfig)).clr)
%     %if regular
% for kr=1:npr
%     for kc=1:npc
%         aux.sfig=str2double(sprintf('%d%d',kr,kc));
%         ntxt=numel(texti.(sprintf('sfig%d',aux.sfig)).tex);
%         for ktx=1:ntxt
%             text(texti.(sprintf('sfig%d',aux.sfig)).pos(ktx,1),texti.(sprintf('sfig%d',aux.sfig)).pos(ktx,2),texti.(sprintf('sfig%d',aux.sfig)).tex{ktx},'parent',han.(sprintf('sfig%d',aux.sfig)),'color',texti.(sprintf('sfig%d',aux.sfig)).clr{ktx},'fontweight','bold')
%         end
%     end
% end

%legend
% if flg.elliptic~=0
%     han.leg(1,1)=legend(han.leg,{'well-posed','ill-posed'},'location','northeast');
% end

%colorbar
% han.cbar=colorbar('peer',han.sfig(1,1),'location','eastoutside');
% set(get(han.cbar,'Ylabel'),'String','gravel content [-]')
% set(get(han.cbar,'Ylabel'),'String',in.zlabel)

pos.sfig=han.sfig(cbar.sfig(1),cbar.sfig(2)).Position;
han.cbar=colorbar(han.sfig(cbar.sfig(1),cbar.sfig(2)),'location',cbar.location);
pos.cbar=han.cbar.Position;
han.cbar.Position=pos.cbar+cbar.displacement;
han.sfig(cbar.sfig(1),cbar.sfig(2)).Position=pos.sfig;
han.cbar.Label.String=cbar.label;

%general
set(findall(han.fig,'-property','FontSize'),'FontSize',flg.prop.fs)
% set(findall(han.fig,'-property','FontName'),'FontName',prop.fn) %!!! attention, there is a bug in Matlab and this is not enforced. It is necessary to change it in the '.eps' to 'ArialMT' (check in a .pdf)
han.fig.Renderer='painters';

%print
D3D_print_fig(simdef,prnt,han)


