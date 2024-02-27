function varargout = getVolume_steps(varargin)
%GETVOLUME_STEPS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = getVolume_steps(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   getVolume_steps
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Kees den Heijer
%
%       Kees.denHeijer@Deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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
% Created: 27 Apr 2010
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id: getVolume_steps.m 7052 2012-07-27 12:44:44Z boer_g $
% $Date: 2012-07-27 20:44:44 +0800 (Fri, 27 Jul 2012) $
% $Author: boer_g $
% $Revision: 7052 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DUROS/analysis/Volume/getVolume_steps.m $
% $Keywords: $

%% check and inventorise input
% input can be specified directly, provided that the order of the input
% arguments corresponds with propertyName (specified below), or as
% propertyName propertyValue pairs. Also a combination is possible as long
% as it starts with direct input (in the right order), followed by
% propertyName propertyValue pairs (regardless of order).

% derive identifier of the argument just before the first propertyName or 
% alternatively the identifier of the last input argument (if no
% propertyName propertyValue pairs are used)
idPropName = [cellfun(@ischar, varargin) true];
id = find(idPropName, 1, 'first')-1;

% define propertyNames and (default) propertyValues (most are empty by default)
propertyName = {...
    'x'...
    'z'...
    'UpperBoundary'...
    'LowerBoundary'...
    'LandwardBoundary'...
    'SeawardBoundary'...
    'x2'...
    'z2'...
    'suppressMessEqualBoundaries'};
propertyValue = [...
    varargin(1:id)...
    repmat({[]}, 1, length(propertyName)-id-1) false];

% create property structure, including the directly specified input
OPTstructArgs = reshape([propertyName; propertyValue], 1, 2*length(propertyName));
OPT = struct(OPTstructArgs{:});

% update property structure with input specified as propertyName
% propertyValue pairs
OPT = setproperty(OPT, varargin{id+1:end});

inputSize = structfun(@size, OPT,...
    'UniformOutput', false);

%% input check
inputAdjusted = false;
if sum(inputSize.x) ~= sum(inputSize.z)
    error('GETVOLUME:SizeInputs', 'Input arguments "x" and "z" must be of same size');
end

if sum(inputSize.x) <= 2 || all(inputSize.x ~= 1)
    error('GETVOLUME:SizeInputs', 'Input arguments "x" and "z" must be vectors');
end

if any(isnan(OPT.z))
    % remove NaNs
    ZnonNaN = ~isnan(OPT.z);
    [OPT.x OPT.z] = deal(OPT.x(ZnonNaN), OPT.z(ZnonNaN));
    
    % check whether the remaining non-NaN part is still a vector
    if sum(size(OPT.x)) <= 2
        error('GETVOLUME:SizeInputs', 'Input arguments "x" and "z" must contain at least two non-NaN data points.');
    end
    inputAdjusted = true;
end

if sum(inputSize.x2) ~= sum(inputSize.z2)
    error('GETVOLUME:SizeInputs', 'Input arguments "x2" and "z2" must be of same size');
end

if isscalar(OPT.x2)
    % x2 and z2 must be either empty or vector
    error('GETVOLUME:SizeInputs', 'Input arguments "x2" and "z2" must be vectors');
end

if any(isnan(OPT.z2))
    % remove NaNs
    Z2nonNaN = ~isnan(OPT.z2);
    [OPT.x2 OPT.z2] = deal(OPT.x2(Z2nonNaN), OPT.z2(Z2nonNaN));
    
    % check whether the remaining non-NaN part is still a vector
    if sum(size(OPT.x2)) <= 2
        error('GETVOLUME:SizeInputs', 'Input arguments "x2" and "z2" must contain at least two non-NaN data points.');
    end
    inputAdjusted = true;
end

for var = {'x' 'z' 'x2' 'z2'}
    if sign(diff(inputSize.(var{1}))) == 1 % in case of rows
        OPT.(var{1}) = OPT.(var{1})';
        inputAdjusted = true;
    end
end

if inputAdjusted
    inputSize = structfun(@size, OPT,...
        'UniformOutput', false);
end

% create separate variables (conform old version of getVolume) out of the OPT-structure
finalInput = struct2cell(OPT);
[x z UpperBoundary LowerBoundary LandwardBoundary SeawardBoundary x2 z2] = deal(finalInput{1:8});

result = createEmptyDUROSResult;

%%
if length(unique(x)) < length(x)
    vertid = [-1; diff(diff(x) == 0); 1];
    startid = find(vertid == -1);
    endid = find(vertid == 1);
    Volume = 0;
    for iid = 1:length(startid)
        Volume = Volume + getVolume(x(startid(iid):endid(iid)), z(startid(iid):endid(iid)),...
            'LandwardBoundary', LandwardBoundary,...
            'SeawardBoundary', SeawardBoundary,...
            'UpperBoundary', UpperBoundary,...
            'LowerBoundary', LowerBoundary,...
            'x2', x2,...
            'z2', z2);
    end
end

%%
function [x, z] = removeDoublePoints(x, z)
[x sortid] = sort(x);
z = z(sortid);

threshold = 1e-10;
if length(unique(x))~=length(x)
    xz = unique([x z], 'rows');
    if size(xz,1)==length(unique(x))
        [x z] = deal(xz(:,1), xz(:,2));
    else
        ids = find(diff(x)==0);
        for idd = 1:length(ids)
            id=ids(idd);
            if id<length(x) && abs(diff(z(id:id+1)))<threshold
                z(id+1) = NaN;
            end
        end
        [x, z] = deal(x(~isnan(z)), z(~isnan(z)));
    end
    %disp('Warning: Duplicate point(s) skipped');
end