function [x,Vardata]=xb_readvar1d(fname,XBdims)
%XB_READVAR1D load xbeach variable
%
% Var=readvar(fname,XBdims)
%
% Output Var is [nx+1,ny+1,nt] array, where nt is XBdims.nt or XBdims.ntm
% Input - fname : name of data file to open, e.g. 'zb.dat' or 'u_mean.dat'
%       - XBdims: dimension data provided by getdimensions function
%
%See also: xbeach

% Created 19-06-2008 : XBeach-group Delft
 
if (length(fname)>9 && strcmp(fname(end-8:end), '_mean.dat'))
    nt=XBdims.ntm;
else
    nt=XBdims.nt;
end
fid=fopen(fname,'r');
Vardata=zeros(XBdims.nx+1,nt);
for i=1:nt
    tmp=fread(fid,size(XBdims.x),'double');
    Vardata(:,i)=squeeze(tmp(:,2));
end
fclose(fid)
x=squeeze(XBdims.x(:,2));
