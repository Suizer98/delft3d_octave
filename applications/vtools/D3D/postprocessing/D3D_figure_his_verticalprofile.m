%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: D3D_figure_his_verticalprofile.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/postprocessing/D3D_figure_his_verticalprofile.m $
%
%plot of 1D volume fraction 2

function D3D_figure_his_verticalprofile(simdef,in)

%% RENAME in

flg=simdef.flg;
% prop=flg.prop;

%% defaults

if isfield(flg.prop,'edgecolor')==0
    flg.prop.edgecolor='k'; %edge color in surf plot
end

if isfield(flg,'cbar')==0
        flg.cbar.displacement=[0,0,0,0];
else
    if isfield(flg.cbar,'displacement')==0
        
    end
end

if isfield(flg,'marg')==0
    simdef.flg.marg.mt=2.5; %top margin [cm]
    simdef.flg.marg.mb=1.5; %bottom margin [cm]
    simdef.flg.marg.mr=2.5; %right margin [cm]
    simdef.flg.marg.ml=2.0; %left margin [cm]
    simdef.flg.marg.sh=1.0; %horizontal spacing [cm]
    simdef.flg.marg.sv=0.0; %vertical spacing [cm]
end

if isfield(flg.prop,'fs')==0
    flg.prop.fs=12;
end

%%
zcoordinate_c=in.zcoordinate_c;
% y_node=in.y_node;
% x_face=in.x_face;
% y_face=in.y_face;

% faces=in.faces;
z_var=in.z.*flg.plot_unitz;
% cvar=in.cvar;
time_r=in.time_r.*flg.plot_unitt;
% switch flg.elliptic
%     case 1
%         ell=in.eigen_ell_p;
%     case 2
%         ell=in.HIRCHK;
% end

% if isfield(in,'a')
%     lims=in.lims;
% end

%% data rework

%limits
    %defaults
% lims.x=[min(x_node),max(x_node)];
% lims.y=[min(y_node),max(y_node)];
% lims.z=[min(z_var),max(z_var)];
% lims.f=[min(min(cvar(:,1))),max(max(cvar(:,1)))];
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
%     if isfield(flg.lims,'f')
%         lims.f=flg.lims.f;
%     end
end

%% REWORK

%interpolate bed level data from cell center to vertices
% F=scatteredInterpolant(x_face,y_face,bl);
% bl_nodes=F(x_node,y_node);

%% FIGURE

%figure input
prnt.filename=sprintf('verticalprofile_%d_%013.3f',flg.which_v,time_r./flg.plot_unitt); %time is already in the plotting unitsm here we recover [s]
if isfield(flg,'prnt_size')==0
    flg.prnt_size=[0,0,25.4,19.05];
end
prnt.size=flg.prnt_size;
npr=1; %number of plot rows
npc=3; %number of plot columns

marg.mt=flg.marg.mt; %top margin [cm]
marg.mb=flg.marg.mb; %bottom margin [cm]
marg.mr=flg.marg.mr; %right margin [cm]
marg.ml=flg.marg.ml; %left margin [cm]
marg.sh=flg.marg.sh; %horizontal spacing [cm]
marg.sv=flg.marg.sv; %vertical spacing [cm]

% prop.ms1=10; 
% prop.lw=1;
% prop.fs=12;
% prop.fn='Helvetica';
prop.color=[... %>= matlab 2014b default
 0.0000    0.4470    0.7410;... %blue
 0.8500    0.3250    0.0980;... %red
 0.9290    0.6940    0.1250;... %yellow
 0.4940    0.1840    0.5560;... %purple
 0.4660    0.6740    0.1880;... %green
 0.3010    0.7450    0.9330;... %cyan
 0.6350    0.0780    0.1840];   %brown
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
%colorbar
% cbar.sfig=[1,1]; 
% cbar.displacement=flg.cbar.displacement; 
% cbar.location='northoutside';
% switch flg.which_v
%     case 1
%         cbar.label='bed elevation [m]';
%     case 2
%         cbar.label='flow depth [m]';
%     case 3
%         switch flg.plot_unitz
%             case 1
%                 cbar.label='mean grain size at the bed surface [m]';
%             case 1000
%                 cbar.label='mean grain size at the bed surface [mm]';
%             otherwise
%                 error('ehem...')
%         end
%     case 4
%         switch flg.plot_unitz
%             case 1
%                 cbar.label='mean grain size at the top substrate [m]';
%             case 1000
%                 cbar.label='mean grain size at the top substrate [mm]';
%             otherwise
%                 error('ehem...')
%         end
%     case 6
%         cbar.label='secondary flow intensity [m/s]';
%     case 8
% 
% end

