function removeSCOcond(sco_file,varargin)
%removeSCOcond : Removes SCO conditions from SCO-file
%
%   Syntax:
%     function removeSCOcond(sco_file,'Hs',minHs,'Tp',minTp)
% 
%   Input:
%     sco_file        String with SCO filename
%     Optional parameter value pairs:
%                     - 'Hs'           Treshold for wave height (m)
%                     - 'Tp'           Treshold for wave period (s)
%                     - 'Dir'          Main wave direction (removes all wave dirs >dir+90 or <dir-90)
%                     - 'Dur'          Treshold for condition duration (days)% 
%
%   Output:
%     .sco file
%   
%   Example:
%     removeSCOcond('test.sco','Hs',0.01,'Tp',1)
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       Bas Huisman
%
%       bas.huisman@deltares.nl	
%
%       Deltares
%       Rotterdamseweg 185
%       PO Box Postbus 177
%       2600MH Delft
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
% Created: 16 Sep 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: removeSCOcond.m 2849 2010-10-01 08:30:33Z huism_b $
% $Date: 2010-10-01 10:30:33 +0200 (Fri, 01 Oct 2010) $
% $Author: huism_b $
% $Revision: 2849 $
% $HeadURL: https://repos.deltares.nl/repos/mctools/trunk/matlab/applications/UNIBEST_CL/SCOextract/removeSCOcond.m $
% $Keywords: $

%-------------analyse input---------------
%-----------------------------------------
parameters = {'Hs','Tp','Dir','Dur'};
tresholds  = {[],[],[],[]}; % defaults
for ii=1:length(varargin)
    for iii=1:length(parameters)
        if strcmp(varargin{ii},parameters{iii})
            tresholds{iii} = varargin{ii+1};
        end
    end
end

if ~isempty(tresholds{3})
    tresholds{3} = [mod(tresholds{3}-90,360);mod(tresholds{3}+90,360)];
end

%-------------read SCO data---------------
%-----------------------------------------
[h0,Hs,Tp,xdir0,dur0,x,y,numOfDays] = readSCO(sco_file);

id1=[1:length(Hs)];id2=[1:length(Tp)];id3=[1:length(xdir0)];id4=[1:length(dur0)];

if ~isempty(tresholds{1})
    id1 = find(Hs>tresholds{1});
end

if ~isempty(tresholds{2})
    id2 = find(Tp>tresholds{2});
end

if ~isempty(tresholds{3})
    if tresholds{3}(1)<tresholds{3}(2)
        id3 = find(xdir0>tresholds{3}(1) & xdir0<tresholds{3}(2));
    else
        id3 = find(xdir0>tresholds{3}(1) | xdir0<tresholds{3}(2));
    end
end
    
if ~isempty(tresholds{4})
    id4 = find(dur0>tresholds{4});
end

idkeep = intersect(id1,id2);
idkeep = intersect(idkeep,id3);
idkeep = intersect(idkeep,id4);

if isempty(x) | isempty(y)
    x=0;
    y=0;
end
writeSCO(sco_file,h0(idkeep),Hs(idkeep),Tp(idkeep),xdir0(idkeep),dur0(idkeep),x,y,numOfDays);
