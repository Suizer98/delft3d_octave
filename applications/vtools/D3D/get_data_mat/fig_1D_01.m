%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18411 $
%$Date: 2022-10-06 20:18:03 +0800 (Thu, 06 Oct 2022) $
%$Author: chavarri $
%$Id: fig_1D_01.m 18411 2022-10-06 12:18:03Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/fig_1D_01.m $
%
%MATLAB BUGS:
%   -The command to change font name does not work. It does not give error
%   but it does not change the font [151102].
%   -When getting and setting position of ylabels, axis, colorbars,
%   etcetera, if the figure is open in screensize the result is different
%   than if it is not. Moreover, you may need to put a pause(1) after getting
%   positions and setting them [151105].
%   -When something is out of the axes (the box delimited by 'Position')
%   (e.g. text outside the axes), the continuous colors (e.g. from a plot
%   like 'area') have weird lines in .eps.
%   -FontName if interpreter LaTeX: check post 114116
%	-When adding text in duration axis, scatter interprets days while surf interprets hours

% in_p.fig_print=; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
% in_p.fname=;
% in_p.fig_visible=;

function fig_1D_01(in_p)

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
    in_p.fig_size=[0,0,14,14];
end
if isfield(in_p,'xlims')==0 || isnan(in_p.xlims(1))
    in_p.xlims=[min(in_p.s),max(in_p.s)];
end
if isfield(in_p,'ylims')==0 || isnan(in_p.ylims(1))
    bol_p=in_p.s>=in_p.xlims(1) & in_p.s<=in_p.xlims(2);
    in_p.ylims=[min(min(in_p.val(bol_p,:),[],'omitnan'),[],'omitnan'),max(max(in_p.val(bol_p,:),[],'omitnan'),[],'omitnan')];
end
if isnan(in_p.ylims(1))
    in_p.ylims=[0,0];
end
in_p.ylims=in_p.ylims+[-1,1].*abs(mean(in_p.ylims)/1000)+10.*[-eps,eps];
if isfield(in_p,'lan')==0
    in_p.lan='en';
end
if isfield(in_p,'fid_log')==0
    in_p.fid_log=NaN;
end
in_p.plot_gen_struct=0;
if isfield(in_p,'gen_struct')
%     in_p.plot_gen_struct=1;
    in_p.plot_all_struct=1;
    in_p.all_struct=in_p.gen_struct;
    in_p.all_struct=struct_assign_val(in_p.all_struct,'type',1);
end
in_p.plot_all_struct=0;
if isfield(in_p,'all_struct')
    in_p.plot_all_struct=1;
end
if isfield(in_p,'is_diff')==0
    in_p.is_diff=0;
end
in_p.plot_val0=0;
if isfield(in_p,'val0')
    in_p.plot_val0=1;
end
if isfield(in_p,'plot_mea')==0 
    if isfield(in_p,'val_mea')
        in_p.plot_mea=true;
    else
        in_p.plot_mea=false;
    end
end
if isfield(in_p,'is_std')==0
    in_p.is_std=0;
end
if isfield(in_p,'do_title')==0
    if isfield(in_p,'tim')==0
        in_p.do_title=0;
    else
        in_p.do_title=1;
    end
end
if isfield(in_p,'xlab_str')==0
    in_p.xlab_str='dist_prof';
end
if isfield(in_p,'xlab_un')==0
    in_p.xlab_un=1;
end
if isfield(in_p,'mt')==0
    in_p.mt=1;
end
if isfield(in_p,'mb')==0
    in_p.mb=1.5;
end
if isfield(in_p,'mr')==0
    in_p.mr=0.5;
end
if isfield(in_p,'ml')==0
    in_p.ml=1.5;
end
if isfield(in_p,'do_marker')==0
    in_p.do_marker=0;
end
if isfield(in_p,'leg_loc')==0
    in_p.leg_loc='eastoutside';
end
if isfield(in_p,'fig_fs')==0
    in_p.fig_fs=10;
end
if isfield(in_p,'leg_move')==0
    in_p.leg_move=NaN;
end
if isfield(in_p,'markersize')==0
    in_p.markersize=10;
