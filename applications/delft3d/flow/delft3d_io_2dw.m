function varargout=delft3d_io_2dw(cmd,varargin),
%DELFT3D_IO_2DW   read/write 2D weirs <<beta version!>>
%
%  WEIRS = delft3d_io_2dw('read' ,filename);
%
%        delft3d_io_2dw('write',filename,WEIRS);
%
% where WEIRS is a struct with fields 'm','n'
%
%  WEIRS = delft3d_io_2dw('read' ,filename,G);
%
% also returns the x and y coordinates, where G = delft3d_io_grd('read',...)
%
% To plot weirs use the example below:
%
%   plot(WEIRS.X,WEIRS.Y)
%
% See also: delft3d_io_ann, delft3d_io_bca, delft3d_io_bch, delft3d_io_bnd,
%           delft3d_io_crs, delft3d_io_dep, delft3d_io_dry, delft3d_io_eva,
%           delft3d_io_fou, delft3d_io_grd, delft3d_io_ini, delft3d_io_mdf,
%           delft3d_io_obs, delft3d_io_restart,             delft3d_io_src,
%           delft3d_io_tem, delft3d_io_thd, delft3d_io_wnd,

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 ARCADIS
%       grasmeijerb
%
%       bart.grasmeijer@arcadis.nl
%
%       Voorsterweg 28, Marknesse, The Netherlands
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 23 Mar 2012
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: delft3d_io_2dw.m 11006 2014-07-29 18:00:03Z ottevan $
% $Date: 2014-07-30 02:00:03 +0800 (Wed, 30 Jul 2014) $
% $Author: ottevan $
% $Revision: 11006 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/flow/delft3d_io_2dw.m $
% $Keywords: $


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

function S=Local_read(varargin)

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

        S.DATA(i).direction = fscanf(fid,'%s',1);

        S.DATA(i).mn        = fscanf(fid,'%i'  ,4);

        S.DATA(i).cal       = fscanf(fid,'%f'  ,1);

        S.DATA(i).height    = fscanf(fid,'%f'  ,1);

        S.DATA(i).real      = fscanf(fid,'%f'  ,1);

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

%     if nargin >1
%         G   = varargin{2};
%         S.x = nan.*S.m;
%         S.y = nan.*S.m;
%         for i=1:S.NTables
%             m = S.m(1,i);
%             n = S.n(1,i);
%             if     strcmpi(S.DATA(i).direction,'u')
%                 if n-1==0
%                     disp(i);
%                 end
%                 S.x(:,i) = [G.cor.x(n,m  ) G.cor.x(n-1  ,m  )];
%                 S.y(:,i) = [G.cor.y(n,m  ) G.cor.y(n-1  ,m  )];
%                 S.height(:,i) = [S.DATA(i).height S.DATA(i).height];
%             elseif strcmpi(S.DATA(i).direction,'v')
% 
%                 S.x(:,i) = [G.cor.x(n  ,m-1) G.cor.x(n  ,m  )];
%                 S.y(:,i) = [G.cor.y(n  ,m-1) G.cor.y(n  ,m  )];
%                 S.height(:,i) = [S.DATA(i).height S.DATA(i).height];
%             end
% 
%         end
%     end
    
    
    %% optionally get world coordinates
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
                S.height{i} = [S.DATA(i).height S.DATA(i).height NaN];
            elseif strcmpi(S.DATA(i).direction,'v')
                if ~(n0==n1);error('n0 is not n1');end
                S.x{i}   = [G.cor.x(n0     ,m0-1:m1)  NaN];
                S.y{i}   = [G.cor.y(n0     ,m0-1:m1)  NaN];
                S.height{i} = [S.DATA(i).height S.DATA(i).height NaN];
            end
        end
        S.X = cell2mat(S.x);
        S.Y = cell2mat(S.y);
        S.HEIGHT = cell2mat(S.height);
    end
    
end



% ------------------------------------
% ------------------------------------
% ------------------------------------

function iostat=Local_write(filename,STRUCT),

iostat       = 1;
fid          = fopen(filename,'w');
OS           = 'windows';

for i=1:length(STRUCT.DATA)

    % fprintfstringpad(fid,20,STRUCT.DATA(i).name,' ');

    fprintf(fid,'%1c',' ');
    % fprintf automatically adds one space between all printed variables
    % within one call
    fprintf(fid,' %1c %5i %5i %5i %5i %3.2f %3.2f %7.3f',...
        STRUCT.DATA(i).direction,...
        STRUCT.DATA(i).mn(1)    ,...
        STRUCT.DATA(i).mn(2)    ,...
        STRUCT.DATA(i).mn(3)    ,...
        STRUCT.DATA(i).mn(4)    ,...
        STRUCT.DATA(i).cal      ,...
        STRUCT.DATA(i).height   ,...
        -999.999                );

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

