%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18458 $
%$Date: 2022-10-18 18:26:40 +0800 (Tue, 18 Oct 2022) $
%$Author: chavarri $
%$Id: plot_map_2DH_diff_01.m 18458 2022-10-18 10:26:40Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/plot_map_2DH_diff_01.m $
%
%

function plot_map_2DH_diff_01(fid_log,flg_loc,simdef_ref,simdef)

[tag,tag_fig,tag_serie]=gdm_tag_fig(flg_loc);

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag,'do_s'); if ret; return; end

%% DEFAULTS

if isfield(flg_loc,'clims')==0
    flg_loc.clims=[NaN,NaN];
    flg_loc.clims_diff_s=[NaN,NaN];
end

if isfield(flg_loc,'clims_type')==0
    flg_loc.clims_type=1;
end

if isfield(flg_loc,'tim_type')==0
    flg_loc.tim_type=1;
end

if isfield(flg_loc,'do_3D')==0
    flg_loc.do_3D=0;
end

if isfield(flg_loc,'do_s_diff')==0
    flg_loc.do_s_diff=0;
end

if isfield(flg_loc,'var_idx')==0
    flg_loc.var_idx=cell(1,numel(flg_loc.var));
end
var_idx=flg_loc.var_idx;

flg_loc=gdm_parse_plot_along_rkm(flg_loc);

%% PATHS

fdir_mat_ref=simdef_ref.file.mat.dir;
fdir_mat=simdef.file.mat.dir;
fpath_mat_ref=fullfile(fdir_mat_ref,sprintf('%s.mat',tag));
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time_ref=strrep(fpath_mat_ref,'.mat','_tim.mat'); %shuld be the same for reference and non-reference
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat'); %shuld be the same for reference and non-reference
fdir_fig=fullfile(simdef.file.fig.dir,tag_fig,tag_serie);
mkdir_check(fdir_fig);
fpath_map_ref=simdef_ref.file.map;
fpath_map=simdef_ref.file.map;
runid_ref=simdef_ref.file.runid;
runid=simdef.file.runid;

%% LOAD

% load(fpath_mat,'data');
gridInfo_ref=gdm_load_grid(fid_log,fdir_mat_ref,fpath_map_ref);
gridInfo=gdm_load_grid(fid_log,fdir_mat,fpath_map);

tim_ref=load(fpath_mat_time_ref,'tim');
time_dnum_ref=tim_ref.tim.time_dnum;
% time_ref_v=gdm_time_dnum_flow_mor(flg_loc,tim_ref.tim.time_dnum,tim_ref.tim.time_mor_dnum); 
[time_ref_v,~]=gdm_time_flow_mor(flg_loc,simdef_ref,tim_ref.tim.time_dnum,tim_ref.tim.time_dtime,tim_ref.tim.time_mor_dnum,tim_ref.tim.time_mor_dtime); %[nt_ref,1] 

tim=load(fpath_mat_time,'tim');
time_dnum=tim.tim.time_dnum; %time_dnum is the local one
time_mor_dnum=tim.tim.time_mor_dnum;

%% DIMENSIONS

nt=numel(time_dnum_ref);
nclim=size(flg_loc.clims_diff_s,1);
nvar=numel(flg_loc.var);

if flg_loc.do_s_diff==0
    ndiff=1;
else 
    ndiff=2;
end

%%

% max_tot=max(data(:));
[xlims,ylims]=D3D_gridInfo_lims(gridInfo);

%figures
in_p=flg_loc;
in_p.fig_print=1; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
in_p.fig_visible=0;
in_p.xlims=xlims;
in_p.ylims=ylims;
in_p.gridInfo=gridInfo_ref;

fext=ext_of_fig(in_p.fig_print);

%ldb
if isfield(flg_loc,'fpath_ldb')
    in_p.ldb=D3D_read_ldb(flg_loc.fpath_ldb);
end

ktc=0;
messageOut(fid_log,sprintf('Reading %s kt %4.2f %%',tag,ktc/nt*100));

kt_v=gdm_kt_v(flg_loc,nt); %time index vector