end
if isfield(in_p,'plot_pillars_name')==0
    in_p.plot_pillars_name=0;
end

v2struct(in_p)

%% check if printing
print_fig=check_print_figure(in_p);
if ~print_fig
    return
end

%% SIZE

%figure input
prnt.filename=fname;
prnt.size=fig_size; %slide=[0,0,25.4,19.05]; slide16:9=[0,0,33.867,19.05] tex=[0,0,11.6,..]; deltares=[0,0,14.5,22]
npr=1; %number of plot rows
npc=1; %number of plot columns
marg.mt=mt; %top margin [cm]
marg.mb=mb; %bottom margin [cm]
marg.mr=mr; %right margin [cm]
marg.ml=ml; %left margin [cm]
marg.sh=1.0; %horizontal spacing [cm]
marg.sv=0.0; %vertical spacing [cm]

%% PLOT PROPERTIES 

prop.ms1=10; 
prop.mf1='g'; 
prop.mt1='s'; 
prop.lw1=1;
prop.ls1='-'; %'-','--',':','-.'
prop.m1='none'; % 'o', '+', '*', ...
prop.fs=fig_fs;
prop.fn='Helvetica';
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
set(groot,'defaultAxesColorOrder',prop.color)
% set(groot,'defaultAxesColorOrder','default') %reset the color order to the default value

%set interpreter to Latex (to have bold text use \bfseries{})
% set(groot,'defaultTextInterpreter','Latex'); 
% set(groot,'defaultAxesTickLabelInterpreter','Latex'); 
% set(groot,'defaultLegendInterpreter','Latex');
set(groot,'defaultTextInterpreter','tex'); 
set(groot,'defaultAxesTickLabelInterpreter','tex'); 
set(groot,'defaultLegendInterpreter','tex');

%% COLORBAR AND COLORMAP
% kr=1; kc=1;
% cbar(kr,kc).displacement=[0.0,0,0,0]; 
% cbar(kr,kc).location='northoutside';
% cbar(kr,kc).label='surface fraction content of fine sediment [-]';

% brewermap('demo')
nv=size(val,2); 
if nv<=9
    cmap=brewermap(nv,'set1');
else
    cmap=jet(nv);
end
if do_marker
    mk=repmat({'o','+','*','.','x','s','d','^','v','>','<','p','h'},1,nv); %we are for sure safe...
else
    mk=repmat({'none'},1,nv);
end
%center around 0
% ncmap=1000;
% cmap1=brewermap(ncmap,'RdYlGn');
% cmap=flipud([flipud(cmap1(1:ncmap/2-ncmap*0.05,:));flipud(cmap1(ncmap/2+ncmap*0.05:end,:))]);

%cutted centre colormap
% ncmap=100;
% cmap=flipud(brewermap(ncmap,'RdBu'));
% fact=0.1; %percentage of values to remove from the center
% cmap=[cmap(1:(ncmap-round(fact*ncmap))/2,:);cmap((ncmap+round(fact*ncmap))/2:end,:)];
% %compressed colormap
% ncmap=100;
% cmap=flipud(brewermap(ncmap,'RdYlBu'));
% p1=0.5; %fraction of cmap compressed in p2
% p2=0.7; %fraction of
% np1=round(ncmap*p1);
% np2=round(ncmap*p2);
% x=1:1:ncmap;
% x1=1:1:np1; %x vector
% x2=1:1:ncmap-np1; %x vector
% y1=cmap(1:np1,:); 
% y2=cmap(np1+1:end,:); 
% xq1=linspace(1,np1,np2); %query vector 1
% xq2=linspace(1,ncmap-np1,ncmap-np2); %query vector 2
% vq1=interp1(x1,y1,xq1);
% vq2=interp1(x2,y2,xq2);
% cmap=[vq1;vq2];
% %gauss colormap
% ncmap=100;
% cmap=flipud(brewermap(ncmap,'RdYlBu'));
% x=linspace(0,1,ncmap);
% xs=normcdf(x,0.5,0.25);
% plot(x,xs)
% cmap2=interp1(x,cmap,xs);
% cmap=cmap2;
% %merge 2 colormaps at a specific value. cmap1 spans between [clim_l(1),aux_cmap_change] and cmap 2 between [aux_cmap_change,clim_l(2)]
% ncmap=100; %total number of colors (will be rounded)
% aux_cmap_change=1; %value in which the colormaps change. 
% aux_cmap1_n=round(ncmap*(aux_cmap_change-clim_l(1))/(clim_l(2)-clim_l(1)));
% aux_cmap2_n=round(ncmap*(clim_l(2)-aux_cmap_change)/(clim_l(2)-clim_l(1)));
% cmap1=flipud(brewermap(aux_cmap1_n,'Reds'));
% cmap2=brewermap(aux_cmap2_n,'Greens');
% cmap=[cmap1;cmap2];

