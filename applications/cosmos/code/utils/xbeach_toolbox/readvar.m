function [Var info]=readvar(fname,XBdims,dims)
% Var=readvar(fname,XBdims,dims) or
% [Var info]=readvar(fname,XBdims,dims)
%
% Input - fname : name of data file to open, e.g. 'zb.dat' or 'u_mean.dat'
%       - XBdims: dimension data provided by getdimensions function
%       - dims  : rank of the variable matrix being read ('2D','3Dwave',
%                 '3Dbed','3Dsed', or '4Dbed')
%
% If no dims is given, this function will try to automatically find the
% best way to read the file
%
% Output Var is XBeach output ND array
% Output info is character array describing the dimensions of Var, i.e.
% info = ['x' 'y' 't'], where the first dimension in Var is the x-coordinate,
% the second dimension in Var is the y-coordinate and the third dimension in
% Var is the time coordinate (XBdims.nt or XBdims.ntm)
%
% Created 24-11-2008 : XBeach-group Delft
%
% See also getdimensions, read2Dout, readpoint, readgraindist, readbedlayers,
%          readsediment

options=[' 3Dwave';' 3Dsed ';' 3Dbed ';' 4Dbed '];

% Determine output time series length in dims.dat
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

% First open file using memmapfile if possible
try
    D = memmapfile(fname,'format','double');
    temp = D.data;
catch
    fid=fopen(fname,'r');
    temp=fread(fid,'double');
    fclose(fid);
end
sz=length(temp)/(XBdims.nx+1)/(XBdims.ny+1)/nt;

% In case file does not match dims.dat 
if sz>max(XBdims.ntheta,XBdims.nd*XBdims.ngd)
    display('File length is longer than suggested in dims.dat');
    if exist('dims','var')
        display('- data file may be corrupt, or contain data of a previous simulation');
    else
        display('- if simulation is running, retry and specify dims type');
        display('- if simulation is complete, data file may be corrupt, or contain data of a previous simulation');
        display('  please try again with specified dims type');
        display(' ');
        display(' Valid dims types are:');
        display(options(1:end,:));
        display(' ');
    end
end

% User knows what to specify
if exist('dims','var')
    if strcmpi(dims,'2D')
        [Var info]=read2Dout(fname,XBdims);
    elseif strcmpi(dims,'3Dwave')
        [Var info]=readwaves(fname,XBdims);
    elseif strcmpi(dims,'3Dbed')
        [Var info]=readbedlayers(fname,XBdims);
    elseif strcmpi(dims,'3Dsed')
        [Var info]=readsediment(fname,XBdims);
    elseif strcmpi(dims,'4Dbed')
        [Var info]=readgraindist(fname,XBdims);
    else
        error(['Unknown dims type: ',dims]);
    end
else
    % user does not know dims type
    if sz>max(XBdims.ntheta,XBdims.nd*XBdims.ngd)
        warning('Function will return values as though 2D array, but could not determine dims type with certainty');
        Var=read2Dout(fname,XBdims);
    else
        % Probably 2D array
        if sz==1
%            display('Assuming array is 2D');
            [Var info]=read2Dout(fname,XBdims);
        else
            % more complicated, could be ntheta, or nd or ngd or nd*ngd
            check=zeros(4,1);
            if sz==XBdims.ntheta
                check(1)=1;
            end
            if sz==XBdims.nd
                check(2)=1;
            end
            if sz==XBdims.ngd
                check(3)=1;
            end
            if sz==XBdims.nd*XBdims.ngd
                check(4)=1;
            end
            % Complies with nothing
            if sum(check)==0
                warning('File cannot be read, unknown size. Returning unprocessed values');
                Var=temp;
                info=['unknown'];
            elseif sum(check)==1
                ty=find(check==1);
                switch ty
                    case 1
                        display('Assuming array is 3Dwave');
                        [Var info]=readwaves(fname,XBdims);
                    case 2
                        display('Assuming array is 3Dbed');
                        [Var info]=readbedlayers(fname,XBdims);
                    case 3
                        display('Assuming array is 3Dsed');
                        [Var info]=readsediment(fname,XBdims);
                    case 4
                        display('Assuming array is 4Dbed');
                        [Var info]=readgraindist(fname,XBdims);
                end
            else
                display('Variable read is ambiguous');
                display('Please try one of the following dims:')
                display(options(check==1,:));
            end
        end
    end
end
