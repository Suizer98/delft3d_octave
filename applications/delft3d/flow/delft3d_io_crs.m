function varargout=delft3d_io_crs(cmd,varargin),
%DELFT3D_IO_CRS   read/write cross sections (*.crs) <<beta version!>>
%
%  DAT = delft3d_io_crs('read' ,filename);
%
%        delft3d_io_crs('write',filename,DAT);
%
% where DAT is a struct with fields 'm','n'
%
%  DAT = delft3d_io_crs('read' ,filename,G);
%
% also returns the x and y coordinates, where G = delft3d_io_grd('read',...)
%
% To plot one;all cross sections use the example below:
%
%   plot(DAT.x{1},DAT.y{1});plot(DAT.X,DAT.Y)
%delft3d_io_dep, pol2dry

%   --------------------------------------------------------------------
%   Copyright (C) 2005 Delft University of Technology
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

% $Id: delft3d_io_crs.m 17308 2021-05-26 08:18:16Z kaaij $
% $Date: 2021-05-26 16:18:16 +0800 (Wed, 26 May 2021) $
% $Author: kaaij $
% $Revision: 17308 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/flow/delft3d_io_crs.m $

if nargin ==0
   error(['AT least 1 input arguments required: d3d_io_...(''read''/''write'',filename)'])
elseif nargin ==1
    varargin = {cmd,varargin{:}};
    cmd = 'read';
end

switch lower(cmd),
    case 'read',
        S=Local_read(varargin{:});
        if nargout==1
            varargout = {S};
        elseif nargout >1
            error('too much output paramters: 0 or 1')
        end
        if S.iostat<0,
            error(['Error opening file: ',varargin{1}])
        end;
    case 'write',
        iostat=Local_write(varargin{:});
        if nargout==1
            varargout = {iostat};
        elseif nargout >1
            error('too much output paramters: 0 or 1')
        end
        if iostat<0,
            error(['Error opening file: ',varargin{1}])
        end;
end;

% ------------------------------------

function S=Local_read(varargin),

S.filename = varargin{1};

fid          = fopen(S.filename,'r');
if fid==-1
    S.iostat   = fid;
else
    S.iostat   = -1;
    i            = 0;

    while ~feof(fid)
        i = i + 1;
    %  [S.namst,...
    %   S.mn1  ,...
    %   S.mn2  ,...
    %   S.mn3  ,...
    %   S.mn4  ]=textread(S.filename,'%20c%d%d%d%d');
    %   TK: fscanf does not work when cross section names contain integers
    %   S.DATA(i).name         = fscanf(fid,'%20c',1);
    %   S.DATA(i).mn           = fscanf(fid,'%i'  ,4);
    %   ==> read the line and scan the line; use str2num because 001 is not
    %                                        read properly using sscanf
       line      = fgetl(fid);
       S.DATA(i).name         = sscanf(line( 1: 20),'%20c',1);
       numbers                = strtrim(line(21:end));
       index                  = d3d2dflowfm_decomposestr(numbers);
       for i_mn = 1:4
           S.DATA(i).mn(i_mn) = str2num(numbers(index(i_mn):index(i_mn + 1) - 1));
       end
       S.NTables = length(S.DATA);
       m_step = 1 ;
       n_step = 1 ;
       if S.DATA(i).mn(1) > S.DATA(i).mn(3) m_step = -1; end
       if S.DATA(i).mn(2) > S.DATA(i).mn(4) n_step = -1; end
      [S.DATA(i).m,... % turn the endpoint-description along gridlines into vectors
       S.DATA(i).n]=meshgrid(S.DATA(i).mn(1):m_step:S.DATA(i).mn(3),...
                                  S.DATA(i).mn(2):n_step:S.DATA(i).mn(4));
       S.DATA(i).m(1) = S.DATA(i).mn(1);
       S.DATA(i).m(2) = S.DATA(i).mn(3);
       S.DATA(i).n(1) = S.DATA(i).mn(2);
       S.DATA(i).n(2) = S.DATA(i).mn(4);

%      fgetl(fid); % read rest of line
    end

    S.iostat   = 1;
    S.NTables  = i;
    for i=1:S.NTables
        S.m(:,i) = [S.DATA(i).mn(1) S.DATA(i).mn(3)];
        S.n(:,i) = [S.DATA(i).mn(2) S.DATA(i).mn(4)];
    end
    % make same data structure as delft3d_io_thd
    for i=1:S.NTables
        if S.m(1,i)==S.m(2,i);
            S.DATA(i).direction='u';
        elseif S.n(1,i)==S.n(2,i);
            S.DATA(i).direction='v';
        else '?'
        end
    end

    %% get world coordinates
    if nargin >1
        G   = varargin{2};
        for i=1:S.NTables
            m0 = min(S.m(:,i));m1 = max(S.m(:,i));
            n0 = min(S.n(:,i));n1 = max(S.n(:,i));
            if     strcmpi(S.DATA(i).direction,'u')
                if ~(m0==m1);error('m0 is not m1');end
                S.x{i}   = [G.cor.x(n0-1:n1,m1     ); NaN]';
                S.y{i}   = [G.cor.y(n0-1:n1,m1     ); NaN]';
            elseif strcmpi(S.DATA(i).direction,'v')
                if ~(n0==n1);error('n0 is not n1');end
                S.x{i}   = [G.cor.x(n0     ,m0-1:m1)  NaN];
                S.y{i}   = [G.cor.y(n0     ,m0-1:m1)  NaN];
            end
        end
        S.X = cell2mat(S.x);
        S.Y = cell2mat(S.y);
    end

end


if nargout==1
   varargout = {S};
else
   varargout = {S,S.iostat};
end

% ------------------------------------

function iostat=Local_write(filename,S),

iostat       = 1;
fid          = fopen(filename,'w');
OS           = 'windows'; % or 'unix'

% edit - 9June'17 - Julien Groenenboom
%   S.m=S.m';
%   S.n=S.n';

for i=1:size(S.m,1)

   fprintf(fid,'%-20s %.3d %.3d %.3d %.3d',S.DATA(i).name,S.m(i,1),S.n(i,1),S.m(i,2),S.n(i,2));
   if     strcmpi(OS(1),'u')
      fprintf(fid,'\n');
   elseif strcmpi(OS(1),'w')
      fprintf(fid,'\r\n');
   end

end


fclose(fid);
iostat=1;

% ------------------------------------

