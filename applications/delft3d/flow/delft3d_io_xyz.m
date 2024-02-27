function varargout=delft3d_io_xyz(cmd,varargin),
%DELFT3D_IO_XYZ   Read/write xyz depth samples file
%
% [x,y,z]   = delft3d_io_xyz('read' , filename);
%             delft3d_io_xyz('write', filename,x,y,z);
%
% See also: flow

%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Gerben de Boer
%
%       <g.j.deboer@deltares.nl>
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% $Id: delft3d_io_xyz.m 7514 2012-10-17 14:08:49Z boer_g $
% $Date: 2012-10-17 22:08:49 +0800 (Wed, 17 Oct 2012) $
% $Author: boer_g $
% $Revision: 7514 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/flow/delft3d_io_xyz.m $
% $Keywords: $

if nargin ==1
   error(['AT least 2 input arguments required: d3d_io_...(''read''/''write'',filename)'])
end

switch lower(cmd),
case 'read',
  [x,y,z,iostat] = Local_read(varargin{:});
  if nargout ==3
     varargout = {x,y,z};
  elseif nargout >1
     error('too much output parameters: 0 or 1')
  end
  if iostat<0,
     error(['Error opening file: ',varargin{1}])
  end;
case 'write',
  iostat=Local_write(varargin{:});
  if nargout ==1
     varargout = {iostat};
  elseif nargout >1
     error('too much output parameters: 0 or 1')
  end
  if iostat<0,
     error(['Error opening file: ',varargin{1}])
  end;
end;

%% ------------------------------------

function varargout = Local_read(fname,varargin),

%% Locate
   
   tmp = dir(fname);
   
   if length(tmp)==0
      
      D.iostat = -1;
      disp (['??? Error using ==> delft3d_io_wnd'])
      disp (['Error finding meteo file: ',fname])
      
   elseif length(tmp)>0
   
      D.filedate  = tmp.date;
      D.filebytes = tmp.bytes;
   
   %% Read
         
      %try
      
      fid = fopen(fname, 'r');
      
      raw=fscanf(fid,'%f',Inf);
      
      x = raw(1:3:end);
      y = raw(2:3:end);
      z = raw(3:3:end);
      
      clear raw
      
      iostat = fclose(fid);

      %catch
      %
      %   D.iostat = -3;
      %   disp (['??? Error using ==> ',mfilename])
      %   disp (['Error reading wind file: ',fname])
      %
      %end % catch
   
   end %elseif length(tmp)>0

if nargout==1
   varargout = {x,y,z};   
else
   varargout = {x,y,z,iostat};   
end

%% ------------------------------------

function iostat=Local_write(fname,x,y,z,varargin),

   OPT.debug  = 1;

   iostat     = 0;

%% Initialize

   iostat       = 1;

%% Locate
   
   tmp       = dir(fname);
   writefile = [];
   
   if length(tmp)==0
      
      writefile = true;
      
   else

      while ~islogical(writefile)
         disp(['xyz samples already exists: ''',fname,'''']);
         writefile    = input('o<verwrite> / c<ancel>: ','s');
         if strcmpi(writefile(1),'o')
            writefile = true;
         elseif strcmpi(writefile(1),'c')
            writefile = false;
            iostat    = 0;
         end
      end

   end % length(tmp)==0
   
   if writefile
   
     fid = fopen(fname,'w');
     
     n = length(x(:));
     
     for i=1:n
        if OPT.debug
         if mod(i,1e4)==0
          disp([num2str(100*i/n),' %'])
         end
        end
        if ~isnan(z(i))
        fprintf(fid,'%f %f %f \n',x(i),y(i),z(i));
        end
     end
     
   end % writefile

%% Close

   fclose(fid);
   iostat=1;
