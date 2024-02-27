%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 17115 $
%$Date: 2021-03-16 06:06:55 +0800 (Tue, 16 Mar 2021) $
%$Author: chavarri $
%$Id: check_input.m 17115 2021-03-15 22:06:55Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/check_input.m $
%
%check_input is a function that checks that the input is enough and makes sense
%
%input_out=check_input(input,path_file_input,fid_log)
%
%INPUT:
%   -input = variable containing the input [struct] e.g. input
%
%OUTPUT:
%   -input = variable containing the input [struct] e.g. input
%
%HISTORY:
%160223
%   -V. Created for the first time.
%
%160429
%   -L. changed hydrodynamic boundary conditions;
%       - new case numbers
%       - repeated hydrograph
%       - adjusted warning/error messages related to bc conditions
%       - boundary conditions from file
%160429
%   -L. adjust for morphodynamic boundary conditions;
%
%160429
%   -L adjust for more possibilities for initial conditions
% line 92 warning instead of error
%
%160705
%   -L entered path_folder_main check
%
%160818
%   -L put input.mor.interfacetype into nf>1 check
%   -L: line 468 typo?
%
%161010
%   -L&V. Nourishment crap
%   -L. case 13 1604011
%
%170123
%   -L. major updates based on updated manual
%
%170727
%   -V. modulization
%
%171013
%   -V. change order of check_mor and check_bcm

function input_out=check_input(input,path_file_input,fid_log)

%% 
%% RUN
%% 

if isfield(input,'run')==0 %if it does not exist 
    error('There is no run tag. Provide input.run')
else
    if ischar(input.run)==0
        error('input.run must be a char')
    end
end

%check for branches
if isfield(input.grd,'br')
    nb=size(input.grd.br,1);
else
    nb=1;
    input.grd.br=[1,2];
end
input.mdv.nb=nb;

%preallocate input_out
% input_out=struct(); %this does not work because of dissimilar size, we can smarly preallocate each field

%add missing structure elements
if isfield(input,'aux')==0 
    input.aux=struct();
end
if isfield(input,'nour')==0 
    input.nour=struct();
end
if isfield(input,'frc')==0 
    input.frc=struct();
end

input.grd.bc_mat=zeros(nb,8);
input.grd.br_ord=zeros(nb,1); %vector to help retrieving the order. Easily found with sort so let me know if you want to keep it
input.grd.nbif  =[];          %size is unknown but may be found 
input.ini.Q=zeros(nb,1);
for kb=1:nb
    input_out(kb,1)=input;
end

if input.mdv.nb~=1
    input_out=check_bra(input_out,fid_log);
end

for kb=1:nb
    %we pass twice through the check to prevent dependencies between functions. Better would be
    %to pass while there are change in input. 
%     for kit=1:2 
%% MDV
input_out(kb,1)=check_mdv(input_out(kb,1),path_file_input,fid_log);

%% FRICTION
input_out(kb,1)=check_frc(input_out(kb,1),fid_log);

%% WIDTH
input_out(kb,1)=check_width(input_out(kb,1),fid_log);

%% INI
input_out(kb,1)=check_ini(input_out(kb,1),fid_log);

%% MOR
input_out(kb,1)=check_mor(input_out(kb,1),fid_log);

%% SED
input_out(kb,1)=check_sed(input_out(kb,1),fid_log);

%% BCH
input_out(kb,1)=check_bch(input_out(kb,1),fid_log);

%% BCM
input_out(kb,1)=check_bcm(input_out(kb,1),fid_log);

%% TRA
input_out(kb,1)=check_tra(input_out(kb,1),fid_log);

%% NOUR
input_out(kb,1)=check_nour(input_out(kb,1),fid_log);

%% OUTPUT CHECK
% input_out(kb,1)=check_out(input_out(kb,1),fid_log); %as under CFl based time step the number of output files is not known, this input check is deprecated
%     end %kit
end %kb

%%
%% SAVE
%% 

input=input_out; %just to save
save(fullfile(input(1,1).mdv.path_folder_main,'input.mat'),'input')

