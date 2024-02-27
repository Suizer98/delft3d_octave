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

function fig_twoD(in_2D,eig_r,eig_i,kwx_v,kwy_v)

%% DEFAULT

if isfield(in_2D,'qs_anl')==0
    in_2D.qs_anl=0;
end
if isfield(in_2D,'fig')==0
    in_2D.fig.dummy=NaN;
end
if isfield(in_2D.fig,'fig_visible')==0
    in_2D.fig.fig_visible=true;
end
if isfield(in_2D.fig,'fig_print')==0
    in_2D.fig.fig_print=false;
end
if isfield(in_2D.fig,'fig_name')==0
    in_2D.fig.fig_name='domain';
end
if isfield(in_2D.fig,'print_size')==0
    in_2D.fig.print_size=[0,0,17,10];
end

v2struct(in_2D) %better to keep structure below
v2struct(fig)

%%

np1=numel(kwx_v);
np2=numel(kwy_v);
[nc,ne]=size(eig_r);
lwx_v=2*pi./kwx_v;
lwy_v=2*pi./kwy_v;

    %%  growth rate
% eig_i(eig_i==0)=NaN;
eig_i(abs(eig_i)<1e-16)=NaN;
max_gr=max(eig_i,[],2,'omitnan');

%positive growth rate
gr_p=max_gr>0;
max_grp=NaN(nc,1);
max_grp(gr_p)=max_gr(gr_p);

%matrix form
[xm_k,ym_k]=meshgrid(kwx_v,kwy_v);
[xm_l,ym_l]=meshgrid(lwx_v,lwy_v);
max_gr_m=reshape(max_gr,np1,np2)';
max_grp_m=reshape(max_grp,np1,np2)';
% min_cl_m=reshape(min_cl,np,np)';

%qs
if qs_anl==1
eig_i_qs(eig_i_qs==0)=NaN;
max_gr_qs=max(eig_i_qs,[],2,'omitnan');

max_gr_qs_m=reshape(max_gr_qs,np1,np2)';
end

    %% celerity
%take the celerity of the eigenvalues related to exner-hirano that we identify as the smallest
eig_r(abs(eig_r)<1e-16)=NaN;
[m_s,p_s]=sort(abs(eig_r),2);
eig_r_morph=NaN(size(eig_r,1),ne-3);
for kc=1:nc
    eig_r_morph(kc,:)=eig_r(kc,p_s(kc,1:ne-3));
end

%matrix form
max_cl_m=NaN(np1,np2,ne-3);
for ke=1:ne-3
    max_cl_m(:,:,ke)=reshape(eig_r_morph(:,ke),np1,np2)'./xm_k;
end

%% data rework
% close all

%max location
[max_idx_sc_val,max_idx_sc]=max(max_gr_m(:));
[max_idx_sc_x,max_idx_sc_y]=ind2sub(size(max_gr_m),max_idx_sc);


ks=1;
%%
%figure input
% prnt.filename=sprintf('dom_%s',str_p{1,ks});
prnt.filename=fig_name;
prnt.size=print_size; %slide=[0,0,25.4,19.05]; tex=[0,0,11.6,..]
npr=1; %number of plot rows
npc=2; %number of plot columns
marg.mt=1.0; %top margin [cm]
marg.mb=1.5; %bottom margin [cm]
marg.mr=0.5; %right margin [cm]
marg.ml=1.5; %left margin [cm]
marg.sh=1.5; %horizontal spacing [cm]
marg.sv=0.0; %vertical spacing [cm]

prop.ms1=20; 
prop.lw1=1;
prop.ls1='-';
prop.ls2='--';
prop.fs=10;
prop.fn='Helvetica';
prop.markertype1='o';
prop.markertype2='s';
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
% prop.color=[... %<  matlab 2014b default
%  0.0000    0.0000    0.0000;... %black
%  0.0000    0.0000    0.0000;... %black
%  1.0000    0.0000    0.0000;... %red
%  0.0000    0.7500    0.7500;... %cyan
%  0.7500    0.0000    0.7500;... %purple
%  0.7500    0.7500    0.0000;... %ocre
%  0.2500    0.2500    0.2500];   %grey

% set(groot,'defaultAxesColorOrder',prop.color)
% set(groot,'defaultAxesColorOrder','default') %reset the color order to the default value

%set interpreter to Latex (to have bold text use \bfseries{})
% set(groot,'defaultTextInterpreter','Latex'); 
% set(groot,'defaultAxesTickLabelInterpreter','Latex'); 
% set(groot,'defaultLegendInterpreter','Latex');
set(groot,'defaultTextInterpreter','tex'); 
set(groot,'defaultAxesTickLabelInterpreter','tex'); 
set(groot,'defaultLegendInterpreter','tex');

