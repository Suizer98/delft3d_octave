function varargout = delft3d_io_adm(cmd,varargin)
% DELFT3D_IO_ADM  reads Delft3D nest *.adm file with BETA neumann extension (BETA)
%
% [bnd1,bnd2] = delft3d_io_adm('read',filename)
% [bnd1     ] = delft3d_io_adm('read',filename,1)
% [bnd1     ] = delft3d_io_adm('read',filename,2)
%
% where
% bnd1 is organized in a struct with one 
%      entry per boundary point and
%
% bnd2 has one field per parameter with a matrix
%      containg the data for all boudnary points,
%      the first index being the boundary point number.
%
% Note that each (m,n) coordinate exists twice, once as 
% at water level point, and once as normal velocity point.
% In future the tangential velcotiy points might be added.
%
% See also: delft3d_io_ann, delft3d_io_bca, delft3d_io_bch, delft3d_io_bnd, 
%           delft3d_io_crs, delft3d_io_dep, delft3d_io_dry, delft3d_io_eva, 
%           delft3d_io_fou, delft3d_io_grd, delft3d_io_ini, delft3d_io_mdf, 
%           delft3d_io_obs, delft3d_io_restart,             delft3d_io_src, 
%           delft3d_io_tem, delft3d_io_thd, delft3d_io_wnd, 

%   --------------------------------------------------------------------
%   Copyright (C) 2004 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl	
%
%       Fluid Mechanics Section
%       Faculty of Civil Engineering and Geosciences
%       PO Box 5048
%       2600 GA Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   --------------------------------------------------------------------

switch lower(cmd),
case 'read',
  filename   = varargin{1};
  if nargin==2
     outputtype = 1;
     [ADM1,ADM2]=Local_read(filename,0);
     varargout = {ADM1,ADM2};
  elseif nargin==3
     outputtype = varargin{2};
     [ADM]=Local_read(filename,outputtype);
     varargout = {ADM};
  end
  
  
case 'write',
  iostat=Local_write(varargin{1:end});
  if nargout ==1
     varargout = {iostat};
  elseif nargout >1
     error('too much output paramters: 0 or 1')
  end
  if iostat<0,
     error(['Error opening file: ',varargin{1}])
  end;
end;

% ------------------------------------
% ------------------------------------
% ------------------------------------

function varargout=Local_read(filename,outputtype)

fid       = fopen(filename,'r');

option_debug = 0;

if fid < 0
  error(['Error opening file: ',filename])
end

try

   i_small   = 0;
   i_large   = 0;
   
   record   = fgetl(fid);
   
   while strcmp(record(1),'*')
      record   = fgetl(fid);
   end   
   
   first       = 1;
   end_of_file = 0;
   
   while ~end_of_file
   
      if ~first
         record   = fgetl(fid);
         if record==-1
            end_of_file = 1;
            break
         end
      else
         first = 0;
         end_of_file = 0;
      end
      
      i_small = i_small + 1;
      
      bnd(i_small).m = str2num(record(60:62));
      bnd(i_small).n = str2num(record(64:66));
      location       = record(25:35);
      
      if     strcmp(location,'water level')
         location = 'zwl';
      elseif strcmp(location,'velocity   ');
         location = 'vel';
      end
      
      numbers = sscanf(record(76:end),'%f');
      
      bnd(i_small).angle = numbers(1);
      bnd(i_small).x     = numbers(2);
      bnd(i_small).y     = numbers(3);
      bnd(i_small).type  = location;
      
      numbers = fscanf(fid,'%20f');
      
      bnd(i_small).ptr_m = numbers(1:5:end);
      bnd(i_small).ptr_n = numbers(2:5:end);
      bnd(i_small).ptr_w = numbers(3:5:end);
      bnd(i_small).ptr_x = numbers(4:5:end);
      bnd(i_small).ptr_y = numbers(5:5:end);
      
      if option_debug
      disp(['Read boundary ',num2str(i_small),' ',location]);
      end
   
   end
   
   n_small   = i_small;
   
   BND.m     = repmat(0  ,[n_small 1]);
   BND.n     = repmat(0  ,[n_small 1]);
   BND.x     = repmat(0  ,[n_small 1]);
   BND.y     = repmat(0  ,[n_small 1]);
   BND.angle = repmat(0  ,[n_small 1]);
   BND.type  = repmat(' ',[n_small 3]);
   
   BND.ptr_m = repmat(0  ,[n_small 4]);
   BND.ptr_n = repmat(0  ,[n_small 4]);
   BND.ptr_w = repmat(0  ,[n_small 4]);
   BND.ptr_x = repmat(0  ,[n_small 4]);
   BND.ptr_y = repmat(0  ,[n_small 4]);
   
   for i_small = 1:n_small
   
      BND.m    (i_small,:) = bnd(i_small).m    ;
      BND.n    (i_small,:) = bnd(i_small).n    ;
      BND.x    (i_small,:) = bnd(i_small).x    ;
      BND.y    (i_small,:) = bnd(i_small).y    ;
      BND.angle(i_small,:) = bnd(i_small).angle;
      BND.type (i_small,:) = bnd(i_small).type ;
      
      BND.ptr_m(i_small,:) = bnd(i_small).ptr_m;
      BND.ptr_n(i_small,:) = bnd(i_small).ptr_n;
      BND.ptr_w(i_small,:) = bnd(i_small).ptr_w;
      BND.ptr_x(i_small,:) = bnd(i_small).ptr_x;
      BND.ptr_y(i_small,:) = bnd(i_small).ptr_y;
      
      ptr_mask = (BND.ptr_m==0) & (BND.ptr_n==0) & (BND.ptr_w==0);
      
      BND.ptr_x(ptr_mask) = nan;
      BND.ptr_y(ptr_mask) = nan;
   
   end
   
catch
   error(['Error reading file (after sucessfull opening): ',filename])
end   
   
   if nargout==2 & outputtype==0 
      varargout = {bnd,BND};
   else
      if nargout==1 & outputtype==1
         varargout = {bnd};
      elseif nargout==1 & outputtype==2
         varargout = {BND};
      end
   end   


