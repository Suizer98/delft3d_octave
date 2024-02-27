%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17494 $
%$Date: 2021-09-22 20:24:01 +0800 (Wed, 22 Sep 2021) $
%$Author: chavarri $
%$Id: D3D_compare_batch.m 17494 2021-09-22 12:24:01Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/postprocessing/D3D_compare_batch.m $
%
%

function D3D_compare_batch(input_m,flg)

%% PARSE

% parin=inputParser;
% 
% addOptional(parin,'fdir_fig',pwd);
% 
% parin=parse(varargin{:});
% 
% fdir_fig=parin.Results.fdir_fig;

if isfield(flg,'fdir_fig')==0
    flg.fdir_fig=pwd;
end

v2struct(flg);

%% CALC

mkdir_check(fdir_fig)

messageOut(NaN,'Initializing')

nt=numel(kt_v);
ns=numel(input_m.sim);

%% LOOP ON FIRST TIME 

in_read.kt=1;
simdef.flg.get_cord=0;
simdef.flg.get_EHY=0;
simdef.flg.which_v=33;
simdef.flg.which_p=2;

% gridInfo_all=struct();
c_area=cell(ns,1);
dx_all=NaN(ns,1);
ncells=NaN(ns,1);
for ks=1:ns
    
    %paths
    path_sim=input_m.sim(ks).path_sim;
    simdef.D3D.dire_sim=path_sim;
    simdef=D3D_simpath(simdef);
    
    %time
    %based only on reference. Maybe take all and do a check 
    if ks==ks_ref
        [ismor,~,~]=D3D_is(simdef.file.map);
        [time_r,time_mor_r,time_dnum]=D3D_results_time(simdef.file.map,ismor,[1,Inf]);
        ntt=numel(time_dnum);
        kt_v_loc=kt_v;
        kt_v_loc(isnan(kt_v_loc))=ntt;
        time_dnum_kt=time_dnum(kt_v_loc);
        if ismor
        time_mor_r_kt=time_mor_r(kt_v_loc);
        end
        time_r_kt=time_r(kt_v_loc);
        kt_v=kt_v_loc;
%         if ks==1
%             kt_v_pre=kt_v_loc;
%         end
%         if sum(kt_v_loc-kt_v_pre)~=0
%             warning('The final time is different for varying simulations')
%         end
%         kt_v_pre=kt_v_loc;
    end
    
    %grid
    gridInfo_all(ks)=EHY_getGridInfo(simdef.file.map,{'XYcen','face_nodes_xy','XYcor'});
    
    %in this way we also get D3D4. Check if correct when needed.
%     in_read.kt=1;
%     simdef.flg.get_cord=1;
%     simdef.flg.get_EHY=1;
%     simdef.flg.which_v=which_v;
%     out_read=D3D_read(simdef,in_read);
% 
%     if isfield(out_read,'face_nodes_x')
%         gridInfo.face_nodes_x=out_read.face_nodes_x;
%         gridInfo.face_nodes_y=out_read.face_nodes_y;
%     else
%         gridInfo.Xcor=out_read.Xcor;
%         gridInfo.Ycor=out_read.Ycor;
%     end

    %cell area
    simdef.flg.which_v=33;
    out_read=D3D_read(simdef,in_read);
    c_area{ks}=out_read.z;
    
    %flow link length
    dx_all(ks)=mean(D3D_flow_link_length(simdef.file.map));
    
    %number of cells
    ncells(ks)=size(gridInfo_all(ks).face_nodes_x,2);
end

%check if all grids are the same
different_grids=0;
if any(ncells-ncells(1))
    different_grids=1;
end

val_ref=squeeze(c_area{ks_ref});
np=numel(val_ref);

val_all=cell(ns,nt);
if different_grids
val_int=NaN(np,ns,nt);
end

%set back to variable prior to loop
simdef.flg.get_cord=0;
simdef.flg.get_EHY=0;
simdef.flg.which_s=5; %for using EHY plot in case of D3D

%variable to pass to title and convergence
switch conv_vari
    case 1
        var_tit=dx_all;
        var_tit_name='link len. [m]';
    otherwise 
        error('ups...')
end

%simulation order
%deal first with reference for having it for plotting
sim_v=1:ns;
sim_v(ks_ref)=[];
sim_v=[ks_ref,sim_v];

%% VARIABLE LOOP
nv=numel(which_v);
for kv=1:nv
simdef.flg.which_v=which_v(kv);
%% TIME LOOP
for kt=1:nt    
    in_read.kt=kt_v(kt);
    %% SIMULATION LOOP
    for ks=sim_v

        messageOut(NaN,sprintf('dealing with variable %4.2f %% simulation %4.2f %% time %4.2f %%',kt/nt*100,ks/ns*100,kt/nt*100))

        path_sim=input_m.sim(ks).path_sim;
        simdef.D3D.dire_sim=path_sim;
        simdef=D3D_simpath(simdef);

        switch flg.read_data 
            case 1 %general
                out_read=D3D_read(simdef,in_read);
                val_l=out_read.z;
                val_label=out_read.zlabel;
                
                %2DO read the grid outside the time loop and save it
