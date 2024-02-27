%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18455 $
%$Date: 2022-10-17 13:25:35 +0800 (Mon, 17 Oct 2022) $
%$Author: chavarri $
%$Id: create_mat_map_sedtransoff_01.m 18455 2022-10-17 05:25:35Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/create_mat_map_sedtransoff_01.m $
%
%

function create_mat_map_sedtransoff_01(fid_log,flg_loc,simdef)

tag=flg_loc.tag;

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%% PARSE

g=9.81; %make input? read from mdu?

if isfield(flg_loc,'do_sb')==0
    flg_loc.do_sb=0;
end

%% PATHS

fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
fpath_map=gdm_fpathmap(simdef,0);

%% OVERWRITE

ret=gdm_overwrite_mat(fid_log,flg_loc,fpath_mat); if ret; return; end

%% GRID

% gridInfo=gdm_load_grid(fid_log,fdir_mat,fpath_map);

%% GET RAW VARIABLES

var_raw={'mesh2d_umod','mesh2d_czs','h','Ltot','Fak'}; %do not change order, we use it for loading in loop
tag_2DH='fig_map_2DH_01';
in_plot_2DH.fdir_sim=flg_loc.fdir_sim;
in_plot_2DH.(tag_2DH).do=1;
in_plot_2DH.(tag_2DH).do_p=0; %regular plot
in_plot_2DH.(tag_2DH).do_diff=0; %difference initial time
in_plot_2DH.(tag_2DH).do_s=0; %difference with reference
in_plot_2DH.(tag_2DH).do_s_diff=0; %difference with reference and initial time
in_plot_2DH.(tag_2DH).overwrite=flg_loc.overwrite;
in_plot_2DH.(tag_2DH).var=var_raw; %open D3D_list_of_variables
in_plot_2DH.(tag_2DH).tim=flg_loc.tim; %all times
in_plot_2DH.(tag_2DH).order_anl=2; %1=normal; 2=random

D3D_gdm(in_plot_2DH)

%% LOAD TIME

[nt,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx]=gdm_load_time_simdef(fid_log,flg_loc,fpath_mat_time,simdef);

%% SED MOR

dk=D3D_read_sed(simdef.file.sed);
        
mor=D3D_io_input('read',simdef.file.mor);
Thresh=mor.Morphology0.Thresh;

%% DIMENSIONS

nvar=numel(var_raw);
nst=numel(flg_loc.sedtrans); 
% nf=numel(dk);

%% COMMON FLAGS

flg.Dm=1; %arithmetic
flg.friction_closure=1; 
flg.E=0;
flg.vp=0;
flg.particle_activity=0;
flg.extra=0;

cnt.g=9.81; %we should read from mdu...
cnt.R=1.65; %we should read from sed, but then varie per sediment size fraction...
cnt.p=0.00; %we compute sediment transport without pores
cnt.rho_w=1000; %read properly...

mor_fac=1;
E_param=NaN;
vp_param=NaN;
Gammak=NaN;

%% CREATE <qbk>

kt_v=gdm_kt_v(flg_loc,nt); %time index vector
var_sum=cell(nst,1);
unit_v=cell(nst,1);

