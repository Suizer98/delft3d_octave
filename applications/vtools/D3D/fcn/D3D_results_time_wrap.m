%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18391 $
%$Date: 2022-09-27 19:13:00 +0800 (Tue, 27 Sep 2022) $
%$Author: chavarri $
%$Id: D3D_results_time_wrap.m 18391 2022-09-27 11:13:00Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_results_time_wrap.m $
%
%Wrap around <D3D_results_time> to allow for SMT input
%
%INPUT
%   -
%
%OUTPUT
%   -
%
%TODO:
%   -

function [time_r,time_mor_r,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx,time_idx]=D3D_results_time_wrap(sim_path,varargin)

%% PARSE

switch numel(varargin)
    case 0
        nc_type='map'; 
        write_csv=1;
    case 1
        nc_type=varargin{1};
        write_csv=1;
    case 2
        nc_type=varargin{1};
        write_csv=varargin{2};
end

%% CALC

simdef.D3D.dire_sim=sim_path;
simdef=D3D_simpath(simdef);

switch simdef.D3D.structure
    case {1,2,3}
        sim_idx=NaN;
        fpath_nc=simdef.file.(nc_type);
        ismor=D3D_is(fpath_nc);
        [time_r,time_mor_r,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime]=D3D_results_time(fpath_nc,ismor,[1,Inf]);
        time_idx=(1:1:numel(time_r))';
    case 4
        fdir_output=fullfile(sim_path,'output');
        dire=dir(fdir_output);
        nf=numel(dire)-2-1; %already the number of the files, which start at 0
        time_r=[];
        time_mor_r=[];
        time_dnum=[];
        time_dtime=[];
        time_mor_dnum=[];
        time_mor_dtime=[];
        sim_idx=[];
        fpath_map={};
        time_idx=[];
        for kf=0:1:nf
            fdir_loc=fullfile(fdir_output,num2str(kf));
            simdef.D3D.dire_sim=fdir_loc;
            simdef=D3D_simpath(simdef);
            fpath_nc=simdef.file.(nc_type);
            ismor=D3D_is(fpath_nc);
            [time_r_loc,time_mor_r_loc,time_dnum_loc,time_dtime_loc,time_mor_dnum_loc,time_mor_dtime_loc]=D3D_results_time(fpath_nc,ismor,[1,Inf]);
            
            time_r=cat(1,time_r,time_r_loc);
            time_mor_r=cat(1,time_mor_r,time_mor_r_loc);
            time_dnum=cat(1,time_dnum,time_dnum_loc);
            time_dtime=cat(1,time_dtime,time_dtime_loc);
            time_mor_dnum=cat(1,time_mor_dnum,time_mor_dnum_loc);
            time_mor_dtime=cat(1,time_mor_dtime,time_mor_dtime_loc);
            sim_idx=cat(1,sim_idx,kf.*ones(size(time_mor_dtime_loc)));
            fpath_map=cat(1,fpath_map,repmat({fpath_nc},numel(time_mor_dtime_loc),1));
            if isempty(time_idx)
                time_idx=(1:1:numel(time_r_loc))';
            else
                time_idx=cat(1,time_idx,(time_idx(end)+1:1:time_idx(end)+1+numel(time_r_loc))');
            end
                
            
            messageOut(NaN,sprintf('Joined time %4.2f %%',kf/nf*100));
        end
        
        %write CSV
        write_csv_01(sim_path,fpath_map,time_r,time_mor_r,time_dnum,time_mor_dnum,sim_idx);
end

end %function

%%
%% FUNCTIONS
%%

function write_csv_01(sim_path,fpath_map,time_r,time_mor_r,time_dnum,time_mor_dnum,sim_idx)

%remove NaN to prevent cases in writing

bol_nan=isnan(time_mor_dnum);
time_mor_dnum(bol_nan)=0;

bol_nan=isnan(time_mor_dnum);
time_mor_dnum(bol_nan)=0;

nt=numel(time_r);
fdir_csv=fullfile(sim_path,'csv');
mkdir_check(fdir_csv);
fpath_tim_csv=fullfile(fdir_csv,'tim.csv');
%better to always create in case tim file is overwritten
%         if exist(fpath_tim_csv,'file')~=2
fid=fopen(fpath_tim_csv,'w');
fprintf(fid,'index, flow time since start [s], morpho time since start [s], flow date [datenum], morpho date [datenum], flow date [yyyy-mm-dd HH:MM:SS], morpho date [yyyy-mm-dd HH:MM:SS], map path \r\n');
for kt=1:nt
    fprintf(fid,'%03d, %10.1f, %10.1f, %15.7f, %15.7f, %s, %s, %s \r\n',sim_idx(kt),time_r(kt),time_mor_r(kt),time_dnum(kt),time_mor_dnum(kt),datestr(time_dnum(kt),'yyyy-mm-dd HH:MM:SS'),datestr(time_mor_dnum(kt),'yyyy-mm-dd HH:MM:SS'),fpath_map{kt});
end %kt
fclose(fid);
%         end

end %function