%% TEXT

%     %irregulra
% kr=1; kc=1;
% texti.sfig(kr,kc).pos=[0.015,0.5e-3;0.03,-0.5e-3;0.005,-1e-3];
% texti.sfig(kr,kc).tex={'1','2','a'};
% texti.sfig(kr,kc).clr={prop.color(1,:),prop.color(2,:),'k'};
% texti.sfig(kr,kc).ref={'ul'};
% texti.sfig(kr,kc).fwe={'bold','normal'};
% texti.sfig(kr,kc).rot=[0,90];
% 
%     %regular
% text_str={'a','b','c';'d','e','f';'g','h','i';'j','k','l';'m','n','o'};
% text_str={'a','b';'c','d';'e','f';'g','h'};
% for kr=1:npr
%     for kc=1:npc
% % kr=1; kc=1;
% texti.sfig(kr,kc).pos=[0.5,0.5];
% texti.sfig(kr,kc).tex={text_str{kr,kc}}; %#ok
% texti.sfig(kr,kc).clr={'k'};
% texti.sfig(kr,kc).ref={'lr'};
% texti.sfig(kr,kc).fwe={'bold'};
% texti.sfig(kr,kc).rot=[0,90];
%     end
% end
%     %regular more than one
% text_str={'Hir.','Hir.','Hir.';'Ia','Ia','Ia';'Ib','Ib','Ib';'IIa','IIa','IIa';'IIb','IIb','IIb';'IIc','IIc','IIc';'IId','IId','IId'};
% text_str2={'a','b','c';'d','e','f';'g','h','i';'j','k','l';'m','n','o';'p','q','r';'s','t','u'};
% for kr=1:npr
%     for kc=1:npc
% % kr=1; kc=1;
% texti.sfig(kr,kc).pos=[0.5,0.5;0.5,0.5];
% texti.sfig(kr,kc).tex={text_str{kr,kc},text_str2{kr,kc}}; %#ok
% texti.sfig(kr,kc).clr={'k','k'};
% texti.sfig(kr,kc).ref={'ll','lr'};
% texti.sfig(kr,kc).fwe={'bold','normal'};
% texti.sfig(kr,kc).rot=[0,90];
%     end
% end

%% LABELS AND LIMITS

kr=1; kc=1;
lims.y(kr,kc,1:2)=ylims;
lims.x(kr,kc,1:2)=xlims;
% lims.c(kr,kc,1:2)=clims;
if ~isempty(xlab_str)
    xlabels{kr,kc}=labels4all(xlab_str,xlab_un,lan);
else
    xlabels{kr,kc}='';
end
[lab,str_var,str_un,str_diff,str_background,str_std]=labels4all(lab_str,1,lan);
if is_diff
    ylabels{kr,kc}=str_diff;
elseif is_std
    ylabels{kr,kc}=str_std;
else
    ylabels{kr,kc}=lab;
end
% ylabels{kr,kc}=labels4all('dist_mouth',1,lan);
% lims_d.x(kr,kc,1:2)=seconds([3*3600+20*60,6*3600+40*60]); %duration
% lims_d.x(kr,kc,1:2)=[datenum(1998,1,1),datenum(2000,01,01)]; %time


%% FIGURE INITIALIZATION

