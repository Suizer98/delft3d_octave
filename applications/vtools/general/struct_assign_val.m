%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18455 $
%$Date: 2022-10-17 13:25:35 +0800 (Mon, 17 Oct 2022) $
%$Author: chavarri $
%$Id: struct_assign_val.m 18455 2022-10-17 05:25:35Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/struct_assign_val.m $
%

function stru=struct_assign_val(stru,str,val)

ns=numel(stru);
ni=numel(val);
if ni==1 %same value to all structure fields        
    vec=val.*ones(ns,1);
elseif ns==ni
    vec=val;
else
    error('The size of the vector is different than the size of the structure and it is not 1')
end

aux=num2cell(vec);
[stru.(str)]=aux{:};

end %function