%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 16592 $
%$Date: 2020-09-17 01:32:43 +0800 (Thu, 17 Sep 2020) $
%$Author: chavarri $
%$Id: fig_xt.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/postprocessing/fig_xt.m $
%
%function_name does this and that


%INPUT:
%   -
%
%OUTPUT:
%   -
%
%HISTORY:
%160223
%   -V. Created for the first time.
%
%160603
%   -V. Print .eps added

function fig_xt(path_fold_main,fig_input)

%% 
%% READ
%% 

%paths
% path_file_input=fullfile(path_fold_main,'input.mat');
% path_file_output=fullfile(path_fold_main,'output.mat');

%input (input)
% input=struct();
% load(path_file_input); 
% v2struct(input.mdv,{'fieldnames','nx','xcen'});

%output
fig_input.mdv.plot_type=2;
[xp,zp,yp]=extract_data(path_fold_main,fig_input);

%% RENAME

%input
% v2struct(input.mdv,{'fieldnames','nx'});

%fig_input
v2struct(fig_input.xtv);

%% FIGURE INITIALIZE

%figure position
switch disppos
	case 1
		disppos_vec=[0,0,1,1];
	case 2
		disppos_vec=[-1,0,1,1];
	case 3
		disppos_vec=[-1,0,2,1];
end

han.fig=figure('name',prnt.filename);
set(han.fig,'units','centimeters','paperposition',prnt.size)
set(han.fig,'units','normalized','outerposition',disppos_vec)
[mt,mb,mr,ml,sh,sv]=pre_subaxis(han.fig,marg.mt,marg.mb,marg.mr,marg.ml,marg.sh,marg.sv);

%subplots initialize
    %if regular
for kr=1:npr
    for kc=1:npc
        han.sfig(kr,kc)=subaxis(npr,npc,kc,kr,1,1,'mt',mt,'mb',mb,'mr',mr,'ml',ml,'sv',sv,'sh',sh);
    end
end

%properties
    %sub11
kr=1; kc=1;   
hold(han.sfig(kr,kc),'on')
% axis(han.sfig(kr,kc),'equal')
han.sfig(kr,kc).Box='on';
if lims.auto==0
    han.sfig(kr,kc).XLim=lims.x(kr,kc,:);
    han.sfig(kr,kc).YLim=lims.y(kr,kc,:);
%     aux_yelev=lims.y(kr,kc,1)*ones(1,nx);
else
%     min_elev=-0.15;
%     aux_yelev=min_elev*ones(1,nx);
end
han.sfig(kr,kc).XLabel.String=xlabels{kr,kc};
han.sfig(kr,kc).YLabel.String=ylabels{kr,kc};
% han.sfig(kr,kc).XTickLabel='';
% han.sfig(kr,kc).YTickLabel='';
% han.sfig(kr,kc).XTick=[];  
% han.sfig(kr,kc).YTick=[];  
% han.sfig(kr,kc).XScale='log';
% han.sfig(kr,kc).YScale='log';
% han.sfig(kr,kc).Title.String=sprintf('%s=%f',titlestr{kr,kc},0);
% han.sfig(kr,kc).XColor='r';
% han.sfig(kr,kc).YColor='k';

%% PLOTS

[xpm,ypm]=meshgrid(xp,yp);

kr=1; kc=1;    
han.p(kr,kc,1)=surf(xpm,ypm,zp',zp','parent',han.sfig(kr,kc),'edgecolor',prop.edgecolor);

%colormap
% kr=1; kc=1;
% view(han.sfig(kr,kc),[0,90]);
if lims.auto==0
    colormap(han.sfig(kr,kc),cmap);
    caxis(han.sfig(kr,kc),lims.c(kr,kc,1:2));
end

%colorbar
pos.sfig=han.sfig(cbar.sfig(1),cbar.sfig(2)).Position;
han.cbar=colorbar(han.sfig(cbar.sfig(1),cbar.sfig(2)),'location',cbar.location);
pos.cbar=han.cbar.Position;
han.cbar.Position=pos.cbar+cbar.displacement;
han.sfig(cbar.sfig(1),cbar.sfig(2)).Position=pos.sfig;
han.cbar.Label.String=cbar.label;

%% DISPLAY 

switch dispfig
    case 1
        paths_print=fullfile(path_fold_main,'figures',sprintf('%s_%d.png',prnt.filename,varp));
        print(han.fig,paths_print,'-dpng','-r300')
    case 2
        paths_print=fullfile(path_fold_main,'figures',sprintf('%s_%d.eps',prnt.filename,varp));
        print(han.fig,paths_print,'-depsc2','-loose','-cmyk')
end
   
end




