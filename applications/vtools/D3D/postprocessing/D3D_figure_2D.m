%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17102 $
%$Date: 2021-03-03 05:30:16 +0800 (Wed, 03 Mar 2021) $
%$Author: chavarri $
%$Id: D3D_figure_2D.m 17102 2021-03-02 21:30:16Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/postprocessing/D3D_figure_2D.m $
%
%plot of 1D volume fraction 2

function D3D_figure_2D(simdef,in)

%% RENAME in

simdef=D3D_figure_defaults(simdef);

flg=simdef.flg;

%% limits

switch flg.which_s
    case 1
        XZ=in.XZ(2:end-1,:).*flg.plot_unitx;
        YZ=in.YZ(2:end-1,:).*flg.plot_unity;
        z_var=in.z(2:end-1,:).*flg.plot_unitz;
        cvar=z_var;
        
        lims.x=[min(min(XZ)),max(max(XZ))];
        lims.y=[min(min(YZ)),max(max(YZ))];
        lims.z=[min(min(z_var)),max(max(z_var))];
        lims.f=[min(min(cvar)),max(max(cvar))];
    case 4
        faces=in.faces;
        x_node=in.x_node*flg.plot_unitx;
        y_node=in.y_node*flg.plot_unity;
        z_var=in.z.*flg.plot_unitz;
        cvar=z_var;
        
        lims.x=[min(x_node),max(x_node)];
        lims.y=[min(y_node),max(y_node)];
        lims.z=[min(z_var),max(z_var)];
        lims.f=[min(min(cvar)),max(max(cvar))];
end

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
    if isfield(flg.lims,'f')
        lims.f=flg.lims.f;
    end
end

%% other

time_r=in.time_r.*flg.plot_unitt;

%% FIGURE

%figure input
prnt.filename=sprintf('2D_%d_%010.0f',flg.which_v,time_r./flg.plot_unitt); %time is already in the plotting unitsm here we recover [s]
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
% prop.fs=flg.prop.fs;
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
cbar.displacement=flg.cbar.displacement;
cbar.location='northoutside';
if isfield(in,'zlabel_code')
    cbar.label=labels4all(in.zlabel_code,flg.plot_unitz,flg.language);
else
    warning('Consider adding a code to zlabel in D3D_read_map')
    cbar.label=in.zlabel;
end

%text
% aux.sfig=11;
% texti.(sprintf('sfig%d',aux.sfig)).pos=[0.015,0.5e-3;0.03,-0.5e-3;0.005,-1e-3];
% texti.(sprintf('sfig%d',aux.sfig)).tex={'1','2','a'};
% texti.(sprintf('sfig%d',aux.sfig)).clr={prop.color(1,:),prop.color(2,:),'k'};


% brewermap('demo')
% cmap=brewermap(3,'set1');

switch flg.which_v
    case 7
        cmap=[...
            0.0000    1.0000    0.0000;... %green
            1.0000    0.0000    0.0000]; %red
    otherwise
        cmap=flipud(brewermap(100,'RdYlBu'));
end

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
% % han.sfig(kpr,kpc).YScale='log';
% han.sfig(kpr,kpc).Title.String='c';
% xlabel(han.sfig(kpr,kpc),sprintf('streamwise position %s',aux_s));
xlabel(han.sfig(kpr,kpc),labels4all('x',flg.plot_unitx,flg.language));
% ylabel(han.sfig(kpr,kpc),sprintf('crosswise position %s',aux_s));
ylabel(han.sfig(kpr,kpc),labels4all('y',flg.plot_unity,flg.language));
if flg.addtitle
    [~,str_var,str_un]=labels4all('t',flg.plot_unitt,flg.language);
    title(han.sfig(kpr,kpc),sprintf('%s = %5.2f%s',str_var,time_r,str_un))
end
   

%plots
% kpr=1; kpc=1;  
if isfield(flg,'add_tiles') && flg.add_tiles
addTiles(flg.tiles_path,flg.plot_unitx,flg.plot_unity);
end

