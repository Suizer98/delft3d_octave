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
%$Id: eig_from_output.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/postprocessing/eig_from_output.m $
%
%function_name does this and that
%
%
%INPUT:
%
%OUTPUT:
%   -
%
%HISTORY:
%180320
%   -V. Created for the first time.
%

function lambdas=eig_from_output(output_m)

%% 
%% RENAME
%%


%%
%% CALC 
%%

%% find fIk

%% compute lambda

[ell_idx,out]=elliptic_nodes(u,h,Cf,La,qbk,Mak,fIk,input,fid_log,kt);

end %function

