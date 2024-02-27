%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: D3D_figure_3D.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/postprocessing/D3D_figure_3D.m $
%
%plot of 1D volume fraction 2

function D3D_figure_3D(flg,file,in)

%% RENAME in


% XCOR=in.XCOR.*flg.plot_unitx;
XZ=in.XZ.*flg.plot_unitx;
YZ=in.YZ.*flg.plot_unity;
bl=in.bl.*flg.plot_unitz;
% sub=in.sub;
cvar=in.cvar;
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
% ncordy=nl+1;

if isfield(in,'a')
    lims=in.lims;
end

%% data rework

%patches
% Cm=cvar'; %fraction 2
% Xm=repmat(XCOR,ncordy,1);
% Ym=sub;
% 
% xr=reshape(Xm',ncordx*ncordy,1);
% yr=reshape(Ym',ncx*(nl+1),1);
% aux= reshape(repmat(1:1:ncordx,2,1),ncordx*2,1);
% aux1=reshape(repmat(1:1:ncx*(nl+1),2,1),(ncx*(nl+1))*2,1);
% aux2=aux(2:end-1);
% aux3=repmat(aux2,nl+1,1);
% v(:,1)=xr(aux3);
% v(:,2)=yr(aux1);
% 
% f=NaN(nl*ncx,4);
% f(:,1:2)=(reshape(1:1:(ncx*2*nl),2,nl*ncx))';
% aux=(reshape((ncx*2+1):1:((ncx*2)*(nl+1)),2,nl*ncx))';
% f(:,3)=aux(:,2);
% f(:,4)=aux(:,1);
% 
% col=reshape(Cm,ncx*nl,1);

%limits
if isfield(in,'lims')
    lims.x=in.lims.x;
    lims.y=in.lims.y;
    lims.z=in.lims.z;
    lims.f=in.lims.f;
else
%     lims.x=[XCOR(1),XCOR(end)];
    lims.x=[min(min(XZ)),max(max(XZ))];
    lims.y=[min(min(YZ)),max(max(YZ))];
    lims.z=[min(min(bl)),max(max(bl))];
    lims.f=[min(min(cvar)),max(max(cvar))];
end

%% FIGURE

%figure input
prnt.filename=sprintf('etab_dm_%010.0f',time_r./flg.plot_unitt); %time is already in the plotting unitsm here we recover [s]
prnt.size=[0,0,25.4,19.05]; %slide=[0,0,25.4,19.05]
npr=1; %number of plot rows
npc=1; %number of plot columns
marg.mt=2.0; %top margin [cm]
marg.mb=2.0; %bottom margin [cm]
marg.mr=2.0; %right margin [cm]
marg.ml=2.0; %left margin [cm]
marg.sh=1.0; %horizontal spacing [cm]
marg.sv=0.0; %vertical spacing [cm]

% prop.ms1=10; 
% prop.lw=1;
prop.fs=12;
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
set(han.fig,'units','centimeters','paperposition',prnt.size)
set(han.fig,'units','normalized','outerposition',[0,0,1,1])
[mt,mb,mr,ml,sh,sv]=pre_subaxis(han.fig,marg.mt,marg.mb,marg.mr,marg.ml,marg.sh,marg.sv);

%subplots initialize
han.sfig(1,1)=subaxis(npr,npc,1,1,1,1,'mt',mt,'mb',mb,'mr',mr,'ml',ml,'sv',sv,'sh',sh);

%properties
    %sub11
kpr=1; kpc=1;    
hold(han.sfig(kpr,kpc),'on')
han.sfig(kpr,kpc).Box='on';
% axis(han.han.sfig(kpr,kpc),'equal')
han.sfig(kpr,kpc).XLim=lims.x;
han.sfig(kpr,kpc).YLim=lims.y;
han.sfig(kpr,kpc).ZLim=lims.z;
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
ylabel(han.sfig(kpr,kpc),'crosswise position [m]');
zlabel(han.sfig(kpr,kpc),'elevation [m]');
% xlim(han.sfig(kpr,kpc),lims.x)
% ylim(han.sfig(kpr,kpc),lims.y)
% zlim(han.sfig(kpr,kpc),lims.y)
if flg.plot_unitt==1/3600 %conversion from s
    title(han.sfig(kpr,kpc),sprintf('time [h] = %5.2f',time_r))
    % title(han.sfig(kpr,kpc),sprintf('%d years',round(time/3600/24/365)))
else
    error('Hard-code the label')
end
    

%plots
% kpr=1; kpc=1;  

%substrate
han.surf1=surf(XZ,YZ,bl,cvar);
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

han.surf1.EdgeColor='none';

light
material dull
han.surf1.FaceLighting='gouraud';

%water level
% han.wl=plot(XZ(2:end),S1,'color','b','linewidth',2);

%colormap
colormap(han.sfig(1,1),cmap);

%view
view(han.sfig(1,1),[20,17]);

%caxis
caxis(han.sfig(1,1),lims.f);

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
han.cbar=colorbar('peer',han.sfig(1,1),'location','eastoutside');
% set(get(han.cbar,'Ylabel'),'String','gravel content [-]')
set(get(han.cbar,'Ylabel'),'String','mean grain size [m]')

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

%print
if flg.print==0
    pause
elseif flg.print==0.5
    pause(flg.pauset);
elseif flg.print==1
    print(han.fig,fullfile(file.dire_sim,'figures',strcat(prnt.filename,'.eps')),'-depsc2','-loose','-cmyk')
elseif flg.print==2
    print(han.fig,fullfile(file.dire_sim,'figures',strcat(prnt.filename,'.png')),'-dpng','-r300')    
end


