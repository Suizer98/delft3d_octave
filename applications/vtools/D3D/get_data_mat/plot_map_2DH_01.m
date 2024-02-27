%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18415 $
%$Date: 2022-10-10 19:07:38 +0800 (Mon, 10 Oct 2022) $
%$Author: chavarri $
%$Id: plot_map_2DH_01.m 18415 2022-10-10 11:07:38Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/plot_map_2DH_01.m $
%
%

function plot_map_2DH_01(fid_log,flg_loc,simdef)

[tag,tag_fig,tag_serie]=gdm_tag_fig(flg_loc);

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag,'do_p'); if ret; return; end

%%

%% DEFAULTS

% if isfield(flg_loc,'background')==0
%     flg_loc.background=NaN
% end

if isfield(flg_loc,'clims')==0
    flg_loc.clims=[NaN,NaN];
    flg_loc.clims_diff_t=[NaN,NaN];
end
if isfield(flg_loc,'clims_diff_t')==0
    flg_loc.clims_diff_t=flg_loc.clims;
end

if isfield(flg_loc,'do_diff')==0
    flg_loc.do_diff=1;
end

if isfield(flg_loc,'xlims')==0
    flg_loc.xlims=[NaN,NaN];
    flg_loc.ylims=[NaN,NaN];
end

if isfield(flg_loc,'tim_type')==0
    flg_loc.tim_type=1;
end

if isfield(flg_loc,'var_idx')==0
    flg_loc.var_idx=cell(1,numel(flg_loc.var));
end
var_idx=flg_loc.var_idx;

if isfield(flg_loc,'clims_type')==0
    flg_loc.clims_type=1; %constant values
end

if isfield(flg_loc,'do_vector')==0
    flg_loc.do_vector=zeros(1,numel(flg_loc.var));
end

if isfield(flg_loc,'do_3D')==0
    flg_loc.do_3D=0;
end

flg_loc=gdm_parse_plot_along_rkm(flg_loc);

%% PATHS

fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
fdir_fig=fullfile(simdef.file.fig.dir,tag_fig,tag_serie);
mkdir_check(fdir_fig);
fpath_map=simdef.file.map;
% fpath_grd=simdef.file.mat.grd;
runid=simdef.file.runid;

%% LOAD

% load(fpath_mat,'data');
gridInfo=gdm_load_grid(fid_log,fdir_mat,fpath_map);

load(fpath_mat_time,'tim');
v2struct(tim); %time_dnum, time_dtime

%% DEPENDENT INPUT

switch flg_loc.clims_type
    case 2
        if isfield(flg_loc,'clims_type_var')==0
            flg_loc.clims_type_var=time_dnum(1); 
        end
end

%% DIMENSIONS

nt=size(time_dnum,1);
nclim=size(flg_loc.clims,1);
nvar=numel(flg_loc.var);
nxlim=size(flg_loc.xlims,1);

%%

% max_tot=max(data(:));
[xlims_all,ylims_all]=D3D_gridInfo_lims(gridInfo);

%figures
in_p=flg_loc;
in_p.fig_print=1; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
in_p.fig_visible=0;
in_p.gridInfo=gridInfo;
in_p=gdm_read_plot_along_rkm(in_p,flg_loc);

fext=ext_of_fig(in_p.fig_print);

%ldb
if isfield(flg_loc,'fpath_ldb')
    in_p.ldb=D3D_read_ldb(flg_loc.fpath_ldb);
end

ktc=0;
messageOut(fid_log,sprintf('Reading %s kt %4.2f %%',tag,ktc/nt*100));

kt_v=gdm_kt_v(flg_loc,nt); %time index vector

if flg_loc.do_diff==0
    ndiff=1;
else 
    ndiff=2;
end