% cbar.label=in.zlabel;
%text
% aux.sfig=11;
% texti.(sprintf('sfig%d',aux.sfig)).pos=[0.015,0.5e-3;0.03,-0.5e-3;0.005,-1e-3];
% texti.(sprintf('sfig%d',aux.sfig)).tex={'1','2','a'};
% texti.(sprintf('sfig%d',aux.sfig)).clr={prop.color(1,:),prop.color(2,:),'k'};

%limits


% brewermap('demo')
% cmap=brewermap(3,'set1');
% cmap=brewermap(100,'RdYlBu');

%figure initialize
han.fig=figure('name',prnt.filename);
set(han.fig,'paperunits','centimeters','paperposition',prnt.size)
set(han.fig,'units','normalized','outerposition',[0,0,1,1])
[mt,mb,mr,ml,sh,sv]=pre_subaxis(han.fig,marg.mt,marg.mb,marg.mr,marg.ml,marg.sh,marg.sv);

%subplots initialize
for kr=1:npr
    for kc=1:npc
        han.sfig(kr,kc)=subaxis(npr,npc,kc,kr,1,1,'mt',mt,'mb',mb,'mr',mr,'ml',ml,'sv',sv,'sh',sh);
    end
end

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
han.sfig(kpr,kpc).Title.String='x direction';
switch flg.plot_unitx
    case 1
        aux_s='[m/s]';
    otherwise
        error('Hard-code the label')
end
xlabel(han.sfig(kpr,kpc),sprintf('velocity %s',aux_s));
%
switch flg.plot_unity
    case 1
        aux_s='[m]';
    otherwise
        error('Hard-code the label')
end
% ylabel(han.sfig(kpr,kpc),sprintf('crosswise position %s',aux_s));
ylabel(han.sfig(kpr,kpc),sprintf('elevation %s',aux_s));
% zlabel(han.sfig(kpr,kpc),'elevation [m]');
% xlim(han.sfig(kpr,kpc),lims.x)
% ylim(han.sfig(kpr,kpc),lims.y)
% zlim(han.sfig(kpr,kpc),lims.y)
% switch flg.plot_unitt
%     case 1 %conversion from s 
%         aux_t='s';
%     case 1/3600 %conversion from s
%         aux_t='h';
%     case 1/3600/24
%         aux_t='days';
% end
% % title(han.sfig(kpr,kpc),sprintf('%s time = %5.2f %s',aux_s,time_r,aux_t))
% if flg.which_p~=8
% title(han.sfig(kpr,kpc),sprintf('time = %5.2f %s',time_r,aux_t))
% end
    
kpr=1; kpc=2;    
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
han.sfig(kpr,kpc).Title.String='y direction';
switch flg.plot_unitx
    case 1
        aux_s='[m/s]';
    otherwise
        error('Hard-code the label')
end
xlabel(han.sfig(kpr,kpc),sprintf('velocity %s',aux_s));
%
switch flg.plot_unity
    case 1
        aux_s='[m]';
    otherwise
        error('Hard-code the label')
