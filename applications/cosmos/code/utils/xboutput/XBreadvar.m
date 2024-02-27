function [Var info]=XBreadvar(fname,XBdims,memopt,nodims)
% Var=readvar(fname,XBdims,nodims) or
% [Var info]=readvar(fname,XBdims,nodims)
%
% Output Var is XBeach output 3D/4D/5D array
% Output info is character array describing the dimensions of Var, i.e.
% info = ['x' 'y' 't'], where the first dimension in Var is the x-coordinate,
% the second dimension in Var is the y-coordinate and the third dimension in
% Var is the time coordinate (XBdims.nt or XBdims.ntm)
% Input - fname : name of data file to open, e.g. 'zb.dat' or 'u_mean.dat'
%       - XBdims: dimension data provided by getdimensions function
%       - nodims: rank of the variable matrix being read (default = 2)
%
% Created 19-06-2008 : XBeach-group Delft

if ~exist('nodims','var');
    nodims=2;
end

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

if any(strcmpi(fname(1:end-nameend),integernames))
    type='integer';
else
    type='double';
end

fid=fopen(fname,'r');
switch type
    case'double'
        switch nodims
            case 2
                Var=zeros(XBdims.nx+1,XBdims.ny+1,nt);
                info=['x ' 'y ' 't '];
                switch memopt
                   case 'double'
                        for i=1:nt
                            Var(:,:,i)=fread(fid,size(XBdims.x),'double');
                        end
                    case 'single'
                        for i=1:nt
                            Var(:,:,i)=single(fread(fid,size(XBdims.x),'double'));
                        end
                end
            case 3
                Var=zeros(XBdims.nx+1,XBdims.ny+1,nt);
            case 4
                Var=zeros(XBdims.nx+1,XBdims.ny+1,XBdims.nd,XBdims.ngd,nt);
                for i=1:nt
                    for ii=1:XBdims.ngd
                        for iii=1:XBdims.nd
                            Var(:,:,iii,ii,i)=fread(fid,size(XBdims.x),'double');
                        end
                    end
                end
                info=['x   ' 'y   ' 'nd  ' 'ngd ' 't   '];
        end
    case 'integer'
        switch nodims
            case 2
                Var=zeros(XBdims.nx+1,XBdims.ny+1,nt);
                for i=1:nt
                    Var(:,:,i)=fread(fid,size(XBdims.x),'int');
                end
                info=['x ' 'y ' 't '];
            case 3
                Var=zeros(XBdims.nx+1,XBdims.ny+1,nt);
            case 4
                Var=zeros(XBdims.nx+1,XBdims.ny+1,XBdims.nd,XBdims.ngd,nt);
                for i=1:nt
                    for ii=1:XBdims.ngd
                        for iii=1:XBdims.nd
                            Var(:,:,iii,ii,i)=fread(fid,size(XBdims.x),'int');
                        end
                    end
                end
                info=['x   ' 'y   ' 'nd  ' 'ngd ' 't   '];
        end
end

fclose(fid);