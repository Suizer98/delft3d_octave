%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17855 $
%$Date: 2022-03-25 14:31:33 +0800 (Fri, 25 Mar 2022) $
%$Author: chavarri $
%$Id: D3D_plot_domain_number.m 17855 2022-03-25 06:31:33Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_plot_domain_number.m $
%
%bnd file creation

function D3D_plot_domain_number(fdir_sim,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'ldb',{});
addOptional(parin,'fig_print',0);
addOptional(parin,'fig_path','');

parse(parin,varargin{:})

ldb=parin.Results.ldb;
fig_print=parin.Results.fig_print;
fig_path=parin.Results.fig_path;

%% PATHS

simdef.D3D.dire_sim=fdir_sim;
simdef=D3D_simpath(simdef);
fpath_map=simdef.file.map;

%% CALC

gridInfo=EHY_getGridInfo(fpath_map,{'XYcen','domain_number','face_nodes_xy'});

[domain_u,idx1,idx2]=unique(gridInfo.domain_number);

%% PLOT

figure
hold on
%IMPROVE
%random colors rather than ordered per domain number will help to differentiate between domains.
EHY_plotMapModelData(gridInfo,gridInfo.domain_number)
% scatter(gridInfo.Xcen,gridInfo.Ycen,10,gridInfo.domain_number)
axis equal
nu=numel(domain_u);
for ku=1:nu
    bol_d=idx2==ku;
    xm=mean(gridInfo.Xcen(bol_d));
    ym=mean(gridInfo.Ycen(bol_d));
    text(xm,ym,num2str(domain_u(ku)),'color','r')
end

if ~isempty(ldb)
    ldb=D3D_read_ldb(fpath_ldb);
    nldb=numel(ldb);
    for kldb=1:nldb
        plot(ldb(kldb).cord(:,1),ldb(kldb).cord(:,2),'color','k','linewidth',1,'linestyle','-','marker','none')
    end
end

%% SAVE

if isempty(fig_path)
    fig_path=fullfile(fdir_sim,'figures','domain_number');
    mkdir_check(fig_path);
end

if any(fig_print==1)
    fpath_fig=fullfile(fig_path,'domain_number.fig');
    savefig(gcf,fpath_fig);
end

end %function