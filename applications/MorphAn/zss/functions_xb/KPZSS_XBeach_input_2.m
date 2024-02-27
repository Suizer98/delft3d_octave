function [Profiles,sheets,fn,Scenarios,Category,Rp_in,Hs_in,Tp_in,D50,limits,lwb]= KPZSS_XBeach_input_2(dir_profiles,dir_hbc)

%   --------------------------------------------------------------------
%   Matlab script to load input for KPZSS_Xbeach_visualisation
%   M.Q.T. Groenewegen 
%   maurits.groenewegen@rws.nl
%   3-nov-2021
%
%   Syntax:
%   [Profiles,sheets,fn,Scenarios,Category,Rp_in,Hs_in,Tp_in,D50,limits] = XBeach_KPZSS_input()
%
%   Input:
%   dir_profiles    - Directory with xlsx file with profiles (created by
%                       KPZSS_Profiles_create.m)
%   dir_hbc         - Directory with xlsx file with hydraulic boundary conditions
%
%   Output:
%   Profiles    -    Struct with morfological scenarios data 
%   sheets      -    Sheetnames of excel   
%   fn          -    Fieldnames of Profiles struct
%   Scenarios   -    Names of scenarios 
%   Category    -    Flooding probability categories
%   Rp_in       -    Maximum storm search level
%   Hs_in       -    Significant wave height during the storm
%   Tp_in       -    Peak wave period during the storm
%   D50         -    Grain size
%   limits      -    x- and y-limits plots   
%   --------------------------------------------------------------------

%   Name of profiles from xlsx file
sheets = sheetnames(dir_profiles);

%   Load profiles of xlsx file
Profiles = struct(...
    'A',xlsread(dir_profiles,1),...
    'B',xlsread(dir_profiles,2),...
    'C',xlsread(dir_profiles,3),...
    'D',xlsread(dir_profiles,4),...
    'E',xlsread(dir_profiles,5),...
    'F',xlsread(dir_profiles,6),...
    'G',xlsread(dir_profiles,7),...
    'H',xlsread(dir_profiles,8),...
    'I',xlsread(dir_profiles,9),...
    'J',xlsread(dir_profiles,10),...
    'K',xlsread(dir_profiles,11),...
    'L',xlsread(dir_profiles,12),...
    'M',xlsread(dir_profiles,13),...
    'N',xlsread(dir_profiles,14),...
    'O',xlsread(dir_profiles,15),...
    'P',xlsread(dir_profiles,16),...
    'Q',xlsread(dir_profiles,17),...
    'R',xlsread(dir_profiles,18),...
    'S',xlsread(dir_profiles,19),...
    'T',xlsread(dir_profiles,20),...
    'U',xlsread(dir_profiles,21),...
    'V',xlsread(dir_profiles,22),...
    'W',xlsread(dir_profiles,23),...
    'X',xlsread(dir_profiles,24),...
    'Y',xlsread(dir_profiles,25),...
    'Z',xlsread(dir_profiles,26));

%   Read struct names
fn = fieldnames(Profiles);

%   Load hydraulic boundary conditions
Rp_in =struct('Rp_I',xlsread(dir_hbc,'Rp_I'),'Rp_II',xlsread(dir_hbc,'Rp_II'),...
    'Rp_III',xlsread(dir_hbc,'Rp_III'),'Rp_IV',xlsread(dir_hbc,'Rp_IV'),...
    'Rp_V',xlsread(dir_hbc,'Rp_V'));
Hs_in =struct('Hs_I',xlsread(dir_hbc,'Hs_I'),'Hs_II',xlsread(dir_hbc,'Hs_II'),...
    'Hs_III',xlsread(dir_hbc,'Hs_III'),'Hs_IV',xlsread(dir_hbc,'Hs_IV'),...
    'Hs_V',xlsread(dir_hbc,'Hs_V'));
Tp_in =struct('Tp_I',xlsread(dir_hbc,'Tp_I'),'Tp_II',xlsread(dir_hbc,'Tp_II'),...
    'Tp_III',xlsread(dir_hbc,'Tp_III'),'Tp_IV',xlsread(dir_hbc,'Tp_IV'),...
    'Tp_V',xlsread(dir_hbc,'Tp_V'));
D50 =xlsread(dir_hbc,'D50');

%   Scenario names
Scenarios = ["S0","S1_1","S1_2","S1_3","S2_1","S2_2","S2_3","S3_1","S3_2",...
    "S3_3","S4_1","S4_2","S4_3","S5_1","S5_2","S5_3","S6_1","S6_2","S6_3"];

%   Catagory names
Category = ["Iv","IIv","IIIv","IVv","Vv"];

% X and Y limits of plots for each profile
limits = [-600 350 0 20;...     %1
            -280 250 0 20;...   %2
            -250 650 0 20;...    %3
            -350 50 0 20;...    %4
            -100 300 0 20;...    %5
            -750 0 0 20;...     %6
            -150 200 0 20;...   %7
            -300 300 0 20;...   %8
            -300 250 0 25;...   %9
            -300 650 0 20;...   %10
            -600 300 0 20;...   %11
            -800 350 0 20;...   %12
            -350 300 0 20;...   %13
            -300 100 0 20;...   %14
            -320 320 0 20;...   %15
            -250 350 0 20;...   %16
            -250 350 0 20;...   %17
            -250 300 0 20;...   %18
            -200 300 0 20;...   %19
            600 1100 0 20;...   %20
            -700 -150 0 20;...  %21
            -250 250 0 20;...   %22
            -200 250 0 20;...   %23
            -450 150 0 20;...   %24
            -100 150 0 20;...   %25
            -250 200 0 20];     %26

% Landward boundary for fitting boundary profile
lwb = [-535;...      %1
            -260;...    %2
            -205;...    %3
            -340;...    %4
            -90;...    %5
            -700;...    %6
            -140;...    %7
            -265;...    %8
            -235;...    %9
            -270;...    %10
            NaN;...    %11
            NaN;...    %12
            NaN;...    %13
            NaN;...    %14
            NaN;...    %15
            NaN;...    %16
            NaN;...    %17
            NaN;...    %18
            [-140];...    %19
            [630];...    %20
            NaN;...    %21
            -155;...    %22
            -195;...    %23
            NaN;...    %24
            NaN;...    %25
            NaN];      %26          
        
end
