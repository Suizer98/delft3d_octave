%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: ncwrite_class.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/ncwrite_class.m $
%



function ncwrite_class(file,varname,var_original,var_new)

    switch class(var_original)
        case 'double'
            var_new_class=double(var_new);
        case 'int32'
            var_new_class=int32(var_new);
        otherwise
            error('include a new case')
    end
    
    ncwrite(file,varname,var_new_class)

end %function