function varargout=delft3d_io_obs(cmd,varargin),
%DELFT3D_IO_OBS   read/write observations points file (*.obs) <<beta version!>>
%
%  D          = delft3d_io_obs('read' ,filename);
% [x,y,namst] = delft3d_io_obs('read' ,filename);
%
% reads all lines from an *.obs observation point file into
% a struct D with fields m, n and name. Optionally
%
%  D = delft3d_io_obs('read' ,filename,G);
%  D = delft3d_io_obs('read' ,filename,'gridfilename.grd');
%
% To write river locations
%
%        delft3d_io_obs('write','filename.obs',D);
%        delft3d_io_obs('write','filename.obs',m,n,namst);
%
% where D is a struct with fields 'm','n','namst'
% where namst is read as a 2C char array, but can also be a cellstr.
%
%  D = delft3d_io_obs('read' ,filename,G);
%  [x,y,namst] = delft3d_io_obs('read' ,filename,G);
%
% also returns the x and y coordinates, where G = delft3d_io_grd('read',...)
%
% See also: dflowfm.opendap2obs, delft3d, d3d_attrib, delft3d_io_xyn, XY2MN, pol2obs

%   --------------------------------------------------------------------
%   Copyright (C) 2005-8 Delft University of Technology
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
%   USA or
%   http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% $Id: delft3d_io_obs.m 16386 2020-05-19 15:05:20Z kaaij $
% $Date: 2020-05-19 23:05:20 +0800 (Tue, 19 May 2020) $
% $Author: kaaij $
% $Revision: 16386 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/flow/delft3d_io_obs.m $

if nargin ==1
   error(['At least 2 input arguments required: ',mfilename,'(''read''/''write'',filename)'])
end

switch lower(cmd),
case 'read',
 [S,iostat]=Local_read(varargin{:});
  if nargout==1
     varargout = {S};
  elseif nargout ==2
     varargout = {S.x,S.y};
  elseif nargout ==3
     varargout = {S.x,S.y,S.namst};
  elseif nargout ==4
    error('too much output parameters: [1..3]')
  end

  if iostat<0,
     error(['Error opening file: ',varargin{1}])
  end;

case 'write',
  iostat=Local_write(varargin{:});
  if nargout ==1
     varargout = {iostat};
  elseif nargout >1
    error('too much output parameters: [0..1]')
  end
  if iostat<0,
     error(['Error opening file: ',varargin{1}])
  end;
end;

% ------------------------------------

function [S,iostat] = Local_read(varargin)

S.filename = varargin{1};

   try

     [S.namst,...
      S.m    ,...
      S.n    ]=textread(S.filename,'%20c%d%d');

     S.NTables = length(S.m);
     S.m=S.m';
     S.n=S.n';

    %% optionally get world coordinates
     if nargin >1
        if ischar(varargin{2})
           G   = delft3d_io_grd('read',varargin{2});
        else
           G   = varargin{2};
        end
        for i=1:length(S.m)
           S.x(i) = G.cen.x(S.n(i)-1,S.m(i)-1);
           S.y(i) = G.cen.y(S.n(i)-1,S.m(i)-1);
        end
     end

     iostat  = 1;
   catch
     try
         fid = fopen(S.filename,'r');
         i_stat = 1
         while ~feof(fid)
             tline = fgetl(fid);
             S.namst(i_stat,1:20) = tline(1:20);
             tmp = sscanf(tline(21:end),'%i%i');
             S.m(i_stat) = tmp(1);
             S.n(i_stat) = tmp(2);
             i_stat = i_stat + 1;
          end
          fclose(fid);
          iostat = 1;
    catch
        iostat  = -1;
     end
   end

if nargout==1
   varargout = {S};
else
   varargout = {S,iostat};
end

% ------------------------------------

function iostat=Local_write(varargin)

filename     = varargin{1};
iostat       = 1;
OPT.OS       = 'windows'; % or 'unix'
OPT.format   = 'obs';

%% Does not work like this
% OPT = setproperty(OPT,varargin{2:end});
if isstruct (varargin{2})
    OPT = setproperty(OPT,varargin{3:end});
else
    names = false;
    try
        OPT = setproperty(OPT,varargin{4:end});
     catch
        OPT = setproperty(OPT,varargin{5:end});
        names = true;
    end
end

if strcmpi(OPT.format,'obs')

   fid          = fopen(filename,'w');
   if     isstruct (varargin{2})
      D       = varargin{2};
   else
      D.m     = varargin{2};
      D.n     = varargin{3};
      if names
          D.namst = varargin{4};
      end
   end

   if ~isfield(D,'namst')
      D.namst = [];
      for iobs=1:length(D.m)
         D.namst = strvcat(D.namst,['(',num2str(D.m(iobs)),',',...
                                        num2str(D.n(iobs)),')']);
      end
   end

   D.namst = cellstr(D.namst);

   for iobs=1:length(D.m)

      fprintfstringpad(fid,20,D.namst{iobs});

      fprintf(fid,' %7d',D.m    (iobs  ));
      fprintf(fid,' %7d',D.n    (iobs  ));
      fprinteol(fid,OPT.OS)

   end

   iostat = fclose(fid);

elseif strcmpi(OPT.format,'ann')

% TODO

end

%% EOF
