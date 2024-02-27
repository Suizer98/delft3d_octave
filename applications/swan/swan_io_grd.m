function varargout = swan_io_grd(cmd,fname,varargin)
%SWAN_IO_GRD              read/write SWAN ASCII grid file     (BETA VERSION)
%
% dep = swan_io_grd('load' ,fname,mxc,myc,xexc,yexc,<IDLA>)
% dep = swan_io_grd('read' ,fname,mxc,myc,xexc,yexc,<IDLA>)
%
% dep = swan_io_grd('load' ,fname,cgrid            ,<IDLA>)
% dep = swan_io_grd('read' ,fname,cgrid            ,<IDLA>)
%
% dep = swan_io_grd('write',fname,x  ,y  ,<IDLA>)
%
%    where size(x,1) = mmax 
%    and   size(x,2) = nmax 
%    
%    These mmax and nmax are 1 smaller than those mentioned 
%    in the Delft3d-FLOW mdf file, as the Delft3d-FLOW adds 
%    one dummy row and column.
%    
%    These mmax and nmax are 1 bigger than those mentioned 
%    in the SWAN input file as mmax and nmax refer to number of 
%    nodes, while the SWAN inp file refers to number of meshes.
%
%    where cgrid is a struct with fields 'mxc','myc','xexc','yexc'
%    which can be obtained by reading the associated *.swn input file with
%    swan_input.
%    NOTE 1. mxc and myc are number of meshes, which are one 
%     less then the number of nodes in the file !!
%    NOTE 2. mxc and myc are 2 smaller
%     than mmax and nmax mentioned in the Delft3d-FLOW mdf file, as
%     the Delft3d-FLOW adds one dummy row and column of nodes.
%    NOTE 3. Only default IDLA option (see SWAN manual) currently implemented.
%
% See also: SWAN_IO_SPECTRUM, SWAN_IO_INPUT, SWAN_IO_TABLE, SWAN_IO_BOT

%   --------------------------------------------------------------------
%   Copyright (C) 2006-2009 Deltares
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

% $Id: swan_io_grd.m 14544 2018-08-27 12:22:25Z matthijs.benit.x $
% $Date: 2018-08-27 20:22:25 +0800 (Mon, 27 Aug 2018) $
% $Author: matthijs.benit.x $
% $Revision: 14544 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/swan/swan_io_grd.m $

if     strcmp(cmd,'read') | ...
       strcmp(cmd,'load')
       
   %% Input
   %% ------------------------------

   if isstruct(varargin{1})
      cgrid = varargin{1};
      mxc   = cgrid.mxc ;
      myc   = cgrid.myc ;
      xexc  = cgrid.xexc;
      yexc  = cgrid.yexc;
      if nargin>3
       IDLA = varargin{2};
      end
   else
      mxc   = varargin{1};
      myc   = varargin{2};
      xexc  = varargin{3};
      yexc  = varargin{4};
      if nargin>6
       IDLA = varargin{5};
      end
   end

   mmax = mxc + 1; % mxc is number of meshes, we want number of nodes mmax
   nmax = myc + 1; % mxc is number of meshes, we want number of nodes nmax

   %% Read
   %% ------------------------------

   DAT.filename     = fname;
   iostat           = 1;
   
   tmp = dir(fname);
   
   if length(tmp)==0
      
      if nargout==1
         error(['Error finding file: ',fname])
      else
         iostat = -1;
      end      
      
   elseif length(tmp)>0
   
      DAT.filedate     = tmp.date;
      DAT.filebytes    = tmp.bytes;
   
      sptfilenameshort = filename(fname);
      
      fid       = fopen  (fname,'r');

      if fid < 0
         
         if nargout==1
            error(['Error opening file: ',fname])
         else
            iostat = -1;
         end
      
      elseif fid > 2
      
         try
         
         %% Start actual reading of the file
         %% ------------------------------
         
         %% x-coordinates
         %% ------------------------------
          
          rec = fgetl(fid);
          
          [DAT.X,count] = fscanf(fid,'%g',mmax*nmax);
         %warning ('Still to implement other then default IDLA options ...');
          DAT.X = reshape(DAT.X,mmax,nmax);
          DAT.X(DAT.X==xexc) = nan;
         
         %% y-coordinates
         %% ------------------------------
          
          rec = fgetl(fid); % read last part of previous line eol character)
          if ~strcmp(lower(strtrim(rec)),'y-coordinates')
          rec = fgetl(fid);
          end
          
          [DAT.Y,count] = fscanf(fid,'%g',mmax*nmax);
         %warning ('Still to implement other then default IDLA options ...');
          DAT.Y = reshape(DAT.Y,mmax,nmax);
          DAT.Y(DAT.Y==yexc) = nan;
          
         catch
          
            if nargout==1
               error(['Error reading file: ',fname])
            else
               iostat = -1;
            end      
         
         end % try
         
         fclose(fid);
         
      end %  if fid <0
      
   end % if length(tmp)==0
   
   DAT.iomethod = '';
   DAT.read_at  = datestr(now);
   DAT.iostatus = iostat;
   
   varargout = {DAT};
   
elseif strcmp(cmd,'write')

   %% Input
   %% ------------------

   x  = varargin{1};
   y  = varargin{2};
   
   if nargin>5
      error('syntax: dep = swan_io_grd(''write'',filename,x,y,<IDLA>');
   end
   
    %  %% only works when all lines are full
    %  leng = prod(size(dep))./4;
    %  dep  = reshape(dep,[4 leng])';
    %  %% check whether the maximum lenght of file lines =  120 characters?
    %  save(fname,'dep','-ascii')
      
      fid = fopen(fname,'w');
      
      npoints         = size(x,1); %length(x(:));
      pointsperline   = 6;
      nlines          = floor(npoints./pointsperline);
      pointslastline  = 1:(npoints - pointsperline*nlines);
      format          = [repmat('%12.3f ',[1 pointsperline      ]),'\n'];
      if ~isempty(pointslastline)
      formatlastline  = [repmat('%12.3f ',[1 pointslastline(end)]),'\n'];
      end
      
      %% x
      %% -------------------------
      
      fprintf(fid,'%s\n','x-coordinates');

      for j=1:size(x,2)
      for iline=1:nlines
         fprintf(fid,format,x((iline-1).*pointsperline + [1:pointsperline],j));
      end
         if ~isempty(pointslastline)
         fprintf(fid,formatlastline,x((iline).*pointsperline + pointslastline,j));
         end
      end
         
      %% y
      %% -------------------------
      
      fprintf(fid,'%s\n','y-coordinates');

      for j=1:size(x,2)
      for iline=1:nlines
         fprintf(fid,format,y((iline-1).*pointsperline + [1:pointsperline],j));
      end
         if ~isempty(pointslastline)
         fprintf(fid,formatlastline,y((iline).*pointsperline + pointslastline,j));
         end
      end

      %% -------------------------
      fclose(fid);
      
      varargout = {1};
      
else 

   error('syntax: dep = swan_io_grd(''write''/''load''/''read'',...)')

end   

%% EOF