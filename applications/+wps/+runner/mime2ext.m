function [ ext ] = mime2ext( mime )
%MIME2EXT Convert mime type to extension
%   Detailed explanation goes here

switch (mime)
    case 'application/netcdf'
        ext = '.nc';
    %TODO fix in PyWPS 
    otherwise
        ext = '.nc';
end
end