%                 if isfield(out_read,'face_nodes_x')
%                     gridInfo_loc.face_nodes_x=out_read.face_nodes_x;
%                     gridInfo_loc.face_nodes_y=out_read.face_nodes_y;
%                 else
%                     gridInfo_loc.Xcor=out_read.Xcor;
%                     gridInfo_loc.Ycor=out_read.Ycor;
%                 end
            case 2 %particular
                switch which_v
                    case 1
                        val_l=ncread(simdef.file.map,'mesh2d_mor_bl',[1,in_read.kt],[Inf,1]);
                        val_label='bed elevation [m]';
                    otherwise 
                        error('ups')
                end
            otherwise
                error('ups')
        end

        val_all{ks,kt}=val_l;
        
        %interpolate on same grid
        if different_grids
            Fint=scatteredInterpolant(gridInfo_all(ks).Xcen,gridInfo_all(ks).Ycen,val_l,'nearest','nearest');
            val_int(:,ks,kt)=Fint(gridInfo_all(ks_ref).Xcen,gridInfo_all(ks_ref).Ycen);
        else
            val_int(:,ks,kt)=val_l;
        end
        
        %% PLOT
        if flg.plot_var_diff==1 || (flg.plot_var_diff==2 && any(kt==[1,nt]))
            
            tim_str=datestr(time_dnum_kt(kt),'yyyy-mm-dd_HH-MM-SS');

            in_p.fname=fullfile(fdir_fig,sprintf('var_diff_%02d_sim_%03d_%03d_t_%s',simdef.flg.which_v,input_m.sim(ks_ref).sim_num,input_m.sim(ks).sim_num,tim_str));
            
            in_p.gridInfo_1=gridInfo_all(ks_ref);
            in_p.val_1=val_all{ks_ref,kt};
            in_p.fixed_weir_1=NaN;
            in_p.do_1=true;
            in_p.tit_1=sprintf('%s %s = %f',conv_categ_names{conv_categ(ks_ref)},var_tit_name,var_tit(ks_ref)); %move to definition 
            
            in_p.gridInfo_2=gridInfo_all(ks);
            in_p.val_2=val_all{ks,kt};
            in_p.fixed_weir_2=NaN; 
            in_p.do_2=true;
            in_p.tit_2=sprintf('%s %s = %f',conv_categ_names{conv_categ(ks)},var_tit_name,var_tit(ks)); %move to definition 
            
            in_p.gridInfo_diff=gridInfo_all(ks_ref);
            in_p.val_diff=val_int(:,ks,kt)-val_int(:,ks_ref,kt);
            
            in_p.part_pli=NaN;
            in_p.axis_eq=axis_eq;
            in_p.log_val=0;
            if ismor
                in_p.tim_str=sprintf('time = %f s',time_mor_r_kt(kt)); %tim_str;
            else
                in_p.tim_str=sprintf('time = %f s',time_r_kt(kt)); %tim_str;
            end
            in_p.val_label=val_label;
            
            if isfield(out_read,'z_size')
                in_p.val_1_size=out_read.z_size;
                in_p.val_2_size=out_read.z_size;
                in_p.val_diff_size=out_read.z_size;
            end

            D3D_fig_cmp_compare(in_p);
            
            if log_val==1
                in_p.log_val=1;
                in_p.fname=fullfile(fdir_fig,sprintf('var_diff_log_%02d_sim_%03d_%03d_t_%s',simdef.flg.which_v,input_m.sim(ks_ref).sim_num,input_m.sim(ks).sim_num,tim_str));
                D3D_fig_cmp_compare(in_p);
            end
        end %plot_var_diff

    end %ks
end %kt

%% SAVE

if ismor
    data=v2struct(time_dnum_kt,time_r_kt,time_mor_r_kt,gridInfo_all,val_all,val_int,c_area,simdef,tag_cmp,input_m,val_label);
else
    data=v2struct(time_dnum_kt,time_r_kt,              gridInfo_all,val_all,val_int,c_area,simdef,tag_cmp,input_m,val_label);
end

path_val_mat=fullfile(fdir_fig,sprintf('data_%02d.mat',which_v(kv)));
save(path_val_mat,'data')

%% clean label

tok=regexp(val_label,'[','split');
val_label_str=tok{1,1};
val_label_uni=sprintf('[%s',tok{1,2});

%% norms

kval=0;

kval=kval+1;
norms_label{kval,1}='St. Bert''s number';
norms_label{kval,2}='B_num';
norms_label{kval,3}='[-]';

kval=kval+1;
norms_label{kval,1}='max. abs. diff.';
norms_label{kval,2}='max_abs_diff';
norms_label{kval,3}=val_label_uni;

kval=kval+1;
norms_label{kval,1}='std. diff.';
norms_label{kval,2}='std_diff';
norms_label{kval,3}=val_label_uni;

kval=kval+1;
norms_label{kval,1}='norm';
norms_label{kval,2}='norm';
norms_label{kval,3}=val_label_uni;

nval=size(norms_label,1);

norms=NaN(ns,ns,nt,nval); %[sim,ref,time,val]; val=[Berts number, max. abs. diff., std]

