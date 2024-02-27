function varargout = swan_io_node(cmd,varargin)
%SWAN_IO_ELE  read/write SWAN UNSTRUCTURED ele file
%
% reads Triangle node file as described in
% http://www.cs.cmu.edu/afs/cs/project/quake/public/www/triangle.ele.html
%
%   [tri,<ind,<p>>] = swan_io_ele('read',filename)
%   swan_io_ele('write',filename,tri,<ind,<p>>)
%
% where tri [nx3] is the 2D connecvitiy matrix vectors, ind an optional element index,
% and p is a 2D property matrix with size(p,2) properties; size(p,1) == size(tri,1)
%
% Example:
%
%    basename = 'test\bla';
%    nodefile = [basename '.node'];
%    elefile  = [basename '.ele'];
%
%    [x,y,b,p] = swan_io_node('read',nodefile); 
%    [tri,ind] = swan_io_ele ('read',elefile);
%
%    % plot mesh, switch off legend per lien segment
%    triplot(tri,x,y,'color',[.5 .5 .5],'handlevisibility','off');
%    hold on
%
%    % plot open boundary
%    TR = triangulation(tri, x,y);
%    fe = freeBoundary(TR)';
%    plot(x(fe),y(fe),'k','linewidth',2,'handlevisibility','off');
%
%    % plot open boundary values for assigning boundary conditions
%    bs = setxor(unique(b),0); % exclude 0
%    colors = [1 0 0; 0 1 0; 0 0 1];
%    for i=1:length(bs)
%        mask = b==bs(i);sum(mask);
%        plot(x(mask),y(mask),'.','color',colors(:,i),'Displayname',['b=',num2str(bs(i))])
%        hold on
%    end
%
%    legend show
%    axislat;tickmap('ll')
%    grid on
%    print2a4(basename,'v','w','-r200','o')
%
% See also: SWAN_IO_NODE, trisurf, triplot

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

elefile = varargin{1};

if     strcmp(cmd,'read') | ...
       strcmp(cmd,'load')
       
% http://www.cs.cmu.edu/afs/cs/project/quake/public/www/triangle.ele.html
       
    fid = fopen(elefile);                         % load TRIANGLE element based connectivity file
    [nelem] = fscanf(fid,'%i',[1 3]);             % get number of triangles
    ncol = 4+nelem(3);                            % specify number of columns in elefile
    tri = fscanf(fid,'%i',[ncol nelem(1)])';      % get connectivity table
    
    ind = tri(:,1);
    p   = tri(:,5:end);
    tri = tri(:,2:4); % last, inline replacement
    
    varargout = {tri,ind,p};

elseif strcmp(cmd,'write')
    
    tri = varargin{2};
    ind = 1:size(tri,1);
    att = repmat(nan,[size(tri,1) 0]);
    if nargin > 3
       ind = varargin{3};
       if nargin > 4
       att = varargin{4};
       end
    end
    nind = size(ind,2);
    natt = size(att,2);

    fid = fopen(elefile,'w');
    fprintf(fid,'%i %i %i\n',size(tri,1),size(tri,2),natt);
    for i=1:size(tri,1)
        fprintf(fid,'%d ',ind(i),tri(i,:));
        if ~isempty(att)
        fprintf(fid,'%18.10f ',att(i,:));
        end
        fprintf(fid,'\n');
    end    
    fclose(fid);

end   

%% EOF