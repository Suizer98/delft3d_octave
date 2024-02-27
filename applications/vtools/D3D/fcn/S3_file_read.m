%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17806 $
%$Date: 2022-03-03 18:38:35 +0800 (Thu, 03 Mar 2022) $
%$Author: chavarri $
%$Id: S3_file_read.m 17806 2022-03-03 10:38:35Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/S3_file_read.m $
%
%Select output file depending on variable
%
%INPUT:
%
%OUTPUT:
%

function file_read=S3_file_read(which_v,file)

switch which_v
    case {2,12} %map
        file_read=file.map;
    case {10} %reachsegments
        file_read=file.reach;
    otherwise
        error('add')
end

end %function
