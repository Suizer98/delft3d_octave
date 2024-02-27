%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: update_boundary_conditions_rmm_sre.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/rmm_setup/update_boundary_conditions_rmm_sre.m $
%

function update_boundary_conditions_rmm_sre(simdef)

%% START

fprintf('Start \n')

v2struct(simdef)

%% check folder structure
paths=get_paths_sre(paths);

%% read conversion label
fprintf('Start reading location labels \n')
[loclabels,loclabels_rtc]=read_conversion_labels(paths.loclabels);
fprintf('Done reading location labels \n')

%% read new bc
fprintf('Start reading new boundary conditions \n')
bcn=load(paths.bcmat);
fprintf('Done reading new boundary conditions \n')

%% copy sre
fprintf('Start copying new model \n')
mkdir(paths.sre_out)
[cstat,~]=copyfile(paths.sre_in,paths.sre_out);
if cstat~=true
    error('Original SOBEK RE model could not be copied. Check original and destination paths')
end
fprintf('Done copying new model \n')

%% modify computational time (DEFRUN.1)
fprintf('Start modifying DEFRUN.1 \n')
modify_defrun_1(paths.defrun_1,start_time,stop_time)
fprintf('Done modifying DEFRUN.1 \n')

%% modify RTC

    %% modify triggers
fprintf('Start modifying RTC triggers \n')
modify_defstr_5(paths.defstr_5,start_time,stop_time)
fprintf('Done modifying RTC triggers \n')

    %% modify time series
fprintf('Start modifying RTC time series \n')
modify_defstr_4(paths.defstr_4,start_time,stop_time,bcn,loclabels_rtc)
fprintf('Done modifying RTC time series \n')

%% modify boundary conditions

    %% read names
fprintf('Start reading goemetry names \n')
defcnd_1=SRE_read_defcnd_1(paths.defcnd_1);
fprintf('Done reading geometry names \n')

    %% modify water level and discharge (FLBO)
fprintf('Start modifying water level and discharge time series \n')
modify_defcnd_2(paths.defcnd_2,defcnd_1,bcn,loclabels)
fprintf('Done modifying water level and discharge time series \n')

    %% modify lateral discharge (FLBR)
fprintf('Start modifying lateral discharge time series \n')
modify_defcnd_3(paths.defcnd_3,defcnd_1,bcn,loclabels) 
fprintf('Done modifying lateral discharge time series \n')

    %% modify salt concentration (STBO)
fprintf('Start modifying salinity time series \n')
modify_defcnd_6(paths.defcnd_6,defcnd_1,bcn,loclabels) 
fprintf('Done modifying salinity time series \n')

	%% modify wind
fprintf('Start modifying wind time series \n')
modify_defmet_1(paths.defmet_1,bcn,loclabels)
fprintf('Done modifying wind time series \n')

%% END

fprintf('Done! \n')

end %function