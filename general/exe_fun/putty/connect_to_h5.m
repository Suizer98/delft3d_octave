function connect_to_h5(user)
%Connect to Deltares' Hydrax5 (H5) UNIX computational facility through Matlab
%Only works when present on Deltares campus (and having a valid account)
if ~(exist('user','var')==1 && ischar(user)); user = ''; end;
putty('h5',user,'quiet')