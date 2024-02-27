function [times wl] = generateWaterLevelsFromAstro(flow, opt)
%GENERATEWATERLEVELSFROMASTRO  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   [times wl] = generateWaterLevelsFromAstro(flow, opt)
%
%   Input:
%   flow  =
%   opt   =
%
%   Output:
%   times =
%   wl    =
%
%   Example
%   generateWaterLevelsFromAstro
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
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

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: generateWaterLevelsFromAstro.m 17170 2021-04-08 14:54:54Z ormondt $
% $Date: 2021-04-08 22:54:54 +0800 (Thu, 08 Apr 2021) $
% $Author: ormondt $
% $Revision: 17170 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/delft3dflow/nesting/generateWaterLevelsFromAstro.m $
% $Keywords: $

%%
t0=flow.startTime;
t1=flow.stopTime;
dt=opt.bctTimeStep;
times=t0:dt/1440:t1;

runid = '';
if isfield(opt,'runid')
    runid=opt.runid;
end
if isempty(runid)
    runid='.';
end

openBoundaries=delft3dflow_readBndFile([runid filesep opt.waterLevel.BC.bndAstroFile]);
astronomicComponentSets=delft3dflow_readBcaFile([runid filesep opt.waterLevel.BC.astroFile]);

if ~isempty(opt.waterLevel.BC.corFile)
    corrections=delft3dflow_readBcaFile(opt.waterLevel.BC.corFile);
    for j=1:length(corrections(1).component)
        ii=strmatch(astronomicComponentSets(1).component{j},astronomicComponentSets(1).component,'exact');
        for i=1:length(astronomicComponentSets)
            astronomicComponentSets(i).amplitude(ii)=astronomicComponentSets(i).amplitude(ii)*corrections(i).amplitude(j);
            astronomicComponentSets(i).phase(ii)=astronomicComponentSets(i).phase(ii)+corrections(i).phase(j);
        end
    end
end

for k=1:length(astronomicComponentSets)
    compSet{k}=astronomicComponentSets(k).name;
end

nr=length(openBoundaries);

for i=1:nr
    
    ia=strmatch(openBoundaries(i).compA,compSet,'exact');
    setA=astronomicComponentSets(ia);
    comp=[];
    A=[];
    G=[];
    for j=1:setA.nr
        comp{j}=setA.component{j};
        A(j,1)=setA.amplitude(j);
        G(j,1)=setA.phase(j);
    end
    prediction=makeTidePrediction(times,comp,A,G,opt.latitude);
    wl(i,1,:)=prediction;
    
    ib=strmatch(openBoundaries(i).compB,compSet,'exact');
    setB=astronomicComponentSets(ib);
    comp=[];
    A=[];
    G=[];
    for j=1:setB.nr
        comp{j}=setB.component{j};
        A(j,1)=setB.amplitude(j);
        G(j,1)=setB.phase(j);
    end
    prediction=makeTidePrediction(times,comp,A,G,opt.latitude);
    wl(i,2,:)=prediction;
    
end

