function [it1 it2] = istime(T1,T2)
%ISTIME True for set time.
%   iT1 = ISTIME(T1,T2) for a time serie T1 and T2 returns an array of the same
%   size as T1 containing true where the times of T1 are in T2 and false 
%   otherwise.
%
%   [iT1 iT2] = ISTIME(T1,T2) also returns an array iT2 containing the
%   index in T2 for each element in T1 which is a member of 
%   T2 and 0 if there is no such index.
%
%   NOTE: The reason to use ISTIME insted of ISMEMBER is because 2 
%   different serial date numbers may correspont to the same date 
%   (rounding values) and ISMEMBER will treat them as two different dates.
%
%   See also: TIME_INTERSECT, TIME_ROUND, TIME_CEIL, TIME_FLOUR

%   Copyright 2011 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   2008-Jun-19 Created by Gaytan-Aguilar
%   email: sandra.gaytan@deltares.com
%--------------------------------------------------------------------------

if ~isnumeric(T1)
    T1 = datenum(T1);
end
if ~isnumeric(T2)
    T2 = datenum(T2);
end

T1 = T1(:);
T2 = T2(:);
T1 = datevec(T1);
T2 = datevec(T2);
T1 = round(T1);
T2 = round(T2);
T1 = datenum(T1);
T2 = datenum(T2);

[it1, it2] = ismember(T1, T2);