han.fig=figure('name',prnt.filename);
set(han.fig,'paperunits','centimeters','paperposition',prnt.size,'visible',fig_visible)
set(han.fig,'units','normalized','outerposition',[0,0,1,1]) %full monitor 1
% set(han.fig,'units','normalized','outerposition',[-1,0,1,1]) %full monitor 2
[mt,mb,mr,ml,sh,sv]=pre_subaxis(han.fig,marg.mt,marg.mb,marg.mr,marg.ml,marg.sh,marg.sv);

%subplots initialize
    %if regular
for kr=1:npr
    for kc=1:npc
        han.sfig(kr,kc)=subaxis(npr,npc,kc,kr,1,1,'mt',mt,'mb',mb,'mr',mr,'ml',ml,'sv',sv,'sh',sh);
    end
end
    %if irregular
% han.sfig(1,1)=subaxis(npr,npc,1,1,1,1,'mt',mt,'mb',mb,'mr',mr,'ml',ml,'sv',sv,'sh',sh);

    %add axis on top
% kr=1; kc=2;
% % pos.sfig=[0.25,0.6,0.25,0.25]; % position of first axes    
% pos.sfig=han.sfig(1,1).Position; % position of first axes    
% han.sfig(kr,kc)=axes('units','normalized','Position',pos.sfig,'XAxisLocation','bottom','YAxisLocation','right','Color','none');
%% HOLD
for kr=1:npr
    for kc=1:npc
        hold(han.sfig(kr,kc),'on')
    end
end
%% MAP TILES

% kr=1; kc=1;
% OPT.xlim=x_lims;
% OPT.ylim=y_lims;
% OPT.epsg_in=28992; %WGS'84 / google earth
% OPT.epsg_out=28992; %Amersfoort
% OPT.tzl=tzl; %zoom
% OPT.save_tiles=false;
% OPT.path_save='C:\Users\chavarri\checkouts\riv\earth_tiles\';
% % OPT.path_tiles=fullfile(pwd,'earth_tiles'); 
% OPT.map_type=3;%map type
% OPT.han_ax=han.sfig(kr,kc);
% 
% plotMapTiles(OPT);

%% EHY

% kr=1; kc=1;
% set(han.fig,'CurrentAxes',han.sfig(kr,kc))
% %data_map.grid=EHY_getGridInfo(filename,{'face_nodes_xy'});
% EHY_plotMapModelData(data_map.grid,data_map.val,'t',1); 

%% PLOT

kr=1; kc=1;    
for kv=1:nv
han.p(kr,kc,kv)=plot(s,val(:,kv),'parent',han.sfig(kr,kc),'color',cmap(kv,:),'linewidth',prop.lw1,'linestyle',prop.ls1,'marker',mk{kv},'markersize',markersize);
end
if isfield(in_p,'leg_str')
    str_sim=leg_str;
else
    if nv==1
        str_sim={labels4all('sim',1,lan)};
    else
        str_sim={sprintf('%d',kv)}; %change to runid?
    end
