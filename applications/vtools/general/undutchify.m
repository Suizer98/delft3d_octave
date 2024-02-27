%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16882 $
%$Date: 2020-12-04 12:41:05 +0800 (Fri, 04 Dec 2020) $
%$Author: chavarri $
%$Id: undutchify.m 16882 2020-12-04 04:41:05Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/undutchify.m $
%
%if it is a string, it changes comma by dot and makes it a number
%in case it is a cell array do:
%
%matrix=cellfun(@(x)undutchify(x),cell_array);

function meaningfull_value=undutchify(nonsense_number)

if ischar(nonsense_number)
    meaningfull_value=str2double(strrep(nonsense_number,',','.'));
else
    meaningfull_value=nonsense_number;
end

end %function