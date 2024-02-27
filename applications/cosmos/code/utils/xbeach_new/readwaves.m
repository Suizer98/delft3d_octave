function [var info]=readwaves(fname,XBdims)
% Var=readwaves(fname,XBdims) or
% [Var info]=readwaves(fname,XBdims)
%
% Output Var is XBeach output 4D array with wave data per wave bin
% Output info is character array describing the dimensions of Var, i.e.
% info = ['x' 'y' 'ntheta' 't'], where the first dimension in Var is the x-coordinate,
% etc.
% Input - fname : name of data file to open, e.g. 'Subg.dat'
%       - XBdims: dimension data provided by getdimensions function
%
% Created 24-11-2009 : XBeach-group Delft
%
% See also getdimensions, readvar, readpoint, readgraindist, readbedlayers,
%          readsediment


if (length(fname)>9 && strcmp(fname(end-8:end), '_mean.dat'))
    nt=XBdims.ntm;
elseif (length(fname)>8 && strcmp(fname(end-7:end), '_max.dat'))
    nt=XBdims.ntm;
elseif (length(fname)>8 && strcmp(fname(end-7:end), '_min.dat'))
    nt=XBdims.ntm;
elseif (length(fname)>8 && strcmp(fname(end-7:end), '_var.dat'))
    nt=XBdims.ntm;
else
    nt=XBdims.nt;
end


info=['x  ' 'y  ' 'ntheta ' 't  '];

try
    D = memmapfile(fname,'format','double');
    % limit size of data return to what is specified in XBdims
    var = reshape(D.data(1:(XBdims.nx+1)*(XBdims.ny+1)*XBdims.ntheta*nt),XBdims.nx+1,XBdims.ny+1,XBdims.ntheta,nt);
catch
    var=zeros(XBdims.nx+1,XBdims.ny+1,XBdims.ntheta,nt);
    fid=fopen(fname,'r');
    for i=1:nt
        for ii=1:XBdims.ntheta
            var(:,:,ii,i)=fread(fid,[XBdims.nx+1,XBdims.ny+1],'double');
        end
    end
    fclose(fid);
end