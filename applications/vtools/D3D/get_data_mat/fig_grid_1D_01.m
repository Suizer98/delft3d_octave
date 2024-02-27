%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18455 $
%$Date: 2022-10-17 13:25:35 +0800 (Mon, 17 Oct 2022) $
%$Author: chavarri $
%$Id: fig_grid_1D_01.m 18455 2022-10-17 05:25:35Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/fig_grid_1D_01.m $
%
%plot of 1D 

function fig_grid_1D_01(in_p)

%% DEFAULTS

if isfield(in_p,'fig_visible')==0
    in_p.fig_visible=1;
end
if isfield(in_p,'fig_print')==0
    in_p.fig_print=0;
end
if isfield(in_p,'fname')==0
    in_p.fname='fig';
end
if isfield(in_p,'fig_size')==0
    in_p.fig_size=[0,0,14,14]; %(1+sqrt(5)/2)
end
if isfield(in_p,'fig_overwrite')==0
    in_p.fig_overwrite=1;
end
if isfield(in_p,'fid_log')==0
    in_p.fid_log=NaN;
end
if isfield(in_p,'lan')==0
    in_p.lan='en';
end
if isfield(in_p,'axis_equal')==0
    in_p.axis_equal=1;
end
if isfield(in_p,'plot_nodes')==0
    in_p.plot_nodes=1;
end
if isfield(in_p,'plot_branches')==0
    in_p.plot_branches=1;
end
if isfield(in_p,'plot_sat')==0
    in_p.plot_sat=0;
end

v2struct(in_p)

%%

% nb=numel(network1d_branch_order);
nb=size(gridInfo.branch_id,1); %first is 0
nn=size(gridInfo.net_node_id,1);
% network1d_node_id=network1d_node_id';
geom_cs=[1;cumsum(gridInfo.node_count_geom)];

%% default

kr=1; kc=1;
lims.y(kr,kc,1:2)=ylims;
lims.x(kr,kc,1:2)=xlims;

%% FIGURE

%square option
npr=1; %number of plot rows
npc=1; %number of plot columns
axis_m=allcomb(1:1:npr,1:1:npc);

%some of them
% axis_m=[1,1;2,1;2,2];

na=size(axis_m,1);

%figure input
prnt.filename=fname;
prnt.size=fig_size; %slide=[0,0,25.4,19.05]; slide16:9=[0,0,33.867,19.05] tex=[0,0,11.6,..]; deltares=[0,0,14.5,22]
marg.mt=1.0; %top margin [cm]
marg.mb=1.5; %bottom margin [cm]
marg.mr=0.5; %right margin [cm]
marg.ml=1.5; %left margin [cm]
marg.sh=1.0; %horizontal spacing [cm]
marg.sv=0.0; %vertical spacing [cm]

% prop.ms1=10; 
% prop.lw=1;
prop.fs=10;
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
% cbar.sfig=[1,1]; 
% cbar.displacement=[0.0,0,0,0]; 
% cbar.location='eastoutside';
% cbar.label='fraction of gravel [-]';

%text
% aux.sfig=11;
% texti.(sprintf('sfig%d',aux.sfig)).pos=[0.015,0.5e-3;0.03,-0.5e-3;0.005,-1e-3];
% texti.(sprintf('sfig%d',aux.sfig)).tex={'1','2','a'};
% texti.(sprintf('sfig%d',aux.sfig)).clr={prop.color(1,:),prop.color(2,:),'k'};

%limits


% brewermap('demo')
% cmap=brewermap(3,'set1');
% 
% if isvector(z)
%     cmap=[0,0,0];
% else
%     nsz=numel(SZ);
%     zdim=size(z);
%     idx_d2=zdim(find(zdim~=nsz));
%     cmap=brewermap(idx_d2,'RdYlBu');    
% end
% set(groot,'defaultAxesColorOrder',cmap)

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
if axis_equal
axis(han.sfig(kpr,kpc),'equal')
end
han.sfig(kpr,kpc).XLim=lims.x;
han.sfig(kpr,kpc).YLim=lims.y;
% han.sfig(kpr,kpc).ZLim=lims.z;
han.sfig(kpr,kpc).XLabel.String='x coordinate [m]';
han.sfig(kpr,kpc).YLabel.String='y coordinate [m]';
% % han.sfig(kpr,kpc).XTickLabel='';
% % han.sfig(kpr,kpc).YTickLabel='';
% % han.sfig(kpr,kpc).XTick=[];  
% % han.sfig(kpr,kpc).YTick=[];  
% % han.sfig(kpr,kpc).XScale='log';
% % han.sfig(kpr,kpc).YScale='log';
% han.sfig(kpr,kpc).Title.String='c';
% if flg.plot_unitx==1
%     xlabel(han.sfig(kpr,kpc),'x-coordinate [m]');
% else
%     error('Hard-code the label')
% end
% ylabel(han.sfig(kpr,kpc),in.zlabel);
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
% % if flg.which_p~=8
% if flg.addtitle
% title(han.sfig(kpr,kpc),sprintf('time = %5.2f %s',time_r,aux_t))
% end

% switch flg.plot_unitt
%     case 1
%         title(han.sfig(kpr,kpc),sprintf('time = %5.2f s, y [m]=%4.2f',time_r,YZ(1)))    
%     case 1/3600 %conversion from s
%         title(han.sfig(kpr,kpc),sprintf('time = %5.2f h, y [m]=%4.2f',time_r,YZ(1)))
%     case 1/3600/24
%         title(han.sfig(kpr,kpc),sprintf('time = %5.2f days, y [m]=%4.2f',time_r,YZ(1)))
%     case 1/3600/24/365
%         title(han.sfig(kpr,kpc),sprintf('time = %5.2f years, y [m]=%4.2f',time_r,YZ(1)))
%     otherwise
%         
%         error('Hard-code the label')
% end
    

