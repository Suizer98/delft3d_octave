%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 16592 $
%$Date: 2020-09-17 01:32:43 +0800 (Thu, 17 Sep 2020) $
%$Author: chavarri $
%$Id: print_tloop.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/print_tloop.m $
%
%print_tloop is a function that print in the log file the time to finish
%
%print_tloop(time_loop,input,fid_log,kt,kts)
%
%INPUT:
%   -input = variable containing the input [struct] e.g. input
%
%OUTPUT:
%   -
%
%HISTORY:
%
%181104
%   -V. Deprecated function. Use display_tloop only with NaN on fid_log

function print_tloop(time_loop,input,fid_log,kt,kts,time_l,tic_totaltime)

run_id=input.run;

switch input.mdv.dt_type
    case 1
        %% fixed dt

        nt=input.mdv.nt;
        disp_t_nt=input.mdv.disp_t_nt;

        if kts>2
            kt_mean_idx=1:1:disp_t_nt;
        elseif kt>disp_t_nt
            kt_mean_idx=kt-disp_t_nt:kt-1;
        else
            kt_mean_idx=1:kt-1;
        end

        expected_s=(nt-kt)*mean(time_loop(kt_mean_idx)); %expected seconds to finish;

        fl_d=floor(expected_s/3600/24); %floor of the remaining days
        fl_h=floor((expected_s-fl_d*3600*24)/3600); %floor of the remaining hours
        fl_m=floor((expected_s-fl_d*3600*24-fl_h*3600)/60); %floor of the remaining minutes
        fl_s=expected_s-fl_d*3600*24-fl_h*3600-fl_m*60; %remaining minutes
        
        if isnan(fid_log)
            fprintf('run %s; number of saved timesteps = %d; %4.2f%% computed, %01dd %02dh %02dm %2.0fs to finish \n',run_id,kts,kt/nt*100,fl_d,fl_h,fl_m,fl_s);
        else
            fprintf(fid_log,'run %s; number of saved timesteps = %d; %4.2f%% computed, %01dd %02dh %02dm %2.0fs to finish \n',run_id,kts,kt/nt*100,fl_d,fl_h,fl_m,fl_s);
        end

    case 2
        %% fixed CFL
        
        Tstop=input.mdv.Tstop;

        expected_s=(1-time_l/Tstop)/time_l*toc(tic_totaltime);
        
        fl_d=floor(expected_s/3600/24); %floor of the remaining days
        fl_h=floor((expected_s-fl_d*3600*24)/3600); %floor of the remaining hours
        fl_m=floor((expected_s-fl_d*3600*24-fl_h*3600)/60); %floor of the remaining minutes
        fl_s=expected_s-fl_d*3600*24-fl_h*3600-fl_m*60; %remaining minutes
        
        if isnan(fid_log)
            fprintf('run %s; number of saved timesteps = %d; %4.2f%% computed, %01dd %02dh %02dm %2.0fs to finish \n',run_id,kts,time_l/Tstop*100,fl_d,fl_h,fl_m,fl_s);
        else
            fprintf(fid_log,'run %s; number of saved timesteps = %d; %4.2f%% computed, %01dd %02dh %02dm %2.0fs to finish \n',run_id,kts,time_l/Tstop*100,fl_d,fl_h,fl_m,fl_s);
        end
        
end %input.mdv.dt_type

end %print_tloop



