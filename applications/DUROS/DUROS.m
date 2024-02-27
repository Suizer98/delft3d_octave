function [result, messages] = DUROS(varargin)
%DUROS Calculates dune erosion according to the DUROS+ method
%
%   This is the main routine for calculations of dune erosion with the
%   DUROS+ method. Based on hydraulic input parameters a parabolic erosion
%   profile is determined. This profile is extended with a part above the
%   water line (1:1) and beneath the toe (1:12,5). The erosion profile is
%   fitted in the initial profile in such a way that the amount of
%   accretion equals the amount of erosion. Influences of coastal bends and
%   or channels near the dune are incorporated as well as dune breaches.
%   After calculation of the erosion profile the function determines: the 
%   amount of erosion above the maximum storm search level; any additional
%   erosion (due to uncertainties in the calculation method) and; fits a
%   boundary profile in the remaining erosion profile.
%
%   Syntax:
%   [result, messages] = DUROS(xInitial, zInitial, D50, WL_t, Hsig_t, Tp_t)
%
%   Input:
%   xInitial /zInitial -    doubles (n*1) with x-points and the 
%                           corresponding height of the dune initial profile.
%   D50                -    Grain size.
%   WL_t               -    Maximum storm search level
%   Hsig_t             -    Significant wave height during the storm
%   Tp_t               -    Peak wave period during the storm
%
%   Output:
%   result             -    a struc that contains the results for each
%                           calculation step. The result struct has fields:
%                               info:    information about the calculation
%                                           step
%                               Volumes: Cumulative volumes, erosion volume
%                                           and accretion volume
%                               xActive: x-coordinates of the area that was
%                                           changed during the calculation 
%                                           step
%                               zActive: z-coordinates of the points that
%                                           were changed prior to the change
%                               z2Active:z-coordinates of the changed
%                                           points
%                               xLand:   x-points landward of the coordinates
%                                           that were changed during the
%                                           calculation step
%                               zLand:   z-points landward of the coordinates
%                                           that were changed during the
%                                           calculation step
%                               xSea:    x-points seaward of the coordinates
%                                           that were changed during the
%                                           calculation step
%                               zSea:    z-points seaward of the coordinates
%                                           that were changed during the
%                                           calculation step
%                               
%   Example
%
%   See also DuneErosionSettings optimiseDUROS getDuneErosion_DUROS getDuneErosion_additional

%   --------------------------------------------------------------------
%   Copyright (C) 2011 Delft University of Technology
%       Kees den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
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

% Created: $date(dd mmm yyyy)
% Created with Matlab version: $version

% $Id: DUROS.m 4230 2011-03-10 11:00:23Z geer $
% $Date: 2011-03-10 19:00:23 +0800 (Thu, 10 Mar 2011) $
% $Author: geer $
% $Revision: 4230 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DUROS/DUROS.m $
% $Keywords: dune dunes erosion DUROS DUROS+ VTV beach &

%% Initiate variables
% In this step the input is verified. If one of the input arguments is not
% defined, a default value is used:
% 
% # xInitial    - The x-coordinates of the reference profile of the Dutch
%                   coast.
% # zInitial    - The z-coordinates of the reference profile of the Dutch
%                   coast.
% # D50         - The grain diameter. (default 225 [mu])
% # WL_t        - The water level (default 5 [m])
% # Hsig_t      - The significant wave height (default 9 [m])
% # Tp_t        - The peak wave period (default 12 [s])
%
% Next to the input parameters also some settings are obtained from
% _DuneErosionSettings_.
%

writemessage('init');

%% check and inventorise input
OPT = struct(...
    'xInitial', [-250 -24.375 5.625 55.725 230.625 1950]',...
    'zInitial', [15 15 3 0 -3 -14.4625]',...
    'D50', 225e-6,...
    'WL_t', 5,...
    'Hsig_t', 9,...
    'Tp_t', 12);

[xInitial zInitial D50 WL_t Hsig_t Tp_t] = parseDUROSinput(OPT, varargin{:});

NoDUROSResult = false;
AdditionalErosionMax = DuneErosionSettings('get', 'AdditionalErosionMax');
Bend = DuneErosionSettings('get', 'Bend');
SKIPBOUNDPROF = false;

%% Check input
% Next step is to check the quality of the input. _DUROScheckConditions_ is
% used to check a couple of things:
%
% # Does the heigth of the profile exceeds the water level.
% # Does the specified profile have the correct orientation (in other words
%       is the seaward side positive and is the array specified in the
%       correct direction).
% # Aren't there any nan's in the profile (If so, these are removed
% # The DUROS+ calculation method is valid for values of Tp_t between 12 and
%       20 seconds. TP_t is corrected for that if it is out of this range.

