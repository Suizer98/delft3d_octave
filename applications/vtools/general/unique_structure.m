%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18455 $
%$Date: 2022-10-17 13:25:35 +0800 (Mon, 17 Oct 2022) $
%$Author: chavarri $
%$Id: unique_structure.m 18455 2022-10-17 05:25:35Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/unique_structure.m $
%
%Get unique elements of structure

function stru_out=unique_structure(stru_in,fields)

fn=fieldnames(stru_in);
idx_fn=find_str_in_cell(fn,fields);
nel=numel(stru_in);
nfn=numel(idx_fn);
caux=cell(nel,nfn);
for kfn=1:nfn
    caux(:,kfn)={stru_in.(fn{idx_fn(kfn)})};
end
[u,idx_u]=unique(cell2table(caux));
stru_out=stru_in(idx_u);

end %function