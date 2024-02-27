function varargout = jarkus_identify_first_dunerow(x, z, varargin)
%JARKUS_IDENTIFY_FIRST_DUNEROW  find landward side of most seaward dune row
%
%   Function to identify the most seaward dune row with a minimum crest
%   height and a minimum volume. The landward side of the dune row is given
%   as output. If no dune row is found, according to the criteria, the most
%   landward coordinate of the profile is given as output.
%   This function assumes the x is postive seaward
%
%   Syntax:
%   varargout = jarkus_identify_first_dunerow(varargin)
%
%   Input:
%   x         = vector with x-coordinates (positive seaward)
%   z         = vector with z-coordinates (positive upward)
%   varargin  = propertyname-propertyvalue pairs:
%               	'min_crest_level'   : minimum crest level to take into
%                                           account
%                   'min_volume'        : minimum volume to be recognised
%                                           as dune
%
%   Output:
%   varargout =
%
%   Example
%   jarkus_identify_first_dunerow
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Delft University of Technology
%       Kees den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
%       The Netherlands
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
% Created: 28 Jul 2010
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id: jarkus_identify_first_dunerow.m 3977 2011-02-04 16:05:10Z heijer $
% $Date: 2011-02-05 00:05:10 +0800 (Sat, 05 Feb 2011) $
% $Author: heijer $
% $Revision: 3977 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/jarkus/jarkus_identify_first_dunerow.m $
% $Keywords: $

%%
OPT = struct(...
    'min_crest_level', 5,...
    'lowerboundary', 0,...
    'min_volume', 60);

OPT = setproperty(OPT, varargin{:});

%%
% remove nans
[x z] = nanremove(x, z);

% loop over z levels in steps of 20cm
z_levels = OPT.lowerboundary:.2:max(z);

% pre-allocate the landward and seaward boundaries for each z-level
landwardboundary = ones(size(z_levels)) * min(x);
seawardboundary = ones(size(z_levels)) * max(x);
% pre-allocate the x and z of each crest and the volume above each z-level 
[x_crest z_crest Vol] = deal(NaN(size(z_levels)));

for ih = 1:length(z_levels)
    % define h as the z-level under consideration
    h = z_levels(ih);
    % find crossings between the profile and horizontal line at level h
    [xcr zcr x1_new_out z1_new_out x2_new_out z2_new_out crossdir] = findCrossings(x, z, x, ones(size(x))*h);
    % remove 'toughing' crossings
    xcr(crossdir==0) = [];
    crossdir(crossdir==0) = [];
    % check whether there is at least one upward crossing, when going
    % landward
    crossing_found = ~isempty(xcr) && any(crossdir > 0);
    if crossing_found
        % cumsum of crossing direction going landward
        cumcrossdir = cumsum(flipud(crossdir));
        seawardboundary_set = false;
        for icr = 1:length(cumcrossdir)
            % look for the first location where the profile exceeds the
            % z_level (dune front)
            seawardboundary_found = cumcrossdir(icr) == 2;
            if seawardboundary_found && ~seawardboundary_set
                seawardboundary(ih) = xcr(length(cumcrossdir)+1-icr);
                seawardboundary_set = true;
            end
            % after having a dune front, look for the first location where
            % the profile comes below the z_level (back side of dune)
            landwardboundary_found = seawardboundary_set && cumcrossdir(icr) <= 1;
            if landwardboundary_found
                landwardboundary(ih) = xcr(length(cumcrossdir)+1-icr);
                break
            end
        end
        
        % isolate part of profile describing the dune
        duneid = x >= landwardboundary(ih) & x <= seawardboundary(ih);
        [xdune zdune] = deal(x(duneid), z(duneid));
        % the crest is the maximum z within the isolated part
        crestid = max(zdune) == zdune;
        % take the most seaward crest if more are found
        crestid = find(crestid, 1, 'last');
        % save crest coordinates
        z_crest(ih) = zdune(crestid);
        x_crest(ih) = xdune(crestid);
        % derive volume of dune row
        Vol(ih) = getVolume(x, z,...
            'LandwardBoundary', landwardboundary(ih),...
            'SeawardBoundary', seawardboundary(ih),...
            'LowerBoundary', z_levels(ih));
    end
end

% find unique crests
x_crests = unique(x_crest(z_crest>=OPT.min_crest_level));
% pre-allocate the landward position of the dune, the corresponding id and
% the dune volume
[xlandward idlandward Volume] = deal(NaN(size(x_crests)));
for idune = 1:length(x_crests)
    % define crest as the x of the crest under consideration
    crest = x_crests(idune);
    
    % isolate all volumes and z-levels refering to the crest of concern
    Volumes = Vol(x_crest == crest);
    % isolate the corresponding z-levels
    hss = z_levels(x_crest == crest);
    % sort the z-levels in descending order (starting at crest, going down)
    [dummy idx] = sort(hss, 'descend');
    diff_volume_larger_than_threshold = diff(Volumes(idx))>OPT.min_volume;
    if any(diff_volume_larger_than_threshold)
        % find at which level the volume suddenly increases, most probably
        % meaning that an additional dune row is included in the volume
        
        % isolate landwardboundary and seawardboundary corresponding to the
        % crest of concern. Sort to in descending level (using idx)
        lwb_tmp = landwardboundary(x_crest == crest);
        lwb_tmp = lwb_tmp(idx);
        swb_tmp = seawardboundary(x_crest == crest);
        swb_tmp = swb_tmp(idx);
        % identify levels where additional volume is mainly at the landward
        % side of the crest of concern
        extra_volume_at_landward_side = mean([diff(lwb_tmp); diff(swb_tmp)]) < -10;
        if any(diff_volume_larger_than_threshold & extra_volume_at_landward_side)
            % this point is recognised as the landward side of the dune
            xlandward(idune) = lwb_tmp(find(diff_volume_larger_than_threshold & extra_volume_at_landward_side, 1, 'first'));
        else
            % take the most landward point which corresponds to the crest
            % of concern
            xlandward(idune) = lwb_tmp(end);
        end
    else
        % the most landward landwardboundary refering to the crest of
        % concern is recognised as the landward side of the dune
        xlandward(idune) = min(landwardboundary(x_crest == crest));
    end
    % the landward neighbouring point is taken as the landward boundary of
    % the dune row
    idlandward(idune) = find(x<=xlandward(idune), 1, 'last');
    % corresponding x-value is taken instead of the original one
    xlandward(idune) = x(idlandward(idune));
    
    % calculate the volume of the dune row
    %TODO: to be totally correct, here also a seaward boundary should be
    %included
    Volume(idune) = getVolume(x, z,...
        'LandwardBoundary', xlandward(idune),...
        'LowerBoundary', z(idlandward(idune)));
end

% initial landward boundary is set to the landward side of the profile
Landwardboundary = min(x);

% loop over all dunes from the sea side, going landward
for id = sort(idlandward, 'descend')
    if Volume(idlandward == id) > OPT.min_volume
        % the first dune which contains more the the minimum volume is
        % considered as the first dune row
        Landwardboundary = xlandward(idlandward == id);
        break
    end
end

%%
varargout = {Landwardboundary};