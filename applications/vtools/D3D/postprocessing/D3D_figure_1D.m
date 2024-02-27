%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16791 $
%$Date: 2020-11-11 23:06:03 +0800 (Wed, 11 Nov 2020) $
%$Author: chavarri $
%$Id: D3D_figure_1D.m 16791 2020-11-11 15:06:03Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/postprocessing/D3D_figure_1D.m $
%
%plot of 1D volume fraction 2

function D3D_figure_1D(simdef,in)

%% RENAME in

flg=simdef.flg;

% XCOR=in.XCOR.*flg.plot_unitx;
XZ=in.XZ.*flg.plot_unitx;
YZ=in.YZ.*flg.plot_unity;
z=in.z.*flg.plot_unitz;
% sub=in.sub;
% cvar=in.cvar;
time_r=in.time_r.*flg.plot_unitt;
% nx=in.nx;
% nl=in.nl;
switch flg.elliptic
    case 1
        ell=in.eigen_ell_p;
    case 2
        ell=in.HIRCHK;
end
% S1=in.S1;

% ncx=nx-2;
% ncordx=nx-1;
% ncordy=nl

if isfield(in,'a')
    lims=in.lims;
end

if isfield(flg,'prnt_size')==0
    flg.prnt_size=[0,0,25.4,19.05];
end

if isfield(flg,'fig_visible')==0
    flg.fig_visible=1;
end

%% data rework


lims.x=[min(min(XZ(2:end-1))),max(max(XZ(2:end-1)))];
lims.y=[min(min(YZ(2:end-1))),max(max(YZ(2:end-1)))];
lims.z=[min(min(z(2:end-1))),max(max(z(2:end-1)))+eps];
%     lims.f=[min(min(cvar)),max(max(cvar))];

%limits
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
prnt.filename=sprintf('1D_%010.0f',time_r./flg.plot_unitt); %time is already in the plotting unitsm here we recover [s]
% prnt.size=[0,0,17,10]; %slide=[0,0,25.4,19.05]
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
set(han.fig,'paperunits','centimeters','paperposition',prnt.size,'visible',flg.fig_visible)
set(han.fig,'units','normalized','outerposition',[0,0,1,1])
[mt,mb,mr,ml,sh,sv]=pre_subaxis(han.fig,marg.mt,marg.mb,marg.mr,marg.ml,marg.sh,marg.sv);

%subplots initialize
han.sfig(1,1)=subaxis(npr,npc,1,1,1,1,'mt',mt,'mb',mb,'mr',mr,'ml',ml,'sv',sv,'sh',sh);

%properties
    %sub11
kpr=1; kpc=1;    
hold(han.sfig(kpr,kpc),'on')
han.sfig(kpr,kpc).Box='on';
% axis(han.sfig(kpr,kpc),'equal')
%title
if     any(diff(YZ(2:end-1))) &&  ~any(diff(XZ(2:end-1))) %x constant
    han.sfig(kpr,kpc).XLim=lims.y; 
elseif ~any(diff(YZ(2:end-1))) &&  any(diff(XZ(2:end-1))) %y constant
    han.sfig(kpr,kpc).XLim=lims.x;
else
%     han.sfig(kpr,kpc).XLim=lims.x;
end  

han.sfig(kpr,kpc).YLim=lims.z;
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
    xlabel(han.sfig(kpr,kpc),'streamwise position [m]');
else
    error('Hard-code the label')
end
ylabel(han.sfig(kpr,kpc),in.zlabel);
% zlabel(han.sfig(kpr,kpc),'elevation [m]');
% xlim(han.sfig(kpr,kpc),lims.x)
% ylim(han.sfig(kpr,kpc),lims.y)
% zlim(han.sfig(kpr,kpc),lims.y)

switch flg.plot_unitt
    case 1
        time_str='s';
    case 1/3600 %conversion from s
        time_str='h';
    case 1/3600/24
        time_str='day';
    otherwise
        time_str='UT';
end

%title
if     any(diff(YZ(2:end-1))) &&  ~any(diff(XZ(2:end-1))) %x constant
    title(han.sfig(kpr,kpc),sprintf('time = %5.2f %s, x = %4.2f m',time_r,time_str,XZ(2)))    
elseif ~any(diff(YZ(2:end-1))) &&  any(diff(XZ(2:end-1))) %y constant
    title(han.sfig(kpr,kpc),sprintf('time = %5.2f %s, y = %4.2f m',time_r,time_str,YZ(2)))    
else
    title(han.sfig(kpr,kpc),sprintf('time = %5.2f %s',time_str))  
end  

%plot
if any(diff(YZ(2:end-1))) &&  ~any(diff(XZ(2:end-1))) %x constant
    han.p=plot(YZ(2:end-1),z(2:end-1),'color','k'); 
elseif ~any(diff(YZ(2:end-1))) &&  any(diff(XZ(2:end-1))) %y constant
    han.p=plot(XZ,z,'color','k');
else
    error('not sure what to do :)')
%     han.p=plot(XZ,z,'color','k');  
end  


%elliptic
switch flg.elliptic
    case 1
        han.el=scatter(XZ(2:end),repmat(lims.y(1),1,ncx),20,ell,'fill');
            %for legend
        han.leg(1)=scatter(-1000,-1000,20,'k','fill');
        han.leg(2)=scatter(-1000,-1000,20,'m','fill');
    case 2
        idx_p=ell==0;
        han.p1=scatter3(XZ(idx_p),YZ(idx_p),lims.z(1)*ones(size(XZ(idx_p))),10,'g');
        idx_p=ell==1;
        han.p1=scatter3(XZ(idx_p),YZ(idx_p),lims.z(1)*ones(size(XZ(idx_p))),10,'r');
                    %for legend
        han.leg(1)=scatter(-1000,-1000,20,'g','fill');
        han.leg(2)=scatter(-1000,-1000,20,'r','fill');
end

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
if flg.elliptic~=0
    han.leg(1,1)=legend(han.leg,{'hyperbolic','elliptic'},'location','northeast');
end

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
set(findall(han.fig,'-property','FontSize'),'FontSize',flg.prop.fs)
% set(findall(han.fig,'-property','FontName'),'FontName',prop.fn) %!!! attention, there is a bug in Matlab and this is not enforced. It is necessary to change it in the '.eps' to 'ArialMT' (check in a .pdf)
han.fig.Renderer='painters';

%print
D3D_print_fig(simdef,prnt,han)

% if isnan(flg.save_name)
%     str_save=fullfile(file.dire_sim,'figures',prnt.filename);
% else
%     str_save=flg.save_name;
% end
% %print
% if flg.print==0
%     pause
% elseif flg.print==0.5
%     pause(flg.pauset);
% elseif flg.print==1
%     print(han.fig,strcat(str_save,'.eps'),'-depsc2','-loose','-cmyk')
% elseif flg.print==2
%     print(han.fig,strcat(str_save,'.png'),'-dpng','-r600')    
% end
% close(han.fig)


