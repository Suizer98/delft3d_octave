%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 16757 $
%$Date: 2020-11-02 14:34:08 +0800 (Mon, 02 Nov 2020) $
%$Author: chavarri $
%$Id: fig_level.m 16757 2020-11-02 06:34:08Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/postprocessing/fig_level.m $
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

function fig_level(path_fold_main,fig_input)

%% 
%% READ
%% 

%% 
%% READ
%% 

fig_input.mdv.output_var={'etab','h','time_l'};
output_m=extract_output(path_fold_main,fig_input);


%input (input)
input=struct();
path_file_input=fullfile(path_fold_main,'input.mat');
load(path_file_input); 
v2struct(input.mdv,{'fieldnames','xcen'});

time_results=output_m.time_l;
nT=numel(time_results);


%due to the way some functions were prepared for D3D
% in.nx=nx+2; 

%fig_input
v2struct(fig_input.lev);

%time vector
switch time_input
    case 0 
        time_v=1:1:nT;
    case 1
        time_v=time;
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
han.sfig(kr,kc).YLabel.String=ylabels{kr,kc};
% han.sfig(kr,kc).XTickLabel='';
% han.sfig(kr,kc).YTickLabel='';
% han.sfig(kr,kc).XTick=[];  
% han.sfig(kr,kc).YTick=[];  
% han.sfig(kr,kc).XScale='log';
% han.sfig(kr,kc).YScale='log';
han.sfig(kr,kc).Title.String=sprintf('%s=%3.2f',titlestr{kr,kc},0);
% han.sfig(kr,kc).XColor='r';
% han.sfig(kr,kc).YColor='k';

%% FIRST UPDATE

kt=1;

%copy paste this section in the time loop
    %% X DATA

x=xcen*unitx;

    %% Y DATA

etab=output_m.etab(:,:,:,kt)*unity;
etaw=etab+output_m.h(:,:,:,kt)*unity;

%% PLOTS

kr=1; kc=1;    
han.p(kr,kc,1)=plot(x,etab,'parent',han.sfig(kr,kc),'color','k','linewidth',prop.lw1,'linestyle',prop.ls1);
han.p(kr,kc,2)=plot(x,etaw,'parent',han.sfig(kr,kc),'color','b','linewidth',prop.lw1,'linestyle',prop.ls1);

%% UPDATE FIGURE 

for kt=time_v

    %% Y DATA

etab=output_m.etab(:,:,:,kt)*unity;
etaw=etab+output_m.h(:,:,:,kt)*unity;

%% UPDATE FIGURE DATA

kr=1; kc=1;
han.p(kr,kc,1).YData=etab;
han.p(kr,kc,2).YData=etaw;

%% TITLE
han.sfig(kr,kc).Title.String=sprintf('%s=%3.2f',titlestr{kr,kc},time_results(kt)*unitt);

%% DISPLAY
switch dispfig
    case 1
        pause
    case 2
        pause(pausetime)
end
   

end

end %function



