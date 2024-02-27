%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: D3D_run.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_run.m $
%
%run simulation

%INPUT:
%   -file.dire_sim = full path to the output folder [string] e.g. 'd:\victorchavarri\SURFdrive\projects\ellipticity\D3D\runs\1D\998'
%   -runid.serie = run serie [string] e.g. 'A'
%   -runid.number = run identification number [integer(1,1)] e.g. 36
%
%OUTPUT:
%   -starts the simulation

function D3D_run(file,runid)
%% RENAME

dire_sim=file.dire_sim;

runid_serie=runid.serie;
runid_number=runid.number;

%% RUN

file_bat=fullfile(dire_sim,'run_flow2d3d.bat');
file_map=fullfile(dire_sim,sprintf('trim-%s%03d.dat',runid_serie,runid_number));

if exist(file_map,'file')
    error('A results file already exists.')
end

current_folder=cd;
cd(dire_sim)
system(file_bat)
cd(current_folder);