for kvar=1:nvar %variable
    varname=flg_loc.var{kvar};
    var_str=D3D_var_num2str_structure(varname,simdef);
    
    in_p.unit=var_str;
    switch var_str
        case {'T_max','T_da','T_surf'}
            in_p.fact=1/3600/24;
        otherwise
            in_p.fact=1;
    end
    
    layer=gdm_layer(flg_loc,gridInfo.no_layers,var_str);
    
    %time 1 for difference
    kt=1;
    fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'var',var_str,'var_idx',var_idx{kvar},'layer',layer);
    data_ref=load(fpath_mat_tmp,'data');
    if any(simdef.D3D.structure==[2,4]) && sum(size(data_ref.data)==1)==0 || size(data_ref.data,3)>1 %in D3D4 2D data has matrix form
        messageOut(fid_log,sprintf('Cannot plot variable with more than 1 dimension: %s',var_str))
        continue
    end
    
    fpath_file=cell(nt,nclim,ndiff,2); %2D,3D
    for kt=kt_v
        ktc=ktc+1;
        fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'var',var_str,'var_idx',var_idx{kvar},'layer',layer);
        load(fpath_mat_tmp,'data');
        
        switch flg_loc.tim_type
            case 1
                in_p.tim=time_dnum(kt);
            case 2
                in_p.tim=time_mor_dnum(kt);
        end
        
        %load vector
        if flg_loc.do_vector(kvar)
            fpath_mat_tmp=mat_tmp_name(fdir_mat,'uv','tim',time_dnum(kt),'var_idx',var_idx{kvar});
            data_uv=load(fpath_mat_tmp,'data');
            in_p.vec_x=data_uv.data.vel_x;
            in_p.vec_y=data_uv.data.vel_y;
        end
        
        for kclim=1:nclim
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

                for kdiff=1:ndiff
                    
                    [in_p,tag_ref]=gdm_data_diff(in_p,flg_loc,kdiff,kclim,data,data_ref,'clims','clims_diff_t',var_str);

                    fdir_fig_var=fullfile(fdir_fig,var_str,num2str(var_idx{kvar}),tag_ref);
                    mkdir_check(fdir_fig_var,NaN,1,0);

                    fname_noext=fig_name(fdir_fig_var,tag,runid,time_dnum(kt),kdiff,kclim,var_str,kxlim,num2str(var_idx{kvar}));
                    fpath_file{kt,kclim,kdiff,kxlim,1}=sprintf('%s%s',fname_noext,fext); %for movie 

                    in_p.fname=fname_noext;
                    in_p.do_3D=0;

                    fig_map_sal_01(in_p);
                    
                    if flg_loc.do_3D
                        fdir_fig_var=fullfile(fdir_fig,var_str,num2str(var_idx{kvar}),'3D',tag_ref);
                        mkdir_check(fdir_fig_var,NaN,1,0);
                        
                        fname_noext=fig_name(fdir_fig_var,sprintf('%s_3D',tag),runid,time_dnum(kt),kdiff,kclim,var_str,kxlim,num2str(var_idx{kvar}));
                        fpath_file{kt,kclim,kdiff,kxlim,2}=sprintf('%s%s',fname_noext,fext); %for movie 

                        in_p.fname=fname_noext;
                        in_p.do_3D=1;  
                        in_p.gridInfo.Zcen=in_p.val;  
%                         in_p.fig_visible=1;  
%                         in_p.fig_print=0;  
                        
                        fig_map_sal_01(in_p);

                    end
                    
                end %kdiff
            end%kxlim
        end %kclim
        
        %% plot along rkm
        %2DO: move to function for cleaning
        if flg_loc.do_plot_along_rkm==1
            %parsed in <flg_loc>
%             fid=fopen(flg_loc.fpath_rkm_plot_along,'r');
%             rkm_file=textscan(fid,'%f %f %s %f','headerlines',1,'delimiter',',');
%             fclose(fid);
            rkm_file=flg_loc.rkm_file; %maybe a better name...
            
            nrkm=size(rkm_file{1,1},1);
            for krkm=1:nrkm
                
                in_p.xlims=rkm_file{1,1}(krkm)+[-flg_loc.rkm_tol_x,+flg_loc.rkm_tol_x];
                in_p.ylims=rkm_file{1,2}(krkm)+[-flg_loc.rkm_tol_y,+flg_loc.rkm_tol_y];

                for kclim=1:nclim
                    
                    for kdiff=1:ndiff

                        [in_p,tag_ref]=gdm_data_diff(in_p,flg_loc,kdiff,kclim,data,data_ref,'clims','clims_diff_t',var_str);

                        fdir_fig_var=fullfile(fdir_fig,var_str,num2str(var_idx{kvar}),'rkm',datestr(time_dnum(kt),'yyyymmddHHMMSS'),tag_ref);
                        mkdir_check(fdir_fig_var,NaN,1,0);

                        fname_noext=fig_name(fdir_fig_var,tag,sprintf('%s_rkm',runid),time_dnum(kt),kdiff,kclim,var_str,krkm,num2str(var_idx{kvar}));
                        fpath_file{kt,kclim,kdiff,kxlim,1}=sprintf('%s%s',fname_noext,fext); %for movie 

                        in_p.fname=fname_noext;
                        in_p.do_3D=0; %maybe also add 3D?

                        fig_map_sal_01(in_p);
                    end %kdiff
                end %kclim
            end %krkm
        end %do
        
        %% disp
        messageOut(fid_log,sprintf('Reading %s kt %4.2f %%',tag,ktc/nt*100));
    end %kt
    
    %% movies
    
    for kdiff=1:ndiff
        for kclim=1:nclim
            for kxlim=1:nxlim
                fpath_mov=fpath_file(:,kclim,kdiff,kxlim,1);
                gdm_movie(fid_log,flg_loc,fpath_mov,time_dnum);   
                if flg_loc.do_3D
                    fpath_mov=fpath_file(:,kclim,kdiff,kxlim,2);
                    gdm_movie(fid_log,flg_loc,fpath_mov,time_dnum);   
                end
            end
        end
    end
    
end %kvar

end %function

%% 
%% FUNCTION
%%

function fpath_fig=fig_name(fdir_fig,tag,runid,tnum,kref,kclim,var_str,kxlim,var_idx)

fpath_fig=fullfile(fdir_fig,sprintf('%s_%s_%s%s_%s_clim_%02d_xlim_%02d_ref_%02d',tag,runid,var_str,var_idx,datestr(tnum,'yyyymmddHHMMSS'),kclim,kxlim,kref));

end %function