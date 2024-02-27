function varargout=delft3d_io_fou(cmd,varargin),
%DELFT3D_IO_FOU   read/write Fourier files <<beta version!>>
%
%  DATA=delft3d_io_fou('read' ,filename);
%
%       delft3d_io_fou('write',filename,DATA);
%       delft3d_io_fou('write',filename,DATA,<keyword,value>);
%
% Example: change t0 or t1 to let period match n*T
%
%    t0 = 36*60; % skip spin-up 
%    t1 = 44640; % 1 month
%    T  = 60./t_tide_name2freq({'S2','M2'},'unit','cyc/hr')
%    n  = floor((t1-t0)./T)
%    dt = (t1-t0) - n.*T;
%    t1new = t0 + dt
%    round(t1new) % times to be inserted into fou file.
%
% Example: take fou for one month, and make new fou for another month 
% (of same year with same itdate reference date in mdf file)
%
%    D = delft3d_io_fou('read','01.fou');' % pre-configured for Jan
%    yyy = 2009;mm = 2;                    % new one for Feb
%    D.data.t_start = D.data.t_start + (datenum(yyyy,mm,1) - datenum(yyyy,1,1))*24*60;
%    D.data.t_stop  = D.data.t_stop  + (datenum(yyyy,mm,1) - datenum(yyyy,1,1))*24*60;
%    delft3d_io_fou('write',[num2str(mm),'.fou'],D)
%
% See also: delft3d, delft3d_fou2hdf, tekal

%   --------------------------------------------------------------------
%   Copyright (C) 2007 Delft University of Technology
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

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

% $Id: delft3d_io_fou.m 10334 2014-03-05 09:06:25Z boer_g $
% $Date: 2014-03-05 17:06:25 +0800 (Wed, 05 Mar 2014) $
% $Author: boer_g $
% $Revision: 10334 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/flow/delft3d_io_fou.m $

if nargin ==1
   error(['At least 2 input arguments required: delft3d_io_fou(''read''/''write'',filename)'])
end

switch lower(cmd),
case 'read',
  STRUCT=Local_read(varargin{:});
  if nargout ==1
     varargout = {STRUCT};
  elseif nargout >1
     error('too much output paramters: 0 or 1')
  end
  if STRUCT.iostat<0,
     error(['Error opening file: ',varargin{1}])
  end;
case 'write',
  iostat=Local_write(varargin{:});
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
% --READ------------------------------
% ------------------------------------

function varargout=Local_read(fname,varargin),

%% Input

   OPT.case = 'lower';

if odd(nargin)
   i=1;
   while i<=nargin-1,
     if ischar(varargin{i}),
       switch lower(varargin{i})
      %case 'keyword'      ;i=i+1;OPT.case = varargin{i};
       otherwise
          error(sprintf('Invalid string argument: %s.',varargin{i}));
       end
     end;
     i=i+1;
   end;
end

 STRUCT.filename     = fname;
 STRUCT.iostat       = -3;

%% Locate

tmp = dir(fname);

if length(tmp)==0
   
   STRUCT.iostat = -1;
   disp (['??? Error using ==> delft3d_io_mdf'])
   disp (['Error finding file: ',fname])
   
elseif length(tmp)>0

   STRUCT.filedate  = tmp.date;
   STRUCT.filebytes = tmp.bytes;

   fid              = fopen(STRUCT.filename,'r');

   %% Open

   if fid < 0
      
      STRUCT.iostat = -2;
      disp (['??? Error using ==> delft3d_io_mdf'])
      disp (['Error opening file: ',fname])

   elseif fid > 2

   %% Read

   try

      iline      = 0;
      while 1

         %% get line

         newline          = fgetl(fid);
         if ~ischar(newline);break, end % -1 when eof
         iline=iline+1;
   
         [STRUCT.data.parameter{iline},           newline] = strtok (newline);%1
         [value,                                  newline] = strtok (newline);%2
          STRUCT.data.t_start(iline)                       = str2num(value);
         [value,                                  newline] = strtok (newline);%3
          STRUCT.data.t_stop(iline)                        = str2num(value);
         [value,                                  newline] = strtok (newline);%4
          STRUCT.data.n_cycles(iline)                      = str2num(value);
         [value,                                  newline] = strtok (newline);%5
          STRUCT.data.nodal_amplification(iline)           = str2num(value);
         [value,                                  newline] = strtok (newline);%6
          STRUCT.data.astronomical_argument(iline)         = str2num(value);
          try % optional for water levels
         [value,                                  newline] = strtok (newline);%7
          STRUCT.data.layer(iline)                         = str2num(value);
          catch
          STRUCT.data.layer(iline)                         =0; % irrelevant for for water levels or depth-averaged
          end
          try % optional
         [value,                                  newline] = strtok (newline);%8
          STRUCT.data.flag{iline}                          = value; % char value like y/m or min/max
          end
         
      end % while
      
      %% Finished succesfully

      STRUCT.NTables = iline;
      fclose(fid);
      STRUCT.iostat    = 1;

   catch
   
      STRUCT.iostat = -3;
      disp (['??? Error using ==> delft3d_io_fou'])
      disp (['Error reading file: ',fname])
   
   end % catch

end % if fid < 0

end %elseif length(tmp)>0

if nargout==1
   varargout = {STRUCT};   
else
   varargout = {STRUCT,STRUCT.iostat};   
end

% ------------------------------------
% --WRITE-----------------------------
% ------------------------------------

function iostat=Local_write(filename,STRUCT),

iostat       = 1;
fid          = fopen(filename,'w');
OPT.OS       = 'windows'; % or 'unix'

%% Input

   OPT.case = 'lower';
   
   if odd(nargin)
      i=1;
      while i<=nargin-3,
        if ischar(varargin{i}),
          switch lower(varargin{i})
          case 'OS'      ;i=i+1;OPT.OS = varargin{i};
          otherwise
             error(sprintf('Invalid string argument: %s.',varargin{i}));
          end
        end;
        i=i+1;
      end;
   end
   
   for iline=1:length(STRUCT.data.parameter)
   
      fprintf   (fid,'%s '   ,STRUCT.data.parameter{iline}            );%1
      fprintf   (fid,'%d '   ,STRUCT.data.t_start(iline)              );%2
      fprintf   (fid,'%d '   ,STRUCT.data.t_stop(iline)               );%3
      fprintf   (fid,'%d '   ,STRUCT.data.n_cycles(iline)             );%4
      fprintf   (fid,'%5.3f ',STRUCT.data.nodal_amplification(iline)  );%5
      fprintf   (fid,'%5.3f ',STRUCT.data.astronomical_argument(iline));%6
      if isfield(STRUCT.data,'layer') 
      if ~(STRUCT.data.layer(iline)==0)
      fprintf   (fid,'%d ',STRUCT.data.layer(iline)                );%7
      end
      end
      if isfield(STRUCT.data,'flag')
      fprintf   (fid,'%s ',STRUCT.data.flag{iline}                 );%8
      end
      fprinteol (fid,OPT.OS);
      
   end

fclose(fid);
iostat=1;

% ------------------------------------
% ------------------------------------
% ------------------------------------

%% EOF