ktc=0;
messageOut(fid_log,sprintf('Reading %s kt %4.2f %%',tag,ktc/nt*100));
for kst=1:nst
    %variation of each sediment transport relation

    flg.hiding=flg_loc.sedtrans_hiding(kst);
    hiding_param=flg_loc.sedtrans_hiding_param(kst);
    flg.mu=flg_loc.sedtrans_mu(kst);
    flg.mu_param=flg_loc.sedtrans_mu_param(kst);
    flg.sed_trans=flg_loc.sedtrans(kst);
    sed_trans_param=flg_loc.sedtrans_param{kst};
    
    var_sum{kst}=sprintf('%s_sum',flg_loc.sedtrans_name{kst});
    unit_v{kst}='stot';
    
    for kt=kt_v
        ktc=ktc+1;
        
        fpath_mat_st=mat_tmp_name(fdir_mat,flg_loc.sedtrans_name{kst},'tim',time_dnum(kt)); %we save it as 'raw' to be able to read in <gdm_read_data_map_simdef>
        
        if exist(fpath_mat_st,'file')==2 && ~flg_loc.overwrite
            continue
        end
        
        %load data
        for kvar=1:nvar %variable
            varname=var_raw{kvar};
            var_str=D3D_var_num2str_structure(varname,simdef);
            fpath_mat_tmp=mat_tmp_name(fdir_mat,'map_2DH_01','tim',time_dnum(kt),'var',var_str);
            data_loc.(var_raw{kvar})=load(fpath_mat_tmp,'data');
        end
        
        u=data_loc.mesh2d_umod.data'; %[nF,1]
        h=data_loc.h.data'; %[nF,1]
        C=data_loc.mesh2d_czs.data'; %[nF,1]
        Fak=squeeze(data_loc.Fak.data(:,1,:))'; %[nF,nf] (take active layer)
        Ltot=data_loc.Ltot.data'; %[nF,1]
        
        q=u.*h; %[nF,1]
        cf=g./C.^2; %[nF,1]
        La=ones(size(q)); %[nF,1]
        Mak=Fak(:,1:end-1); %[nF,nf-1]

        [qbk,Qbk,thetak,qbk_st,Wk_st,u_st,xik,Qbk_st,Ek,Ek_st,Ek_g,Dk,Dk_st,Dk_g,vpk,vpk_st,Gammak_eq,Dm]=sediment_transport(flg,cnt,h,q,cf,La,Mak,dk,sed_trans_param,hiding_param,mor_fac,E_param,vp_param,Gammak,fid_log,NaN);

        L_all=min(Ltot/Thresh,1);
        val=L_all.*qbk;
        
        data=struct();
        data.val=val; %we have to save it as structure because we use 'raw' type
        
        save_check(fpath_mat_st,'data')
        
        %% save sum 
        
        fpath_mat_st=mat_tmp_name(fdir_mat,var_sum{kst},'tim',time_dnum(kt)); %we save it as 'raw' to be able to read in <gdm_read_data_map_simdef>
        if exist(fpath_mat_st,'file')==2 && ~flg_loc.overwrite
            continue
        end
        data=struct();
        data.val=sum(val,2); %we have to save it as structure because we use 'raw' type

        save_check(fpath_mat_st,'data')
        
        %% disp
        messageOut(fid_log,sprintf('Reading %s kt %4.2f %% kvar %4.2f %%',tag,ktc/nt*100,kvar/nvar*100));
    end %kt
end %kst

%% SUMMERBED

if flg_loc.do_sb
    
in_plot_sb.fdir_sim=flg_loc.fdir_sim;
in_plot_sb.lan=flg_loc.lan;
in_plot_sb.tag_serie=flg_loc.tag_serie;

tag_sb='fig_map_summerbed_01';
in_plot_sb.(tag_sb)=flg_loc;
in_plot_sb.(tag_sb).do=1;
in_plot_sb.(tag_sb).do_p=flg_loc.do_sb_p; %regular plot
in_plot_sb.(tag_sb).do_xvt=1; %x-variable with time in color
in_plot_sb.(tag_sb).do_diff=0; %difference initial time
in_plot_sb.(tag_sb).do_s=0; %difference with reference
in_plot_sb.(tag_sb).do_s_diff=0; %difference with reference and initial time
in_plot_sb.(tag_sb).var=var_sum; %open D3D_list_of_variables
% in_plot_sb.(tag_sb).ylims_var=flg_loc.ylims_var_sum; %do we need it?
in_plot_sb.(tag_sb).do_val_B_mor=ones(size(var_sum)); %compute value of the variable per unit of morphodynamic width
in_plot_sb.(tag_sb).tim=flg_loc.tim; %all times
in_plot_sb.(tag_sb).order_anl=2; %1=normal; 2=random
in_plot_sb.(tag_sb).tim_ave=NaN; 
in_plot_sb.(tag_sb).unit=unit_v; 
in_plot_sb.(tag_sb).do_cum=ones(size(var_sum)); 

D3D_gdm(in_plot_sb)

end


end %function

%% 
%% FUNCTION
%%
