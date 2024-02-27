%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 16592 $
%$Date: 2020-09-17 01:32:43 +0800 (Thu, 17 Sep 2020) $
%$Author: chavarri $
%$Id: exist_str.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/auxiliary/exist_str.m $
%
function isFieldResult = exist_str (inStruct, fieldName)
% inStruct is the name of the structure or an array of structures to search
% fieldName is the name of the field for which the function searches
isFieldResult = 0;
f = fieldnames(inStruct(1));
for i=1:length(f)
if(strcmp(f{i},strtrim(fieldName)))
isFieldResult = 1;
return;
elseif isstruct(inStruct(1).(f{i}))
isFieldResult = exist_str(inStruct(1).(f{i}), fieldName);
if isFieldResult
return;
end
end
end