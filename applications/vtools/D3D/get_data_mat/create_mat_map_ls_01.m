%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18138 $
%$Date: 2022-06-10 12:17:52 +0800 (Fri, 10 Jun 2022) $
%$Author: chavarri $
%$Id: create_mat_map_ls_01.m 18138 2022-06-10 04:17:52Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/create_mat_map_ls_01.m $
%
%

function create_mat_map_ls_01(fid_log,flg_loc,simdef)

tag=flg_loc.tag;

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%% PARSE


%% PATHS

fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
fpath_map=simdef.file.map;

%% OVERWRITE

ret=gdm_overwrite_mat(fid_log,flg_loc,fpath_mat); if ret; return; end

%% LOAD TIME

[nt,time_dnum,~]=gdm_load_time(fid_log,flg_loc,fpath_mat_time,fpath_map);

%% LOOP TIME

kt_v=gdm_kt_v(flg_loc,nt); %time index vector

npli=numel(flg_loc.pli);

ktc=0; kpli=0;
messageOut(fid_log,sprintf('Reading map_ls_01 pli %4.2f %% kt %4.2f %%',kpli/npli*100,ktc/nt*100));
for kpli=1:npli
    [~,pliname,~]=fileparts(flg_loc.pli{kpli,1});
    pliname=strrep(pliname,' ','_');
    for kt=kt_v
        ktc=ktc+1;
        fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'pli',pliname);

        if exist(fpath_mat_tmp,'file')==2; continue; end
		
        [data_uxy,~]            =EHY_getMapModelData(fpath_map,'varName','uv'        ,'t0',time_dnum(kt),'tend',time_dnum(kt),'mergePartitions',1,'disp',0,'pliFile',flg_loc.pli{kpli,1});
        [data_uz,~]             =EHY_getMapModelData(fpath_map,'varName','mesh2d_ucz','t0',time_dnum(kt),'tend',time_dnum(kt),'mergePartitions',1,'disp',0,'pliFile',flg_loc.pli{kpli,1});
        [data_sal,data_sal.grid]=EHY_getMapModelData(fpath_map,'varName','sal'       ,'t0',time_dnum(kt),'tend',time_dnum(kt),'mergePartitions',1,'disp',0,'pliFile',flg_loc.pli{kpli,1});
        data_map_ls_01.sal=data_sal.val;
        data_map_ls_01.Xcor=data_sal.Xcor;
        data_map_ls_01.Ycor=data_sal.Ycor;
        data_map_ls_01.Scor=data_sal.Scor;
        data_map_ls_01.Xcen=data_sal.Xcen;
        data_map_ls_01.Ycen=data_sal.Ycen;
        data_map_ls_01.Scen=data_sal.Scen;
        data_map_ls_01.Zint=data_sal.Zint;
        data_map_ls_01.Zcen=data_sal.Zcen;
        data_map_ls_01.grid=data_sal.grid;
        data_map_ls_01.uz=data_uz.val;
        data_map_ls_01.ux=data_uxy.vel_x;
        data_map_ls_01.uy=data_uxy.vel_y;
        data_map_ls_01.uperp=data_uxy.vel_perp;
        data_map_ls_01.upara=data_uxy.vel_para;
        
        %save
        save_check(fpath_mat_tmp,'data_map_ls_01');
        
        %disp
        messageOut(fid_log,sprintf('Reading map_ls_01 pli %4.2f %% kt %4.2f %%',kpli/npli*100,ktc/nt*100));
    end    
end %kpli

%% join

%if creating files in parallel, another instance may have already created it.
if exist(fpath_mat,'file')==2
    messageOut(fid_log,'Mat-file already exist.')
    return
end

data_map_ls_01=struct();
for kpli=1:npli
    kt=1;
    fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'pli',pliname);
    tmp=load(fpath_mat_tmp,'data_map_ls_01');
    
    data_map_ls_01(kpli).Xcor=tmp.data_map_ls_01.Xcor;
    data_map_ls_01(kpli).Ycor=tmp.data_map_ls_01.Ycor;
    data_map_ls_01(kpli).Scor=tmp.data_map_ls_01.Scor;
    data_map_ls_01(kpli).Xcen=tmp.data_map_ls_01.Xcen;
    data_map_ls_01(kpli).Ycen=tmp.data_map_ls_01.Ycen;
    data_map_ls_01(kpli).Scen=tmp.data_map_ls_01.Scen;
    data_map_ls_01(kpli).grid=tmp.data_map_ls_01.grid;
    
    [~,ncx,ncz]=size(tmp.data_map_ls_01.sal);
    
    data_map_ls_01(kpli).sal=NaN(nt,ncx,ncz);
    data_map_ls_01(kpli).Zint=NaN(nt,ncx,ncz+1);
    data_map_ls_01(kpli).Zcen=NaN(nt,ncx,ncz);
    data_map_ls_01(kpli).uz=NaN(nt,ncx,ncz);
    data_map_ls_01(kpli).ux=NaN(nt,ncx,ncz);
    data_map_ls_01(kpli).uy=NaN(nt,ncx,ncz);
    data_map_ls_01(kpli).uperp=NaN(nt,ncx,ncz);
    data_map_ls_01(kpli).upara=NaN(nt,ncx,ncz);
        
    for kt=1:nt
        fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'pli',pliname);
        tmp=load(fpath_mat_tmp,'data_map_ls_01');
        
        data_map_ls_01(kpli).sal(kt,:,:)=tmp.data_map_ls_01.sal;
        data_map_ls_01(kpli).Zint(kt,:,:)=tmp.data_map_ls_01.Zint;
        data_map_ls_01(kpli).Zcen(kt,:,:)=tmp.data_map_ls_01.Zcen;
        data_map_ls_01(kpli).uz(kt,:,:)=tmp.data_map_ls_01.uz;
        data_map_ls_01(kpli).ux(kt,:,:)=tmp.data_map_ls_01.ux;
        data_map_ls_01(kpli).uy(kt,:,:)=tmp.data_map_ls_01.uy;
        data_map_ls_01(kpli).uperp(kt,:,:)=tmp.data_map_ls_01.uperp;
        data_map_ls_01(kpli).upara(kt,:,:)=tmp.data_map_ls_01.upara;
    end
end

save_check(fpath_mat,'data_map_ls_01');

end %function