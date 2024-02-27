function LDB = readldb(filename,varargin)
% READLDB reads landboundary files in nan-separated
%  list struct.
%
%    readldb reads all lines from a *.ldb landboudnary file
%    into a nan separated list struct (vector map).
%
%    LDB = readldb(filename) returns the x and y
%    (or lat and lon) vertices in the struct fields
%    LDB.x and LDB.y respectively.
%
%    If LDB has a field named 'Check' containing 
%    'error', somethinh went wrong.
%
%    H =readldb(filename,illegalmarkers) 
%    sets all values in array illegalmarkers tot nan.
%
%    H =readldb(filename,illegalmarkers,scale) 
%    DIVIDES x and y with scale.
%
%    H =readldb(filename,illegalmarkers,[xscale yscale]) 
%    multiplies x with xscale and y with yscale
%
%    See also POLYSPLIT, POLYJOIN, POLYBOOL, POLYCUT, TEKAL
%    (all from matlab mapping toolbox).

%   --------------------------------------------------------------------
%   Copyright (C) 2004 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@citg.tudelft.nl  
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

   FileInfo=tekal('open',filename,'loaddata');
         
   if strcmp(FileInfo.Check,'OK')
      for i=1:length(FileInfo.Field)
          if i==1
             LDB.x=[FileInfo.Field(i).Data(:,1)];
             LDB.y=[FileInfo.Field(i).Data(:,2)];
          else
             LDB.x=[LDB.x' nan FileInfo.Field(i).Data(:,1)']';
             LDB.y=[LDB.y' nan FileInfo.Field(i).Data(:,2)']';
          end
      end
      % Remove illegalmarkers
      % ---------------------
      if nargin>1
         illegalmarkers = varargin{1};
         for i=1:length(illegalmarkers(:))
            LDB.x(LDB.x==illegalmarkers(i))=nan;
            LDB.y(LDB.y==illegalmarkers(i))=nan;
         end
      end
      if nargin>2
          scale = varargin{2};
          if length(scale)==2
             xscale = scale(1);
             yscale = scale(2);
          else
             xscale = scale;
             yscale = scale;
          end
      else
          xscale = 1;
          yscale = 1;
      end
      
   else
      LDB.x=[];
      LDB.y=[];
      LDB.Check = 'error';
   end

   LDB.x=LDB.x.*xscale;
   LDB.y=LDB.y.*yscale;

   LDB.filename    = FileInfo.FileName;
   LDB.no_polygons = length(FileInfo.Field);
