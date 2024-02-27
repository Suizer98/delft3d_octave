%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18361 $
%$Date: 2022-09-14 13:43:17 +0800 (Wed, 14 Sep 2022) $
%$Author: chavarri $
%$Id: D3D_figure_domain_2D.m 18361 2022-09-14 05:43:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/postprocessing/D3D_figure_domain_2D.m $
%
%plot of 1D 

function D3D_figure_domain_2D(simdef,in)

%% RENAME in

% file=simdef.file;
flg=simdef.flg;
v2struct(in);

% nface=size(mesh2d_face_nodes,2);

% mean_mesh2d_face_x_bnd=mean(mesh2d_face_x_bnd,1);
% mean_mesh2d_face_y_bnd=mean(mesh2d_face_y_bnd,1);

%%

if isfield(flg,'plot_unitx')==0
    flg.plot_unitx=1;
end

if isfield(flg,'plot_unity')==0
    flg.plot_unity=1;
end

if isfield(flg,'print')==0
    flg.print=0;
end

if isfield(flg,'equal_axis')==0
    flg.equal_axis=1;
end

%%
% XZ=network1d_geom_x*flg.plot_unitx;
% YZ=network1d_geom_y.*flg.plot_unity;
% SZ=in.SZ.*flg.plot_unitx;
% z=in.z.*flg.plot_unitz;
% sub=in.sub;
% cvar=in.cvar;
% time_r=in.time_r.*flg.plot_unitt;
% nx=in.nx;
% nl=in.nl;

%% data rework


%defaults 
% lims.x=[min(XZ)-eps,max(XZ)+eps];
% lims.y=[min(YZ)-eps,max(YZ)+eps];

%limits
if isfield(flg,'lims')
    if isfield(flg.lims,'x')
        lims.x=flg.lims.x;
    end
    if isfield(flg.lims,'y')
        lims.y=flg.lims.y;
    end 
%     if isfield(flg.lims,'z')
%         lims.z=flg.lims.z;
%     end
%     if isfield(flg.lims,'f')
%         lims.f=flg.lims.f;
%     end
end

if isfield(flg,'prnt_size')==0
    flg.prnt_size=[0,0,25.4,19.05];
end

if isfield(flg,'addtitle')==0
    flg.addtitle=1;
end

%% FIGURE

%figure input
prnt.filename=sprintf('network'); %time is already in the plotting unitsm here we recover [s]
prnt.size=flg.prnt_size;
npr=1; %number of plot rows
npc=1; %number of plot columns
marg.mt=0.5; %top margin [cm]
marg.mb=1.5; %bottom margin [cm]
marg.mr=0.5; %right margin [cm]
marg.ml=2.0; %left margin [cm]
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
if flg.equal_axis
axis(han.sfig(kpr,kpc),'equal')
end
% han.sfig(kpr,kpc).XLim=lims.x;
% han.sfig(kpr,kpc).YLim=lims.y;
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
han.node=scatter(mesh2d_node_x,mesh2d_node_y,10,'k','*');
han.face=scatter(mesh2d_face_x,mesh2d_face_y,10,'r','o');
% han.face=scatter(mean_mesh2d_face_x_bnd,mean_mesh2d_face_y_bnd,10,'g','x');
han.face_line=plot(mesh2d_face_x_bnd,mesh2d_face_y_bnd,'k');

% EHY
% data_map.grid=EHY_getGridInfo(fname_grd,{'grid'});
% plot(data_map.grid.grid(:,1),data_map.grid.grid(:,2),'color','k')

% %nodes
% for kn=1:nn
%     han.p=scatter(network1d_node_x(kn),network1d_node_y(kn),10,'sr','filled');
%     str_p=strrep(network1d_node_id(kn,:),'_',' ');
%     text(network1d_node_x(kn),network1d_node_y(kn),str_p,'Rotation',45,'Fontsize',10,'color','r')    
% end
% 
% %branches
% for kb=1:nb
%     idx_br=mesh1d_node_branch==kb;
%     mean_x=mean(network1d_geom_x(geom_cs(kb):geom_cs(kb+1)));
%     mean_y=mean(network1d_geom_y(geom_cs(kb):geom_cs(kb+1)));
%     str_p=strrep(network1d_branch_id(kb,:),'_',' ');
%     text(mean_x,mean_y,str_p,'Rotation',0,'Fontsize',10,'color','k')    
% end


% han.surf1.EdgeColor='none';

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
legend([han.node,han.face,han.face_line(1)],{'mesh2d\_node\_(x,y) (cell corner)','mesh2d\_face\_(x,y) (cell center)','face (cell edge)'})
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

%print
D3D_print_fig(simdef,prnt,han)

