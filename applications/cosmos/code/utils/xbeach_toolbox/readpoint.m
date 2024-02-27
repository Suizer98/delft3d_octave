function Pointdata=readpoint(fname,XBdims,nvar)
% Pointdata=readpoint(fname,XBdims,nvar)
%
% Output Point is [ntp,nvar+1] array, where ntp is XBdims.ntp
%                 First column of Pointdata is time
%                 Second and further columns of Pointdata are values of
%                 variables
% Input - fname : name of data file to open, e.g. 'point001.dat' or 'rugau001.dat'
%       - XBdims: dimension data provided by getdimensions function
%       - nvar  : number of variables output at this point location
%
% Created 19-06-2008 : XBeach-group Delft
%
% See also getdimensions, readvar, readgraindist, readbedlayers,
%          readsediment, readwaves

if exist('memmapfile.m','file')==2
    D = memmapfile(fname,'format','double');
    Pointdata = reshape(D.data(1:XBdims.ntp*(nvar+1)),nvar+1,XBdims.ntp)';
else
    Pointdata=zeros(XBdims.ntp,nvar+1);
    fid=fopen(fname,'r');
    for i=1:XBdims.ntp
        Pointdata(i,:)=fread(fid,nvar+1,'double');
    end
    fclose(fid);
end