end
% ylabel(han.sfig(kpr,kpc),sprintf('crosswise position %s',aux_s));
ylabel(han.sfig(kpr,kpc),sprintf('elevation %s',aux_s));
% zlabel(han.sfig(kpr,kpc),'elevation [m]');
% xlim(han.sfig(kpr,kpc),lims.x)
% ylim(han.sfig(kpr,kpc),lims.y)
% zlim(han.sfig(kpr,kpc),lims.y)
% switch flg.plot_unitt
%     case 1 %conversion from s 
%         aux_t='s';
%     case 1/3600 %conversion from s
%         aux_t='h';
%     case 1/3600/24
%         aux_t='days';
% end
% % title(han.sfig(kpr,kpc),sprintf('%s time = %5.2f %s',aux_s,time_r,aux_t))
% if flg.which_p~=8
% title(han.sfig(kpr,kpc),sprintf('time = %5.2f %s',time_r,aux_t))
% end

kpr=1; kpc=3;    
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
han.sfig(kpr,kpc).Title.String='z direction';
switch flg.plot_unitx
    case 1
        aux_s='[m/s]';
    otherwise
        error('Hard-code the label')
end
xlabel(han.sfig(kpr,kpc),sprintf('velocity %s',aux_s));
%
switch flg.plot_unity
    case 1
        aux_s='[m]';
    otherwise
        error('Hard-code the label')
end
% ylabel(han.sfig(kpr,kpc),sprintf('crosswise position %s',aux_s));
ylabel(han.sfig(kpr,kpc),sprintf('elevation %s',aux_s));
% zlabel(han.sfig(kpr,kpc),'elevation [m]');
% xlim(han.sfig(kpr,kpc),lims.x)
% ylim(han.sfig(kpr,kpc),lims.y)
% zlim(han.sfig(kpr,kpc),lims.y)
% switch flg.plot_unitt
%     case 1 %conversion from s 
%         aux_t='s';
%     case 1/3600 %conversion from s
%         aux_t='h';
%     case 1/3600/24
%         aux_t='days';
% end
% % title(han.sfig(kpr,kpc),sprintf('%s time = %5.2f %s',aux_s,time_r,aux_t))
% if flg.which_p~=8
% title(han.sfig(kpr,kpc),sprintf('time = %5.2f %s',time_r,aux_t))
% end

%plots
kr=1; kc=1;
plot(z_var(:,1),zcoordinate_c,'parent',han.sfig(kr,kc))

kr=1; kc=2;
plot(z_var(:,2),zcoordinate_c,'parent',han.sfig(kr,kc))

kr=1; kc=3;
plot(z_var(:,3),zcoordinate_c,'parent',han.sfig(kr,kc))

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
% colormap(han.sfig(1,1),cmap);

%view
% if isfield(flg,'view')
% view(han.sfig(1,1),flg.view);
% end

%caxis
% caxis(han.sfig(1,1),lims.z+[-eps,+eps]); %eps it to avoid error when values are equal

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
% switch flg.which_v
%     case {1,2,3,4,6,8}
% pos.sfig=han.sfig(cbar.sfig(1),cbar.sfig(2)).Position;
% han.cbar=colorbar(han.sfig(cbar.sfig(1),cbar.sfig(2)),'location',cbar.location);
% pos.cbar=han.cbar.Position;
% han.cbar.Position=pos.cbar+cbar.displacement;
% han.sfig(cbar.sfig(1),cbar.sfig(2)).Position=pos.sfig;
% han.cbar.Label.String=cbar.label;
% end

%general
set(findall(han.fig,'-property','FontSize'),'FontSize',flg.prop.fs)
if flg.which_s==2
    clabel(han.p1,han.surf1,'FontSize',7)
end
% set(findall(han.fig,'-property','FontName'),'FontName',prop.fn) %!!! attention, there is a bug in Matlab and this is not enforced. It is necessary to change it in the '.eps' to 'ArialMT' (check in a .pdf)
han.fig.Renderer='painters';
% han.fig.Renderer='opengl';

% if isnan(flg.save_name)
%     str_save=fullfile(file.dire_sim,'figures',prnt.filename);
% else
%     str_save=flg.save_name;
% end

%linked figure with faces indices
% if simdef.flg.fig_faceindices==1
%     D3D_figure_faceindices(han,in)
% end

%print
D3D_print_fig(simdef,prnt,han)