%colorbar
kr=1; kc=2;
cbar(kr,kc).displacement=[0.0,0,0,0]; 
cbar(kr,kc).location='northoutside';
cbar(kr,kc).label='minimum diffusion coefficient [m^2/s]';

%text
    %irregulra
% kr=1; kc=1;
% texti.sfig(kr,kc).pos=[0.015,0.5e-3;0.03,-0.5e-3;0.005,-1e-3];
% texti.sfig(kr,kc).tex={'1','2','a'};
% texti.sfig(kr,kc).clr={prop.color(1,:),prop.color(2,:),'k'};
% texti.sfig(kr,kc).ref={'ul'};
% texti.sfig(kr,kc).fwe={'bold','normal'};
% texti.sfig(kr,kc).rot=[0,90];

    %regular
text_str={'a','b','c';'d','e','f';'g','h','i';'j','k','l';'m','n','o'};
% text_str={'a','b';'c','d';'e','f';'g','h'};
for kr=1:npr
    for kc=1:npc
% kr=1; kc=1;
texti.sfig(kr,kc).pos=[0.5,0.5];
texti.sfig(kr,kc).tex={text_str{kr,kc}}; %#ok
texti.sfig(kr,kc).clr={'k'};
texti.sfig(kr,kc).ref={'lr'};
texti.sfig(kr,kc).fwe={'bold'};
texti.sfig(kr,kc).rot=[0,0];
    end
end
    %regular more than one
% text_str={'a','b','c';'d','e','f';'g','h','i';'j','k','l';'m','n','o';'p','q','r';'s','t','u'};
% % text_str1={'S','U','Hir.';'Ia','Ia','Ia';'Ib','Ib','Ib';'IIa','IIa','IIa';'IIb','IIb','IIb';'IIc','IIc','IIc';'IId','IId','IId'};
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

clim_l=max(abs(min(max_gr)),abs(max(max_gr)));
clim_f=[-clim_l,clim_l];

if exist('f_clim','var')==0
    f_clim(1,1:2)=[1,1];
end


%axes and limits
kr=1; kc=1;
lims.x(kr,kc,1:2)=[min(kwx_v),max(kwx_v)];
lims.y(kr,kc,1:2)=[min(kwy_v),max(kwy_v)];
lims.c(kr,kc,1:2)=clim_f*f_clim(ks,1);
xlabels{kr,kc}='k_{wx} [rad/m]';
ylabels{kr,kc}='k_{wy} [rad/m]';

kr=1; kc=2;
lims.x(kr,kc,1:2)=[min(lwx_v),max(lwx_v)];
lims.y(kr,kc,1:2)=[min(lwy_v),max(lwy_v)];
lims.c(kr,kc,1:2)=clim_f*f_clim(ks,2);
xlabels{kr,kc}='l_{wx} [m]';
ylabels{kr,kc}='l_{wy} [m]';

% brewermap('demo')
ncmap=1000000;
cmap1=brewermap(ncmap,'RdYlGn');
% cmap=[flipud(cmap1(1:ncmap/2-ncmap*0.05,:));flipud(cmap1(ncmap/2+ncmap*0.05:end,:))];
% cmap=flipud([flipud(cmap1(1:ncmap/2-ncmap*0.05,:));flipud(cmap1(ncmap/2+ncmap*0.05:end,:))]);
cmap=flipud([flipud(cmap1(1:ncmap/2-ncmap*0.05,:));0,0,0;flipud(cmap1(ncmap/2+ncmap*0.05+1:end,:))]);

% set(groot,'defaultAxesColorOrder',cmap)

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

%figure initialize
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

    %add axis to sub1
%     aux_yco=-0.37;
% pos.sfig=han.sfig(1,1).Position; % position of first axes    
% han.sfig(1,2)=axes('units','normalized','Position',pos.sfig+[0  ,0,0,aux_yco],'XAxisLocation','top','YAxisLocation','right','XColor','none','YColor',prop.color(1,:),'Color','none','ylim',[0,1]);
% han.sfig(1,2).YLabel.String='sediment transport rate (coarse) [g/min]';

%properties
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
han.sfig(kr,kc).Title.String='growth rate [rad/s]';
% han.sfig(kr,kc).XColor='r';
% han.sfig(kr,kc).YColor='k';

kr=1; kc=2;   
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
% han.sfig(kr,kc).Title.String='c';
% han.sfig(kr,kc).XColor='r';
% han.sfig(kr,kc).YColor='k';

%plots
% plot_v1{1,1}=[-1,0,5,10,15,20,25];
% plot_v2{1,1}=[-1000,-10,-0.01,0];

kr=1; kc=1;    
if exist('plot_v1','var')
    han.p1=contourf(xm_k,ym_k,max_gr_m,plot_v1{ks,1},'showtext','on','parent',han.sfig(kr,kc));
