function varargout = delft3d_io_xyn(cmd,varargin)
%DELFT3D_IO_XYN   Read annotation files in a nan-separated list struct (*.xyn)
%
%    D          = DELFT3D_IO_XYN ('read','filename.xyn')
%   [x,y,names] = DELFT3D_IO_XYN ('read','filename.xyn')
%
%    reads all lines from an *.xyn observation point file into
%    a struct with fields x,y and name. The 3-column (x|y|name)
%    *.xyn format is inoput for D-Flow-FM.
%
%    D = DELFT3D_IO_XYN ('write','filename.xyn',D)
%    D = DELFT3D_IO_XYN ('write','filename.xyn',x,y,names)
%
%    writes 3-column (x|y|name) file.
%
%    D = DELFT3D_IO_XYN ('read','filename.xyn','epsg',epsg_code)
%
%    assumes the (x,y) data to be defined in epsg_code, and 
%    calculates (lon,lat) (epsg=4326).
%
% See also: dflowfm.opendap2obs, delft3d_io_obs, XY2MN, delft3d_io_ann, d3d_attrib

%%  --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%
%       Gerben de Boer
%
%       gerben.deboer@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

%% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
%  OpenEarthTools is an online collaboration to share and manage data and 
%  programming tools in an open source, version controlled environment.
%  Sign up to recieve regular updates of this function, and to contribute 
%  your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
%  $Id: delft3d_io_xyn.m 13769 2017-09-26 15:30:03Z groenenb $
%  $Date: 2017-09-26 23:30:03 +0800 (Tue, 26 Sep 2017) $
%  $Author: groenenb $
%  $Revision: 13769 $
%  $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/flow/delft3d_io_xyn.m $
%  $Keywords: $

if nargin ==1
   error(['At least 2 input arguments required: ',mfilename,'(''read''/''write'',filename)'])
end

switch lower(cmd),

case 'read',
 [STRUCT,iostat]=Local_read(varargin{:});
  if nargout==1
     varargout = {STRUCT};
  elseif nargout ==2
     varargout = {STRUCT.x,STRUCT.y};
  elseif nargout ==3
     varargout = {STRUCT.x,STRUCT.y,STRUCT.name};
  elseif nargout ==4
    error('too much output parameters: [1..3]')
  end
  
  if iostat<0,
     error(['Error opening file: ',varargin{1}])
  end;  

case 'write',
  iostat=Local_write(varargin{:});
  if nargout==1
     varargout = {iostat};
  elseif nargout >1
    error('too much output parameters: [0..1]')
  end
  if iostat<0,
     error(['Error opening file: ',varargin{1}])
  end;
end;

% ------------------------------------
% ------------------------------------
% ------------------------------------

function [D,iostat]=Local_read(varargin)

   OPT.epsg = [];

   fname  = varargin{1};
   
   OPT    = setproperty(OPT,{varargin{2:end}});

   fid    = fopen(fname,'r');

   D.x    = [];
   D.y    = [];
   D.name = {};

   rec = fgetl(fid);
   while ~isnumeric(rec)
       
       [x   ,rec ] = strtok(rec);
       [y   ,name] = strtok(rec);
       name = strtrim(name);
       
       if strcmpi(name(  1),'''') & ...
          strcmpi(name(end),'''')
          name = name(2:end-1);
       end
       
       if strcmpi(name(  1),'"') & ...
          strcmpi(name(end),'"')
          name = name(2:end-1);
       end       
       
       D.x(end+1)    = str2num(x);
       D.y(end+1)    = str2num(y);
       D.name{end+1} = name;

       rec = fgetl(fid);

   end
   iostat = fclose(fid);
   
   if ~isempty(OPT.epsg)
   [D.lon,D.lat] = convertCoordinates(D.x,D.y,'CS1.code',OPT.epsg,'CS2.code',4326);
   end
   
   varargout = {D,iostat};   
% ------------------------------------
% ------------------------------------
% ------------------------------------

function iostat=Local_write(varargin)   

   filename     = varargin{1};
   iostat       = 1;
   fid          = fopen(filename,'w');
   OS           = 'windows'; % or 'unix'

   if     nargin ==2
      D      = varargin{2};
   elseif nargin >3
      D.x    = varargin{2};
      D.y    = varargin{3};
      D.name = varargin{4};
   end
   
      for i=1:length(D.x)
       if ~isnan(D.x(i))
        fprintf(fid,'%10.7f %10.7f ''%s''',D.x(i),D.y(i),D.name{i});
        fprinteol(fid,OS);
       end
      end
   
   iostat = fclose(fid);

%% EOF