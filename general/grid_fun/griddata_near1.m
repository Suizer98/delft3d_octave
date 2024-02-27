function varargout = griddata_near1(X,Y,XI,YI,npts,varargin)
%griddata_near1  2-step data gridding and surface fitting
%
%     [PI,RI,<WI>] = GRIDDATA_NEAR1(X,Y,  XI,YI,npts); % NO Z !!!
%      ZI          = GRIDDATA_NEAR2(X,Y,Z,XI,YI,PI,WI);
%
% returns the indices of the datapoints in (X,Y) that are 
% closest to (XI,YI). The distance between (XI,YI) and (X,Y)
% is returned in RI, it can be used to calculate weights WI.
% npts is the number of points from (X,Y) that are to be used 
% for interpolating each (XI,YI) element. For interpolating from lines, 
% npts is usually 2, for interpolating from triangular meshes npts is 3,
% and for interpolating from orthogonal or curvi-linear grids
% npts is 4, but npts can have any integer value. npts is used as 
% the first dimension for PI,RI,WI so that their size is [npts size(XI)].
%
% The combination GRIDDATA_NEAR1 and GRIDDATA_NEAR2 allows to 
% repeatedly interpolate multiple fields from one static topology (X,Y)
% to another static topology (XI,YI). For instance, to interpolate
% numerous time dependendent fields defined on one static topology.
% For interpolating local boundary conditions from an overall GCM 
% (general circulation models) this is usually referred to as nesting.
%
% [PI,RI,WI] = griddata_near1(..) returns weight WI using 
% an inverse quadratic method that add up to 1 per (XI,YI).
% [PI,RI,WI] can be used in GRIDDATA_NEAREST2(...) to do the actual
% interpolation. WI has size [npts size(XI)], so that sum(B.WI,1) is 1.
%
%See also: GRIDDATA_NEAR2, GRIDDATA, GRIDDATA_NEAREST, GRIDDATA_REMAP, INTERP2, BIN2
%          TriScatteredInterp, DELFT3D_IO_ADM, NESTING, arbcross

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012
%       Dr.ir. Gerben J. de Boer, Deltares
%
%       gerben.deboer@deltares.nl
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: griddata_near1.m 8044 2013-02-06 21:48:42Z boer_g $
% $Date: 2013-02-07 05:48:42 +0800 (Thu, 07 Feb 2013) $
% $Author: boer_g $
% $Revision: 8044 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/grid_fun/griddata_near1.m $
% $Keywords: $

OPT.ndisp = 100;
OPT.Rmax  = Inf; % make this optionally same size as X and Y.
OPT.quiet = false;

if nargin==0;varargout = {OPT};return;end

OPT  = setproperty(OPT,varargin);

PI   = zeros([npts (size(XI))]);
RI   = zeros([npts (size(XI))]);
if nargout > 2
WI   = zeros([npts (size(XI))]);
end
R    =   NaN((size(X )));
npix =      length(XI(:));

if nargout==2
   index = zeros(size(XI));
end

%% print commandline waitbar
if ~OPT.quiet
    s = arrayfun(@(n) sprintf('|%d%%',n),0:10:100,'UniformOutput',false);
    s{end} = [s{end} '     '];
    fprintf('%s',char(s)');
    fprintf('\n');
end

pix.distance = 0;
for ipix = 1:npix % index in new (orthogonal) grid
  R = sqrt((XI(ipix) - X).^2 + ...
           (YI(ipix) - Y).^2);
  for ipts = 1:npts
      
    if ipts > 1
        R(PI(1:ipts-1,ipix)) = Inf;
    end

    [pix.distance,pix.index] = min(R(:)); % index in old (random point) grid
    
    if (pix.distance < OPT.Rmax)
        PI(ipts,ipix) = pix.index;
        RI(ipts,ipix) = pix.distance;
    end

    if ~OPT.quiet 
        if mod(ipix-1,floor(npix/100))==0
            if mod(ipix-1,floor(npix/10))==0
                %fprintf('|');
            else
                fprintf('.');
            end
        end
    end
  end % ipts
  if nargout > 2
      WI(:,ipix) = 1./(PI(:,ipix));
      WI(:,ipix) = WI(:,ipix)./sum(WI(:,ipix));
  end
end % ipix


% keep npts as first dimension for easy selection on it: 
% PI(ipts,:) works for any dimensionality of PI

%rank = length(size(PI));
%PI = permute(PI,[2:rank 1]);
%RI = permute(RI,[2:rank 1]);
%WI = permute(WI,[2:rank 1]);

if ~OPT.quiet
    fprintf('\n');
end
%% EOF

if nargout==1
   varargout = {PI};
elseif nargout==2
   varargout = {PI,RI};
elseif nargout==3
   varargout = {PI,RI,WI};
end