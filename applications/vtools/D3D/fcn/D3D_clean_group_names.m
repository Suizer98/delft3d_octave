%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17397 $
%$Date: 2021-07-09 04:48:14 +0800 (Fri, 09 Jul 2021) $
%$Author: chavarri $
%$Id: D3D_clean_group_names.m 17397 2021-07-08 20:48:14Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_clean_group_names.m $
%

function [names,names_clean]=D3D_clean_group_names(mdu)

names  = fieldnames(mdu);

%when writing a file read with delft3d_io_sed, the block names have a number. 
%Here we remove it
ngroup=numel(names);
names_clean=cell(ngroup,1);
for kb=1:ngroup
    tok=regexp(names{kb,1},'\d','split');
    names_clean{kb,1}=tok{1,1};
end %kb

end %function