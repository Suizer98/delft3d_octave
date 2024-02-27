function [q,bi,varargout] = quat2net(x,y,varargin)
%QUAT2NET quadrangulates a mesh into a network
%
%    [quad,bi  ] = quat2net(x,y)
%    [map4,map2] = quat2net(x,y)
%
% where x and y are plaid matrices as returned by NDGRID
% or MESHGRID, quad (nx4) and bi (nx2) are integer pointer 
% arrays into vectors [x(:),y(:)], behaving like tri (nx3) 
% in TRISURF. For proper understanding think of them as 
% pointer mappers using 2,3 or 4 target coordinates per row:
% bi -> map2, tri -> map3, quad -> map4. quad indexes the  
% perimeter of quadrangles, bi indexes the separate face segment  
% after removal of overlap between adjacenent quadrangles.
%
% quad and bi fail when you swap x and y afterwards, for instance
% upon interchanging NDGRID and MESHGRID arrays. quad and bi are 
% meant to work on (x,y) or (x(:),y(:)).
%
% Use [..] = quat2net(x,y,'sub2ind',0) to make sure q and bi pointer
% into x(~isnan(x)), by default rather than info the full arrays.
%
% Example: NDGRID vs MESHGRID orientation
%
%  del = [3 10];
%  
%  subplot(1,2,1)
%  [x,y]=ndgrid(1:3,1:4);
%  plot(x(del),y(del),'rx','markersize',15,'linewidth',2)
%  hold on
%  x(del)=nan;y(del)=nan;% nans are taken care off, and not included
%  [q,bi]=quat2net(x,y);
%  pcolor(x,y,x.*0);
%  text(x(:),y(:),num2str([1:12]'),'color','b')
%  poly_bi_plot(bi,x   ,y   ,'r--')
%  poly_bi_plot(bi,x(:),y(:),'b:','linewidth',2)
%  title({'ndgrid',''})
%  
%  subplot(1,2,2)
%  [xm,ym]=meshgrid(1:3,1:4);
%  plot(xm(del),ym(del),'rx','markersize',15,'linewidth',2)
%  hold on
%  xm(del)=nan;ym(del)=nan;% nans are taken care off, and not included
%  [qm,bim]=quat2net(xm,ym);
%  pcolor(xm,ym,xm.*0);
%  text(x(:),y(:),num2str([1:12]'),'color','b')
%  poly_bi_plot(bim,xm   ,ym   ,'r--')
%  poly_bi_plot(bim,xm(:),ym(:),'b:','linewidth',2)%
%  title({'meshgrid',''})
%
%See also: quat, dflowfm, poly_bi_unique

%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Gerben de Boer
%
%       <g.j.deboer@deltares.nl>
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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

% $Id: quat2net.m 10789 2014-06-03 09:47:34Z kaaij $
% $Date: 2014-06-03 17:47:34 +0800 (Tue, 03 Jun 2014) $
% $Author: kaaij $
% $Revision: 10789 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/grid_fun/quat2net.m $

h_waitbar   = waitbar(0,'Converting Delft3D-Flow grid file into DflowFM grid');
OPT.sub2ind = 1;
OPT.debug   = 1;
OPT = setproperty(OPT,varargin);

q  = quat(x,y,'sub2ind',OPT.sub2ind);
bi = repmat(0,[size(q,1)*4 2]);
nq = size(q,1);
for iq=1:nq
   if OPT.debug
      if mod(iq,100)==0
          waitbar(100.*iq/nq,h_waitbar);
%         disp([mfilename,' progress ',num2str(100.*iq/nq),' %'])
      end
   end
   bi((iq-1)*4+1:iq*4,:) = [q(iq,:); q(iq,[2 3 4 1])]';
end
bi = poly_bi_unique(bi);

close(h_waitbar);