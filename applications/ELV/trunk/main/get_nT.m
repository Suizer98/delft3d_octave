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
%$Id: get_nT.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/get_nT.m $
%
%get_nT changes the variable input.mdv.nT to the number of files in the temporary folder with the results.
%
%input=get_nT(input,fid_log)
%
%INPUT:
%   -
%
%OUTPUT:
%   -
%
%HISTORY:
%181104
%   -V. Created for the first time.

function input=get_nT(input,~)

%%
%% RENAME
%%

path_folder_TMP_output=input(1,1).mdv.path_folder_TMP_output;

%%
%% SAVE
%%

dir_TMP_output=dir(path_folder_TMP_output);
nF=numel(dir_TMP_output)-2; %number of files in directory (. and ..)
input(1,1).mdv.nT=nF;

%solve funy problem: if the simulation crashes when there is only one temporal results file (i.e., nT=1), when creating output.mat the last dimension is 1 (so it does not exist) and we have variables size problems.
if nF==1
    input(1,1).mdv.nT=2;
end