end
if plot_all_struct
% plot(([[gen_struct.rkm];[gen_struct.rkm]]),repmat(ylims,numel([gen_struct.rkm]),1)','--','color',[0.6,0.6,0.6],'parent',han.sfig(kr,kc))
    %better loop to control color and whether to plot them or not in the future
    nas=numel([all_struct.rkm]);
    cmap_alls=[0.4,0.4,0.4;0.8,0.8,0.8];
    for kas=1:nas
        plot([all_struct(kas).rkm;all_struct(kas).rkm],ylims,'--','color',cmap_alls(all_struct(kas).type,:),'parent',han.sfig(kr,kc))
    end
end
if plot_mea
%     han.p(kr,kc,2)=plot(mea_etab_p.rkm,mea_etab_p.etab,'parent',han.sfig(kr,kc),'color',prop.color(2,:),'linewidth',prop.lw1,'linestyle',prop.ls1,'marker',prop.m1);
    nfv=numel(han.p(kr,kc,:));
    han.p(kr,kc,nfv+1)=plot(s_mea,val_mea,'parent',han.sfig(kr,kc),'color','k','linewidth',prop.lw1,'linestyle',prop.ls1,'marker',prop.m1,'markersize',markersize);
    if isfield(in_p,'leg_mea')==0
        str_leg={str_sim{:},labels4all('mea',1,lan)}; %check concatenation is right
    else
        str_leg={str_sim{:},in_p.leg_mea};
    end
else
    str_leg=str_sim;
end
if plot_val0
    nfv=numel(han.p(kr,kc,:));
    han.p(kr,kc,nfv+1)=plot(s,val0,'parent',han.sfig(kr,kc),'color','k','linewidth',prop.lw1,'linestyle','--','marker',prop.m1,'markersize',markersize);
    str_leg={str_leg{:},'initial'};
end
% han.sfig(kr,kc).ColorOrderIndex=1; %reset color index
% han.p(kr,kc,1)=plot(x,y,'parent',han.sfig(kr,kc),'color',prop.color(1,:),'linewidth',prop.lw1);
% han.p(kr,kc,1).Color(4)=0.2; %transparency of plot
% han.p(kr,kc,1)=scatter(data_2f(data_2f(:,3)==0,1),data_2f(data_2f(:,3)==0,2),prop.ms1,prop.mt1,'filled','parent',han.sfig(kr,kc),'markerfacecolor',prop.mf1);
% surf(x,y,z,c,'parent',han.sfig(kr,kc),'edgecolor','none')

%% PROPERTIES

    %sub11
kr=1; kc=1;   
hold(han.sfig(kr,kc),'on')
grid(han.sfig(kr,kc),'on')
% axis(han.sfig(kr,kc),'equal')
han.sfig(kr,kc).Box='on';
han.sfig(kr,kc).XLim=lims.x(kr,kc,:);
han.sfig(kr,kc).YLim=lims.y(kr,kc,:);
han.sfig(kr,kc).XLabel.String=xlabels{kr,kc};
han.sfig(kr,kc).YLabel.String=ylabels{kr,kc};
% han.sfig(kr,kc).XTickLabel='';
% han.sfig(kr,kc).YTickLabel='';
% han.sfig(kr,kc).XTick=[];  
% han.sfig(kr,kc).YTick=[];  
% han.sfig(kr,kc).XScale='log';
% han.sfig(kr,kc).YScale='log';
if do_title
    if numel(tim)==1
        han.sfig(kr,kc).Title.String=datestr(tim,'dd-mm-yyyy HH:MM');
    elseif numel(tim)==2
        han.sfig(kr,kc).Title.String=sprintf('%s - %s',datestr(tim(1),'dd-mm-yyyy HH:MM'),datestr(tim(2),'dd-mm-yyyy HH:MM'));
    else
        error('not sure how more than 2 will look like')
    end
end
% han.sfig(kr,kc).XColor='r';
% han.sfig(kr,kc).YColor='k';

%duration ticks
% xtickformat(han.sfig(kr,kc),'hh:mm')
% han.sfig(kr,kc).XLim=lims_d.x(kr,kc,:);
% han.sfig(kr,kc).XTick=hours([4,6]);

%colormap
% kr=1; kc=2;
% view(han.sfig(kr,kc),[0,90]);
% colormap(han.sfig(kr,kc),cmap);
% if ~isnan(lims.c(kr,kc,1:1))
% caxis(han.sfig(kr,kc),lims.c(kr,kc,1:2));
% end

%% ADD TEXT
if plot_all_struct

for kas=1:nas
    if all_struct(kas).type==2 && ~plot_pillars_name; continue; end
    structure_name=strrep(all_struct(kas).name,'ST_',''); %dangerours... better to clean using rwsnames
    idx=strfind(structure_name,'=');
    structure_name(1:idx)='';
    text(all_struct(kas).rkm,ylims(1),structure_name,'Rotation',90)
end
end

    %if irregular
% which_pos_text=[1,1;2,1;3,1;3,2];
% nsf=size(which_pos_text);
% for ksf=1:nsf
%     kr=which_pos_text(ksf,1);
%     kc=which_pos_text(ksf,2);
%         ntxt=numel(texti.sfig(kr,kc).tex);
%         for ktx=1:ntxt
%             %if the specified values are in cm 
%             aux.pos=cm2ax(texti.sfig(kr,kc).pos(ktx,:),han.fig,han.sfig(kr,kc),'reference',texti.sfig(kr,kc).ref{ktx});
% %             text(texti.sfig(kr,kc).pos(1,1),texti.sfig(kr,kc).pos(1,2),texti.sfig(kr,kc).tex{ktx},'parent',han.sfig(kr,kc),'color',texti.sfig(kr,kc).clr{ktx},'fontweight','bold')
%             text(aux.pos(1,1),aux.pos(1,2),texti.sfig(kr,kc).tex{ktx},'parent',han.sfig(kr,kc),'color',texti.sfig(kr,kc).clr{ktx},'fontweight',texti.sfig(kr,kc).fwe{ktx},'rotation',texti.sfig(kr,kc).rot(ktx))
%         end
% end
%     %if regular
% for kr=1:npr
%     for kc=1:npc
%         ntxt=numel(texti.sfig(kr,kc).tex);
%         for ktx=1:ntxt
%             %if the specified values are in cm 
%             aux.pos=cm2ax(texti.sfig(kr,kc).pos(ktx,:),han.fig,han.sfig(kr,kc),'reference',texti.sfig(kr,kc).ref{ktx});
% %             text(texti.sfig(kr,kc).pos(1,1),texti.sfig(kr,kc).pos(1,2),texti.sfig(kr,kc).tex{ktx},'parent',han.sfig(kr,kc),'color',texti.sfig(kr,kc).clr{ktx},'fontweight','bold')
%             text(aux.pos(1,1),aux.pos(1,2),texti.sfig(kr,kc).tex{ktx},'parent',han.sfig(kr,kc),'color',texti.sfig(kr,kc).clr{ktx},'fontweight',texti.sfig(kr,kc).fwe{ktx},'rotation',texti.sfig(kr,kc).rot(ktx))
%         end
%     end
% end

%% LEGEND

kr=1; kc=1;
pos.sfig=han.sfig(kr,kc).Position;
% %han.leg=legend(han.leg,{'hyperbolic','elliptic'},'location','northoutside','orientation','vertical');
% %han.leg(kr,kc)=legend(han.sfig(kr,kc),reshape(han.p(kr,kc,1:2),1,2),{'\tau<1','\tau>1'},'location','south');
if plot_mea || nv>1
    han.leg(kr,kc)=legend(han.sfig(kr,kc),reshape(han.p(kr,kc,:),1,numel(han.p(kr,kc,:))),str_leg,'location',leg_loc);
    pos.leg=han.leg(kr,kc).Position;
end
if ~isnan(leg_move(1))
han.leg.Position=pos.leg+leg_move;
han.sfig(kr,kc).Position=pos.sfig;
end

%% COLORBAR

% kr=1; kc=1;
% pos.sfig=han.sfig(kr,kc).Position;
% han.cbar=colorbar(han.sfig(kr,kc),'location',cbar(kr,kc).location);
% pos.cbar=han.cbar.Position;
% han.cbar.Position=pos.cbar+cbar(kr,kc).displacement;
% han.sfig(kr,kc).Position=pos.sfig;
% han.cbar.Label.String=cbar(kr,kc).label;
% 	%set the marks of the colorbar according to your vector, the number of lines and colors of the colormap is np1 (e.g. 20). The colorbar limit is [1,np1].
% aux2=fliplr(d1_r./La_v); %we have plotted the colors in the other direction, so here we can flip it
% v2p=[1,5,11,15,np1];
% han.cbar.Ticks=v2p;
% aux3=aux2(v2p);
% aux_str=cell(1,numel(v2p));
% for ka=1:numel(v2p)
%     aux_str{ka}=sprintf('%5.3f',aux3(ka));
% end
% han.cbar.TickLabels=aux_str;

%% GENERAL
set(findall(han.fig,'-property','FontSize'),'FontSize',prop.fs)
set(findall(han.fig,'-property','FontName'),'FontName',prop.fn) %!!! attention, there is a bug in Matlab and this is not enforced. It is necessary to change it in the '.eps' to 'ArialMT' (check in a .pdf)
% han.fig.Renderer='painters';

%% PRINT

if any(fig_print==1)
    print(han.fig,strcat(prnt.filename,'.png'),'-dpng','-r300');
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

end %function