writemessage(100,'Start first step: Get and fit DUROS profile');
% step 1 initiated early to include correction of the Tp in the messages.
[xInitial,zInitial,D50,WL_t,Hsig_t,Tp_t] = DUROSCheckConditions(xInitial,zInitial,D50,WL_t,Hsig_t,Tp_t);
if islogical(xInitial)
    % serious warning occured. We cannot perform a calculation.
    result = createEmptyDUROSResult;
    result.info.resultinboundaries = false;
    messages = writemessage('get');
    return;
end

% debug plot initial profile
if dbstate
    dbPlotDuneErosion('new');
end

%% Step 1 / 2
if DuneErosionSettings('get', 'DUROS')
    %% STEP 1: get DUROS erosion
    % In this step the DUROS(+) profile is constructed and iterated. After
    % that the additional erosion volume is calculated (if specified in
    % _DuneErosionSettings_.
    %
    % The shape of the erosion profile is provided by the following
    % formulation:
    %
    % $$\left( {{{7,6} \over {H_{0s} }}} \right)y = 0,4714\left[ {\left( {{{7,6} \over {H_{0s} }}} \right)^{1,28} \left( {{{12} \over {T_p }}} \right)^{0,45} \left( {{w \over {0,0268}}} \right)^{0,56} x + 18} \right]^{0,5}  - 2,0$$
    % 
    [result, Volume, x00min, x0max, x0except, x0min] = getDuneErosion_DUROS(xInitial, zInitial, D50, WL_t, Hsig_t, Tp_t,false);
    
    % update initial profile with minor modification by findCrossings
    [xInitial zInitial] = deal(...
        [result(1).xLand; result(1).xActive; result(1).xSea],...
        [result(1).zLand; result(1).zActive; result(1).zSea]);
    
    xz=deal(sortrows([xInitial zInitial]));
    Q=diff(xz(:,1))~=0;Q=[true;Q];              % = get unique/distinct x-values
    xInitial=xz(Q,1);zInitial=xz(Q,2);   
    
    if isempty(Volume)
        NoDUROSResult = true;
    end
    %% STEP 2: get profile shift due to coastal Bend
    % In case of the presence of a bend in the coastline the assessment
    % rules prescribe an extra erosion volume that has to be dealt with.
    % This step specifies this volume and calculates the extra retreat and
    % resulting erosion profile.
    
    if result(1).info.resultinboundaries && ~NoDUROSResult
        TargetVolume = eval(DuneErosionSettings('AdditionalVolume'));  % Attention, TargetVolume represents an additional amount of erosion, which is a negative number (!)
        AdditionalErosionforCoastalBend = Bend > 6;
        if AdditionalErosionforCoastalBend
            FallvelocityArgs = [DuneErosionSettings('get', 'FallVelocity') {D50}];
            w = feval(FallvelocityArgs{:});
            G = getG(TargetVolume + Volume, Hsig_t, w, Bend);
            if ~isempty(G)
                g = G/diff(result(1).zActive([end 1])); % G = g * z ==> g = G/z; see Basisrapport Zandige Kust pp 469
                x0bend = result(1).info.x0 + g;
                writemessage(51, ['Additional retreat of ' num2str(-g, '%.2f') ' m as a contribution for a coastal bend']);
                x0bendwithinboundaries = x0bend > x0min && x0bend < x0max;
                if ~x0bendwithinboundaries
                    x0bend = x0min;
                    writemessage(53, ['Additional retreat as a contribution for a coastal bend limited to ' num2str(-(x0bend-result(1).info.x0), '%.2f') ' m']);
                end
                xInitialpreBend = [result(1).xLand; result(1).xActive; result(1).xSea];
                zInitialpreBend = [result(1).zLand; result(1).zActive; result(1).zSea];
                result(end+1) = getDUROSprofile(xInitialpreBend, zInitialpreBend, x0bend, Hsig_t, Tp_t, WL_t, w);
                x1vol = result(end).xActive;
                z1vol = result(end).z2Active;
                x2vol = cat(1,result(1).xLand,result(1).xActive,result(1).xSea);
                z2vol = cat(1,result(1).zLand,result(1).z2Active,result(1).zSea);
                
                % add VTVinfo to result structure
                result(end).VTVinfo.Xp = x0bend;
                result(end).VTVinfo.Zp = WL_t;
                result(end).VTVinfo.Xr = result(end).xActive(1);
                result(end).VTVinfo.Zr = result(end).zActive(1);
                result(end).VTVinfo.G = G;
                result(end).Volumes.Volume = result(2).VTVinfo.AVolume + getVolume('x',x2vol,'z',z2vol,'x2',x1vol,'z2',z1vol,'LowerBoundary',WL_t);
                result(end).info.ID = 'Coastal Bend';
                if ~x0bendwithinboundaries
                    %TODO: recalculate G (because it is limited by x0min)
                end
                idAddProf = 3;
                idAddVol = 3;
                
                % the shifted DUROS profile has been constructed with respect
                % to the initial profile. To create the correct patch, the
                % active profile has to adapted, to the original DUROS result.
                
                % part of the seaward tail has to become part of the active
                % profile
                idSea = result(end).xSea <= result(1).xActive(end);
                result(end).xActive = [result(end).xActive; result(end).xSea(idSea)];
                result(end).xSea = result(end).xSea(~idSea);
                result(end).z2Active = [result(end).z2Active; result(end).zSea(idSea)];
                result(end).zSea = result(end).zSea(~idSea);
                % zActive can now be interpolated based on the original DUROS
                % result
                result(end).zActive = interp1([result(1).xLand; result(1).xActive; result(1).xSea],...
                    [result(1).zLand; result(1).z2Active; result(1).zSea],...
                    result(end).xActive);
            else
                writemessage(55, 'Coastal bend outside scope of regulations (Bend > 24)');
                idAddProf = 1;
                idAddVol = 2;
            end
        else
            idAddProf = 1;
            idAddVol = 2;
        end
    end
end

%% STEP 3: get additional erosion
% Now it's time to calculate the additional erosion based on the erosion
% above the maximum storm surge level as calculated in step 1.

if DuneErosionSettings('get', 'AdditionalErosion') && ~NoDUROSResult
    if result(1).info.resultinboundaries
        writemessage(300,'Start third step: get Additional erosion');
        if AdditionalErosionMax
            maxRetreat = DuneErosionSettings('maxRetreat'); % No more than 15 m additional retreat
        else
            maxRetreat = []; % No limitation
        end
        zDUROS = [result(idAddProf).zLand; result(idAddProf).z2Active; result(idAddProf).zSea];
        idnr = length(result)+1;
        if max(zDUROS) < WL_t
            % no additional erosion because DUROS solution does not have
            % any point above the water level.
            result(idnr) = noAdditionaleErosionResult(xInitial,zInitial,result,maxRetreat,TargetVolume);
            SKIPBOUNDPROF = true;
        else
            msg = writemessage('get');
            if any([msg{:,1}]==-5)
                % AVolume is corrected...
                Xp = result(idAddProf).VTVinfo.Xp;
                x2 = [Xp - (max(zInitial) - WL_t), Xp, max(xInitial)];
                z2 = [max(zInitial), WL_t, WL_t];
                [dum rtemp] = getVolume(xInitial,zInitial,...
                    'LowerBoundary', WL_t,...
                    'LandwardBoundary', min(x2),...
                    'x2', x2,...
                    'z2', z2);
                AVolume = -rtemp.Volumes.Erosion;
            else
                AVolume = result(idAddVol).Volumes.Volume;
            end
            result(idnr) = getDuneErosion_additional(xInitial,zInitial,...
                result(idAddProf),...
                WL_t,...
                TargetVolume,...
                AVolume,...  % AVolume
                maxRetreat,...
                x0except);
        end
    else
        result(end+1) = createEmptyDUROSResult;
        writemessage(41,'No additional erosion possible');
        SKIPBOUNDPROF = true;
    end
end

%% STEP 4: fit Boundary profile
% The last step is to fit a boundary profile in the remaining dunes. this
% step accounts for that. 
if DuneErosionSettings('get', 'BoundaryProfile') && ~NoDUROSResult
    if ~SKIPBOUNDPROF && result(end).info.resultinboundaries
        writemessage(400,'Start fourth step: fit boundary profile');
        x2 = [result(end).xLand; result(end).xActive; result(end).xSea];
        z2 = [result(end).zLand; result(end).z2Active; result(end).zSea];
        [x2 idUnique] = unique(x2);
        z2 = z2(idUnique);
        result(end+1) = fitBoundaryProfile(xInitial, zInitial, x2, z2, WL_t, Tp_t, Hsig_t, x00min, result(end).info.x0, x0except);
    else
        result(end+1) = createEmptyDUROSResult;
        result(end).info.ID = 'BoundaryProfile';
        writemessage(-1,'Boundary profile cannot be fit into the profile');
    end
end

%% STEP 5: process messages
% Finally the messages issued during the calculation are processed and
% stored in the result. It will be a seperate output as well.
messages=writemessage('get');
for i=1:length(result)
    ids=find([messages{:,1}]==i*100,1,'last');
    ids_next=find([messages{:,1}]==100*(i+1),1,'first');
    if isempty(ids_next)
        ids_next=size(messages,1)+1;
    end
    result(i).info.messages=messages(ids+1:ids_next-1,:);
end
if DuneErosionSettings('get','Verbose')
    msgcodes = DuneErosionSettings('get','verbosemessages');
    cds = cell2mat(messages(:,1));
    if any(ismember(msgcodes,cds))
        for imess = 1:size(messages,1)
            if any(msgcodes==cds(imess))
                disp(messages{imess,2});
            end
        end
    end
end

%% add input to result structure
% Don't forget to specify the input in the result as well. someone could
% try to recreate the results and may needs it...
if ~exist('Bend','var')
    Bend = 0;
end
result(1).info.input = struct(...
    'D50', D50,...
    'WL_t', WL_t,...
    'Hsig_t', Hsig_t,...
    'Tp_t', Tp_t,...
    'Bend',Bend);