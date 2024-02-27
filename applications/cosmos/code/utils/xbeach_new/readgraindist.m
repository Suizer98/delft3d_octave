function [graindis info]=readgraindist(fname,XBdims)
% Var=readgraindis(fname,XBdims) or
% [Var info]=readgraindist(fname,XBdims)
%
% Output Var is XBeach output 5D array with bed composition data
% Output info is character array describing the dimensions of Var, i.e.
% info = ['x' 'y' 'nd' 'ngd' 't'], where the first dimension in Var is the x-coordinate,
% etc.
% Input - fname : name of data file to open, e.g. 'pbbed.dat'
%       - XBdims: dimension data provided by getdimensions function
%
% Created 24-11-2009 : XBeach-group Delft
%
% See also getdimensions, readvar, readpoint, readbedlayers, readsediment,
%          readwaves

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

info=['x  ' 'y  ' 'nd ' 'ngd' '  t'];
try
    D = memmapfile(fname,'format','double');
    % limit size of data return to what is specified in XBdims
    graindis = reshape(D.data(1:(XBdims.nx+1)*(XBdims.ny+1)*XBdims.nd*XBdims.ngd*nt),XBdims.nx+1,XBdims.ny+1,XBdims.nd,XBdims.ngd,nt);
catch
    graindis=zeros(XBdims.nx+1,XBdims.ny+1,XBdims.nd,XBdims.ngd,nt);
    fid=fopen(fname,'r');
    for i=1:nt
        for ii=1:XBdims.ngd
            for jj=1:XBdims.nd
                graindis(:,:,jj,ii,i)=fread(fid,[XBdims.nx+1,XBdims.ny+1],'double');
            end
        end
    end
    fclose(fid);
end



