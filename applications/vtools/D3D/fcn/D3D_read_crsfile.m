%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17508 $
%$Date: 2021-09-30 17:17:04 +0800 (Thu, 30 Sep 2021) $
%$Author: chavarri $
%$Id: D3D_read_crsfile.m 17508 2021-09-30 09:17:04Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_read_crsfile.m $
%

function cs_input=D3D_read_crsfile(path_crs)

ncs_input=numel(path_crs);
cs_input=struct('Name',{},'Data',[]);
ks=1;
for kcs_input=1:ncs_input
    fname_cs=path_crs{kcs_input};
    cs=tekal('read',fname_cs,'loaddata');
    nval=numel(cs.Field);
    for ki=1:nval
        cs_input(ks).Name=cs.Field(ki).Name;
        cs_input(ks).Data=cs.Field(ki).Data;
        ks=ks+1;
    end
end

end %function