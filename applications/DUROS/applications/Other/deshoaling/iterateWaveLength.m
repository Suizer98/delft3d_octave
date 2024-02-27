function [L iterinfo] = iterateWaveLength(h,Tp,g)
%ITERATWAVELENGTH  Determines a wave length iteratively
%
%   According to linear wave theory a wave length can be calculated with:
%
%               L = L0 * tanh (2*pi()*h / L)
%
%   in which:
%
%               L0 = (g * Tp^2) / (2 * pi())
%
%   With h, Tp and g as input the wave length under these conditions can 
%   than be determine iteratively. This routine starts with L0 as a first
%   guess for L and calculates the wave length. The difference between a
%   guess and the calculated wave length is compared to a precision
%   criterium. If the precision is not met, a next gues is made by taking
%   the mean between the former gues and its outcome. A maximum number of
%   iterations of 50 is implemented
%
%   Syntax:
%   [L iterinfo] = iterateWaveLength(h,Tp,g)
%
%   Input:
%   h   =   depth [m] at the location the wave length has to be calculated.
%   Tp  =   Peak period [s] corresponding to the wave length at that depth.
%   g   =   gravity acceleration coefficient.
%
%   Output:
%   L   =   the calculated wave length [m] belonging to the input parameters.
%   iterinfo = a structure containing information about the iteration
%           process (such as all estimations of L the number of iteration
%           needed and the total iteration time.
%
%   Example
%   iteratWaveLEngth
%
%   See also deshoal

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltares.nl	
%
%       <ADDRESS>
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

% Created: 09 Feb 2009
% Created with Matlab version: 7.6.0.324 (R2008a)

% $Id: iterateWaveLength.m 1660 2009-02-11 16:07:51Z geer $
% $Date: 2009-02-12 00:07:51 +0800 (Thu, 12 Feb 2009) $
% $Author: geer $
% $Revision: 1660 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DUROS/applications/Other/deshoaling/iterateWaveLength.m $
% $Keywords:

%% Initiate settings
maxiter = 50;
targetprec = 1e-2;
iter = 1;

%% create info struct
iterinfo = struct(...
    'maxiter',maxiter,...
    'numberOfIterations',nan,...
    'targetPrecision',targetprec,...
    'precision',nan(maxiter,1),...
    'iterationtime',nan,...
    'L',nan(maxiter,1),...
    'nextL',nan(maxiter,1),...
    'MaxIterReached',false,...
    'PrecisionMet',false);

%% calculate constant parameters
L0 = (g*Tp.^2) / (2*pi());
iterinfo.nextL(1) = L0;

%% initiate condition variable
iterinfo.PrecisionMet = false;

%% start iteration
tic
while ~iterinfo.PrecisionMet
    %% calculate the wave length based on a guess
    iterinfo.L(iter) = L0 * tanh((2*pi().*h) / iterinfo.nextL(iter));
    
    %% calculate the precision
    iterinfo.precision(iter) = iterinfo.L(iter) - iterinfo.nextL(iter);
    
    %% chech whether the precision is met and the maximum number of iteratios is reached
    iterinfo.PrecisionMet = abs(iterinfo.precision(iter))<targetprec;
    iterinfo.MaxIterReached = iter == maxiter;
    if ~iterinfo.PrecisionMet && ~iterinfo.MaxIterReached
        %% if not, make a new guess
        iterinfo.nextL(iter+1) = (iterinfo.L(iter) + iterinfo.nextL(iter))./2;
        iter = iter+1;
    end
end

%% process the iteration results
iterinfo.iterationtime = toc;
iterinfo.numberOfIterations = iter;
L = iterinfo.L(iter);

if ~iterinfo.PrecisionMet
    %% give a warning each time the precision is not met...
    warning('IterateL:PrecisionNotMet','Be carefull with the result, the precision is not met');
end
if ~iterinfo.MaxIterReached
    %% clear memory that is not going to be used
    iterinfo.L(iter+1:end) = [];
    iterinfo.nextL(iter+1:end) = [];
    iterinfo.precision(iter+1:end) = [];
end