else
    han.p1=contourf(xm_k,ym_k,max_gr_m,'showtext','on','parent',han.sfig(kr,kc));
end
for ke=1:ne-3
    [han.p2,aux.p]=contour(xm_k,ym_k,max_cl_m(:,:,ke),[0,0],'showtext','off','parent',han.sfig(kr,kc));
    aux.p.LineWidth=2;
    aux.p.Color='k';
%     han.p2=contour(xm_k,ym_k,max_cl_m(:,:,ke),'showtext','on')
end
han.sfig(kr,kc).ColorOrderIndex=1; %reset color index

kr=1; kc=2;    
if exist('plot_v2','var')
    han.p1=contourf(xm_l,ym_l,max_gr_m,plot_v2{ks,1},'showtext','on','parent',han.sfig(kr,kc));
else
    han.p1=contourf(xm_l,ym_l,max_gr_m,'showtext','on','parent',han.sfig(kr,kc));
end
for ke=1:ne-3
    [han.p2,aux.p]=contour(xm_l,ym_l,max_cl_m(:,:,ke),[0,0],'showtext','off','parent',han.sfig(kr,kc));
    aux.p.LineWidth=2;
    aux.p.Color='k';
%     han.p2=contour(xm_l,ym_l,max_cl_m(:,:,ke),'showtext','on')
end
han.sfig(kr,kc).ColorOrderIndex=1; %reset color index
scatter3(xm_l(max_idx_sc_x,max_idx_sc_y),ym_l(max_idx_sc_x,max_idx_sc_y),max_idx_sc_val,50,'k','parent',han.sfig(kr,kc),'filled');


%colormap
for kc=1:npc
% kr=1; kc=1;
% view(han.sfig(kr,kc),[0,90]);
colormap(han.sfig(kr,kc),cmap);
caxis(han.sfig(kr,kc),lims.c(kr,kc,1:2));
end

%text
% kr=1; kc=1;  

%if the specified values are in cm 
% texti.sfig(kr,kc).pos=cm2ax(texti.sfig(kr,kc).pos,han.fig,han.sfig(kr,kc),'reference','ll');

    %if irregular
% text(texti.sfig(kr,kc).pos(1),texti.sfig(kr,kc).pos(2),texti.sfig(kr,kc).tex,'parent',han.sfig(kr,kc),'color',texti.sfig(kr,kc).clr)
    %if regular
for kr=1:npr
    for kc=1:npc
        ntxt=numel(texti.sfig(kr,kc).tex);
        for ktx=1:ntxt
            %if the specified values are in cm 
            aux.pos=cm2ax(texti.sfig(kr,kc).pos(ktx,:),han.fig,han.sfig(kr,kc),'reference',texti.sfig(kr,kc).ref{ktx});
%             text(texti.sfig(kr,kc).pos(1,1),texti.sfig(kr,kc).pos(1,2),texti.sfig(kr,kc).tex{ktx},'parent',han.sfig(kr,kc),'color',texti.sfig(kr,kc).clr{ktx},'fontweight','bold')
            text(aux.pos(1,1),aux.pos(1,2),texti.sfig(kr,kc).tex{ktx},'parent',han.sfig(kr,kc),'color',texti.sfig(kr,kc).clr{ktx},'fontweight',texti.sfig(kr,kc).fwe{ktx},'rotation',texti.sfig(kr,kc).rot(ktx))
        end
    end
end

%legend
% kr=1; kc=1;
% han.leg(kr,kc)=legend(han.sfig(kr,kc),reshape(han.p(kr,kc,1:2),1,2),{'\tau<1','\tau>1'},'location','south');

%colorbar
% kr=1; kc=2;
% pos.sfig=han.sfig(kr,kc).Position;
% han.cbar=colorbar(han.sfig(kr,kc),'location',cbar(kr,kc).location);
% pos.cbar=han.cbar.Position;
% han.cbar.Position=pos.cbar+cbar(kr,kc).displacement;
% han.sfig(kr,kc).Position=pos.sfig;
% han.cbar.Label.String=cbar(kr,kc).label;

kr=1; kc=1;
han.sfig(kr,kc).Title.Units='normalized';
pos.cbar=han.sfig(kr,kc).Title.Position;
han.sfig(kr,kc).Title.Position=pos.cbar+[0.6,0.05,0];

%general
set(findall(han.fig,'-property','FontSize'),'FontSize',prop.fs)
set(findall(han.fig,'-property','FontName'),'FontName',prop.fn) %!!! attention, there is a bug in Matlab and this is not enforced. It is necessary to change it in the '.eps' to 'ArialMT' (check in a .pdf)
% han.fig.Renderer='painters';

%print
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
