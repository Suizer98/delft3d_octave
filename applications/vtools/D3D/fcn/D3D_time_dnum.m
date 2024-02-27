%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18397 $
%$Date: 2022-09-29 23:07:34 +0800 (Thu, 29 Sep 2022) $
%$Author: chavarri $
%$Id: D3D_time_dnum.m 18397 2022-09-29 15:07:34Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_time_dnum.m $
%
%Read time in datenum format
%
%double: represent indices of the times to load. I.e., load the results at times [1,5,10];
%NaN = all
%Inf = last

function [time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx,idx_g,time_idx]=D3D_time_dnum(fpath_map,in_dtime,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'tim_type',1);
addOptional(parin,'tol',1);
addOptional(parin,'fdir_mat','');

parse(parin,varargin{:});

tim_type=parin.Results.tim_type;
tol=parin.Results.tol;
fdir_mat=parin.Results.fdir_mat;

%check if his or map
    %not robust enough I think for when dealing with SMT and D3D4
str_tim='';
if ~isfolder(fpath_map) && contains(fpath_map,'_his')
    str_tim='_his';
end
fpath_tim_all=fullfile(fdir_mat,sprintf('tim%s.mat',str_tim));

%%

if isa(in_dtime(1),'double') 
    %get all results time
    idx_g=NaN; %not needed, but we need to output it
    %if it is NaN we read it anyhow because we do not reach this point in case it is NaN and it is the same size as the one we have already.
    if isempty(fdir_mat) || exist(fpath_tim_all,'file')~=2 || any(isnan(in_dtime)) 
        messageOut(NaN,sprintf('Mat-file with all times not available or outdated. Reading.'))
        if isfolder(fpath_map) %SMT
            [time_r,time_mor_r,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx,time_idx]=D3D_results_time_wrap(fpath_map);
        else
            is_mor=D3D_is(fpath_map);
            [time_r,time_mor_r,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime]=D3D_results_time(fpath_map,is_mor,[1,Inf]);
            sim_idx=NaN(size(time_r));
            time_idx=(1:1:numel(time_r))';
        end
        data=v2struct(time_r,time_mor_r,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx,time_idx);
        save_check(fpath_tim_all,'data')
    else
        messageOut(NaN,sprintf('Mat-file with all times available. Loading: %s',fpath_tim_all))
        load(fpath_tim_all,'data')
        v2struct(data);
        
        %check all fields exist
        fn=fieldnames(data);
        fn_check={'time_dnum','time_dtime','time_mor_dnum','time_mor_dtime','sim_idx','time_idx'}; %fieldnames that must be present
        [~,bol_f]=find_str_in_cell(fn_check,fn);
        if ~all(bol_f) %old time file, data is missing. 
            messageOut(NaN,'Old time file. Erasing and computing again.')
            delete(fpath_tim_all)
            [time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx,idx_g,time_idx]=D3D_time_dnum(fpath_map,in_dtime,varargin{:});
            return
        end
    end
    
    %get the requested ones

        %all
    if any(isnan(in_dtime))  
        return
    end
    
        %match each one
    ntt=numel(time_dnum);
    nt=numel(in_dtime);
    time_dnum_s=NaN(nt,1);
    time_dtime_s=NaT(nt,1);
    time_dtime_s.TimeZone='+00:00';
    time_mor_dnum_s=NaN(nt,1);
    time_mor_dtime_s=NaT(nt,1);
    time_mor_dtime_s.TimeZone='+00:00';
    sim_idx_s=NaN(nt,1);
    time_idx_s=NaN(nt,1);
    for kt=1:nt
        if isinf(in_dtime(kt)) %last
            idx_g=ntt;
        elseif mod(in_dtime(kt),1)==0 && in_dtime(kt)<=ntt %if integer and smaller than total number of results, you are specifying index
            idx_g=in_dtime(kt);
            if ntt>datenum(1687,07,05) %if there are more than 
                messageOut(NaN,'I supposed the input was an index but the number of results is huge, so maybe you want datenum?') %create a flag to force datenum
            end
        else %datenum
            if tim_type==1
                tim_cmp=time_dnum;
            elseif tim_type==2
                tim_cmp=time_mor_dnum;
            else
                error('not sure what you want')
            end
            idx_g=absmintol(tim_cmp,in_dtime(kt),'tol',tol,'dnum',1);
        end

        time_dnum_s(kt,1)=time_dnum(idx_g);
        time_dtime_s(kt,1)=time_dtime(idx_g);
        time_mor_dnum_s(kt,1)=time_mor_dnum(idx_g);
        time_mor_dtime_s(kt,1)=time_mor_dtime(idx_g);
        sim_idx_s(kt,1)=sim_idx(idx_g);
        time_idx_s(kt,1)=time_idx(idx_g);
    end
    time_dnum=time_dnum_s;
    time_dtime=time_dtime_s;
    time_mor_dnum=time_mor_dnum_s;
    time_mor_dtime=time_mor_dtime_s;
    sim_idx=sim_idx_s;
    time_idx=time_idx_s;
%     end
elseif isa(in_dtime(1),'datetime') %datetime
    tim_cmp=datenum_tzone(in_dtime);
    [time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx,idx_g,time_idx]=D3D_time_dnum(fpath_map,tim_cmp,varargin{:});
    return
else
    error('ups...')
end