%plots
% han.p=scatter(in.mesh1d_x_node,in.mesh1d_y_node,10,'k','filled');
if plot_sat
    addTiles(flg.tiles_path)
end
han.p=scatter(gridInfo.x_geom,gridInfo.y_geom,10,'r','filled','parent',han.sfig(kr,kc));

%nodes
if plot_nodes
for kn=1:nn
    han.p=scatter(gridInfo.x_net_node(kn),gridInfo.y_net_node(kn),20,'sr','filled','parent',han.sfig(kr,kc));
    str_p=strrep(gridInfo.net_node_id(kn,:),'_','\_');
    text(gridInfo.x_net_node(kn),gridInfo.y_net_node(kn),str_p,'Rotation',45,'Fontsize',10,'color','c','parent',han.sfig(kr,kc))    
end
end

%branches
if plot_branches
for kb=1:nb
    idx_br=gridInfo.branch==kb;
    mean_x=mean(gridInfo.x_geom(geom_cs(kb):geom_cs(kb+1)));
    mean_y=mean(gridInfo.y_geom(geom_cs(kb):geom_cs(kb+1)));
    str_p=strrep(gridInfo.branch_id(kb,:),'_','\_');
    text(mean_x,mean_y,str_p,'Rotation',0,'Fontsize',10,'color','k','parent',han.sfig(kr,kc))    
end
end

%mesh1d
plot(gridInfo.x_node,gridInfo.y_node,'*','parent',han.sfig(kr,kc))

% light
% material dull
% han.surf1.FaceLighting='gouraud';

%water level
% han.wl=plot(XZ(2:end),S1,'color','b','linewidth',2);

%colormap
% colormap(han.sfig(1,1),cmap);

%view
% view(han.sfig(1,1),[0,90]);

%caxis
% caxis(han.sfig(1,1),lims.f);

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
%     han.leg(1,1)=legend(han.leg,{'hyperbolic','elliptic'},'location','northeast');
% end

% if ~isvector(z)
%         nf=numel(in.kf);
%        if nf>1
%            str_leg=cell(nf,1);
%            for kf=1:nf
%             str_leg{kf,1}=sprintf('frac. %02d',in.kf(kf));
%            end
%            han.leg(1,1)=legend(han.p,str_leg,'location','eastoutside');
%        end
% end
% switch flg.which_v
%     case {8}
%        nf=numel(in.kf);
%        if nf>1
%            str_leg=cell(nf,1);
%            for kf=1:nf
%             str_leg{kf,1}=sprintf('frac. %02d',in.kf(kf));
%            end
%            han.leg(1,1)=legend(han.p,str_leg,'location','eastoutside');
%        end
% end

%colorbar
% han.cbar=colorbar('peer',han.sfig(1,1),'location','northoutside');
% set(get(han.cbar,'Ylabel'),'String','gravel content [-]')
% set(get(han.cbar,'Ylabel'),'String','mean grain size [m]')
% set(get(han.cbar,'Ylabel'),'String','flow depth [m]')

% pos.sfig=han.sfig(cbar.sfig(1),cbar.sfig(2)).Position;
% han.cbar=colorbar(han.sfig(cbar.sfig(1),cbar.sfig(2)),'location',cbar.location);
% pos.cbar=han.cbar.Position;
% han.cbar.Position=pos.cbar+cbar.displacement;
% han.sfig(cbar.sfig(1),cbar.sfig(2)).Position=pos.sfig;
% han.cbar.Label.String=cbar.label;

% pos.(sprintf('sfig%d',cbar.sfig))=han.(sprintf('sfig%d',cbar.sfig)).Position;
% han.cbar=colorbar(han.(sprintf('sfig%d',cbar.sfig)),'location',cbar.location);
% pos.cbar=han.cbar.Position;
% han.cbar.Position=pos.cbar+cbar.displacement;
% han.(sprintf('sfig%d',cbar.sfig)).Position=pos.(sprintf('sfig%d',cbar.sfig));
% han.cbar.Label.String=cbar.label;

%general
set(findall(han.fig,'-property','FontSize'),'FontSize',prop.fs)
% set(findall(han.fig,'-property','FontName'),'FontName',prop.fn) %!!! attention, there is a bug in Matlab and this is not enforced. It is necessary to change it in the '.eps' to 'ArialMT' (check in a .pdf)
han.fig.Renderer='painters';

%return to default
set(groot,'defaultAxesColorOrder','default') %reset the color order to the default value

%% PRINT

if any(fig_print==1)
    print(han.fig,strcat(prnt.filename,'.png'),'-dpng','-r600');
    messageOut(NaN,sprintf('Figure printed: %s',strcat(prnt.filename,'.png'))) 
end
if any(fig_print==2)
    savefig(han.fig,strcat(prnt.filename,'.fig'))
    messageOut(NaN,sprintf('Figure printed: %s',strcat(prnt.filename,'.fig'))) 
end
if any(fig_print==3)
    print(han.fig,strcat(prnt.filename,'.eps'),'-depsc2','-loose','-cmyk')
    messageOut(NaN,sprintf('Figure printed: %s',strcat(prnt.filename,'.eps'))) 
end
if any(fig_print==4)
    print(han.fig,strcat(prnt.filename,'.jpg'),'-djpeg','-r300')
    messageOut(NaN,sprintf('Figure printed: %s',strcat(prnt.filename,'.jpg'))) 
end
if any(ismember(fig_print,[1,2,3,4]))
close(han.fig);

end

