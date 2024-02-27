%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18455 $
%$Date: 2022-10-17 13:25:35 +0800 (Mon, 17 Oct 2022) $
%$Author: chavarri $
%$Id: plot_grid_01.m 18455 2022-10-17 05:25:35Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/plot_grid_01.m $
%
%

function plot_grid_01(fid_log,flg_loc,simdef)

[tag,tag_fig,tag_serie]=gdm_tag_fig(flg_loc);

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

if isfield(flg_loc,'xlims')==0
    flg_loc.xlims=[NaN,NaN];
    flg_loc.ylims=[NaN,NaN];
end

flg_loc=gdm_parse_plot_along_rkm(flg_loc);

flg_loc.plot_pol=0;
if isfield(flg_loc,'pol')==1
    flg_loc.plot_pol=1;
end

%% PATHS

fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
fdir_fig=fullfile(simdef.file.fig.dir,tag_fig,tag_serie);
mkdir_check(fdir_fig);
% fpath_map=simdef.file.map;
% fpath_grd=simdef.file.mat.grd;
fpath_grd=simdef.file.grd;
runid=simdef.file.runid;

%% LOAD

gridInfo=gdm_load_grid(fid_log,fdir_mat,'');
[ismor,is1d,str_network1d,issus]=D3D_is(fpath_grd);

%% DIMENSIONS

% nclim=size(flg_loc.clims,1); %why clims in the grid?
nxlim=size(flg_loc.xlims,1);
nvar=1; %for when we plot orthogonality

%%

[xlims_all,ylims_all]=D3D_gridInfo_lims(gridInfo);

%figures
in_p=flg_loc;
% in_p.fig_print=1; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
% in_p.fig_visible=0;
in_p.gridInfo=gridInfo;
in_p=gdm_read_plot_along_rkm(in_p,flg_loc);

fext=ext_of_fig(in_p.fig_print);

%ldb
if isfield(flg_loc,'fpath_ldb')
    in_p.ldb=D3D_read_ldb(flg_loc.fpath_ldb);
end

%pol
if flg_loc.plot_pol
    np=numel(flg_loc.pol);
    pol=cell(np,1);
    for kp=1:np
        pol{kp,1}=D3D_io_input('read',flg_loc.pol{kp},'xy_only',true); %maybe it gives problems if it is not shp due to parsing 
    end
    in_p.pol=pol;
end

for kvar=1:nvar %variable

    var_str='grid';
        
    for kxlim=1:nxlim

        %xlim
        xlims=flg_loc.xlims(kxlim,:);
        ylims=flg_loc.ylims(kxlim,:);
        if isnan(xlims(1))
            xlims=xlims_all;
            ylims=ylims_all;
        end
        in_p.xlims=xlims;
        in_p.ylims=ylims;

        fname_noext=fig_name(fdir_fig,tag,runid,var_str,kxlim);

        in_p.fname=fname_noext;

        switch simdef.D3D.structure
            case 1
                error('do. I think that reading with EHY should pass to the case of FM')
            case 2
                if is1d 
                    fig_grid_1D_01(in_p);
                else
                    fig_grid_2D_01(in_p);
                end
        end

    end %kxlim
    
    %% plot along rkm
    if ~is1d && flg_loc.do_plot_along_rkm==1
                    
        %2DO: move to function for cleaning
%         fid=fopen(flg_loc.fpath_rkm_plot_along,'r');
%         rkm_file=textscan(fid,'%f %f %s %f','headerlines',1,'delimiter',',');
%         fclose(fid);
        rkm_file=flg_loc.rkm_file; %maybe a better name...
        
        fdir_fig_loc=fullfile(fdir_fig,'rkm');
        mkdir_check(fdir_fig_loc,NaN,1,0);
        
        nrkm=size(flg_loc.rkm_file{1,1},1);
        for krkm=1:nrkm

            in_p.xlims=rkm_file{1,1}(krkm)+[-flg_loc.rkm_tol_x,+flg_loc.rkm_tol_x];
            in_p.ylims=rkm_file{1,2}(krkm)+[-flg_loc.rkm_tol_y,+flg_loc.rkm_tol_y];

            fname_noext=fig_name(fdir_fig_loc,tag,sprintf('%s_rkm',runid),var_str,krkm);

            in_p.fname=fname_noext;

            fig_grid_2D_01(in_p);
        end %krkm
    end %do
        
end %kvar

end %function

%% 
%% FUNCTION
%%

function fpath_fig=fig_name(fdir_fig,tag,runid,var_str,kxlim)

fpath_fig=fullfile(fdir_fig,sprintf('%s_%s_%s_xlim_%02d',tag,runid,var_str,kxlim));

end %function