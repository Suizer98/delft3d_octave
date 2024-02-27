%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17748 $
%$Date: 2022-02-10 14:51:59 +0800 (Thu, 10 Feb 2022) $
%$Author: chavarri $
%$Id: D3D_runid.m 17748 2022-02-10 06:51:59Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_runid.m $
%
%runid file creation

%INPUT:
%   -simdef.D3D.dire_sim = full path to the output folder [string] e.g. 'd:\victorchavarri\SURFdrive\projects\ellipticity\D3D\runs\1D\998'
%   -simdef.runid.serie = run serie [string] e.g. 'A'
%   -simdef.runid.number = run identification number [integer(1,1)] e.g. 36
%
%OUTPUT:
%   -a .tra file compatible with D3D is created in file_name

function D3D_runid(simdef)
%% RENAME

dire_sim=simdef.D3D.dire_sim;

%% FILE

% data{1,1}=sprintf('sim_%s%03d',simdef.runid.serie,simdef.runid.number);
% data{1,1}=sprintf('sim_%s%s',simdef.runid.serie,simdef.runid.number);
data{1,1}=sprintf('%s',simdef.runid.name);

%% WRITE

file_name=fullfile(dire_sim,'runid');
writetxt(file_name,data);