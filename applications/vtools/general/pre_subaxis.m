%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: pre_subaxis.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/pre_subaxis.m $
%
% npr=1; %number of plot rows
% npc=1; %number of plot columns
% marg.mt=1.0; %top margin [cm]
% marg.mb=2.0; %bottom margin [cm]
% marg.mr=4.0; %right margin [cm]
% marg.ml=2.0; %left margin [cm]
% marg.sh=0.0; %horizontal spacing [cm]
% marg.sv=0.0; %vertical spacing [cm]
% 
% [mt,mb,mr,ml,sh,sv]=pre_subaxis(h.fig,marg.mt,marg.mb,marg.mr,marg.ml,marg.sh,marg.sv);
% h.sfig=subaxis(npr,npc,1,1,1,1,'mt',mt,'mb',mb,'mr',mr,'ml',ml,'sv',sv,'sh',sh);



function [mt,mb,mr,ml,sh,sv]=pre_subaxis(handle,mt_i,mb_i,mr_i,ml_i,sh_i,sv_i)

dim=get(handle,'paperposition');
width=dim(3);
height=dim(4);

mt=mt_i/height;
mb=mb_i/height;
mr=mr_i/width;
ml=ml_i/width;
sh=sh_i/width;
sv=sv_i/height;

