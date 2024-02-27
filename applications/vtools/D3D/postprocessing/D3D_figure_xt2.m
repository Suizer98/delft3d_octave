%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: D3D_figure_xt2.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/postprocessing/D3D_figure_xt2.m $
%
%plot of 1D volume fraction 2

function D3D_figure_xt2(flg,file,in)

%% RENAME in

XZ=in.XZ.*flg.plot_unitx;
YZ=in.YZ.*flg.plot_unitt;
z=in.z;
cvar=in.z;

nx=in.nx;
nl=in.nl;
kf=in.kf;
switch flg.elliptic
    case 1
        ell=in.eigen_ell_p;
    case 2
        ell=in.HIRCHK;
end

[xp,yp]=meshgrid(XZ,YZ);

%limits
if isfield(flg,'lims')
    lims.x=flg.lims.x;
    lims.y=flg.lims.y;
    lims.f=flg.lims.f;
else
    lims.x=[XZ(1),XZ(end)];
    lims.y=[min(min(XY)),max(max(XY))];
    lims.f=[min(min(cvar)),max(max(cvar))];
end

%% FIGURE

%figure input
prnt.filename='xy'; %time is already in the plotting unitsm here we recover [s]
prnt.size=[0,0,17,10]; %slide=[0,0,25.4,19.05]
npr=1; %number of plot rows
npc=2; %number of plot columns
marg.mt=2.0; %top margin [cm]
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
kr=1; kc=1;
cbar(kr,kc).displacement=[0.0,0,0,0]; 
cbar(kr,kc).location='northoutside';
cbar(kr,kc).label=sprintf('f_{s%d} [-]',kf);

%text
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
texti.sfig(kr,kc).rot=[0,90];
    end
end

%limits


% brewermap('demo')
% cmap=brewermap(3,'set1');
cmap=brewermap(100,'RdYlBu');
cmap2=[0,1,0;1,0,0];

%figure initialize
han.fig=figure('name',prnt.filename);
set(han.fig,'units','centimeters','paperposition',prnt.size)
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
kr=1; kc=1;    
hold(han.sfig(kr,kc),'on')
han.sfig(kr,kc).Box='on';
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
    xlabel(han.sfig(kr,kc),'streamwise position [m]');
else
    error('Hard-code the label')
end
% title(han.sfig(kpr,kpc),sprintf('time = %5.2f s',time_r))
xlim(han.sfig(kr,kc),lims.x)
ylim(han.sfig(kr,kc),lims.y)
switch flg.plot_unitt
    case 1 %conversion from s
        ylabel(han.sfig(kr,kc),'time [s]');
    case 1/3600 %conversion from s
        ylabel(han.sfig(kr,kc),'time [h]');
    otherwise
        error('Hard-code the label')
end
    
kr=1; kc=2;    
hold(han.sfig(kr,kc),'on')
han.sfig(kr,kc).Box='on';
% axis(han.han.sfig(kpr,kpc),'equal')
% han.sfig(kpr,kpc).XLim=lims.x;
% han.sfig(kpr,kpc).YLim=lims.y;
% han.sfig(kpr,kpc).XLabel.String='streamwise position x-x_0 [m]';
% han.sfig(kpr,kpc).YLabel.String={'elevation [m]'};
% % han.sfig(kpr,kpc).XTickLabel='';
han.sfig(kr,kc).YTickLabel='';
% % han.sfig(kpr,kpc).XTick=[];  
% % han.sfig(kpr,kpc).YTick=[];  
% % han.sfig(kpr,kpc).XScale='log';
% % han.sfig(kpr,kpc).YScale='log';
% han.sfig(kpr,kpc).Title.String='c';
if flg.plot_unitx==1
    xlabel(han.sfig(kr,kc),'streamwise position [m]');
else
    error('Hard-code the label')
end
% title(han.sfig(kpr,kpc),sprintf('time = %5.2f s',time_r))
xlim(han.sfig(kr,kc),lims.x)
ylim(han.sfig(kr,kc),lims.y)
% switch flg.plot_unitt
%     case 1 %conversion from s
%         ylabel(han.sfig(kr,kc),'time [s]');
%     case 1/3600 %conversion from s
%         ylabel(han.sfig(kr,kc),'time [h]');
%     otherwise
%         error('Hard-code the label')
% end

%plots
kr=1; kc=1;  
han.s=surf(xp,yp,z,cvar,'parent',han.sfig(kr,kc),'edgecolor','none');

kr=1; kc=2;  
han.s=surf(xp,yp,ell,ell,'parent',han.sfig(kr,kc),'edgecolor','none');

    %for legend
han.leg(1)=scatter(-1000,-1000,20,'g','fill');
han.leg(2)=scatter(-1000,-1000,20,'r','fill');

%water level
% han.wl=plot(XZ(2:end),S1,'color','b','linewidth',2);

%colormap
kr=1; kc=1;
view(han.sfig(kr,kc),[0,90]);
colormap(han.sfig(kr,kc),cmap);
caxis(han.sfig(kr,kc),lims.f);

kr=1; kc=2;
view(han.sfig(kr,kc),[0,90]);
colormap(han.sfig(kr,kc),cmap2);
caxis(han.sfig(kr,kc),[0,1]);


%text
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
kr=1; kc=1;
pos.sfig=han.sfig(kr,kc).Position;
han.leg=legend(han.leg,{'well-posed','ill-posed'},'location','northoutside');
pos.leg=han.leg.Position;
han.leg.Position=pos.leg+[0,0.1,0,0];
han.sfig(kr,kc).Position=pos.sfig;

%colorbar
kr=1; kc=1;
pos.sfig=han.sfig(kr,kc).Position;
han.cbar=colorbar(han.sfig(kr,kc),'location',cbar(kr,kc).location);
pos.cbar=han.cbar.Position;
han.cbar.Position=pos.cbar+cbar(kr,kc).displacement;
han.sfig(kr,kc).Position=pos.sfig;
han.cbar.Label.String=cbar(kr,kc).label;

%general
set(findall(han.fig,'-property','FontSize'),'FontSize',prop.fs)
% set(findall(han.fig,'-property','FontName'),'FontName',prop.fn) %!!! attention, there is a bug in Matlab and this is not enforced. It is necessary to change it in the '.eps' to 'ArialMT' (check in a .pdf)

%print
if flg.print==0
    pause
elseif flg.print==0.5
    pause(flg.pauset);
elseif flg.print==1
    print(han.fig,fullfile(file.dire_sim,'figures',strcat(prnt.filename,'.eps')),'-depsc2','-loose','-cmyk')
elseif flg.print==2
    print(han.fig,fullfile(file.dire_sim,'figures',strcat(prnt.filename,'.png')),'-dpng','-r600')    
end


