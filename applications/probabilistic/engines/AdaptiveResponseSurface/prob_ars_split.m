function ARS = prob_ars_split(ARS, u, b, z, varargin)
%PROB_ARS_SPLIT  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = prob_ars_split(varargin)
%
%   Input: For <keyword,value> pairs call prob_ars_split() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   prob_ars_split
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       Rotterdamseweg 185
%       2629HD Delft
%       Netherlands
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
% Created: 15 Oct 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id: prob_ars_split.m 7486 2012-10-15 13:09:43Z hoonhout $
% $Date: 2012-10-15 21:09:43 +0800 (Mon, 15 Oct 2012) $
% $Author: hoonhout $
% $Revision: 7486 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/engines/AdaptiveResponseSurface/prob_ars_split.m $
% $Keywords: $

%% read options

OPT = struct(...
    'epsZ',             1e-2,                   ...                         % Precision for Z=0
    'dist_betamin',     1                       ...                         % Distance criterium for detecting separate design points           
);

OPT = setproperty(OPT, varargin{:});

ARS0 = ARS;

%% Detect design points

% select points near Z=0 and in beta sphere
idx_z0  = find(abs(z)<OPT.epsZ);                                                  % Determine which points have Z=0
idx_bs  = idx_z0(prob_ars_inbetasphere(ARS, b(idx_z0)));              % Find other points with close to the same beta

% determine distances
distances   = triu(pointdistance_pairs(u(idx_bs,:),u(idx_bs,:)));                             % Calculate distances between design points

% define clusters
c   = 0;
ref = nan(size(b(idx_bs)));
clusters = cell(size(b(idx_bs)));
for i = 1:size(distances,1)
    if isnan(ref(i))
        c           = c+1;
        ref(i)      = c;
        clusters{c} = [i];
    end
    for j = i+1:size(distances,2)
        if distances(i,j) < sqrt(size(u,2))*OPT.dist_betamin && distances(i,j) > 0
            if isnan(ref(j))
                clusters{ref(i)} = [clusters{ref(i)} j];
            elseif ref(i) ~= ref(j)
                clusters{ref(i)} = [clusters{ref(i)} clusters{ref(j)}];
                clusters{ref(j)} = [];
            end
            ref(j) = ref(i);
        end
    end
end
clusters = clusters(~cellfun(@isempty, clusters));

% determine design point per cluster
idx_DPs  = cellfun(@(x) idx_bs(x(find(abs(b(idx_bs(x)))==min(abs(b(idx_bs(x)))),1))), clusters);

% determine points per design point
distances     = pointdistance_pairs(u(idx_DPs,:),u);                         % calculate distances from other points to design points
[d idx_clust] = min(distances,[],1);                                               % Locate closest Design Point for each other point
idx_clust     = idx_clust';

% determine origin
switch length(idx_DPs)
    case 0
        idx_org = false(size(idx_clust));
    case 1
        idx_org = false(size(b));
    otherwise
        idx_org = b==0;
end

% create new ARS structure
ARS = repmat(prob_ars_struct_mult, 1, max(1,length(idx_DPs)));
for i = 1:length(ARS)
    ARS(i).hasfit   = false;
    ARS(i).active   = ARS0(1).active;
    ARS(i).betamin  = ARS0(1).betamin;
    ARS(i).dbeta    = ARS0(1).dbeta;
    
    ARS(i).u        = u(idx_clust==i&~idx_org,:);
    ARS(i).b        = b(idx_clust==i&~idx_org);
    ARS(i).z        = z(idx_clust==i&~idx_org);
    
    if length(idx_DPs) >= i
        ARS(i).u_BS     = u(idx_bs(clusters{i}),:);
        ARS(i).b_BS     = b(idx_bs(clusters{i}));
        ARS(i).z_BS     = z(idx_bs(clusters{i}));
        ARS(i).idx_BS   = idx_bs(clusters{i});
    
        ARS(i).u_DP     = u(idx_DPs(i),:);
        ARS(i).b_DP     = b(idx_DPs(i));
        ARS(i).idx_DP   = idx_DPs(i);
    end
end