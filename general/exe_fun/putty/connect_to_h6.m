function connect_to_h6(user)
%Connect to Deltares' Hydrax6 (H6) UNIX computational facility through Matlab
%Only works when present on Deltares campus (and having a valid account)
if ~(exist('user','var')==1 && ischar(user)); user = ''; end;
putty('h6',user,'quiet')