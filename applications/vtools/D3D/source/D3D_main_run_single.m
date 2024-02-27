%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17396 $
%$Date: 2021-07-09 04:47:55 +0800 (Fri, 09 Jul 2021) $
%$Author: chavarri $
%$Id: D3D_main_run_single.m 17396 2021-07-08 20:47:55Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/source/D3D_main_run_single.m $
%
%MAIN SCRIPT for creating a Delft3D simulation

%% PREAMBLE

clc
clear
warning on

%% INPUT

simdef.runid.serie='trial';
simdef.runid.number='004'; %character, but numeric
simdef.runid.input_filename="c:\Users\chavarri\OneDrive - Stichting Deltares\all\projects\00_codes\210305_parallel_sequential\input_D3D_bars.m";

% simdef.D3D.home='C:\Users\chavarri\checkouts\20190405_Hirano_regularisation\src\bin\'; %D3D location (string) if inexistent the default is 4278; e.g. 'd:\victorchavarri\SURFdrive\programas\Delft3D\6.01.09.4278\'
% simdef.D3D.home='C:\Program Files (x86)\Deltares\Delft3D FM Suite 2019.02 HMWQ (1.5.2.44357)\plugins\DeltaShell.Dimr\kernels\'; 
% simdef.D3D.home='C:\Users\chavarri\checkouts\latest_dflowfm\'; %D3D location (string) if inexistent the default is 4278; e.g. 'd:\victorchavarri\SURFdrive\programas\Delft3D\6.01.09.4278\'
simdef.D3D.home='C:\Users\chavarri\checkouts\6.03.00.65936\';
% simdef.D3D.home='C:\Program Files\Deltares\Delft3D 4.03.02\'; %D3D location (string) if inexistent the default is 4278; e.g. 'd:\victorchavarri\SURFdrive\programas\Delft3D\6.01.09.4278\'
% simdef.D3D.home='C:\Users\chavarri\checkouts\oss_artifacts_x64_64757\'; %D3D location (string) if inexistent the default is 4278; e.g. 'd:\victorchavarri\SURFdrive\programas\Delft3D\6.01.09.4278\'
% simdef.D3D.home='d:\checkouts\Delft3D_7545\bin\'; %D3D location (string) if inexistent the default is 4278; e.g. 'd:\victorchavarri\SURFdrive\programas\Delft3D\6.01.09.4278\'
% simdef.D3D.home='p:\h6\opt\delft3dfm\latest\';

simdef.D3D.compile=0; %compiled D3D: 0=DIMR; 1=me; 2=old (installed D3D4)

simdef.D3D.paths_runs='c:\Users\chavarri\temporal\D3D\runs\';
simdef.D3D.structure=2; %1=Delf3D 4 (structured); 2=DFlowFM (unstructured)

simdef.D3D.run=0; %run in matlab: 0=NO; 1=YES
simdef.D3D.arch=2; %Architechture: 1=win32; 2=win64

erase_previous=1; %erase previous simulation. Take care!!!!

%% Please run!

oh_D3D_please_run