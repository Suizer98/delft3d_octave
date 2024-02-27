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
%$Id: compare_results.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/compare_results.m $
%
%compare_results compares 2 output file. 0 means they are the same
%
%[equal_bol_t,equal_bol,dif_idx,dif_res,dif_max,diff_time]=compare_results(output_ref,output_chk,var)
%
%INPUT:
%   -
%
%OUTPUT:
%   -
%
%HISTORY:
%170207
%   -V. Created for the first time.
%
function [equal_bol_t,equal_bol,dif_idx,dif_res,dif_max,diff_time,diff_time_rel]=compare_results(output_ref,output_chk,var)

% output_ref=load('d:\checkouts\ELV\test\reference\002\output.mat');
% output_chk=load('d:\checkouts\ELV\test\reference\003\output.mat');
% 
% var={'u','h','etab','Mak','La','msk','Ls','qbk','Cf','ell_idx'}; %variables name to output; 

output_ref=load(output_ref);
output_chk=load(output_chk);

tol=1e-8;

nv=numel(var);
dif_idx=cell(nv,1);
dif_res=cell(nv,1);
equal_bol=true(nv,1);
dif_max=NaN(nv,1);

for kv=1:nv
    dif_res{kv,1}=output_ref.(var{kv})-output_chk.(var{kv});
    dif_lidx=find(abs(dif_res{kv,1})>tol);
    dif_idx{kv,1}=ind2sub(size(dif_lidx),dif_lidx);
    equal_bol(kv,1)=~isempty(dif_idx{kv,1});
    dif_max(kv,1)=max(max(max(max(abs(dif_res{kv,1})))));
end

equal_bol_t=any(equal_bol);

%time
if isfield(output_ref,'time_loop') && isfield(output_chk,'time_loop')
    time_ref=sum(output_ref.time_loop);
    time_chk=sum(output_chk.time_loop);
else
    time_ref=NaN;
    time_chk=NaN;
end

diff_time=time_chk-time_ref;
diff_time_rel=(time_chk-time_ref)/time_ref;


