function [Var info]=read2Dout(fname,XBdims)
% Var=readvar(fname,XBdims,nodims) or
% [Var info]=readvar(fname,XBdims,nodims)
%
% Output Var is XBeach output 3D array
% Output info is character array describing the dimensions of Var, i.e.
% info = ['x' 'y' 't'], where the first dimension in Var is the x-coordinate,
% the second dimension in Var is the y-coordinate and the third dimension in
% Var is the time coordinate (XBdims.nt or XBdims.ntm)
% Input - fname : name of data file to open, e.g. 'zb.dat' or 'u_mean.dat'
%       - XBdims: dimension data provided by getdimensions function
%       - nodims: rank of the variable matrix being read (default = 2)
%
% Created 19-06-2008 : XBeach-group Delft
%
% See also getdimensions, readpoint, readgraindist, readbedlayers,
%          readsediment, readwaves


nodims=2;

if (length(fname)>9 && strcmp(fname(end-8:end), '_mean.dat'))
    nt=XBdims.ntm;
    nameend=9;
elseif (length(fname)>8 && strcmp(fname(end-7:end), '_max.dat'))
    nt=XBdims.ntm;
    nameend=8;
elseif (length(fname)>8 && strcmp(fname(end-7:end), '_min.dat'))
    nt=XBdims.ntm;
    nameend=8;
elseif (length(fname)>8 && strcmp(fname(end-7:end), '_var.dat'))
    nt=XBdims.ntm;
    nameend=8;
else
    nt=XBdims.nt;
    nameend=4;
end

integernames={'wetz';
    'wetu';
    'wetv';
    'struct';
    'nd';
    'respstruct'};

[pathstr,name,ext] = fileparts(fname);
if any(strcmpi(name,integernames))
    type='int32';
else
    type='double';
end

try
    D = memmapfile(fname,'format',type);
    % limit size of data return to what is specified in XBdims
    Var = reshape(D.data(1:(XBdims.nx+1)*(XBdims.ny+1)*nt),XBdims.nx+1,XBdims.ny+1,nt);
catch
    fid=fopen(fname,'r');
    Var=zeros(XBdims.nx+1,XBdims.ny+1,nt,type);
    for i=1:nt
        Var(:,:,i)=fread(fid,size(XBdims.x),type);
    end
    fclose(fid);
end
info=['x ' 'y ' 't '];
