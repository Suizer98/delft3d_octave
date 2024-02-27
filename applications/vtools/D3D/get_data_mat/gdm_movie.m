%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18311 $
%$Date: 2022-08-19 12:18:42 +0800 (Fri, 19 Aug 2022) $
%$Author: chavarri $
%$Id: gdm_movie.m 18311 2022-08-19 04:18:42Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_movie.m $
%
%

function gdm_movie(fid_log,flg_loc,fpath_mov,time_dnum)
     
%% PARSE

if isfield(flg_loc,'do_movie')==0
    flg_loc.do_movie=1;
end

if isfield(flg_loc,'tim_movie')==0
    flg_loc.tim_movie=20; %[s] duration of the movie
end

if isfield(flg_loc,'fig_overwrite')==0
    flg_loc.fig_overwrite=0;
end

if isfield(flg_loc,'mov_overwrite')==0
    flg_loc.mov_overwrite=flg_loc.fig_overwrite;
end

if isfield(flg_loc,'rat')==0
    T=time_dnum(end)-time_dnum(1);
    flg_loc.rat=T/(flg_loc.tim_movie/24/3600); %[-] we want <rat> model seconds in each movie second
end

%%

if flg_loc.do_movie==0; return; end

%% CALC

dt_aux=diff(time_dnum);
dt=dt_aux(1)*24*3600; %[s] we have 1 frame every <dt> seconds 
make_video(fpath_mov,'frame_rate',1/dt*flg_loc.rat,'overwrite',flg_loc.mov_overwrite);
 
end %function