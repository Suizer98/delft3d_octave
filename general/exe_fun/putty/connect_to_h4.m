function connect_to_h4(user)
%Connect to Deltares' Hydrax4 (H4) UNIX computational facility through Matlab
%Only works when present on Deltares campus (and having a valid account)
if ~(exist('user','var')==1 && ischar(user)); user = ''; end;
putty('h4',user,'quiet')