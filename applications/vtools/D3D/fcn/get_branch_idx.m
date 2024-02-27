%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16624 $
%$Date: 2020-10-07 03:18:25 +0800 (Wed, 07 Oct 2020) $
%$Author: chavarri $
%$Id: get_branch_idx.m 16624 2020-10-06 19:18:25Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/get_branch_idx.m $
%
function branch_2p_idx=get_branch_idx(br_2p,branch_id)

nb=numel(br_2p);
nbt=size(branch_id,1);



if iscell(br_2p) %cell
    branch_2p_idx=NaN(1,nb);
    for kb=1:nb
        %remove spaces
        br_2p{kb}=br_2p{kb}(~isspace(br_2p{kb}));

        for kbt=1:nbt
%             branch_id_clean=strrep(branch_id(kbt,:),' ','');
            branch_id_clean=branch_id(kbt,~isspace(branch_id(kbt,:)));
%             if contains(branch_id(kbt,:),br_2p{kb})
            if strcmp(branch_id_clean,br_2p{kb})
                branch_2p_idx(kb)=kbt;
            end %if
        end %nbt
    end %kb  
elseif isa(br_2p,'double')
    if isnan(br_2p) %I do not get why I did this part of the code
        branch_2p_idx=unique(br_2p); 
    end    
else
    error('put the name of the observation station or the branch in a cell array')
end %is cell

if any(isnan(branch_2p_idx))
    fprintf('The possible branch names are: \n')
    for kbt=1:nbt
        if iscell(branch_id)
            fprintf('%s\n',branch_id{kbt,1}) 
        else
            fprintf('%s\n',branch_id(kbt,:)) 
        end
    end
%     if isnan(in
    fprintf('The branch name(s) I cannot find is(are): \n')
    br_nf=br_2p(isnan(branch_2p_idx));
    nbnf=numel(br_nf);
    for kbnf=1:nbnf
       fprintf('%s\n',br_nf{1,kbnf}) 
    end
    error('branch name not found')
end

end