function xout = smooth1_nan(xin,varargin)
%SMOOTH1_NAN   As smooth1 but with different nan behaviour
%
% Exactly as smooth1, but nan values are handled differently:
%  Nan valueas are ignored, so that a moving average is taken as if the
%  nanmean was computed for each window. This is different from filtering
%  the nan values out in advance, as that would affect the window width.
%
% See also: SMOOTH1

%29-9-2006

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

% $Id: smooth1_nan.m 7239 2012-09-12 13:37:45Z tda.x $
% $Date: 2012-09-12 21:37:45 +0800 (Wed, 12 Sep 2012) $
% $Author: tda.x $
% $Revision: 7239 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/el_mat/smooth1_nan.m $
% $Keywords$

   if nargin==1
      if ischar(xin)
         if strcmpi(xin,'test')
         smooth1test
         xout = [];
         return
         else
           error('syntax wrong')
         end
      else
         run_avg_reach = 2; % so span = 5
      end
   elseif nargin==2
      run_avg_reach = varargin{1};
      if ~mod(run_avg_reach,1)==0
         run_avg_reach = round(run_avg_reach);
         disp(['Warning: window smooth1 rounded to ',num2str(run_avg_reach)])
      end
   else
      error('only 2 inputs')
   end

   %% the 1-based index of each element of the 
   %% input array
   
   index = 1:length(xin);
   
   %% initialise output and counter for number of points used
   %% on moving average (important near boundaries)
   
   xout      = repmat(0,size(xin));
   n_points  = repmat(0,size(xin));
   
   for span =-run_avg_reach:run_avg_reach
   
      %% shift the indices and make sure that afterwards there are
      %% no references to indices outside the range of the input vector.
      subset                        = t2d(index + span);
      xin_subset                    = xin(subset);
      nans                          = isnan(xin_subset);
      xin_subset(nans)              = 0;
      xout    (subset - span)       = xout    (subset - span) + xin_subset;
      n_points(subset - span)       = n_points(subset - span) + ~nans;

   end
   
   
   xout = xout./n_points;
   xout(isnan(xin)) = nan;
   %% t2d = trunctodomain
   %% -------------------
   function indexout = t2d(indexin)

      indexout = indexin(find( (indexin > 0                ) ...
                              &(indexin < length(indexin)+1) ));
                              
                              
%% TEST
%% -------------------
function smooth1test

tmp=rand(100,1);

TMP = figure;
plot(tmp)
hold on

stencils = 3:100;

colors =clrmap(jet,length(stencils));

disp(['NO     stencil:',num2str(0,'%0.3d'),', mean:', num2str(mean(tmp))])

for i=1:length(stencils)
   sm = smooth1(tmp,stencils(i));
   plot(sm,'color',colors(i,:))
   disp(['smooth stencil:',num2str(stencils(i),'%0.3d'),', mean:', num2str(mean(sm))])
end

caxis([stencils(1) stencils(end)])
colorbarwithtitle('stencil');

pause
try
close(TMP)
end

