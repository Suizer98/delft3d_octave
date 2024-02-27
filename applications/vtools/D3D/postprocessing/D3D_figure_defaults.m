%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17190 $
%$Date: 2021-04-15 16:24:15 +0800 (Thu, 15 Apr 2021) $
%$Author: chavarri $
%$Id: D3D_figure_defaults.m 17190 2021-04-15 08:24:15Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/postprocessing/D3D_figure_defaults.m $
%
%plot of 1D volume fraction 2

function simdef=D3D_figure_defaults(simdef)

flg=simdef.flg;

if isfield(flg,'print')==0
    flg.print=0;
end

if isfield(flg,'prnt_size')==0
    flg.prnt_size=[0,0,25.4,19.05];
end

if isfield(flg,'prop')==0
    flg.prop.dummy=NaN;
end

if isfield(flg.prop,'edgecolor')==0
    flg.prop.edgecolor='k'; %edge color in surf plot
end

if isfield(flg,'cbar')==0
        flg.cbar.displacement=[0,0,0,0];
else
    if isfield(flg.cbar,'displacement')==0
        
    end
end

if isfield(flg,'marg')==0
    flg.marg.mt=2.5; %top margin [cm]
    flg.marg.mb=1.5; %bottom margin [cm]
    flg.marg.mr=2.5; %right margin [cm]
    flg.marg.ml=2.5; %left margin [cm]
    flg.marg.sh=1.0; %horizontal spacing [cm]
    flg.marg.sv=0.0; %vertical spacing [cm]
end

if isfield(flg.prop,'fs')==0
    flg.prop.fs=12;
end

if isfield(flg,'addtitle')==0
    flg.addtitle=1;
end

if isfield(flg,'language')==0
    flg.language='en';
end

if isfield(flg,'fig_visible')==0
    if flg.print>=1
        flg.fig_visible=0;
    else
        flg.fig_visible=1;
    end
end

if isfield(flg,'plot_unitx')==0
    flg.plot_unitx=1;
end

if isfield(flg,'plot_unity')==0
    flg.plot_unity=1;
end

if isfield(flg,'plot_unitz')==0
    flg.plot_unitz=1;
end

if isfield(flg,'plot_unitt')==0
    flg.plot_unitt=1;
end

if isfield(flg,'equal_axis')==0
    flg.equal_axis=0;
end

if isfield(flg,'add_tiles')==0
    flg.add_tiles=0;
end

if isfield(flg,'elliptic')==0
    flg.elliptic=0;
end

if isfield(flg,'fig_faceindices')==0
   flg.fig_faceindices=0;
end

if isfield(flg,'YScale')==0
   flg.YScale='linear';
end

%% OUT

simdef.flg=flg;

end %function