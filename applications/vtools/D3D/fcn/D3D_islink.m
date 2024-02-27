%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17536 $
%$Date: 2021-10-30 03:38:05 +0800 (Sat, 30 Oct 2021) $
%$Author: chavarri $
%$Id: D3D_islink.m 17536 2021-10-29 19:38:05Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_islink.m $
%
%get data from 1 time step in D3D, output name as in D3D

function islink=D3D_islink(which_v)

islink=0;
switch which_v
    case [43]
        islink=1;
    otherwise
        islink=0;
end

end