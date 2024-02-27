
%% INPUT

%ATTENTION!
%   -filepath of the boundary definition file and the administration file cannot have spaces. 
%   -use sinlge apostrophe (') and not double ("). 
%   -if using an external file, 'locationfile' cannot have neither single
%   nor double apostrophe (e.g.
%   locationfile=c:\Users\chavarri\temporal\files\temp\pol_RMMbnd_nesthdRD_geo.pli)

%boundary defintion: 
    %Option 1) pli-file in the same coordinates as the grid with the
        %support points where the interpolation is to be conducted. In this case it
        %is assumed you want water level.
    %Option 2) external-file calling the pli-file(s)
files{1,1}='p:\11205258-016-kpp2020rmm-3d\C_Work\05_nest\input\pol_RMMbnd_nesthdRD_geo.pli';
%administration file: relates pli-points and observations points.
files{1,2}='p:\11205258-016-kpp2020rmm-3d\C_Work\05_nest\input\nest_RMM3D.adm';
%history file
files{1,3}='p:\11205258-016-kpp2020rmm-3d\C_Work\02_DCMS_simulations\dcms_003\DFM_OUTPUT_DCSM-FM_0_5nm\DCSM-FM_0_5nm_0000_his.nc';
%output file hydrodynamic boundary
files{1,4}='p:\11205258-016-kpp2020rmm-3d\C_Work\05_nest\output\hydro_345_2011.bc';
%output file transport boundary condition
files{1,5}='p:\11205258-016-kpp2020rmm-3d\C_Work\05_nest\output\trans_345_2011.bc';

%local time zone relative to GMT
add_inf.timeZone=0;
%a0 correction water level boundaries
add_inf.a0=0;
%vertical profile for boundary conditions
add_inf.profile='3d-profile';   
%start time for generating the boundary conditions (in datenum units)
add_inf.t_start=datenum(2011,02,27);
%stop time for generating the boundary conditions (in units of TStart in mdu-file)
add_inf.t_stop=datenum(2011,06,02);
%do hydrodynamic
add_inf.do_hydro=true;

%compute salinity
add_inf.genconc(1)=true;
%add to salinity
add_inf.add(1)=0;
%max value of salinity
add_inf.max(1)=100;
%min value of salinity
add_inf.min(1)=0;

%compute temperature
add_inf.genconc(2)=true;
%add to salinity
add_inf.add(2)=0;
%max value of temperature
add_inf.max(2)=100;
%min value of temperature
add_inf.min(2)=0;

%number of values to analyze
% OPT.no_times=144*1; %144 = 1 day (144 values * 10 min/values = 1440 min = 1 day)

add_inf.display=2; %1=waitbar; 2=fprintf

%% CALL

tic
% nesthd_nesthd2(files,add_inf,OPT)
nesthd_nesthd2(files,add_inf)
toc
