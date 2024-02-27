function [RD ErosionVolume] = getRetreatDistance(result, messages, xRef)
%GETRETREATDISTANCE  Computes retreat distance and erosion volume from DUROS result
%
%   Computes retreat distance and erosion volume from DUROS result
%   structure. The function also handles failed DUROS runs to prevent
%   probabilistic computations from failing.
%
%   Syntax:
%   [RD ErosionVolume] = getRetreatDistance(result, messages, xRef)
%
%   Input:
%   result    = DUROS result structure
%   messages  = DUROS messages cell array
%   xRef      = Reference x-location to compute retreat distance against
%
%   Output:
%   RD        = Retreat distance
%   ErosionVolume = ErosionVolume
%
%   Example
%   RD = getRetreatDistance(result, messages, 0);
%
%   See also DUROS, x2z_DUROS

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl	
%
%       Rotterdamseweg 185
%       2629HD Delft
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
% Created: 06 Jul 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: getRetreatDistance.m 10287 2014-02-25 14:31:47Z bieman $
% $Date: 2014-02-25 22:31:47 +0800 (Tue, 25 Feb 2014) $
% $Author: bieman $
% $Revision: 10287 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DUROS/analysis/getRetreatDistance.m $
% $Keywords: $

%% determine retreat distance

try
    
    InitialVolume       = 0;
    AdditionalVolume    = 0;
    RetreatPoint        = xRef;

    messagecodes = cell2mat(messages(:,1));

    % errors indicating that water level is too high
    %   solution:       assume maximum retreat distance of 1000m
    if any(ismember([-10], messagecodes))

        RetreatPoint        = xRef - 1000;
        InitialVolume       = NaN;
        AdditionalVolume    = NaN;

    % errors indicating dune breach at rear-side of dune
    %   more specific:  dune breach at rear-side, with consequently
    %                   insufficient information available for a
    %                   first estimate of the erosion profile
    %   solution:       choose the maximum of 1000m as retreat
    %                   distance
    elseif any(ismember(1, messagecodes)) || all(ismember([-7, 5], messagecodes))

        RetreatPoint        = result(1).VTVinfo.Xr - 1000;
        InitialVolume       = NaN;
        AdditionalVolume    = NaN;

    % errors indicating dune breach at dune valley
    %   solution:       choose maximum of 15m as retreat distance
    elseif all(ismember([45, 60], messagecodes)) 

        RetreatPoint        = result(1).VTVinfo.Xr-15;
        InitialVolume       = result(2).VTVinfo.AVolume;
        AdditionalVolume    = 0;

    % errors indicating that no erosion occurs
    %   solution:       find maximum crossing with water level
    elseif any(ismember([-8 6], messagecodes));

        xInitial = [result(1).xLand;result(1).xActive;result(1).xSea];
        zInitial = [result(1).zLand;result(1).zActive;result(1).zSea];
        
        xcr = findCrossings( ...
            xInitial, zInitial, ...
            xInitial, result(1).info.input.WL_t*ones(size(xInitial,1),1), 'keeporiginalgrid');

        RetreatPoint                        = deal(max(xcr));
        [InitialVolume, AdditionalVolume]   = deal(NaN);

    % errors indicating that no solution is possible
    %   solution:       throw error
    elseif ismember(-7, messagecodes);

        errindex = find(messagecodes == -7);
        disp('*****************************************************************');
        disp(' ');
        disp(messages(errindex(1),2));
        disp('*****************************************************************');
        error(' ');

    % no errors
    else
        if ~DuneErosionSettings('get','AdditionalErosion')
            % No additional erosion
            RetreatPoint        = result(1).VTVinfo.Xr;
            InitialVolume       = result(2).VTVinfo.AVolume;
            AdditionalVolume    = 0;
            
        else
            RetreatPoint        = result(3).VTVinfo.Xr;
            InitialVolume       = result(2).VTVinfo.AVolume;
            AdditionalVolume    = result(3).VTVinfo.TVolume;
        end

    end
catch
    s =lasterror;
    PrintErrorStack(s);
end

ErosionVolume   = -1*(InitialVolume+AdditionalVolume);
RD              = xRef - RetreatPoint;
