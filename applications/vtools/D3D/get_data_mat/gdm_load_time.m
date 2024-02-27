%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18412 $
%$Date: 2022-10-07 22:37:21 +0800 (Fri, 07 Oct 2022) $
%$Author: chavarri $
%$Id: gdm_load_time.m 18412 2022-10-07 14:37:21Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_load_time.m $
%

function [nt,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx,do_load]=gdm_load_time(fid_log,flg_loc,fpath_mat_time,fpath_map,fdir_mat)

%% PARSE

if isfield(flg_loc,'overwrite_tim')==1
    messageOut(fid_log,'<overwrite_tim> flag is outdated. Time will be overwritten if the one present is different than the requested one')
%     flg_loc.overwrite_tim=0;
end

if isfield(flg_loc,'tim_type')==0
    flg_loc.tim_type=1;
end

if isfield(flg_loc,'tim_tol')==0
    flg_loc.tim_tol=10;
end

%% CALC

do_load=0;
if exist(fpath_mat_time,'file')==2 
    messageOut(fid_log,sprintf('Time-file already exists: %s',fpath_mat_time));
    load(fpath_mat_time,'tim');
    v2struct(tim);
    
    nt=numel(time_dnum);
    nt2=numel(flg_loc.tim);

    if isdatetime(flg_loc.tim)
        tim_obj=datenum_tzone(flg_loc.tim);
    else %is double
        ntt=D3D_nt(fpath_map); %inside the NaN check we save computational time
        if any(isnan(flg_loc.tim)) 
            if ntt==nt
                messageOut(fid_log,'Requested time is the same as existing one (all). Loading.')
                return
            else
                %load
                messageOut(fid_log,'Requested time (all) is different than available time. Overwritting.')
                do_load=1;
            end
        elseif nt~=nt2 %must be after passing NaN
            %load
            messageOut(fid_log,'Requested time is different than available time. Overwritting.')
            do_load=1;
        end
        
        if any(isinf(flg_loc.tim)) || (all(mod(flg_loc.tim,1)==0) && max(flg_loc.tim)<=ntt) %if integer and smaller than total number of results, you are specifying index    
            flg_loc.tim_type=3; %index comparison
        end
        
        tim_obj=flg_loc.tim;
    end
    
    if isduration(flg_loc.tim_tol)
        tim_tol_d=days(flg_loc.tim_tol);
    else
        tim_tol_d=flg_loc.tim_tol;
    end
    
    %flow, morpho, index
    switch flg_loc.tim_type
        case 1
            tim_cmp=time_dnum;
        case 2
            tim_cmp=time_mor_dnum;
        case 3
            tim_cmp=time_idx;
    end
    
    %turn inf into last value
    if any(isinf(tim_obj))
        [time_dnum_f,~,time_mor_dnum_f,~,~,~,time_idx_f]=D3D_time_dnum(fpath_map,Inf,'fdir_mat',fdir_mat);
        switch flg_loc.tim_type
            case 1
                tim_obj(isinf(tim_obj))=time_dnum_f;
            case 2
                tim_obj(isinf(tim_obj))=time_mor_dnum_f;
            case 3
                tim_obj(isinf(tim_obj))=time_idx_f;
        end
    end
    if do_load==0
        if any(abs(reshape(tim_cmp,1,[])-reshape(tim_obj,1,[]))>tim_tol_d) 
            messageOut(fid_log,'Requested time is different than available time. Overwritting.')
            do_load=1;
        else
            messageOut(fid_log,sprintf('Requested time is the same as existing one considering tolerance of %d days. Loading.',tim_tol_d))
            return
        end
    end
else
    messageOut(fid_log,'Time-file does not exist. Reading.');
    do_load=1;
end

%load
if do_load==1

[time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx,idx_g,time_idx]=D3D_time_dnum(fpath_map,flg_loc.tim,'tim_type',flg_loc.tim_type,'tol',flg_loc.tim_tol,'fdir_mat',fdir_mat);
tim=v2struct(time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx,time_idx); %#ok

save_check(fpath_mat_time,'tim');

nt=numel(time_dnum);

end

end %function

%% 
%% FUNCTION
%% 
