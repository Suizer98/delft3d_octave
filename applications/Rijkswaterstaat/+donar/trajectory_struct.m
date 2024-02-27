function [S,M]=trajectory_struct(D,M0,ncolumn,varargin)
%trajectory_struct convert matrix output from read to struct
%
%   [S,M]=trajectory_struct(D,M)
%
% converts matrix D from donar.read to struct, and updates
% metadata struct M to include dimensions as for a CF trajectory.
%
%  File              = donar.open(diafile)
% [data ,  metadata] = donar.read(File,1,6) % 1st variable, residing in 6th column
% [struct, metadata] = donar.struct(data, metadata)
%
%See also: open, read, disp, ctd_struct

if nargin==2
    ncolumn = size(D,2)-2; % last ones are:  /-flags, dia index
end

 % TO DO make x,y, when M.data.hdr tells so
 
    M.data = M0;
    
    M.lon.standard_name  = 'degrees_east';
    M.lon.units          = 'Longitude';
    M.lon.long_name      = 'Longitude';

    M.lat.standard_name  = 'degrees_north';
    M.lat.units          = 'Latitude';
    M.lat.long_name      = 'Latitude';

    M.z.standard_name    = 'cm';
    M.z.units            = 'cm';
    M.z.long_name        = 'Vertical coordinate';
    M.z.positive         = 'down';
    
    M.datenum.standard_name = 'time';
    M.datenum.units         = 'days since 1970-01-01';
    M.datenum.long_name     = 'time';
     
    S.lon     = D(:,1);
    S.lat     = D(:,2);
    S.z       = D(:,3);
    S.datenum = D(:,4);
    S.data    = D(:,ncolumn);
   %S.flag    = D(:,ncolumn+1); % always 0: no information
    S.block   = D(:,ncolumn+2);
    
    %% Store header as global attributes
   
   flds = donar.headercode2attribute(fields(M0.hdr));
   
   for i = 1:1:size(flds,1)
       for j = 1:1:size(    flds{i,2},1)
           attcode =        flds{i,2}{j,1}; % 1 or 2
           %varname =        flds{i,2}{j,2}; -1 for nc_global
           attname =        flds{i,2}{j,3};
           attval  = M0.hdr.(flds{i,1}){attcode};
           %nc_attput(ncfile, varname, attname, attval);
           M.nc_global.(attname) = attval;
         % M.data.nc_global.(attname) = attval;
       end
   end