for kvar=1:nvar %variable
    varname=flg_loc.var{kvar};
    var_str=D3D_var_num2str_structure(varname,simdef);
    
    in_p.unit=var_str;
    
    fpath_file=cell(nt,nclim);
    
    layer=gdm_layer(flg_loc,gridInfo.no_layers,var_str);
    
    %time 1 for diff
    kt=1;
    time_ref=time_ref_v(kt);

    fpath_mat_tmp=mat_tmp_name(fdir_mat_ref,tag,'tim',time_dnum_ref(kt),'var',var_str,'var_idx',var_idx{kvar},'layer',layer);
%     fpath_mat_tmp=mat_tmp_name(fdir_mat_ref,tag,'tim',time_dnum_ref(kt),'var',var_str);
    data_ref_0=load(fpath_mat_tmp,'data');

    data_0=gdm_match_times_diff_val_2D(flg_loc,time_dnum,time_mor_dnum,time_ref,data_ref_0,fdir_mat,tag,var_str,gridInfo,gridInfo_ref,layer,var_idx{kvar});

    for kt=kt_v
        ktc=ktc+1;
        
        time_ref=time_ref_v(kt);
        in_p.tim=time_ref;

        fpath_mat_tmp=mat_tmp_name(fdir_mat_ref,tag,'tim',time_dnum_ref(kt),'var',var_str,'var_idx',var_idx{kvar},'layer',layer);
        data_ref=load(fpath_mat_tmp,'data');
        
        data=gdm_match_times_diff_val_2D(flg_loc,time_dnum,time_mor_dnum,time_ref,data_ref,fdir_mat,tag,var_str,gridInfo,gridInfo_ref,layer,var_idx{kvar});
        
        %the output from <gdm_match_times_diff_val_2D> is already the difference!
%         data_s_diff=data-data_ref.data; %difference between runs
%         data_st_diff=(data-data_ref.data)-(data_0-data_ref_0.data); %difference between runs and respect to initial conditions
        
        data_s_diff=data; %difference between runs
        data_st_diff=data_s_diff-(data_0-data_ref_0.data); %difference between runs and respect to initial conditions

        data_st_diff_struct.data=data_st_diff; %to pass to function
        
        for kdiff=1:ndiff
            
            kxlim=1; %2DO make loop
            for kclim=1:nclim
                
                [in_p,tag_ref]=gdm_data_diff(in_p,flg_loc,kdiff,kclim,data_s_diff,data_st_diff_struct,'clims_diff_s','clims_diff_st',var_str);
                tag_ref_3D=sprintf('3D_%s',tag_ref);
                
                fdir_fig_var=fullfile(fdir_fig,var_str,tag_ref);
                mkdir_check(fdir_fig_var,NaN,1,0);
                fdir_fig_var_3d=fullfile(fdir_fig,var_str,tag_ref_3D);
                mkdir_check(fdir_fig_var_3d,NaN,1,0);
                fdir_fig_var_diff=fullfile(fdir_fig,var_str,tag_ref);
                mkdir_check(fdir_fig_var_diff,NaN,1,0);
                fdir_fig_var_3d_diff=fullfile(fdir_fig,var_str,tag_ref_3D);
                mkdir_check(fdir_fig_var_3d_diff,NaN,1,0);

                in_p.is_diff=1;

                fname_noext=fig_name(fdir_fig_var,tag_fig,time_dnum(kt),runid,runid_ref,kclim,var_str,tag_ref,num2str(var_idx{kvar}),kxlim);
                fpath_file{kt,kclim}=sprintf('%s%s',fname_noext,fext); %for movie 

                in_p.fname=fname_noext;
                in_p.do_3D=0;  

                fig_map_sal_01(in_p);

                if flg_loc.do_3D

                    fname_noext=fig_name(fdir_fig_var_3d,tag_fig,time_dnum(kt),runid,runid_ref,kclim,var_str,tag_ref_3D,num2str(var_idx{kvar}),kxlim);
                    bol_nan=isnan(in_p.gridInfo.Xcen);
                    F=scatteredInterpolant(in_p.gridInfo.Xcen(~bol_nan),in_p.gridInfo.Ycen(~bol_nan),data(~bol_nan));
                    vz=F(in_p.gridInfo.Xcor,in_p.gridInfo.Ycor);
                    in_p.fname=fname_noext;
                    in_p.do_3D=1;  
    %                 in_p.gridInfo.Zcen=in_p.val;  
                    in_p.gridInfo.Zcor=vz; 
    %                         in_p.fig_visible=1;  
    %                         in_p.fig_print=0;  

                    fig_map_sal_01(in_p);

                end

            end %kclim
        end %kdiff
        
        %% plot along rkm
        %2DO: move to function for cleaning
        if flg_loc.do_plot_along_rkm==1
            rkm_file=flg_loc.rkm_file; %maybe a better name...
            
            nrkm=size(rkm_file{1,1},1);
            for krkm=1:nrkm
                
                in_p.xlims=rkm_file{1,1}(krkm)+[-flg_loc.rkm_tol_x,+flg_loc.rkm_tol_x];
                in_p.ylims=rkm_file{1,2}(krkm)+[-flg_loc.rkm_tol_y,+flg_loc.rkm_tol_y];

                for kclim=1:nclim
                    
                    for kdiff=1:ndiff

                        [in_p,tag_ref]=gdm_data_diff(in_p,flg_loc,kdiff,kclim,data,data_ref,'clims_diff_s','clims_diff_st',var_str);
                        in_p.is_diff=1; %it is difference between simulations!

                        fdir_fig_var=fullfile(fdir_fig,var_str,num2str(var_idx{kvar}),'rkm',datestr(time_dnum(kt),'yyyymmddHHMMSS'),tag_ref);
                        mkdir_check(fdir_fig_var,NaN,1,0);
                        
                        fname_noext=fig_name(fdir_fig_var,sprintf('%s_rkm',tag_fig),time_dnum(kt),runid,runid_ref,kclim,var_str,tag_ref,num2str(var_idx{kvar}),krkm);
                        fpath_file{kt,kclim,kdiff,kxlim,1}=sprintf('%s%s',fname_noext,fext); %for movie 

                        in_p.fname=fname_noext;
                        in_p.do_3D=0; %maybe also add 3D?
                        

                        fig_map_sal_01(in_p);
                    end %kdiff
                end %kclim
            end %krkm
        end %do
        
        %% disp
        
        messageOut(fid_log,sprintf('Reading %s kt %4.2f %%',tag_fig,ktc/nt*100));
        
    end %kt
    
    %% movies

    for kclim=1:nclim
        fpath_mov=fpath_file(:,kclim);
        gdm_movie(fid_log,flg_loc,fpath_mov,time_dnum);   
    end
    
