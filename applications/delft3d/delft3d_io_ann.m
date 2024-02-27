function varargout = delft3d_io_ann(cmd,varargin)
%DELFT3D_IO_ANN   Read annotation files in a nan-separated list struct (*.ann)  (BETA VERSION)
%
%    DELFT3D_IO_ANN reads all lines from an *.ann annotation file
%    into a nan separated list struct (vector map). Annotation files (and
%    landboudnaries) are in TEKAL format.
%
%    D = DELFT3D_IO_ANN('read',filename) returns the x and y
%    (or lat and lon) vertices in the struct fields
%    D.x and D.y respectively. The texts are returned
%    in D.txt
%
%    [x,y,<txt>] = DELFT3D_IO_ANN('read',filename);
%
%    D = DELFT3D_IO_ANN('read',filename,scale)
%    multiplies x and y with scale
%
%    D = DELFT3D_IO_ANN('read',filename,xscale,yscale)
%    multiplies x and y with xscale and yscale respectively.
%
%    iostat = DELFT3D_IO_ANN('write',filename,D.DATA)
%    iostat = DELFT3D_IO_ANN('write',filename,x,y,txt)
%
% See also: TEKAL, LANDBOUNDARY, DELFT3D_IO_XYN

% 2005 Jan 01
% 2008 Jul 21: made read a sub-function
% 2008 Jul 22: added write option
% 2009 feb 13: made also [x,y,text] output
% 2013 aug   : made also [x,y,text] input
% 2014 march : TK added optional argument for writing "Muppet" (true/false,
%              default false) allowing for writing a annotation file such that
%              it can be used in Muppet.

%   --------------------------------------------------------------------
%   Copyright (C) 2004-2008 Delft University of Technology
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

% $Id: delft3d_io_ann.m 11779 2015-03-04 16:10:35Z kaaij $
% $Date: 2015-03-05 00:10:35 +0800 (Thu, 05 Mar 2015) $
% $Author: kaaij $
% $Revision: 11779 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/delft3d_io_ann.m $

if nargin ==1
   error(['At least 2 input arguments required: delft3d_io_ann(''read''/''write'',filename)'])
end

switch lower(cmd),

case 'read',
   [STRUCT,iostat]=Local_read(varargin{:});
  if nargout==1
     varargout = {STRUCT};
  elseif nargout ==2
     varargout = {STRUCT.DATA.x,STRUCT.DATA.y};
  elseif nargout ==3
     varargout = {STRUCT.DATA.x,STRUCT.DATA.y,STRUCT.DATA.txt};
  elseif nargout ==4
    error('too much output parameters: [1..3]')
  end
  if STRUCT.iostat<0,
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

function [S,iostat]=Local_read(varargin)

   fname = varargin{1};

   tmp               = dir(fname);
   if length(tmp)==0
      error(['Annotation file ''',fname,''' does not exist.'])
   end
   S.name  = tmp.name ;
   S.date  = tmp.date ;
   S.bytes = tmp.bytes;

   if nargin>2
       xscale = varargin{2};
       yscale = varargin{2};
   elseif nargin >3
       xscale = varargin{2};
       yscale = varargin{3};
   else
       xscale = 1;
       yscale = 1;
   end

   RAWDATA = tekal('open',fname);

   if strcmp(RAWDATA.Check,'OK')
      for i=1:length(RAWDATA.Field)
         SUBSET         = tekal('read',RAWDATA,i);
         S.DATA(i).x    = SUBSET{1}(:,1).*xscale;
         S.DATA(i).y    = SUBSET{1}(:,2).*yscale;
         S.DATA(i).txt  = SUBSET{2};
      end
      S.iostat   = 1;
   else
      S.DATA.x   = [];
      S.DATA.y   = [];
      S.DATA.txt = [];
      S.iostat   = 0;
   end

   iostat = S.iostat;

% ------------------------------------

function iostat=Local_write(varargin)

OPT.Muppet   = false;
filename     = varargin{1};
if isnumeric(varargin{2})
   S.x   = varargin{2};
   S.y   = varargin{3};
   S.txt = varargin{4};
   if nargin > 4
       OPT = setproperty(OPT,varargin{5:end});
   end
else
   S     = varargin{2};
   if nargin > 2
       OPT = setproperty(OPT,varargin{5:end});
   end

end

iostat       = 1;
fid          = fopen(filename,'w');
OS           = 'windows';

%% Header

if ~OPT.Muppet
    fprintf  (fid,'%s',['* File created on ',datestr(now),' with matlab function delft3d_io_ann.m']);
    fprinteol(fid,OS);

    fprintf  (fid,'%s',['BLOCK01']);
    fprinteol(fid,OS);

    fprintf  (fid,'%d ',length(S.x));
    fprintf  (fid,'%d ',3             );
    fprinteol(fid,OS);

    %% Table

    for istat=1:length(S.x)

        fprintf  (fid,'%f ',S.x  (istat));
        fprintf  (fid,'%f ',S.y  (istat));
        fprintf  (fid,'%s ',S.txt{istat});
        fprinteol(fid,OS);

    end
else
    for istat=1:length(S.x)

        fprintf  (fid,'%f ',S.x  (istat));
        fprintf  (fid,'%f ',S.y  (istat));
        fprintf  (fid,'%s ',['"' S.txt{istat} '"']);
        fprinteol(fid,OS);

    end
end

iostat = fclose(fid);

%% EOF
