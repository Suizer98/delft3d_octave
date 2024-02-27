%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17102 $
%$Date: 2021-03-03 05:30:16 +0800 (Wed, 03 Mar 2021) $
%$Author: chavarri $
%$Id: D3D_figure_patch.m 17102 2021-03-02 21:30:16Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/postprocessing/D3D_figure_patch.m $
%
%plot of 1D volume fraction 2

function D3D_figure_patch(simdef,in)

%% RENAME in

simdef=D3D_figure_defaults(simdef);

flg=simdef.flg;

%%

XZ=in.XZ.*flg.plot_unitx;
sub=in.sub;
cvar=in.cvar;
time_r=in.time_r.*flg.plot_unitt;
kf=in.kf;
switch flg.elliptic
    case 1
        ell=in.eigen_ell_p;
    case 2
        ell=in.HIRCHK;
end


%% defaults


%limits
lims.x=[min(XZ),max(XZ)];
lims.y=[min(sub(:)),max(sub(:))];
lims.f=[min(cvar(:))-eps,max(cvar(:))+eps];
switch flg.which_v
    case 3
        
    case 26
        cvar_aux=cvar;
        cvar_aux(cvar_aux==1)=NaN;
        lims.f=[nanmin(cvar_aux(:)),nanmax(cvar_aux(:))];
end
if isfield(flg,'lims')
    if isfield(flg.lims,'x')
        lims.x=flg.lims.x;
    end
    if isfield(flg.lims,'y')
        lims.y=flg.lims.y;
    end 
    if isfield(flg.lims,'f')
        lims.f=flg.lims.f;
    end
end

if isfield(flg,'plotLa')==0
    flg.plotLa=0;
end

%% data rework

inpatch.XCOR=reshape(XZ,1,numel(XZ));
inpatch.cvar=cvar;
inpatch.sub=sub;
[f,v,col]=rework4patch(inpatch);

%% FIGURE

%figure input
prnt.filename=sprintf('volfrac_%010.0f',time_r./flg.plot_unitt); %time is already in the plotting unitsm here we recover [s]
prnt.size=flg.prnt_size; %slide=[0,0,25.4,19.05]
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
% prop.fs=10;
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
cmap=brewermap(100,'RdYlBu');

%figure initialize
han.fig=figure('name',prnt.filename);
set(han.fig,'paperunits','centimeters','paperposition',prnt.size,'visible',flg.fig_visible);
set(han.fig,'units','normalized','outerposition',[0,0,1,1]) %full monitor 1
[mt,mb,mr,ml,sh,sv]=pre_subaxis(han.fig,marg.mt,marg.mb,marg.mr,marg.ml,marg.sh,marg.sv);

%subplots initialize
han.sfig(1,1)=subaxis(npr,npc,1,1,1,1,'mt',mt,'mb',mb,'mr',mr,'ml',ml,'sv',sv,'sh',sh);

%properties
    %sub11
kpr=1; kpc=1;    
hold(han.sfig(kpr,kpc),'on')
han.sfig(kpr,kpc).Box='on';
% axis(han.han.sfig(kpr,kpc),'equal')
% han.sfig(kpr,kpc).XLim=lims.x;
% han.sfig(kpr,kpc).YLim=lims.y;
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
    xlabel(han.sfig(kpr,kpc),'streamwise position [m]');
else
    error('Hard-code the label')
end
ylabel(han.sfig(kpr,kpc),'elevation [m]');
xlim(han.sfig(kpr,kpc),lims.x)
ylim(han.sfig(kpr,kpc),lims.y)
if flg.addtitle
switch flg.plot_unitt
    case 1 %conversion from s
    title(han.sfig(kpr,kpc),sprintf('time = %5.2f s',time_r))
    % title(han.sfig(kpr,kpc),sprintf('%d years',round(time/3600/24/365)))
    case 1/3600 %conversion from s
    title(han.sfig(kpr,kpc),sprintf('time = %5.2f h',time_r))
    % title(han.sfig(kpr,kpc),sprintf('%d years',round(time/3600/24/365)))
    case 1/3600/24
    title(han.sfig(kpr,kpc),sprintf('time = %5.2f days',time_r))
    case 1/3600/24/365
    title(han.sfig(kpr,kpc),sprintf('time = %5.2f years',time_r))
    otherwise
%     error('Hard-code the label')
end
end

%plots
% kpr=1; kpc=1;  

%substrate
han.surf=patch('Faces',f,'Vertices',v,'FaceVertexCData',col,'FaceColor','flat');
if flg.plotLa
han.p=stairs(XZ(1:end-1)',sub(2,:),'linewidth',2,'color','g');
han.p=stairs(XZ(1:end-1)',sub(3,:),'linewidth',2,'color','c');
end
% idx_p=150:200;
% han.surf=patch('Faces',f(idx_p,:),'Vertices',v,'FaceVertexCData',col(idx_p),'FaceColor','flat');
% colorbar
% han.surf=patch('Faces',f,'Vertices',v,'CData',col,'FaceVertexCData',col,'FaceColor','flat');
% cdata=ones(2035,1);
% cdata(1)=0;
% cdata(2)=2;
% cdata(3)=NaN;
% han.surf=patch('Faces',f,'Vertices',v,'FaceVertexCData',cdata,'FaceColor','flat');
% set(han.surf,'EdgeColor','none')
set(han.surf,'EdgeColor','k')

%elliptic
if flg.elliptic~=0
han.el=scatter(XZ(2:end),repmat(lims.y(1),1,ncx),20,ell,'fill');
    %for legend
han.leg(1)=scatter(-1000,-1000,20,'k','fill');
han.leg(2)=scatter(-1000,-1000,20,'m','fill');
end

%water level
% han.wl=plot(XZ(2:end),S1,'color','b','linewidth',2);

%colormap
colormap(han.sfig(1,1),cmap);

%view
% view(han.sfig21,[0,90]);



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
% aux.sfig=11; 
if flg.elliptic~=0
han.leg(1,1)=legend(han.leg,{'hyperbolic','elliptic'},'location','northeast');
end

%colorbar
han.cbar=colorbar('peer',han.sfig(1,1),'location','eastoutside');
switch flg.which_v
    case 8
        set(get(han.cbar,'Ylabel'),'String',sprintf('volume fraction content %d [-]',kf))
    case 3
        set(get(han.cbar,'Ylabel'),'String','arithmetic mean grain size [m]')
    case 26
        set(get(han.cbar,'Ylabel'),'String','geometric mean grain size [m]')
    otherwise
        error('8 or 3')
end

%caxis
caxis(han.sfig(1,1),lims.f);

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
set(findall(han.fig,'-property','FontSize'),'FontSize',flg.prop.fs)
% set(findall(han.fig,'-property','FontName'),'FontName',prop.fn) %!!! attention, there is a bug in Matlab and this is not enforced. It is necessary to change it in the '.eps' to 'ArialMT' (check in a .pdf)

%print
D3D_print_fig(simdef,prnt,han)