%substrate
switch flg.which_s
    case 1
        han.surf1=surf(XZ,YZ,z_var,cvar);
        han.surf1.EdgeColor=flg.prop.edgecolor;
    case 2
        [~,han.surf1]=contourf(XZ,YZ,z_var,[lims.f(1):0.005:lims.f(2)],'showtext','on');
%         [han.p1,han.surf1]=contourf(XZ,YZ,z,[0.0009,0.001,0.0015,0.002,0.003,0.0038]*1000,'showtext','on');
    case 3
        han.el1=scatter(reshape(XZ,1,[]),reshape(YZ,1,[]),15,reshape(z_var,1,[]),'fill'); %general
%         idx_p=z==0;
%         han.el1=scatter(reshape(XZ(idx_p),1,[]),reshape(YZ(idx_p),1,[]),10,reshape(z(idx_p),1,[]),'fill');
%         idx_p=z==1;
%         han.el1=scatter(reshape(XZ(idx_p),1,[]),reshape(YZ(idx_p),1,[]),10,reshape(z(idx_p),1,[]),'fill');
    case 4
        patch('Faces',faces,'Vertices',[x_node,y_node],'FaceVertexCData',z_var,'FaceColor','flat','EdgeColor',flg.prop.edgecolor); %in unstructure faces is transposed
end

%elliptic
switch flg.elliptic
    case 1
        ell=in.eigen_ell_p;
        han.el=scatter(XZ(2:end),repmat(lims.y(1),1,ncx),20,ell,'fill');
    case 2
        ell=in.HIRCHK;
        idx_p=ell==0;
        han.p1=scatter3(XZ(idx_p),YZ(idx_p),lims.z(1)*ones(size(XZ(idx_p))),10,'g');
        idx_p=ell==1;
        han.p1=scatter3(XZ(idx_p),YZ(idx_p),lims.z(1)*ones(size(XZ(idx_p))),10,'r');
end
if flg.which_v==7 || flg.elliptic~=0
                    %for legend
    han.leg(1)=scatter(-1000,-1000,20,'g','fill');
    han.leg(2)=scatter(-1000,-1000,20,'r','fill');
end
    
% light
% material dull
% han.surf1.FaceLighting='gouraud';

%water level
% han.wl=plot(XZ(2:end),S1,'color','b','linewidth',2);

%colormap
colormap(han.sfig(1,1),cmap);

%view
if isfield(flg,'view')
view(han.sfig(1,1),flg.view);
end

%caxis
caxis(han.sfig(1,1),lims.z+[-eps,+eps]); %eps it to avoid error when values are equal

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
if flg.which_v==7 || flg.elliptic~=0
    han.leg(1,1)=legend(han.leg,{'well-posed','ill-posed'},'location','northeast');
end

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
%     case {1,2,3,4,6,10,12}
pos.sfig=han.sfig(cbar.sfig(1),cbar.sfig(2)).Position;
han.cbar=colorbar(han.sfig(cbar.sfig(1),cbar.sfig(2)),'location',cbar.location);
pos.cbar=han.cbar.Position;
han.cbar.Position=pos.cbar+cbar.displacement;
han.sfig(cbar.sfig(1),cbar.sfig(2)).Position=pos.sfig;
han.cbar.Label.String=cbar.label;
% end

%general
set(findall(han.fig,'-property','FontSize'),'FontSize',flg.prop.fs)
% if flg.which_s==2
%     clabel(han.p1,han.surf1,'FontSize',7)
% end
% set(findall(han.fig,'-property','FontName'),'FontName',prop.fn) %!!! attention, there is a bug in Matlab and this is not enforced. It is necessary to change it in the '.eps' to 'ArialMT' (check in a .pdf)
% han.fig.Renderer='painters';
% han.fig.Renderer='opengl';

% if isnan(flg.save_name)
%     str_save=fullfile(file.dire_sim,'figures',prnt.filename);
% else
%     str_save=flg.save_name;
% end

%print
D3D_print_fig(simdef,prnt,han)

