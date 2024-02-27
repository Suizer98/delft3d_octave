function fullName=fillExtension(name,ext)

%Fills filename with extension if not given
%
%  fullName=fillExtension(fileName,extension)
%  e.g., fullName=fillExtension('D:\temp\test','dat'); results in 
%       fullName = 'D:\temp\test.dat', simple right?
%
% Robin Morelissen,2006


[fPat, fName, fExt]=fileparts(name);
if isempty(fExt)
    fExt=['.' ext];
end

if isempty(fPat)
    fullName=[fName fExt];
else
    fullName=[fPat filesep fName fExt];
end