for kt=1:nt
    %Berts #
    B_aux=sum((abs(val_int(:,:,kt)-val_int(:,:,1)).*c_area{ks_ref}),1)./sum(c_area{ks_ref});
    norms(:,:,kt,1)=abs(B_aux-B_aux.')./B_aux.';
    
    %max abs diff
    for ks=1:ns
        norms(ks,:,kt,2)=max(abs(val_int(:,:,kt)-val_int(:,ks,kt)),[],1);
    end
    
    %std
    for ks=1:ns
        norms(ks,:,kt,3)=std(val_int(:,:,kt)-val_int(:,ks,kt));
    end
    
    %std
    for ks=1:ns
        norms(ks,:,kt,4)=norm(abs(val_int(:,:,kt)-val_int(:,ks,kt)));
    end
end

%clean upper diagonal
norms_diag=norms;
for ks=1:ns
    for ks2=1:ns
        if ks>ks2
            norms_diag(ks,ks2,:,:)=NaN;
        end
    end
end

%% PLOT matrix norms

kt=nt;
time_str=datestr(time_dnum_kt(kt),'yyyy-mm-dd HH-MM-SS');

in_b.fig_print=1;
in_b.fig_visible=0;
in_b.sim_v=[input_m.sim.sim_num];
in_b.tit=sprintf('time %s',time_str);

for kval=1:nval    
    in_b.B_m=norms_diag(:,:,kt,kval);
    in_b.fname=fullfile(fdir_fig,sprintf('%s_v_%02d_tag_%s_t_%s',norms_label{kval,2},simdef.flg.which_v,tag_cmp,time_str));
    in_b.c_label={norms_label{kval,1},sprintf('%s%s',val_label_str,norms_label{kval,3})};

    D3D_fig_cmp_norms(in_b)
end

%% histogram

nbin=10;
for kval=1:nval
    cou=NaN(nbin,nt);
    edg=NaN(nbin+1,nt);
    for kt=1:nt
        [cou(:,kt),edg(:,kt)]=histcounts(norms_diag(:,:,kt,kval),nbin);
        if ~any(cou(:,kt))
            cou(:,kt)=NaN;
            edg(:,kt)=NaN;
        end
    end
    
    in_h.fname=fullfile(fdir_fig,sprintf('%s_hisc_v_%02d_tag_%s',norms_label{kval,2},simdef.flg.which_v,tag_cmp));
    in_h.edg=edg;
    in_h.cou=cou;
    if ismor
        in_h.time_r=time_mor_r_kt;
    else
        in_h.time_r=time_r_kt;
    end
    in_h.val_label={norms_label{kval,1},sprintf('%s%s',val_label_str,norms_label{kval,3})};
    in_h.lims_y=NaN;
    
    D3D_fig_cmp_hisc(in_h);
    
end

%% PLOT norm of all simulation for all times 

for kval=1:nval
    for ks=1:ns
        in_p4.norm_sim=squeeze(norms(ks,:,:,kval));
        in_p4.sim_names=cellfun(@(X)num2str(X),{input_m.sim(:).sim_id},'UniformOutput',false);
        in_p4.lims_y=[NaN,NaN];
        in_p4.val_label={norms_label{kval,1},sprintf('%s%s',val_label_str,norms_label{kval,3})};

        %morpho time
        in_p4.fname=fullfile(fdir_fig,sprintf('%s_tmor_v_%02d_tag_%s_ref_%s',norms_label{kval,2},simdef.flg.which_v,tag_cmp,input_m.sim(ks).sim_id));
        if ismor
            in_p4.tim_v=time_mor_r_kt;
        else
            in_p4.tim_v=time_r_kt;
        end

        D3D_fig_cmp_norm_t(in_p4);
        
        %flow time
%         in_p4.fname=fullfile(path_fig_out,sprintf('%s_tflow_v_%02d_tag_%s_ref_%s',norms_label{kval,2},simdef.flg.which_v,tag_cmp,input_m.sim(ks).sim_id));
%         in_p4.tim_v=time_r;
% 
%         fig_norm_t(in_p4);
    end
end

%% convergence

for kval=1:nval
    for kt=1:nt
        time_str=datestr(time_dnum_kt(kt),'yyyy-mm-dd HH-MM-SS');
        
        in_pc.fname=fullfile(fdir_fig,sprintf('conv_%s_v_%02d_tag_%s_ref_%s_%s',norms_label{kval,2},simdef.flg.which_v,tag_cmp,input_m.sim(ks).sim_id,time_str));
        in_pc.fig_visible=0;
        in_pc.fig_print=1;
        
        in_pc.norms=norms(:,ks_ref,kt,kval);
        in_pc.dx=dx_all;
        in_pc.conv_categ_names=conv_categ_names;
        in_pc.conv_categ=conv_categ;
        in_pc.var_tit=var_tit;
        in_pc.var_tit_name=var_tit_name;
        in_pc.val_label={norms_label{kval,1},sprintf('%s%s',val_label_str,norms_label{kval,3})};
        
        D3D_fig_cmp_conv(in_pc);
    end
end

end %kv


end %function

%%
%% FUNCTIONS
%%

