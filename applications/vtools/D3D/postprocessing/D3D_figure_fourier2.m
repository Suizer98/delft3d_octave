%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: D3D_figure_fourier2.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/postprocessing/D3D_figure_fourier2.m $
%
%plot of 1D volume fraction 2

function D3D_figure_fourier2(flg,file,in)

%% RENAME in


% XCOR=in.XCOR.*flg.plot_unitx;
XZ=in.XZ.*flg.plot_unitx;
YZ=in.YZ.*flg.plot_unity;
z=in.z.*flg.plot_unitz;
% sub=in.sub;
cvar=z;
time_r=in.time_r.*flg.plot_unitt;
% nx=in.nx;
% nl=in.nl;
% switch flg.elliptic
%     case 1
%         ell=in.eigen_ell_p;
%     case 2
%         ell=in.HIRCHK;
% end
% S1=in.S1;

% ncx=nx-2;
% ncordx=nx-1;
% ncordy=nl+1;


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
if isfield(flg,'lims')
    if isfield(flg.lims,'x')
        lims.x=flg.lims.x;
    else
%         lims.x=[0,max(max(XZ))];
        lims.x=[min(min(XZ)),max(max(XZ))];
    end
    
    if isfield(flg.lims,'y')
        lims.y=flg.lims.y;
    else
%         lims.y=[0,max(max(YZ))];
        lims.y=[min(min(YZ)),max(max(YZ))];
    end
    
    if isfield(flg.lims,'z')
        lims.z=flg.lims.z;
    else
        lims.z=[min(min(z)),max(max(z))];
    end
else
    lims.x=[0,max(max(XZ))];
    lims.y=[0,max(max(YZ))];
%     lims.x=[min(min(XZ)),max(max(XZ))];
%     lims.y=[min(min(YZ)),max(max(YZ))];
    lims.z=[min(min(z)),max(max(z))];
%     lims.f=[min(min(cvar)),max(max(cvar))];
end

%scale
if isfield(flg,'XScale')==0
    flg.XScale='linear';
end
if isfield(flg,'YScale')==0
    flg.YScale='linear';
end
if isfield(flg,'ZScale')==0
    flg.ZScale='linear';
end

%% FIGURE

%figure input
prnt.filename=sprintf('fourier2_%d_%d_%d_%010.0f',flg.which_v,flg.which_s,flg.which_tf,time_r./flg.plot_unitt); %time is already in the plotting unitsm here we recover [s]
% prnt.size=[0,0,17,6]; %slide=[0,0,25.4,19.05]
% prnt.size=[0,0,17,8.0]; %slide=[0,0,25.4,19.05]
% prnt.size=[0,0,7.2,5]; %slide=[0,0,25.4,19.05]
prnt.size=flg.prnt_size;
npr=1; %number of plot rows
npc=1; %number of plot columns
% marg.mt=0.5; %top margin [cm]
% marg.mb=0.5; %bottom margin [cm]
% marg.mr=0.5; %right margin [cm]
% marg.ml=1.5; %left margin [cm]
% marg.sh=1.0; %horizontal spacing [cm]
% marg.sv=0.0; %vertical spacing [cm]

% marg.mt=0.5; %top margin [cm]
% marg.mb=1.0; %bottom margin [cm]
% marg.mr=0.5; %right margin [cm]
% marg.ml=1.5; %left margin [cm]
% marg.sh=1.0; %horizontal spacing [cm]
% marg.sv=0.0; %vertical spacing [cm]

% marg.mt=1.7; %top margin [cm]
% marg.mb=1.1; %bottom margin [cm]
% marg.mr=0.5; %right margin [cm]
% marg.ml=1.5; %left margin [cm]
% marg.sh=1.0; %horizontal spacing [cm]
% marg.sv=0.0; %vertical spacing [cm]

marg.mt=flg.marg.mt; %top margin [cm]
marg.mb=flg.marg.mb; %bottom margin [cm]
marg.mr=flg.marg.mr; %right margin [cm]
marg.ml=flg.marg.ml; %left margin [cm]
marg.sh=flg.marg.sh; %horizontal spacing [cm]
marg.sv=flg.marg.sv; %vertical spacing [cm]

% prop.ms1=10; 
% prop.lw=1;
prop.fs=flg.prop.fs;
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
cbar.sfig=[1,1]; 
% cbar.displacement=[0.0,0.1,0,0]; 
cbar.displacement=flg.cbar.displacement; 
cbar.location='northoutside';
% switch flg.which_v
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
% 
% end

%text
% aux.sfig=11;
% texti.(sprintf('sfig%d',aux.sfig)).pos=[0.015,0.5e-3;0.03,-0.5e-3;0.005,-1e-3];
% texti.(sprintf('sfig%d',aux.sfig)).tex={'1','2','a'};
% texti.(sprintf('sfig%d',aux.sfig)).clr={prop.color(1,:),prop.color(2,:),'k'};

