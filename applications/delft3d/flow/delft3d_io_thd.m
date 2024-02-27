function varargout=delft3d_io_thd(cmd,varargin)
%DELFT3D_IO_THD   read/write thin dams, calculate world coordinates
%
%  D = delft3d_io_thd('read' ,filename);
%
% where D is a struct with fields 'm','n'. Optionally
%
%  D = delft3d_io_thd('read' ,filename,G);
%  D = delft3d_io_thd('read' ,filename,'gridfilename.grd');
%
% also returns the x and y coordinates from the *.grd file, passing
% the grid file name or after reading it first with
%
%   G = delft3d_io_grd('read',...)
%
% To write the thd to file:
% 
%  delft3d_io_thd('write',filename,D);
%  delft3d_io_thd('write',filename,D,<'format',format>);
%
% where format can be 'ldb', 'kml' or (default) 'thd'. Note that
% for *.ldb you need to read the *.thd 1st using the grid:
%
% D = delft3d_io_thd('read' ,'dam.thd','gridfilename.grd')
%     delft3d_io_thd('write','dam.ldb',D,'format','ldb');
%
% To plot one/all thin dams at once use the example below:
%
%   plot(DAT.x{1},DAT.y{1});plot(DAT.X,DAT.Y)
%
% To plot the thin dams in Google Earth, convert first to WGS84
% coordinates if the grid was not spherical already.
%
% [DAT.lon{1},DAT.lat{1}] = convertCoordinates(DAT.x{1},DAT.y{1},...)
%
% See also: delft3d, d3d_attrib, delft3d_io_grd, pol2thd

% Nov 2007: put smallest index first in m and n fields.

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

% $Id: delft3d_io_thd.m 10800 2014-06-03 14:43:06Z bartgrasmeijer.x $
% $Date: 2014-06-03 22:43:06 +0800 (Tue, 03 Jun 2014) $
% $Author: bartgrasmeijer.x $
% $Revision: 10800 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/flow/delft3d_io_thd.m $

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

%   25      13    25      13 V
        
        S.DATA(i).mn        = fscanf(fid,'%i',4);
        S.DATA(i).direction = fscanf(fid,'%s',1);
        
        %  if S.DATA(i).mn(1)==mmax+1
        %     S.DATA(i).mn(1)= mmax;
        %  end
        %  if S.DATA(i).mn(2)==nmax+1
        %     S.DATA(i).mn(2)= nmax;
        %  end
        %  if S.DATA(i).mn(3)==mmax+1
        %     S.DATA(i).mn(3)= mmax;
        %  end
        %  if S.DATA(i).mn(4)==nmax+1
        %     S.DATA(i).mn(4)= nmax;
        %  end
        
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
    %% optionally get world coordinates (different from delft3d_io_2dw)
    if nargin >1
        if ischar(varargin{2})
           G   = delft3d_io_grd('read',varargin{2});
        else
           G   = varargin{2};
        end
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

% ------------------------------------

function iostat=Local_write(filename,S,varargin),

iostat       = 1;
OPT.OS       = 'windows';
OPT.format   = 'thd';

OPT = setproperty(OPT,varargin);

if strcmpi(OPT.format,'thd')

   fid          = fopen(filename,'w');
   for i=1:length(S.DATA)
       
       % fprintfstringpad(fid,20,S.DATA(i).name,' ');
       
       fprintf(fid,'%1c',' ');
       % fprintf automatically adds one space between all printed variables
       % within one call
       fprintf(fid,'%5i %5i %5i %5i %1c',...
           S.DATA(i).mn(1)   ,...
           S.DATA(i).mn(2)   ,...
           S.DATA(i).mn(3)   ,...
           S.DATA(i).mn(4)   ,...
           S.DATA(i).direction    );
       
       if     strcmp(lower(OPT.OS(1)),'u')
           fprintf(fid,'\n');
       elseif strcmp(lower(OPT.OS(1)),'w')
           fprintf(fid,'\r\n');
       end
       
   end;
   fclose(fid);
   iostat=1;
   
elseif strcmpi(OPT.format,'ldb')
    
    INFO = [];
    for i=1:length(S.x)
       INFO.Field(i).Name = ['THD_',num2str(i),'_',S.DATA(i).direction,...
           '_m=',num2str(S.DATA(i).m(1)),...
           '-'  ,num2str(S.DATA(i).m(end)),...
           '_n=',num2str(S.DATA(i).n(1)),...
           '-'  ,num2str(S.DATA(i).n(end))];
       INFO.Field(i).ColLabels{1} = 'x';
       INFO.Field(i).ColLabels{1} = 'y';
       INFO.Field(i).Data = [S.x{i}(1:end-1)',S.y{i}(1:end-1)'];
    end

    NEWINFO = tekal('write',filename',INFO    );
    
end

% ------------------------------------
