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
%$Id: fig_t_cnt.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/postprocessing/fig_t_cnt.m $
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

function fig_t_cnt(path_fold_main,fig_input)

%% 
%% READ
%% 

%output
fig_input.mdv.plot_type=2;
[xp,zp,yp]=extract_data(path_fold_main,fig_input);

%fig_input
v2struct(fig_input.xtv);

%dimensions
szp=size(zp);
nszp=szp(1);
dzp=numel(szp); 

%time vector
if dzp==2
    nT=size(zp,2);
elseif dzp==3
    nT=size(zp,3);
end

switch time_input
    case 0 
        time_v=1:1:nT;
    case 1
        if isnan(time)
            time_v=nT;
        else
            time_v=time;
        end
    case 2
        time_v=1:time:nT;
end

%figure position
switch disppos
	case 1
		disppos_vec=[0,0,1,1];
	case 2
		disppos_vec=[-1,0,1,1];
	case 3
% 		disppos_vec=[-1,0,2,1];
        disppos_vec=[0,0,2,1];
end

%% FIGURE INITIALIZE

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
end
han.sfig(kr,kc).XLabel.String=xlabels{kr,kc};
han.sfig(kr,kc).YLabel.String=cbar.label;
% han.sfig(kr,kc).XTickLabel='';
% han.sfig(kr,kc).YTickLabel='';
% han.sfig(kr,kc).XTick=[];  
% han.sfig(kr,kc).YTick=[];  
han.sfig(kr,kc).XScale=XScale;
han.sfig(kr,kc).YScale=YScale;
han.sfig(kr,kc).Title.String=sprintf('%s=%f',titlestr{kr,kc},0);
% han.sfig(kr,kc).XColor='r';
% han.sfig(kr,kc).YColor='k';

%% FIRST UPDATE

kt=1;

%copy paste this section in the time loop

%% PLOTS

ni=5;
cmap=brewermap(nszp+ni,'Blues');
cmap=cmap(ni+1:end,:);

kr=1; kc=1;    
if dzp==2
    han.p(kr,kc,1)=plot(xp,zp(:,kt),'parent',han.sfig(kr,kc),'color','k','linewidth',1,'linestyle','-');
elseif dzp==3
    for kszp=1:nszp
        han.p(kr,kc,kszp)=plot(xp,zp(kszp,:,kt),'parent',han.sfig(kr,kc),'color',cmap(kszp,:),'linewidth',1,'linestyle','-');
    end
end

%% UPDATE FIGURE 

for kt=time_v

%% UPDATE FIGURE DATA

kr=1; kc=1;
if dzp==2
    han.p(kr,kc,1).YData=zp(:,kt);
elseif dzp==3
    for kszp=1:nszp
        han.p(kr,kc,kszp).YData=zp(kszp,:,kt);
    end
end


%% TITLE
han.sfig(kr,kc).Title.String=sprintf('%s=%3.2f',titlestr{kr,kc},yp(kt));

%% DISPLAY
switch dispfig
    case 1
        paths_print=fullfile(path_fold_main,'figures',sprintf('%s_%d.png',prnt.filename,varp));
        print(han.fig,paths_print,'-dpng','-r300')
    case 2
        paths_print=fullfile(path_fold_main,'figures',sprintf('%s_%d.eps',prnt.filename,varp));
        print(han.fig,paths_print,'-depsc2','-loose','-cmyk')
    case 3
        pause
    case 4
        pause(pausetime)
end
   

end

end %function



