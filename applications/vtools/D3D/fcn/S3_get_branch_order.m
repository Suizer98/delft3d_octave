%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: S3_get_branch_order.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/S3_get_branch_order.m $
%
function branch_id=S3_get_branch_order(simdef)

path_nd=simdef.file.NetworkDefinition;

%read network
fileID_in=fopen(path_nd,'r');
net_in=textscan(fileID_in,'%s','delimiter','\r\n','whitespace','');
fclose(fileID_in);
nl=numel(net_in{1,1});

%loop on lines
kb=1;
branch_id={};
for kl=1:nl
    line_str_loc=net_in{1,1}{kl,1};
    if contains(line_str_loc,'[Branch]')
        br_str_raw=net_in{1,1}{kl+1,1};
        exprid='\w+([.-]?\w+)*';
        words=regexp(br_str_raw,exprid,'match');
        br_str=words{1,2}; %the first is 'id'
        branch_id{kb,1}=br_str;
        
        %update counter
        kb=kb+1;
    end
    
end %kl



end %function