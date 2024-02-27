function varargout=delft3d_io_src(cmd,varargin),
%DELFT3D_IO_SRC   read/write river discharge locations, calculate world coordinates
%
%  D = delft3d_io_src('read' ,filename);
%
% where D is a struct with fields 'm','n'. Optionally
%
%  D = delft3d_io_src('read' ,filename,G);
%  D = delft3d_io_src('read' ,filename,'gridfilename.grd');
%
% also returns the x and y coordinates from the *.grd file, passing
% the grid file name or after reading it first with
%
%   G = delft3d_io_grd('read',...
%
% To write river locations
%
%    delft3d_io_src('write',filename,S);
%    delft3d_io_src('write',filename,S.DATA);
%
% here S.DATA has required fields 'name', 'interpolation', 'm', 'n', 'k'
%
% See also: delft3d, delft3d_io_grd

%   --------------------------------------------------------------------
%   Copyright (C) 2006 Delft University of Technology
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
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% $Id: delft3d_io_src.m 12787 2016-06-28 09:34:59Z verbr_wt $
% $Date: 2016-06-28 17:34:59 +0800 (Tue, 28 Jun 2016) $
% $Author: verbr_wt $
% $Revision: 12787 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/flow/delft3d_io_src.m $

if nargin ==1
    error(['AT least 2 input arguments required: d3d_io_...(''read''/''write'',filename)'])
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
% ------------------------------------
% ------------------------------------

function S=Local_read(varargin),

S.filename = varargin{1};

%   mmax = Inf;
%   nmax = Inf;
%if nargin==3
%   mmax = varargin{2};
%   nmax = varargin{3};
%elseif nargin==4
%   mmax = varargin{3};
%   nmax = varargin{4};
%end

fid          = fopen(S.filename,'r');
if fid==-1
    S.iostat   = fid;
else
    S.iostat   = -1;
    i            = 0;
    
    while ~feof(fid)
        
        i = i + 1;
        linedata = fgetl(fid);
        [S.DATA(i).name, count, errmsg, nextindex] = sscanf(linedata,'%20c',1);
        linedata = linedata(nextindex:end);
        [S.DATA(i).interpolation, count, errmsg, nextindex] = sscanf(linedata,'%1s' ,1);
        linedata = linedata(nextindex:end);
        [S.DATA(i).m, count, errmsg, nextindex] = sscanf(linedata,'%i'  ,1);
        linedata = linedata(nextindex:end);
        [S.DATA(i).n, count, errmsg, nextindex] = sscanf(linedata,'%i'  ,1);
        linedata = linedata(nextindex:end);
        [S.DATA(i).k, count, errmsg, nextindex] = sscanf(linedata,'%i'  ,1);
        linedata = linedata(nextindex:end);
        [S.DATA(i).type, count, errmsg, nextindex] = sscanf(linedata,'%s'  ,1); % new
        linedata = linedata(nextindex:end);
        
        % if S.DATA(i).m==mmax+1
        %    S.DATA(i).m= mmax;
        % end
        % if S.DATA(i).n==nmax+1
        %    S.DATA(i).n= nmax;
        % end
        
        restofline = linedata; % read rest of line
        
        if ~isempty(deblank(restofline))
            [S.DATA(i).m2, count, errmsg, nextindex] = sscanf(linedata,'%i'  ,1);
            linedata = linedata(nextindex:end);
            [S.DATA(i).n2, count, errmsg, nextindex] = sscanf(linedata,'%i'  ,1);
            linedata = linedata(nextindex:end);
            [S.DATA(i).k2, count, errmsg, nextindex] = sscanf(linedata,'%i'  ,1);
        end
        
    end
    
    S.iostat   = 1;
    S.NTables  = i;
    
    S.m = [];
    S.n = [];
    for isrc=1:S.NTables
        S.m = [S.m S.DATA(isrc).m];
        S.n = [S.n S.DATA(isrc).n];
    end
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
end

function iostat=Local_write(filename,varargin),

iostat       = 1;
fid          = fopen(filename,'w');
OS           = 'windows';

if ~isfield(varargin{1},'DATA')
    S.DATA = varargin{1};
else
    S = varargin{1};
end

for i=1:length(S.DATA)
    
    fprintfstringpad(fid,20,S.DATA(i).name,' ');
    
    fprintf(fid,'%1c',' ');
    % fprintf automatically adds one space between all printed variables
    % within one call
    fprintf(fid,'%1c %i %i %i %s',...
        S.DATA(i).interpolation,...
        S.DATA(i).m            ,...
        S.DATA(i).n            ,...
        S.DATA(i).k            ,....
        S.DATA(i).type         ); % new
    if isfield(S.DATA(i),'m2')
        fprintf(fid,' %i %i %i',...
            S.DATA(i).m2            ,...
            S.DATA(i).n2            ,...
            S.DATA(i).k2            );
    end
    
    if     strcmp(lower(OS(1)),'u')
        fprintf(fid,'\n');
    elseif strcmp(lower(OS(1)),'w')
        fprintf(fid,'\r\n');
    end
    
end;
fclose(fid);
iostat=1;

% ------------------------------------
% ------------------------------------
% ------------------------------------

