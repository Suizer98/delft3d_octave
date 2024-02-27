%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: update_boundary_conditions_rmm_s3.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/rmm_setup/update_boundary_conditions_rmm_s3.m $
%

function update_boundary_conditions_rmm_s3(simdef)

%% START

fprintf('Start \n')

v2struct(simdef)

%% check folder structure
paths=get_paths_dimr(paths);

%% read conversion label
fprintf('Start reading location labels \n')
[loclabels,loclabels_rtc]=read_conversion_labels(paths.loclabels);
fprintf('Done reading location labels \n')

%% read new bc
fprintf('Start reading new boundary conditions \n')
bcn=load(paths.bcmat);
fprintf('Done reading new boundary conditions \n')

%% copy s3
fprintf('Start copying new model \n')
mkdir(paths.s3_out)
[cstat,~]=copyfile(paths.s3,paths.s3_out);
if cstat~=true
    error('Original SOBEK 3 model could not be copied. Check original and destination paths')
end
fprintf('Done copying new model \n')

%% modify dimr
fprintf('Start modifying dimr \n')
modify_dimr(paths.dimr,start_time,stop_time)
fprintf('Done modifying dimr \n')

%% modify md1d
fprintf('Start modifying md1d \n')
md1d=S3_read_md1d('read',paths.md1d);
md1d.Time.StartTime=start_time;
md1d.Time.StopTime=stop_time;
S3_read_md1d('write',paths.md1d,md1d,NaN);
fprintf('Done modifying md1d \n')

%% modify RTC

    %% rtcRuntimeConfig
fprintf('Start modifying RuntimeConfig \n')
modify_rtcruntimeconfig(paths.xml_rtcRuntimeConfig,start_time,stop_time)
fprintf('Done modifying RuntimeConfig \n')

    %% time series
fprintf('Start modifying time series \n')
modify_rtctimeseries(paths.xml_rtctimeseries,start_time,stop_time,bcn,loclabels_rtc)
fprintf('Done modifying time series \n')

%% modify boundary conditions

    %% read bc
fprintf('Start reading old boundary conditions \n')
bc=dflowfm_io_extfile('read',paths.bc);
fprintf('Done reading old boundary conditions \n')

    %% modify bc
fprintf('Start modifying boundary conditions \n')
bcmod=modify_boundary_conditions(bc,bcn,loclabels,start_time);
fprintf('Done modifying boundary conditions \n')

    %% write new bc
fprintf('Start writing new boundary conditions \n')
S3_read_extfile('write',paths.bc,bcmod);
fprintf('Done writing new boundary conditions \n')

%% END

fprintf('Done! \n')


end %function