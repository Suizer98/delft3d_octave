function varargout = swan_io_node(cmd,varargin)
%SWAN_IO_NODE  read/write SWAN UNSTRUCTURED node file
%
% reads Triangle node file as described in
% http://www.cs.cmu.edu/afs/cs/project/quake/public/www/triangle.node.html
%
%   [x,y,<b,<p>>] = swan_io_node('read',filename)
%   [x,y,<b,<p>>] = swan_io_node('write',filename,x,y,<b,<p>>)
%
% where x,y are 1D vectors, b is the optional 1D boundary marker vector,
% p is a 2D property matrix with size(p,2) properties; size(p,1) == length(x)
%
% See also: SWAN_IO_ELE, trisurf, triplot, triangular

%   --------------------------------------------------------------------
%   (c) Adapted from example plotgrid.m from http://swan.tudelft.nl
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

% $Id: swan_io_bot.m 4776 2011-07-07 15:33:33Z boer_g $
% $Date: 2011-07-07 17:33:33 +0200 (Thu, 07 Jul 2011) $
% $Author: boer_g $
% $Revision: 4776 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/swan/swan_io_bot.m $

nodefile = varargin{1};

if     strcmp(cmd,'read') | ...
       strcmp(cmd,'load')
       
% http://www.cs.cmu.edu/afs/cs/project/quake/public/www/triangle.node.html
       
    fid = fopen(nodefile);                        % load TRIANGLE vertex based connectivity file
    [nnode] = fscanf(fid,'%i',[1 4]);             % get number of nodes
    ncol = 3+nnode(3)+nnode(4);                   % specify number of columns in nodefile
    data = fscanf(fid,'%f',[ncol nnode(1)])';     % get data
    x=data(:,2); y=data(:,3); b=data(:,end);      % get coordinates
    p=data(:,4:end-1);
    fclose(fid);
    
    varargout = {x,y,b,p};

elseif strcmp(cmd,'write')
    
    x = varargin{2};
    y = varargin{3};
    b = repmat(  0,[length(x) 0]);
    p = repmat(nan,[length(x) 0]);
    if nargin > 4
       b = varargin{4};
       if nargin > 5
       p = varargin{5};
       end
    end
    np = size(p,2);
    nb = size(b,2);
    
    nnode(1) = length(x); % <# of vertices>
    nnode(2) = 2;         % <dimension (must be 2)>
    nnode(3) = np;        % <# of attributes>
    nnode(4) = nb;        % <# of boundary markers (0 or 1)>
    
    fid = fopen(nodefile,'w');
    fprintf(fid,'%i %i %i %i\n',nnode);
    for i=1:nnode(1)
        fprintf(fid,'%d %18.10f %18.10f ',i,x(i),y(i));
        if ~isempty(p)
        fprintf(fid,'%18.10f ',p(i,:));
        end
        if ~isempty(b)
        fprintf(fid,'%d'   ,b(i));
        end
        fprintf(fid,'\n');
    end
    fclose(fid);

end   

%% EOF