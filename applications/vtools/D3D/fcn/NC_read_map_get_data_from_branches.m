%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18311 $
%$Date: 2022-08-19 12:18:42 +0800 (Fri, 19 Aug 2022) $
%$Author: chavarri $
%$Id: NC_read_map_get_data_from_branches.m 18311 2022-08-19 04:18:42Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/NC_read_map_get_data_from_branches.m $
%
%

function [z_br,o_br,cord_br]=NC_read_map_get_data_from_branches(z,in,branch,offset,x_node,y_node,branch_length,branch_id)

branch_2p_idx=get_branch_idx(in.branch,branch_id);

%in FM1D, the branch id start at 0, while is starts at 1 in SOBEK3
% cte_br=1;
% if isempty(find(branch==0,1)) %sobek3;
%     cte_br=0;
% end

%in FM1D, the branch id start at 0, while is starts at 1 in SOBEK3
cte_br=0;
if ~isempty(find(branch==0,1)) %fm;
    branch_2p_idx=branch_2p_idx-1;
    cte_br=1;
end

nb=numel(branch_2p_idx);

z_br=[];
cord_br=[];
o_br=[];
last_dx_bm1=0;
o_br_end_bm1=0;

zsize=size(z);
ndim=numel(zsize);
dim_s=zsize==numel(branch);
idx_dim_s=find(dim_s);

for kb=1:nb
    idx_br=branch==branch_2p_idx(kb); %logical indexes of intraloop branch
    br_length=branch_length(branch_2p_idx(kb)+cte_br); %total branch length. As the branches start counting on 0, in position n+1 we find the length of branch n.
    
    %this is really ugly and there must be a simple way to do it. sorry, I
    %am in a rush :)
    switch ndim
        case 1
            z_a1=z(idx_br);
        case 2
            switch idx_dim_s
                case 1
                    z_a1=z(idx_br,:);
                case 2
                    z_a1=z(:,idx_br);
                otherwise
                    error('ups... check where are the dimensions of the streamwise coordinate')
            end
        case 3
            switch idx_dim_s
                case 1
                    z_a1=z(idx_br,:,:);
                case 2
                    z_a1=z(:,idx_br,:);
                case 3
                    z_a1=z(:,:,idx_br);
                otherwise
                    error('ups... check where are the dimensions of the streamwise coordinate')
            end
        case 4
            switch idx_dim_s
                case 1
                    z_a1=z(idx_br,:,:,:);
                case 2
                    z_a1=z(:,idx_br,:,:);
                case 3
                    z_a1=z(:,:,idx_br,:);
                case 4
                    z_a1=z(:,:,:,idx_br);
                otherwise
                    error('ups... check where are the dimensions of the streamwise coordinate')
            end
        otherwise
            error('ups... more dimensions than I thought')
    end
    
    if isempty(z_a1)
        error('Branch %s has no computational nodes',branch_id(branch_2p_idx(kb)+cte_br,:))
        %
        %        figure
        %        plot(branch,'-*')
    end
    
    o_a1=offset(idx_br);
    last_dx=br_length-o_a1(end);
    
    %     switch idx_dim_s
    %         case 1
    %             z_ba=cat(1,z_br,z_a1);
    %         case 2
    %             z_ba=cat(1,z_br,z_a1);
    %         otherwise
    %             error('ups... check where are the dimensions of the streamwise coordinate')
    %     end
    
    z_ba=cat(idx_dim_s,z_br,z_a1);
    z_br=z_ba;
    %     z_br=[z_br;z_a1];
    o_br=[o_br;o_a1+o_br_end_bm1+last_dx_bm1];
    
    last_dx_bm1=last_dx;
    o_br_end_bm1=o_br(end);
    
    x_node_a1=x_node(idx_br);
    y_node_a1=y_node(idx_br);
    cord_br=[cord_br;[x_node_a1,y_node_a1]];
    
end

% o_br=o_br(2:end);

% np=size(cord_br,1);
% o_br=zeros(np,1);
% for kp=2:np
%     o_br(kp)=o_br(kp-1)+sqrt((cord_br(kp,1)-cord_br(kp-1,1)).^2+(cord_br(kp,2)-cord_br(kp-1,2))^2);
% end

%test uniqueness
% o_u=unique(o_br);
% ndiff=numel(o_u)-numel(o_br);
% if ndiff~=0
%     error('offset has repeated values')
% end

end