end %kvar

end %function

%% 
%% FUNCTION
%%

function fpath_fig=fig_name(fdir_fig,tag,tnum,runid,runid_ref,kclim,var_str,tag_ref,var_idx,kxlim)

fpath_fig=fullfile(fdir_fig,sprintf('%s_%s-%s_%s%s_%s_%s_clim_%02d_xlim_%02d',tag,runid,runid_ref,var_str,var_idx,tag_ref,datestr(tnum,'yyyymmddHHMMSS'),kclim,kxlim));

end %function

%%

function val=gdm_match_times_diff_val_2D(flg_loc,time_dnum,time_mor_dnum,time_ref,data_ref,fdir_mat,tag,var_str,gridInfo,gridInfo_ref,layer,var_idx_loc)

%% PARSE

tol_tim=1; %tolerance to match objective day with available day
if isfield(flg_loc,'tol_tim')
    tol_tim=flg_loc.tol_tim;
end

%% CALC

size_data=size(data_ref.data);

time_loc_v=gdm_time_dnum_flow_mor(flg_loc,time_dnum,time_mor_dnum); %[nt_loc,1]

[kt_loc,min_v,flg_found]=absmintol(time_loc_v,time_ref,'tol',tol_tim,'do_break',0,'do_disp_list',0,'dnum',1);
if ~flg_found
    messageOut(fid_log,'No available reference data:');
    messageOut(fid_log,sprintf('     reference time   : %s',datestr(time_ref      ,'yyyy-mm-dd HH:MM:SS')));
    messageOut(fid_log,sprintf('     closest   time   : %s',datestr(time_loc_v(kt_loc),'yyyy-mm-dd HH:MM:SS')));

    val=NaN(size_data);
else
    fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt_loc),'var',var_str,'var_idx',var_idx_loc,'layer',layer);
    data=load(fpath_mat_tmp,'data');

    val=D3D_diff_val(data.data,data_ref.data,gridInfo,gridInfo_ref);
end    

end %function