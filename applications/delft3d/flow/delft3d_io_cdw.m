function varargout=delft3d_io_cdw(cmd,varargin)
%delft3d_io_cdw   read/write current deflection walls (delft3d special)
%
%  CDW = delft3d_io_cdw('read' ,filename);
%
% where CDW is a struct with fields 'm','n'
%
%  CDW = delft3d_io_cdw('read' ,filename,G);
%
% also returns the x and y coordinates, where G = delft3d_io_grd('read',...)
%
% To plot thin dams use the example below:
%
%   plot(CDW.x,CDW.y)
%
% See also: DELFT3D_IO_THD

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

% $Id: delft3d_io_cdw.m 8823 2013-06-17 16:39:08Z boer_g $
% $Date: 2013-06-18 00:39:08 +0800 (Tue, 18 Jun 2013) $
% $Author: boer_g $
% $Revision: 8823 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/flow/delft3d_io_cdw.m $

if nargin ==0
    error(['AT least 1 input arguments required: d3d_io_...(''read''/''write'',filename)'])
elseif nargin ==1
    varargin = {cmd,varargin{:}};
    cmd = 'read';
end

switch lower(cmd),
    case 'read',
        STRUCT=Local_read(varargin{:});
        if nargout==1
            varargout = {STRUCT};
        elseif nargout >1
            error('too much output paramters: 0 or 1')
        end
        if STRUCT.iostat<0,
            error(['Error opening file: ',varargin{1}])
        end;
end;

% ------------------------------------

function S=Local_read(varargin),

S.filename = varargin{1};

%     mmax = Inf;
%     nmax = Inf;
%  if nargin==3
%     mmax = varargin{2};
%     nmax = varargin{3};
%  elseif nargin==4
%     mmax = varargin{3};
%     nmax = varargin{4};
%  end

fid          = fopen(S.filename,'r');
if fid==-1
    S.iostat   = fid;
else
    S.iostat   = -1;
    i            = 0;
    
    while ~feof(fid)
        
        i = i + 1;
        
%V 26     13   29    13  0.113        -7.60000  999.99
        
        S.DATA(i).direction = fscanf(fid,'%s',1);
        S.DATA(i).mn        = fscanf(fid,'%i',4);
        S.DATA(i).loss      = fscanf(fid,'%f',1);
        S.DATA(i).ztop      = fscanf(fid,'%f',1);
        S.DATA(i).zbot      = fscanf(fid,'%f',1);
        
        % turn the endpoint-description along gridlines into vectors
        % and make sure smallest index is first
        
        [S.DATA(i).m,...
         S.DATA(i).n]=meshgrid(min(S.DATA(i).mn([1,3])):max(S.DATA(i).mn([1,3])),...
                               min(S.DATA(i).mn([2,4])):max(S.DATA(i).mn([2,4])));
        
        fgetl(fid); % read rest of line
        
    end
    
    S.iostat   = 1;
    S.NTables  = i;
    
    for i=1:S.NTables
        S.m(:,i) = [S.DATA(i).mn(1) S.DATA(i).mn(3)];
        S.n(:,i) = [S.DATA(i).mn(2) S.DATA(i).mn(4)];
    end
    
    if nargin >1
        G   = varargin{2};
        
        for i=1:S.NTables
            m0 = S.m(1,i);m1 = S.m(2,i);
            n0 = S.n(1,i);n1 = S.n(2,i);
            if     strcmpi(S.DATA(i).direction,'u')
                if ~(m0==m1);error('m0 is not m1');end
                S.x{i}   = [G.cor.x(n0:n1-1  ,m1  ) NaN];
                S.y{i}   = [G.cor.y(n0:n1-1  ,m1  ) NaN];
            elseif strcmpi(S.DATA(i).direction,'v')
                if ~(n0==n1);error('n0 is not n1');end
                S.x{i}   = [G.cor.x(n0  ,m0-1:m1  ) NaN];
                S.y{i}   = [G.cor.y(n0  ,m0-1:m1  ) NaN];
            end
        end
        S.X = cell2mat(S.x);
        S.Y = cell2mat(S.y);
    end
end