%limits


% brewermap('demo')
% cmap=brewermap(3,'set1');

% switch flg.which_v
%     case 7
%         cmap=[...
%             0.0000    1.0000    0.0000;... %green
%             1.0000    0.0000    0.0000]; %red
%     otherwise
        cmap=brewermap(100,'RdYlBu');
% end

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
% axis(han.sfig(kpr,kpc),'equal')
han.sfig(kpr,kpc).XLim=lims.x;
han.sfig(kpr,kpc).YLim=lims.y;
han.sfig(kpr,kpc).ZLim=lims.z;
% han.sfig(kpr,kpc).XLabel.String='streamwise position x-x_0 [m]';
% han.sfig(kpr,kpc).YLabel.String={'elevation [m]'};
% % han.sfig(kpr,kpc).XTickLabel='';
% % han.sfig(kpr,kpc).YTickLabel='';
% % han.sfig(kpr,kpc).XTick=[];  
% % han.sfig(kpr,kpc).YTick=[];  
han.sfig(kpr,kpc).XScale=flg.XScale;
han.sfig(kpr,kpc).YScale=flg.YScale;
han.sfig(kpr,kpc).ZScale=flg.ZScale;
% han.sfig(kpr,kpc).Title.String='c';

switch flg.plot_unitx
    case 1
        aux_s='[1/m]';
    case 1/1000
        aux_s='[1/km]';
    otherwise
        error('Hard-code the label')
end
% xlabel(han.sfig(kpr,kpc),sprintf('streamwise position %s',aux_s));
switch flg.which_tf
    case 1
        xlabel(han.sfig(kpr,kpc),sprintf('streamwise frequency %s',aux_s));
    case 2
        xlabel(han.sfig(kpr,kpc),'streamwise harmonic [-]');
end


switch flg.plot_unity
    case 1
        aux_s='[1/m]';
    case 1/1000
        aux_s='[1/km]';
    otherwise
        error('Hard-code the label')
end
% ylabel(han.sfig(kpr,kpc),sprintf('crosswise position %s',aux_s));
switch flg.which_tf
    case 1
        ylabel(han.sfig(kpr,kpc),sprintf('transverse frequency %s',aux_s));
    case 2
        ylabel(han.sfig(kpr,kpc),'transverse harmonic [-]');
end
% zlabel(han.sfig(kpr,kpc),'elevation [m]');
% xlim(han.sfig(kpr,kpc),lims.x)
% ylim(han.sfig(kpr,kpc),lims.y)
% zlim(han.sfig(kpr,kpc),lims.y)
% switch flg.which_v
%     case 1 
%         aux_s='bed elevation [m] at';
%     case 3
%         switch flg.plot_unitz
%             case 1
%                 aux_s='mean grain size at the bed surface [m] at';
%             case 1000
%                 aux_s='mean grain size at the bed surface [mm] at';
%         end
%     case 4
%         switch flg.plot_unitz
%             case 1
%                 aux_s='mean grain size at the top substrate [m] at';
%             case 1000
%                 aux_s='mean grain size at the top substrate [mm] at';
%         end
%     case 6
%         aux_s='secondary flow intensity [m/s] at';
%     otherwise
%         aux_s='';
% end
switch flg.plot_unitt
    case 1 %conversion from s 
        aux_t='s';
    case 1/3600 %conversion from s
        aux_t='h';
    case 1/3600/24
        aux_t='days';
end
% title(han.sfig(kpr,kpc),sprintf('%s time = %5.2f %s',aux_s,time_r,aux_t))
if flg.which_p~=8
title(han.sfig(kpr,kpc),sprintf('time = %5.2f %s',time_r,aux_t))
end
   

%plots
% kpr=1; kpc=1;  

%substrate
switch flg.which_s
    case 1
        han.surf1=surf(XZ,YZ,z,cvar);
        han.surf1.EdgeColor='none';
    case 2
        [~,han.surf1]=contourf(XZ,YZ,z,[lims.f(1):0.005:lims.f(2)],'showtext','on');
%         [han.p1,han.surf1]=contourf(XZ,YZ,z,[0.0009,0.001,0.0015,0.002,0.003,0.0038]*1000,'showtext','on');
    case 3
        han.el1=scatter3(reshape(XZ,[],1),reshape(YZ,[],1),reshape(z,[],1),'filled'); %general
%         idx_p=z==0;
%         han.el1=scatter(reshape(XZ(idx_p),1,[]),reshape(YZ(idx_p),1,[]),10,reshape(z(idx_p),1,[]),'fill');
%         idx_p=z==1;
%         han.el1=scatter(reshape(XZ(idx_p),1,[]),reshape(YZ(idx_p),1,[]),10,reshape(z(idx_p),1,[]),'fill');
end

