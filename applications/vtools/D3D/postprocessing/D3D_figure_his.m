%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17190 $
%$Date: 2021-04-15 16:24:15 +0800 (Thu, 15 Apr 2021) $
%$Author: chavarri $
%$Id: D3D_figure_his.m 17190 2021-04-15 08:24:15Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/postprocessing/D3D_figure_his.m $
%
%plot of 1D volume fraction 2

function D3D_figure_his(simdef,in)

%% RENAME in

simdef=D3D_figure_defaults(simdef);

flg=simdef.flg;

%%

% faces=in.faces;
z_var=in.z.*flg.plot_unitz;
time_p=in.time_r.*flg.plot_unitt;

%station or area
where_is_var=1;
if flg.which_v==21
    where_is_var=2;
end
        
%% data rework

%limits
    %defaults
lims.x=[min(time_p),max(time_p)];
lims.y=[min(z_var(:)),max(z_var(:))];
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

%% FIGURE

%figure input
% prnt.filename=sprintf('his_%d',flg.which_v); %time is already in the plotting unitsm here we recover [s]
prnt.filename=sprintf('his_%d_%s',flg.which_v,in.station); %time is already in the plotting unitsm here we recover [s]
prnt.size=flg.prnt_size;
npr=1; %number of plot rows
npc=1; %number of plot columns
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


% brewermap('demo')
% cmap=brewermap(3,'set1');
% cmap=brewermap(100,'RdYlBu');

%figure initialize
han.fig=figure('name',prnt.filename,'visible',flg.fig_visible);
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
han.sfig(kpr,kpc).XLim=lims.x;
han.sfig(kpr,kpc).YLim=lims.y;
% han.sfig(kpr,kpc).ZLim=lims.z;
% han.sfig(kpr,kpc).XLabel.String='streamwise position x-x_0 [m]';
% han.sfig(kpr,kpc).YLabel.String={'elevation [m]'};
% % han.sfig(kpr,kpc).XTickLabel='';
% % han.sfig(kpr,kpc).YTickLabel='';
% % han.sfig(kpr,kpc).XTick=[];  
% % han.sfig(kpr,kpc).YTick=[];  
% % han.sfig(kpr,kpc).XScale='log';
han.sfig(kpr,kpc).YScale=flg.YScale;
switch where_is_var
    case 1
        han.sfig(kpr,kpc).Title.String=strtrim(sprintf('%s',strrep(in.station,'_','\_')));
    case 2
%         han.sfig(kpr,kpc).Title.String=sprintf('%s',strrep(in.dump_area,'_','\_'));
end

switch flg.plot_unitt
    case 1 %conversion from s 
        aux_t='s';
    case 1/3600 %conversion from s
        aux_t='h';
    case 1/3600/24
        aux_t='days';
    case 1/3600/24/365
        aux_t='years';
end
xlabel(han.sfig(kpr,kpc),sprintf('time [%s]',aux_t));
% xlabel('time')
%
% switch flg.plot_unity
%     case 1
%         aux_s='[m]';
%     otherwise
%         error('Hard-code the label')
% end
% ylabel(han.sfig(kpr,kpc),sprintf('crosswise position %s',aux_s));
ylabel(han.sfig(kpr,kpc),in.zlabel);
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
plot(time_p,z_var,'parent',han.sfig(kr,kc))


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
switch where_is_var
    case 2
    han.leg(1,1)=legend(strrep(in.dump_area,'_','\_'));
end
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
% if flg.which_s==2
%     clabel(han.p1,han.surf1,'FontSize',7)
% end
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

