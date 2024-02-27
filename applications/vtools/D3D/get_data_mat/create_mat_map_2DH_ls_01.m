%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18293 $
%$Date: 2022-08-11 00:25:55 +0800 (Thu, 11 Aug 2022) $
%$Author: chavarri $
%$Id: create_mat_map_2DH_ls_01.m 18293 2022-08-10 16:25:55Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/create_mat_map_2DH_ls_01.m $
%
%

function create_mat_map_2DH_ls_01(fid_log,flg_loc,simdef)

tag=flg_loc.tag;

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%% PARSE

if ~isfield(flg_loc,'do_rkm')
    if isfield(flg_loc,'fpath_rkm')
        flg_loc.do_rkm=1;
    else
        flg_loc.do_rkm=0;
    end
end
if flg_loc.do_rkm==1
    if ~isfield(flg_loc,'fpath_rkm')
        error('Provide rkm file')
    elseif exist(flg_loc.fpath_rkm,'file')~=2
        error('rkm file does not exist')
    end
end

if ~isfield(flg_loc,'tol_t')
    flg_loc.tol_t=5/60/24;
end

%% PATHS

fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
% fpath_map=simdef.file.map;

%% OVERWRITE

ret=gdm_overwrite_mat(fid_log,flg_loc,fpath_mat); if ret; return; end

%% DIMENSIONS

nvar=numel(flg_loc.var);
npli=numel(flg_loc.pli);

%% LOAD TIME

[nt,time_dnum,~,time_mor_dnum,time_mor_dtime,sim_idx]=gdm_load_time_simdef(fid_log,flg_loc,fpath_mat_time,simdef);
   
%% LOOP TIME

kt_v=gdm_kt_v(flg_loc,nt); %time index vector

ktc=0; kpli=0;
messageOut(fid_log,sprintf('Reading map_ls_01 pli %4.2f %% kt %4.2f %%',kpli/npli*100,ktc/nt*100));
for kt=kt_v
    ktc=ktc+1;
    for kpli=1:npli
        fpath_pli=flg_loc.pli{kpli,1};
        if exist(fpath_pli,'file')~=2
            error('pli file does not exist: %s',fpath_pli);
        end
        [~,pliname,~]=fileparts(fpath_pli);
        pliname=strrep(pliname,' ','_');
        for kvar=1:nvar %variable
            if ~ischar(flg_loc.var{kvar})
                error('cannot read section along variables not from EHY')
            end
            varname=flg_loc.var{kvar};
            var_str=D3D_var_num2str_structure(varname,simdef);
            
            fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'var',var_str,'pli',pliname);
            if exist(fpath_mat_tmp,'file')==2 && ~flg_loc.overwrite ; continue; end

            %% read data
            
            data=gdm_read_data_map_ls_simdef(fdir_mat,simdef,varname,sim_idx(kt),'pli',fpath_pli,'tim',time_dnum(kt),'tol_t',flg_loc.tol_t,'overwrite',flg_loc.overwrite); %this overwriting flag should be different than the previous one
            
            if flg_loc.do_rkm
                data.rkm_cor=convert2rkm(flg_loc.fpath_rkm,[data.Xcor,data.Ycor],'TolMinDist',1000);
                data.rkm_cen=convert2rkm(flg_loc.fpath_rkm,[data.Xcen,data.Ycen],'TolMinDist',1000);
            end
            
            save_check(fpath_mat_tmp,'data'); 
            messageOut(fid_log,sprintf('Reading %s kt %4.2f %% kpli %4.2f %% kvar %4.2f %%',tag,ktc/nt*100,kpli/npli*100,kvar/nvar*100));
        end
    end
end %kt

        %% JOIN

        %if creating files in parallel, another instance may have already created it.
        %
        %Not a good idea because of the overwriting flag. Maybe best to join it several times.
        %
        % if exist(fpath_mat,'file')==2
        %     messageOut(fid_log,'Finished looping and mat-file already exist, not joining.')
        %     return
        % end

        % data=struct();

        %% first time for allocating

%         kt=1;
%         fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt));
%         tmp=load(fpath_mat_tmp,'data');
% 
%         %constant
% 
%         %time varying
%         nF=size(tmp.data.q_mag,2);
% 
%         q_mag=NaN(nt,nF);
%         q_x=NaN(nt,nF);
%         q_y=NaN(nt,nF);
% 
%         %% loop 
% 
%         for kt=1:nt
%             fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt));
%             tmp=load(fpath_mat_tmp,'data');
% 
%             q_mag(kt,:)=tmp.data.q_mag;
%             q_x(kt,:)=tmp.data.q_x;
%             q_y(kt,:)=tmp.data.q_y;
% 
%         end
% 
%         data=v2struct(q_mag,q_x,q_y); %#ok
%         save_check(fpath_mat,'data');

end %function

%% 
%% FUNCTION
%%