% switch flg.elliptic
%     case 1
%         han.el=scatter(XZ(2:end),repmat(lims.y(1),1,ncx),20,ell,'fill');
%     case 2
%         idx_p=ell==0;
%         han.p1=scatter3(XZ(idx_p),YZ(idx_p),lims.z(1)*ones(size(XZ(idx_p))),10,'g');
%         idx_p=ell==1;
%         han.p1=scatter3(XZ(idx_p),YZ(idx_p),lims.z(1)*ones(size(XZ(idx_p))),10,'r');
% end
% if flg.which_v==7 || flg.elliptic~=0
%                     %for legend
%     han.leg(1)=scatter(-1000,-1000,20,'g','fill');
%     han.leg(2)=scatter(-1000,-1000,20,'r','fill');
% end
    


% light
% material dull
% han.surf1.FaceLighting='gouraud';

%water level
% han.wl=plot(XZ(2:end),S1,'color','b','linewidth',2);

%colormap
colormap(han.sfig(1,1),cmap);


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
% if flg.which_v==7 || flg.elliptic~=0
%     han.leg(1,1)=legend(han.leg,{'well-posed','ill-posed'},'location','northeast');
% end

%colorbar
% if 0
% han.cbar=colorbar('peer',han.sfig(1,1),'location','northoutside');
% % set(get(han.cbar,'Ylabel'),'String','gravel content [-]')
% % set(get(han.cbar,'Ylabel'),'String','mean grain size [m]')
% switch flg.which_v
%     case 1
%         set(get(han.cbar,'Ylabel'),'String','bed elevation [m]')
%     case 2
%         set(get(han.cbar,'Ylabel'),'String','flow depth [m]')
% end
% end

% switch flg.which_v
%     case {2,3,4}
% pos.sfig=han.sfig(cbar.sfig(1),cbar.sfig(2)).Position;
switch flg.which_s
    case 1
        han.cbar=colorbar(han.sfig(cbar.sfig(1),cbar.sfig(2)),'location',cbar.location);
end
% pos.cbar=han.cbar.Position;
% han.cbar.Position=pos.cbar+cbar.displacement;
% han.sfig(cbar.sfig(1),cbar.sfig(2)).Position=pos.sfig;
% han.cbar.Label.String=cbar.label;
% end

%fucking bug
% if 0
%     text(4.28,0.056,'-0.01')
%     text(4.46,0.120,'-0.005')
%     text(4.67,0.309,'0.005')
%     text(4.85,0.381,'0.01')
%     text(5.28,0.353,'0.01')
%     text(5.43,0.245,'0.005')
%     text(5.67,0.096,'-0.005')
%     text(5.85,0.054,'-0.01')
% end
%general
set(findall(han.fig,'-property','FontSize'),'FontSize',prop.fs)
if flg.which_s==2
    clabel(han.p1,han.surf1,'FontSize',7)
end
% set(findall(han.fig,'-property','FontName'),'FontName',prop.fn) %!!! attention, there is a bug in Matlab and this is not enforced. It is necessary to change it in the '.eps' to 'ArialMT' (check in a .pdf)
han.fig.Renderer='painters';
% han.fig.Renderer='opengl';


%print
%view
switch flg.which_s
    case 1
        view(han.sfig(1,1),[0,90]);
        
if isnan(flg.save_name)
    str_save=fullfile(file.dire_sim,'figures',prnt.filename);
else
    str_save=flg.save_name;
end
if flg.print==0
    pause
elseif flg.print==0.5
    pause(flg.pauset);
elseif flg.print==1
    print(han.fig,strcat(str_save,'.eps'),'-depsc2','-loose','-cmyk')
elseif flg.print==2
    print(han.fig,strcat(str_save,'.png'),'-dpng','-r600')    
end

    case 3

view(han.sfig(1,1),[0,0]);
if isnan(flg.save_name)
    str_save=fullfile(file.dire_sim,'figures',strcat(prnt.filename,'_x'));
else
    str_save=flg.save_name;
end

if flg.print==0
    pause
elseif flg.print==0.5
    pause(flg.pauset);
elseif flg.print==1
    print(han.fig,strcat(str_save,'.eps'),'-depsc2','-loose','-cmyk')
elseif flg.print==2
    print(han.fig,strcat(str_save,'.png'),'-dpng','-r600')    
end

view(han.sfig(1,1),[90,0]);
if isnan(flg.save_name)
    str_save=fullfile(file.dire_sim,'figures',strcat(prnt.filename,'_y'));
else
    str_save=flg.save_name;
end
if flg.print==0
    pause
elseif flg.print==0.5
    pause(flg.pauset);
elseif flg.print==1
    print(han.fig,strcat(str_save,'.eps'),'-depsc2','-loose','-cmyk')
elseif flg.print==2
    print(han.fig,strcat(str_save,'.png'),'-dpng','-r600')    
end
end

close(han.fig)
