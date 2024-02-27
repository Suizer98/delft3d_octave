%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17062 $
%$Date: 2021-02-12 20:47:20 +0800 (Fri, 12 Feb 2021) $
%$Author: chavarri $
%$Id: D3D_enc.m 17062 2021-02-12 12:47:20Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_enc.m $
%
%grid files

%INPUT:
%   -simdef.D3D.dire_sim = full path to the output folder [string] e.g. 'd:\victorchavarri\SURFdrive\projects\ellipticity\D3D\runs\1D\998'
%   -simdef.D3D.grd = folder the grid files are [string] e.g. 'd:\victorchavarri\SURFdrive\projects\ellipticity\D3D\runs\1D\files\grd\'
%
%OUTPUT:
%   -a .enc file compatible with D3D is created in folder_out
%
%ATTENTION:
%   -
%
%HISTORY:
%   -161110 V. Creation of the grid files itself

function D3D_enc(simdef)
%% RENAME

dire_sim=simdef.D3D.dire_sim;
path_grd=fullfile(dire_sim,'grd.grd');

%% only straight flume!
% M=simdef.grd.M;
% N=simdef.grd.N;

%% read grid
grd=wlgrid('read',path_grd);
M=size(grd.X,1)+1;
N=size(grd.X,2)+1;

%% FILE

%preamble
data{1  ,1}='1 1 *** begin external enclosure';
data{2  ,1}=sprintf('%d 1',M);
data{3  ,1}=sprintf('%d %d',M,N);
data{4  ,1}=sprintf('1 %d',N);
data{5  ,1}='1 1 *** end external enclosure';

%% WRITE

file_name=fullfile(dire_sim,'enc.enc');
writetxt(file_name,data)
