function [cout h msg] = tricontour3(tri, x, y, z, N, varargin)
%TRICONTOUR3  Triangulated version of contour3
%
%   Code is a duplicate from Matlab built in function contour3, modified to
%   work with triangulated grids. Not all functionality of contour3 is
%   supported (yet), still needs a lot of work.
%
%   Syntax:
%   [cout h msg] = tricontour3(tri, x, y, z, N, varargin)
%
%   Input:
%   tri      =
%   x        =
%   y        =
%   z        =
%   N        =
%   varargin =
%
%   Output:
%   cout     =
%   h        =
%   msg      =
%
%   Example
%   tricontour3
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 <COMPANY>
%       Thijs
%
%       <EMAIL>	
%
%       <ADDRESS>
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 21 Feb 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: tricontour3.m 2321 2010-03-16 16:46:32Z thijs@damsma.net $
% $Date: 2010-03-17 00:46:32 +0800 (Wed, 17 Mar 2010) $
% $Author: thijs@damsma.net $
% $Revision: 2321 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/plot_fun/tricontour3.m $
% $Keywords: $

%%
x = x(:);
y = y(:);
z = z(:);

% Parse possible Axes input
error(nargchk(1,6,nargin,'struct'));
[cax,args,nargs] = axescheck(varargin{:});

% Create the plot
cax = newplot(cax);

% % Check for empty arguments.
% for i = 1:nargs
%   if isempty(args{i})
%     error(id('EmptyInput'),'Input matrix is empty');
%   end
% end

% Trim off the last arg if it's a string (line_spec).
% nin = nargs;
% if ischar(args{end})
%   [lin,col,mark,msg] = colstyle(args{end}); %#ok
%   if ~isempty(msg), error(msg); end %#ok
%   nin = nin - 1;
% else
  lin = '';
  col = '';
% end
% 
% if nin <= 2,
%     [mc,nc] = size(args{1});
%     lims = [1 nc 1 mc];
% else
    lims = [min(x),max(x), ...
            min(y),max(y)];
% end

if isempty(col) % no color spec was given
  colortab = get(cax,'colororder');
  mc = size(colortab,1);
end

% Check for level or number of levels N.  If it's a scalar and a
% non-zero integer, we assume that it must be N.  Otherwise we
% duplicate it so it's treated as a contour level.
% if nin == 3 || nin == 5,
%   if numel(args{2}) == 1 % might be N or a contour level
%      if ~(args{2} == fix(args{2}) && args{2})
%         args{2} = [args{2},args{2}];
%      end
%   end
% end

% Use contours to get the contour levels.
[c] = tricontourc(tri,x,y,z,N); 
% if ~isempty(msg)
%   if nargout==3, 
%     cout = []; h = []; 
%     return
%   else
%     error(msg); %#ok
%   end
% end
%   
% if isempty(c), h = []; if nargout>0, cout = c; end, return, end

if ~ishold(cax)
  view(cax,3); grid(cax,'on')
  set(cax,'xlim',lims(1:2),'ylim',lims(3:4))
end

limit = size(c,2);
i = 1;
h = [];
color_h = [];
while(i < limit)
  z_level = c(1,i);
  npoints = c(2,i);
  nexti = i+npoints+1;

  xdata = c(1,i+1:i+npoints);
  ydata = c(2,i+1:i+npoints);
  zdata = z_level + 0*xdata;  % Make zdata the same size as xdata

  % Create the patches or lines
  if isempty(col) && isempty(lin),
    cu = patch('XData',[xdata NaN],'YData',[ydata NaN], ...
               'ZData',[zdata NaN],'CData',[zdata NaN], ... 
               'facecolor','none','edgecolor','flat',...
               'userdata',z_level,'parent',cax);
  else
    cu = line('XData',xdata,'YData',ydata,'ZData',zdata, ...
              'userdata',z_level,'parent',cax);
  end
  h = [h; cu(:)];
  color_h = [color_h ; z_level];
  i = nexti;
end

% % Register handles with m-code generator
% if ~isempty(h)
%    mcoderegister('Handles',h,'Target',h(1),'Name','contour3');
% end

if isempty(col) && ~isempty(lin)
  % set linecolors - all LEVEL lines should be same color
  % first find number of unique contour levels
  [zlev, ind] = sort(color_h);
  h = h(ind);     % handles are now sorted by level
  ncon = length(find(diff(zlev))) + 1;    % number of unique levels
  if ncon > mc    % more contour levels than colors, so cycle colors
                  % build list of colors with cycling
    ncomp = round(ncon/mc); % number of complete cycles
    remains = ncon - ncomp*mc;
    one_cycle = (1:mc)';
    index = one_cycle(:,ones(1,ncomp));
    index = [index(:); (1:remains)'];
    colortab = colortab(index,:);
  end
  j = 1;
  zl = min(zlev);
  for i = 1:length(h)
    if zl < zlev(i)
      j = j + 1;
      zl = zlev(i);
    end
    set(h(i),'linestyle',lin,'color',colortab(j,:));
  end
else
  if ~isempty(lin)
    set(h,'linestyle',lin);
  end
  if ~isempty(col)
    set(h,'color',col);
  end
end

% If command was of the form 'c = contour(...)', return the results
% of the contours command.
if nargout > 0
  cout = c;
end

function str=id(str)
str = ['MATLAB:contour3:' str];
